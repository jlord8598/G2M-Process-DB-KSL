CREATE OR REPLACE PROCEDURE DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_ACCOUNT_CLASSIFICATION(P_RUN_ID VARCHAR, P_LANE VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XREF_ACCOUNT_CLASSIFICATION
-- The build's one seeder (D-39). Seeds XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION
-- for one lane (P_LANE) from that lane's four fact staging tables. Pacing and
-- the bookings dictionary never feed it (D-37).
--
-- Steps (CLAUDE.md section 5):
--   1 extract  one row per five-part key, every key part through
--              coalesce(nullif(trim(x),''),'~BLANK~'); attributes by MIN()
--   2 propose  RECORD_TYPE STATISTIC -> H1 Statistic before any digit is read;
--              otherwise the section digit (leading digit of segment 2 of a
--              well-formed DDD-DDDD-DDD account, docs/sources.md) seeds H1/H2
--              per the section 5 digit table. Anything else is Unclassified.
--              H3/H4/H5 UNCLASSIFIED (the chart states no Level 2).
--              P_L_SECTION, NORMAL_BALANCE from H2; VALUE_SIGN from
--              NORMAL_BALANCE.
--   3 merge    insert-only; an existing key gets LAST_SEEN_RUN_ID only (D-14)
-- One derivation branch per lane (DAVIDSON added in build 06). No exception
-- is caught; an undeclared lane
-- raises.
-- ============================================================================
declare
    v_before integer;
    v_after  integer;
    e_lane   exception (-20001, 'SPROC_XREF_ACCOUNT_CLASSIFICATION: undeclared lane');
begin
    -- ------------------------------------------------------------------------
    -- the table: issued every run, so the first MERGE of a build has a target
    -- ------------------------------------------------------------------------
    create table if not exists DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION (
          SOURCE_LANE        varchar
        , SOURCE_SITE_CODE   varchar
        , DEPARTMENT         varchar
        , ACCOUNT_KEY        varchar
        , RECORD_TYPE        varchar
        , ASSET_NAME         varchar
        , DEPARTMENT_NAME    varchar
        , ACCOUNT_NUMBER     varchar
        , STAT_ACCOUNT       varchar
        , ACCOUNT_DESC       varchar
        , H1                 varchar
        , H2                 varchar
        , H3                 varchar
        , H4                 varchar
        , H5                 varchar
        , P_L_SECTION        varchar
        , NORMAL_BALANCE     varchar
        , VALUE_SIGN         number(2,0)
        , METRIC_UNIT        varchar
        , AGGREGATION_TYPE   varchar
        , REVIEW_STATUS      varchar
        , SEED_SOURCE        varchar
        , FIRST_SEEN_RUN_ID  varchar
        , LAST_SEEN_RUN_ID   varchar
    );

    v_before := (select count(*) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = :P_LANE);

    if (:P_LANE = 'KSL_SELECT_SERVICE') then
        -- ====================================================================
        -- LANE KSL_SELECT_SERVICE
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows, key parts sentinel-coalesced
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , nullif(trim(ext.account_number), '')                                        as c_acct
                    , nullif(trim(ext.stat_account), '')                                          as c_stat
                    , regexp_like(nullif(trim(ext.account_number), ''), '[0-9]{3}-[0-9]{4}-[0-9]{3}') as acct_ok
                    , regexp_like(nullif(trim(ext.stat_account), ''), '[0-9]{3}-[0-9]{4}-[0-9]{3}')   as stat_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 5, 1))           as digit
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_acct is null                   then 'Unclassified'
                          when not acct_ok                      then 'Unclassified'
                          when digit in (1, 2, 3)               then 'Balance Sheet'
                          when digit = 4                        then 'Revenue'
                          when digit in (5, 6, 7)               then 'Expense'
                          when digit = 8                        then 'Below the Line'
                          when digit = 9                        then 'Allocations & Reserves'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC' and stat_ok then 'STAT_' || substr(c_stat, 5, 2)
                          when k_rtype = 'STATISTIC'             then 'UNCLASSIFIED'
                          when c_acct is null or not acct_ok     then 'UNCLASSIFIED'
                          when digit = 1                         then 'Assets'
                          when digit = 2                         then 'Liabilities'
                          when digit = 3                         then 'Equity'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC' and stat_ok then 'RECORD_TYPE STATISTIC; H2 = STAT_ + chars 5-6 of STAT_ACCOUNT'
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; STAT_ACCOUNT malformed, no family (Q-12)'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired (Q-12)'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 5 of ACCOUNT_NUMBER)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    elseif (:P_LANE = 'PEREGRINE_RESORTS') then
        -- ====================================================================
        -- LANE PEREGRINE_RESORTS
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows, key parts sentinel-coalesced
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , nullif(trim(ext.account_number), '')                                        as c_acct
                    , nullif(trim(ext.stat_account), '')                                          as c_stat
                    , regexp_like(nullif(trim(ext.account_number), ''), '[0-9]{3}-[0-9]{4}-[0-9]{3}') as acct_ok
                    , regexp_like(nullif(trim(ext.stat_account), ''), '[0-9]{3}-[0-9]{4}-[0-9]{3}')   as stat_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 5, 1))           as digit
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_acct is null                   then 'Unclassified'
                          when not acct_ok                      then 'Unclassified'
                          when digit in (1, 2, 3)               then 'Balance Sheet'
                          when digit = 4                        then 'Revenue'
                          when digit in (5, 6, 7)               then 'Expense'
                          when digit = 8                        then 'Below the Line'
                          when digit = 9                        then 'Allocations & Reserves'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC' and stat_ok then 'STAT_' || substr(c_stat, 5, 2)
                          when k_rtype = 'STATISTIC'             then 'UNCLASSIFIED'
                          when c_acct is null or not acct_ok     then 'UNCLASSIFIED'
                          when digit = 1                         then 'Assets'
                          when digit = 2                         then 'Liabilities'
                          when digit = 3                         then 'Equity'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC' and stat_ok then 'RECORD_TYPE STATISTIC; H2 = STAT_ + chars 5-6 of STAT_ACCOUNT'
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; STAT_ACCOUNT malformed, no family (Q-12)'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired (Q-12)'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 5 of ACCOUNT_NUMBER)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    elseif (:P_LANE = 'HHG') then
        -- ====================================================================
        -- LANE HHG (build 02)
        -- Facts: TR12_DATA, FORECAST_ANAPLAN, ROUNDS_DETAIL.
        -- STATISTIC: H1 Statistic first. H2 'ROUNDS_COUNT' (ROUNDS_DETAIL,
        --   the source's column name) or 'STAT_9' (TR12 dept 999, the source's
        --   own section code; no family stated) (D-38, owner Q-01, Q-07).
        -- TR12 money: section digit = first digit of segment 3 of a
        --   well-formed 9999-999-99999 ACCOUNT_CODE (char 10).
        -- Anaplan: the LINE_ITEM name as the stated section, the map approved
        --   by the owner at stop 3 (Q-04). An unmapped item is Unclassified.
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                    , min(source_table)                                       as src_tbl
                    , min(stat_unit_family)                                   as unit_family
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- Anaplan line item map (owner Q-04, stop 3)
            -- ----------------------------------------------------------------
            , amap as (
                select column1 as line_item, column2 as h1, column3 as h2
                from values
                      ('Ala Carte Revenue', 'Revenue', 'Revenue')
                    , ('Banquet F&B Revenue', 'Revenue', 'Revenue')
                    , ('Lodging/Pool Revenue', 'Revenue', 'Revenue')
                    , ('Other Golf Revenue', 'Revenue', 'Revenue')
                    , ('Tennis/Fitness/Spa Revenue', 'Revenue', 'Revenue')
                    , ('Merchandise Sales', 'Revenue', 'Revenue')
                    , ('Cart Fees', 'Revenue', 'Revenue')
                    , ('Green Fees', 'Revenue', 'Revenue')
                    , ('Initiation Fees', 'Revenue', 'Revenue')
                    , ('Membership Dues', 'Revenue', 'Revenue')
                    , ('Timeshare Dues', 'Revenue', 'Revenue')
                    , ('Other F&B Income', 'Revenue', 'Revenue')
                    , ('Food & Beverage Cost of Sales', 'Expense', 'Cost of Goods Sold')
                    , ('Merchandise Cost of Sales', 'Expense', 'Cost of Goods Sold')
                    , ('Administrative Labor', 'Expense', 'Payroll')
                    , ('Course Maintenance Labor', 'Expense', 'Payroll')
                    , ('Food & Beverage Labor', 'Expense', 'Payroll')
                    , ('Golf Operations Labor', 'Expense', 'Payroll')
                    , ('Lodging/Pool Labor', 'Expense', 'Payroll')
                    , ('Membership & Marketing Labor', 'Expense', 'Payroll')
                    , ('Tennis/Fitness/Spa Labor', 'Expense', 'Payroll')
                    , ('Administrative Expense', 'Expense', 'Operating Expenses')
                    , ('Course Maintenance Expense', 'Expense', 'Operating Expenses')
                    , ('Fixed G&A Expense', 'Expense', 'Operating Expenses')
                    , ('Food & Beverage Expense', 'Expense', 'Operating Expenses')
                    , ('Golf Operations Expense', 'Expense', 'Operating Expenses')
                    , ('Lodging/Pool Expense', 'Expense', 'Operating Expenses')
                    , ('Membership & Marketing Expense', 'Expense', 'Operating Expenses')
                    , ('Tennis/Fitness/Spa Expense', 'Expense', 'Operating Expenses')
                    , ('Other Income', 'Below the Line', 'Other Income / (Expense)')
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , nullif(trim(ext.account_number), '')                                          as c_acct
                    , regexp_like(nullif(trim(ext.account_number), ''), '[0-9]{4}-[0-9]{3}-[0-9]{5}') as acct_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 10, 1))           as digit
                    , amap.h1                                                                       as a_h1
                    , amap.h2                                                                       as a_h2
                from ext
                left join amap
                    on  ext.src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                    and amap.line_item = ext.k_acct
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                              then coalesce(a_h1, 'Unclassified')
                          when c_acct is null                   then 'Unclassified'
                          when not acct_ok                      then 'Unclassified'
                          when digit = 4                        then 'Revenue'
                          when digit in (5, 6, 7)               then 'Expense'
                          when digit = 8                        then 'Below the Line'
                          when digit = 9                        then 'Allocations & Reserves'
                          when digit in (1, 2, 3)               then 'Balance Sheet'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'
                               and src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL' then 'ROUNDS_COUNT'
                          when k_rtype = 'STATISTIC'             then 'STAT_9'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                              then coalesce(a_h2, 'UNCLASSIFIED')
                          when c_acct is null or not acct_ok     then 'UNCLASSIFIED'
                          when digit = 1                         then 'Assets'
                          when digit = 2                         then 'Liabilities'
                          when digit = 3                         then 'Equity'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'
                               and src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL'
                              then 'RECORD_TYPE STATISTIC; H2 = ROUNDS_COUNT, the source column name (Q-07)'
                          when k_rtype = 'STATISTIC'
                              then 'RECORD_TYPE STATISTIC (dept 999, owner Q-01); H2 = STAT_9, section code, no family stated'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN' and a_h1 is not null
                              then 'LINE_ITEM name as stated section (owner Q-04, stop 3)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                              then 'LINE_ITEM not in the approved map: nothing to derive'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 10 of ACCOUNT_CODE)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    elseif (:P_LANE = 'NEWBURY') then
        -- ====================================================================
        -- LANE NEWBURY (build 02)
        -- Facts: TRIAL_BALANCE, OPERATING_STATS_BGT, OPERATING_STATS_PYACT.
        -- STATISTIC (VALUE_TYPE STAT): H1 Statistic first; H2 = the
        --   SUBACCOUNT label as stated, carried as STAT_UNIT_FAMILY (D-38).
        -- Money: section digit = first digit of the 6-digit account, segment
        --   2 of a well-formed 9999-999999-9999-999999-9999 key (char 6).
        --   Digit rule only; D&A and income tax are not singled out (Q-14).
        -- BGT / PYACT carry no account: Unclassified (Q-19).
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                    , min(source_table)                                       as src_tbl
                    , min(stat_unit_family)                                   as unit_family
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , nullif(trim(ext.account_number), '')                                                              as c_acct
                    , regexp_like(nullif(trim(ext.account_number), ''), '[0-9]{4}-[0-9]{6}-[0-9]{4}-[0-9]{6}-[0-9]{4}') as acct_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 6, 1))                                as digit
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_acct is null                   then 'Unclassified'
                          when not acct_ok                      then 'Unclassified'
                          when digit = 4                        then 'Revenue'
                          when digit in (5, 6, 7)               then 'Expense'
                          when digit = 8                        then 'Below the Line'
                          when digit = 9                        then 'Allocations & Reserves'
                          when digit in (1, 2, 3)               then 'Balance Sheet'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'             then coalesce(nullif(trim(unit_family), ''), 'UNCLASSIFIED')
                          when c_acct is null or not acct_ok     then 'UNCLASSIFIED'
                          when digit = 1                         then 'Assets'
                          when digit = 2                         then 'Liabilities'
                          when digit = 3                         then 'Equity'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC' and nullif(trim(unit_family), '') is not null
                              then 'RECORD_TYPE STATISTIC (VALUE_TYPE STAT); H2 = SUBACCOUNT label as stated'
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; no SUBACCOUNT label'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive (Q-19)'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 6 of FULL_ACCOUNT_KEY)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    elseif (:P_LANE = 'HERSHA') then
        -- ====================================================================
        -- LANE HERSHA (build 03)
        -- Facts: GL_ACTUAL, GL_STAT.
        -- STATISTIC (GL_CODE Stat; GL_STAT, owner Q-02): H1 Statistic first; H2 = the
        --   account code (999999, ST10x0), the source's own code (D-38).
        -- Money: section digit = first digit of a 6-digit ACCOUNT_CODE, the section 5
        --   table throughout (owner Q-03: HERSHA_ACCOUNTS states no section, so no map;
        --   610000, 630000, 700000, 714000 listed for correction in the master).
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table
                from DEV_G2M_AI.STAGING.STG_HERSHA_GL_ACTUAL
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table
                from DEV_G2M_AI.STAGING.STG_HERSHA_GL_STAT
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , nullif(trim(ext.account_number), '')                       as c_acct
                    , regexp_like(nullif(trim(ext.account_number), ''), '[0-9]{6}') as acct_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 1, 1)) as digit
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_acct is null                   then 'Unclassified'
                          when not acct_ok                      then 'Unclassified'
                          when digit = 4                        then 'Revenue'
                          when digit in (5, 6, 7)               then 'Expense'
                          when digit = 8                        then 'Below the Line'
                          when digit = 9                        then 'Allocations & Reserves'
                          when digit in (1, 2, 3)               then 'Balance Sheet'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'             then k_acct
                          when c_acct is null or not acct_ok     then 'UNCLASSIFIED'
                          when digit = 1                         then 'Assets'
                          when digit = 2                         then 'Liabilities'
                          when digit = 3                         then 'Equity'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; H2 = account code as stated'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER not 6 digits: not repaired'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 1 of ACCOUNT_CODE; owner Q-03)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    elseif (:P_LANE = 'INVITED_CLUBS') then
        -- ====================================================================
        -- LANE INVITED_CLUBS (build 03)
        -- Fact: ESSBASE_EXTRACT. Section stated by META_ACCOUNT.ACCOUNT_TYPE, carried in
        --   staging as META_ACCOUNT_TYPE (owner Q-05). STATISTIC (DATA_TYPE
        --   non-currency): H1 Statistic first; H2 = the account member name (D-38).
        --   asset / liability / equity -> Balance Sheet; revenue -> Revenue; expense
        --   -> the A-code digit (A + 5 digits, char 2: 5 COGS, 7 Operating Expenses,
        --   8 Below the Line; 6 is not Payroll: H1 Expense, H2 UNCLASSIFIED, owner
        --   Q-13); expense without a digit, saved assumption
        --   (currency) and accounts not in META -> Unclassified.
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, meta_account_type
                from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                    , min(meta_account_type)                                  as m_type
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , lower(trim(ext.m_type))                                                as c_type
                    , regexp_like(nullif(trim(ext.account_number), ''), 'A[0-9]{5}')         as acct_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 2, 1))      as digit
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_type = 'asset'                 then 'Balance Sheet'
                          when c_type = 'liability'             then 'Balance Sheet'
                          when c_type = 'equity'                then 'Balance Sheet'
                          when c_type = 'revenue'               then 'Revenue'
                          when c_type = 'expense' and acct_ok and digit in (5, 6, 7) then 'Expense'
                          when c_type = 'expense' and acct_ok and digit = 8          then 'Below the Line'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'             then k_acct
                          when c_type = 'asset'                  then 'Assets'
                          when c_type = 'liability'              then 'Liabilities'
                          when c_type = 'equity'                 then 'Equity'
                          when c_type = 'revenue'                then 'Revenue'
                          when c_type = 'expense' and acct_ok and digit = 5 then 'Cost of Goods Sold'
                          when c_type = 'expense' and acct_ok and digit = 6 then 'UNCLASSIFIED'
                          when c_type = 'expense' and acct_ok and digit = 7 then 'Operating Expenses'
                          when c_type = 'expense' and acct_ok and digit = 8 then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC (META DATA_TYPE non-currency); H2 = account member name'
                          when c_type is null                    then 'account not in META_ACCOUNT: nothing to derive (owner Q-05)'
                          when c_type in ('asset', 'liability', 'equity', 'revenue')
                              then 'META_ACCOUNT.ACCOUNT_TYPE ' || c_type || ' (stated; owner Q-05)'
                          when c_type = 'expense' and acct_ok and digit = 6
                              then 'META ACCOUNT_TYPE expense; A6 range is not Payroll: H2 UNCLASSIFIED (owner Q-13)'
                          when c_type = 'expense' and acct_ok and digit between 5 and 8
                              then 'META ACCOUNT_TYPE expense; section digit ' || digit || ' (char 2 of A-code; owner Q-05)'
                          when c_type = 'expense'                then 'META ACCOUNT_TYPE expense, no usable A-code digit: Unclassified (owner Q-05)'
                          else 'META ACCOUNT_TYPE ' || c_type || ': no standard section (owner Q-05)'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    elseif (:P_LANE = 'BEAUMIER') then
        -- ====================================================================
        -- LANE BEAUMIER (build 03)
        -- Facts: BP, BUDGET. No account: ACCOUNT_KEY = LINE_ITEM. Section stated in
        --   words (owner Q-06): PL_SECTION Total Operating Revenue -> Revenue; COGS ->
        --   Cost of Goods Sold; * Payroll Expenses -> Payroll; Other Expenses -> Below
        --   the Line where any row of the key has PL_LINE Non-Operating Income &
        --   Expenses or EBITDA_GROUP NOI, else Operating Expenses.
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, pl_section, pl_line, ebitda_group
                from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, pl_section, pl_line, ebitda_group
                from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                    , min(pl_section)                                         as m_section
                    , count(distinct pl_section)                              as n_section
                    , max(iff(pl_line = 'Non-Operating Income & Expenses' or ebitda_group = 'NOI', 1, 0)) as m_btl
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , iff(ext.n_section = 1, ext.m_section, null)               as c_section
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_section = 'Total Operating Revenue' then 'Revenue'
                          when c_section = 'COGS'               then 'Expense'
                          when c_section = '* Payroll Expenses' then 'Expense'
                          when c_section = 'Other Expenses' and m_btl = 1 then 'Below the Line'
                          when c_section = 'Other Expenses'     then 'Expense'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'             then k_acct
                          when c_section = 'Total Operating Revenue' then 'Revenue'
                          when c_section = 'COGS'                then 'Cost of Goods Sold'
                          when c_section = '* Payroll Expenses'  then 'Payroll'
                          when c_section = 'Other Expenses' and m_btl = 1 then 'Other Income / (Expense)'
                          when c_section = 'Other Expenses'      then 'Operating Expenses'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC'
                          when c_section is null                 then 'PL_SECTION absent or not single-valued: nothing to derive'
                          when c_section = 'Other Expenses' and m_btl = 1
                              then 'PL_SECTION Other Expenses with Non-Operating PL_LINE or NOI group: Below the Line (owner Q-06)'
                          else 'PL_SECTION ' || c_section || ' (stated; owner Q-06)'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    elseif (:P_LANE = 'DAVIDSON') then
        -- ====================================================================
        -- LANE DAVIDSON (build 06)
        -- Facts: HOTEL_MONTHLY_REPORT (MR), FULL_YEAR_PL (PL).
        -- STATISTIC: H1 Statistic first. H2 is the source's own code: the MR
        --   natural account (9000-9990, owner Q-07), else the MR LINE_CLASS
        --   (ADR, Rooms) or the PL line text (D-38). 9990 is a stat-ledger
        --   offset and adds to no total (SEED_SOURCE says so).
        -- MR money: by natural account (segment 2 of a 6-segment ACCOUNT, staged
        --   as NATURAL_ACCOUNT), owner Q-09 (from data; source owner to
        --   confirm): 4xxx Revenue; 5000-5006 Payroll; 5100, 5110 Cost of Goods
        --   Sold; 5200-5204, 5900 Operating Expenses; 5990 Allocations &
        --   Reserves; 6xxx Payroll, 7xxx Operating Expenses, 8xxx Other Income
        --   / (Expense) (the section digit). Any other natural, and the
        --   one-segment x... strings, Unclassified.
        -- PL: no code. Worded sections only (owner Q-09): Operating Revenues and
        --   MISCELLANEOUS INCOME Revenue; Departmental Expenses and
        --   Undistributed Operating Expenses Operating Expenses; the two
        --   Non-Operating sections Other Income / (Expense). Department
        --   sections Unclassified.
        -- H2 values are from the standard hierarchy only; none is invented.
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, natural_account
                from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, null::varchar as natural_account
                from DEV_G2M_AI.STAGING.STG_DAVIDSON_FULL_YEAR_PL
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                    , min(source_table)                                       as src_tbl
                    , min(natural_account)                                    as nat
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            , prop as (
                select
                      ext.*
                    , try_to_number(ext.nat) as n
                from ext
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'                 then 'Statistic'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT' then
                              case
                                  when n between 4000 and 4999       then 'Revenue'
                                  when n between 5000 and 5006       then 'Expense'
                                  when n in (5100, 5110)             then 'Expense'
                                  when n between 5200 and 5204       then 'Expense'
                                  when n = 5900                      then 'Expense'
                                  when n = 5990                      then 'Allocations & Reserves'
                                  when n between 6000 and 7999       then 'Expense'
                                  when n between 8000 and 8999       then 'Below the Line'
                                  else 'Unclassified'
                              end
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL' then
                              case
                                  when k_dept in ('Operating Revenues', 'MISCELLANEOUS INCOME')                            then 'Revenue'
                                  when k_dept in ('Departmental Expenses', 'Undistributed Operating Expenses')              then 'Expense'
                                  when k_dept in ('Non-Operating Income and Expenses', 'NON-OPERATING INCOME & EXPENSE')   then 'Below the Line'
                                  else 'Unclassified'
                              end
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'                 then coalesce(nat, k_acct)
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT' then
                              case
                                  when n between 4000 and 4999       then 'Revenue'
                                  when n between 5000 and 5006       then 'Payroll'
                                  when n in (5100, 5110)             then 'Cost of Goods Sold'
                                  when n between 5200 and 5204       then 'Operating Expenses'
                                  when n = 5900                      then 'Operating Expenses'
                                  when n between 6000 and 6999       then 'Payroll'
                                  when n between 7000 and 7999       then 'Operating Expenses'
                                  when n between 8000 and 8999       then 'Other Income / (Expense)'
                                  else 'UNCLASSIFIED'
                              end
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL' then
                              case
                                  when k_dept in ('Operating Revenues', 'MISCELLANEOUS INCOME')                            then 'Revenue'
                                  when k_dept in ('Departmental Expenses', 'Undistributed Operating Expenses')              then 'Operating Expenses'
                                  when k_dept in ('Non-Operating Income and Expenses', 'NON-OPERATING INCOME & EXPENSE')   then 'Other Income / (Expense)'
                                  else 'UNCLASSIFIED'
                              end
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC' and nat = '9990'
                              then 'RECORD_TYPE STATISTIC; natural 9990 (LAOFF/STOFF) stat-ledger offset, adds to no total; H2 = the natural account (owner Q-07)'
                          when k_rtype = 'STATISTIC' and nat is not null
                              then 'RECORD_TYPE STATISTIC; H2 = the natural account, the source code (owner Q-07)'
                          when k_rtype = 'STATISTIC'
                              then 'RECORD_TYPE STATISTIC; H2 = the source line identifier (LINE_CLASS or PL line text; Q-06)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT' and n is null
                              then 'no natural account (one-segment or blank ACCOUNT): nothing to derive, not repaired'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT' and (n between 4000 and 5006 or n in (5100, 5110) or n between 5200 and 5204 or n in (5900, 5990))
                              then 'natural account ' || nat || ' (owner Q-09 map, from data; source owner to confirm)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT' and n between 6000 and 8999
                              then 'section digit ' || left(nat, 1) || ' of natural account ' || nat || ' (owner Q-09: as proposed)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT'
                              then 'natural account ' || nat || ': not in the owner map, nothing derived'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL' and h1 <> 'Unclassified'
                              then 'PL SECTION ' || k_dept || ' as stated section (owner Q-09)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL'
                              then 'PL SECTION ' || k_dept || ': department section, mixes revenue and expense, not mapped (owner Q-09)'
                          else 'source table not in the lane: nothing to derive'
                      end as seed_source
                from prop
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        when matched then update set
              tgt.last_seen_run_id = :P_RUN_ID
        when not matched then insert (
              source_lane, source_site_code, department, account_key, record_type
            , asset_name, department_name, account_number, stat_account, account_desc
            , h1, h2, h3, h4, h5, p_l_section, normal_balance, value_sign
            , metric_unit, aggregation_type, review_status, seed_source
            , first_seen_run_id, last_seen_run_id
        ) values (
              src.k_lane, src.k_site, src.k_dept, src.k_acct, src.k_rtype
            , src.asset_name, src.department_name, src.account_number, src.stat_account, src.account_desc
            , src.h1, src.h2, src.h3, src.h4, src.h5, src.p_l_section, src.normal_balance, src.value_sign
            , src.metric_unit, src.aggregation_type, 'UNREVIEWED', src.seed_source
            , :P_RUN_ID, :P_RUN_ID
        );

    else
        raise e_lane;
    end if;

    v_after := (select count(*) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = :P_LANE);
    return 'XREF_ACCOUNT_CLASSIFICATION lane=' || :P_LANE || ' keys=' || v_after || ' inserted=' || (v_after - v_before);
end;
$$;
