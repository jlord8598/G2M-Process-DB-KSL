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
-- One derivation branch per lane. No exception is caught; an undeclared lane
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

    else
        raise e_lane;
    end if;

    v_after := (select count(*) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = :P_LANE);
    return 'XREF_ACCOUNT_CLASSIFICATION lane=' || :P_LANE || ' keys=' || v_after || ' inserted=' || (v_after - v_before);
end;
$$;
