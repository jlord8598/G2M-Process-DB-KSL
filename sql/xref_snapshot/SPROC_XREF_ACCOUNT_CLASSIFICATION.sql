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
--   3 merge    insert-only; an existing key gets LAST_SEEN_RUN_ID only (D-14).
--              Changing a branch never reaches existing rows: build 08 re-seeded
--              INVITED_CLUBS and NEWBURY once, by an approved D-44 UPDATE of the
--              classification columns (scripts/reseed_build08.sql).
-- One derivation branch per lane (DAVIDSON added in build 06; ALTERRA,
-- ATLANTIC_AVIATION and JW_VENICE in build 11; JW_VENICE rebuilt build 12). No exception
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
        -- LANE KSL_SELECT_SERVICE (build 01; rebuilt builds 04, 05, 13, D-44)
        -- Build 13 (owner Q-01, Q-05; D-46 account blocks, char 5-8 of the
        -- account): 1x Assets; 2x Assets (due-from); 30-38 and 3900-3955
        -- Liabilities; 3956-3999 Equity; 4x Revenue; 5x COGS; 6x Payroll; 7x
        -- Operating Expenses; 8704 / 8705 / 8712 / 8720 Below the Line /
        -- Depreciation & Amortization; other 8x
        -- Below the Line / Other Income / (Expense); 9x Allocations & Reserves.
        -- D-44 re-seed: an existing AMOUNT key in a changed block (2x, 3x, the
        -- D&A accounts) whose stored classification differs from
        -- this mapping is updated in H1-H5, section, balance, sign, unit,
        -- aggregation and seed source only. Keys never move.
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
                    , substr(nullif(trim(ext.account_number), ''), 5, 4)                          as main4
                    , substr(nullif(trim(ext.account_number), ''), 5, 2)                          as blk2
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
                          when digit = 2                         then 'Assets'
                          when digit = 3 and main4 between '3956' and '3999' then 'Equity'
                          when digit = 3                         then 'Liabilities'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when main4 in ('8704', '8705', '8712', '8720') then 'Depreciation & Amortization'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC' and stat_ok then 'RECORD_TYPE STATISTIC; H2 = STAT_ + chars 5-6 of STAT_ACCOUNT'
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; STAT_ACCOUNT malformed, no family (Q-12)'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired (Q-12)'
                          when digit = 2                         then 'block 2x due-from: Assets (owner Q-01, build 13; D-46)'
                          when digit = 3 and main4 between '3956' and '3999' then 'block 3956-3999: Equity (owner Q-01, build 13; D-46)'
                          when digit = 3                         then 'block 30-38 / 3900-3955: Liabilities (owner Q-01, build 13; D-46)'
                          when main4 in ('8704', '8705', '8712', '8720') then 'D&A account ' || main4 || ': Depreciation & Amortization (owner Q-01, build 13; D-46)'
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
                      when 'Depreciation & Amortization' then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Depreciation & Amortization' then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                      when 'Depreciation & Amortization' then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
                , (k_rtype = 'AMOUNT' and acct_ok
                   and (digit in (2, 3) or main4 in ('8704', '8705', '8712', '8720'))) as reseed_block
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        -- D-44 re-seed (owner Q-01, Q-05, build 13): changed blocks only, and only
        -- where the stored classification differs from the approved mapping
        when matched and src.reseed_block
                     and (tgt.h1 is distinct from src.h1 or tgt.h2 is distinct from src.h2
                          or tgt.p_l_section is distinct from src.p_l_section
                          or tgt.normal_balance is distinct from src.normal_balance
                          or tgt.value_sign is distinct from src.value_sign) then update set
              tgt.h1               = src.h1
            , tgt.h2               = src.h2
            , tgt.h3               = src.h3
            , tgt.h4               = src.h4
            , tgt.h5               = src.h5
            , tgt.p_l_section      = src.p_l_section
            , tgt.normal_balance   = src.normal_balance
            , tgt.value_sign       = src.value_sign
            , tgt.metric_unit      = src.metric_unit
            , tgt.aggregation_type = src.aggregation_type
            , tgt.seed_source      = src.seed_source
            , tgt.last_seen_run_id = :P_RUN_ID
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
        -- LANE PEREGRINE_RESORTS (build 01; rebuilt builds 04, 05, 13, D-44)
        -- Build 13 (owner Q-01, Q-05; D-46 account blocks, char 5-8 of the
        -- account): 1x Assets; 2x Assets (due-from); 30-38 and 3900-3955
        -- Liabilities; 3956-3999 Equity; 4x Revenue; 5x COGS; 6x Payroll; 7x
        -- Operating Expenses; 8704 / 8705 / 8712 / 8720 Below the Line /
        -- Depreciation & Amortization; 86xx Expense / Operating Expenses; other 8x
        -- Below the Line / Other Income / (Expense); 9x Allocations & Reserves.
        -- D-44 re-seed: an existing AMOUNT key in a changed block (2x, 3x, the
        -- D&A accounts, 86xx) whose stored classification differs from
        -- this mapping is updated in H1-H5, section, balance, sign, unit,
        -- aggregation and seed source only. Keys never move.
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
                    , substr(nullif(trim(ext.account_number), ''), 5, 4)                          as main4
                    , substr(nullif(trim(ext.account_number), ''), 5, 2)                          as blk2
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
                          when digit = 8 and blk2 = '86'          then 'Expense'
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
                          when digit = 2                         then 'Assets'
                          when digit = 3 and main4 between '3956' and '3999' then 'Equity'
                          when digit = 3                         then 'Liabilities'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when main4 in ('8704', '8705', '8712', '8720') then 'Depreciation & Amortization'
                          when digit = 8 and blk2 = '86'         then 'Operating Expenses'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC' and stat_ok then 'RECORD_TYPE STATISTIC; H2 = STAT_ + chars 5-6 of STAT_ACCOUNT'
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; STAT_ACCOUNT malformed, no family (Q-12)'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired (Q-12)'
                          when digit = 2                         then 'block 2x due-from: Assets (owner Q-01, build 13; D-46)'
                          when digit = 3 and main4 between '3956' and '3999' then 'block 3956-3999: Equity (owner Q-01, build 13; D-46)'
                          when digit = 3                         then 'block 30-38 / 3900-3955: Liabilities (owner Q-01, build 13; D-46)'
                          when main4 in ('8704', '8705', '8712', '8720') then 'D&A account ' || main4 || ': Depreciation & Amortization (owner Q-01, build 13; D-46)'
                          when digit = 8 and blk2 = '86'         then 'block 86: Operating Expenses (owner Q-05, build 13; D-46)'
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
                      when 'Depreciation & Amortization' then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Depreciation & Amortization' then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                      when 'Depreciation & Amortization' then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
                , (k_rtype = 'AMOUNT' and acct_ok
                   and (digit in (2, 3) or main4 in ('8704', '8705', '8712', '8720') or (digit = 8 and blk2 = '86'))) as reseed_block
            from cls
        ) src
            on  tgt.source_lane      = src.k_lane
            and tgt.source_site_code = src.k_site
            and tgt.department       = src.k_dept
            and tgt.account_key      = src.k_acct
            and tgt.record_type      = src.k_rtype
        -- D-44 re-seed (owner Q-01, Q-05, build 13): changed blocks only, and only
        -- where the stored classification differs from the approved mapping
        when matched and src.reseed_block
                     and (tgt.h1 is distinct from src.h1 or tgt.h2 is distinct from src.h2
                          or tgt.p_l_section is distinct from src.p_l_section
                          or tgt.normal_balance is distinct from src.normal_balance
                          or tgt.value_sign is distinct from src.value_sign) then update set
              tgt.h1               = src.h1
            , tgt.h2               = src.h2
            , tgt.h3               = src.h3
            , tgt.h4               = src.h4
            , tgt.h5               = src.h5
            , tgt.p_l_section      = src.p_l_section
            , tgt.normal_balance   = src.normal_balance
            , tgt.value_sign       = src.value_sign
            , tgt.metric_unit      = src.metric_unit
            , tgt.aggregation_type = src.aggregation_type
            , tgt.seed_source      = src.seed_source
            , tgt.last_seen_run_id = :P_RUN_ID
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
        -- Build 10 (D-46, owner Q-03, Q-04, Q-09, stop 2 correction): TR12 money
        --   H1/H2 from STG_HHG_CHART_OF_ACCOUNTS.ACCOUNT_TYPE on department +
        --   natural account (segments 2, 3). Where the department is not listed,
        --   the account's type if it has one type at every listed department;
        --   mixed-type accounts (49950, 51990, 52100) and accounts with no COA
        --   row keep the digit rule. Revenue -> Revenue (51050, 51060 -> COGS);
        --   Cost of Sales -> COGS; Labor -> Payroll; Operating Expense -> Opex;
        --   Other Income -> Below the Line / OI/E; Below EBITDA -> Below the Line,
        --   H2 D&A (82000, 82100, 82200), Income Taxes (84000), else OI/E.
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
            -- chart of accounts: type per department + natural account, and the
            -- type per natural account where it is single across departments
            -- ----------------------------------------------------------------
            , coa as (
                select department_code as c_dept, natural_account as c_nat, min(account_type) as c_type
                from DEV_G2M_AI.STAGING.STG_HHG_CHART_OF_ACCOUNTS
                where 1=1
                group by 1, 2
            )
            , coa_nat as (
                select natural_account as c_nat, min(account_type) as c_type
                from DEV_G2M_AI.STAGING.STG_HHG_CHART_OF_ACCOUNTS
                where 1=1
                group by 1
                having count(distinct account_type) = 1
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
                    , split_part(nullif(trim(ext.account_number), ''), '-', 3)                      as nat
                    , coalesce(coa.c_type, coa_nat.c_type)                                          as t_type
                    , iff(coa.c_type is not null, 'department + natural account', 'natural account, single type') as t_how
                from ext
                left join amap
                    on  ext.src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                    and amap.line_item = ext.k_acct
                left join coa
                    on  ext.src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA'
                    and coa.c_dept = split_part(nullif(trim(ext.account_number), ''), '-', 2)
                    and coa.c_nat  = split_part(nullif(trim(ext.account_number), ''), '-', 3)
                left join coa_nat
                    on  ext.src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA'
                    and coa_nat.c_nat = split_part(nullif(trim(ext.account_number), ''), '-', 3)
            )
            , prop2 as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC' or not acct_ok or t_type is null then null
                          when t_type = 'Revenue' and nat in ('51050', '51060')        then 'Expense|Cost of Goods Sold'
                          when t_type = 'Revenue'                                       then 'Revenue|Revenue'
                          when t_type = 'Cost of Sales'                                 then 'Expense|Cost of Goods Sold'
                          when t_type = 'Labor'                                         then 'Expense|Payroll'
                          when t_type = 'Operating Expense'                             then 'Expense|Operating Expenses'
                          when t_type = 'Other Income'                                  then 'Below the Line|Other Income / (Expense)'
                          when t_type = 'Below EBITDA' and nat in ('82000', '82100', '82200')
                                                                                        then 'Below the Line|Depreciation & Amortization'
                          when t_type = 'Below EBITDA' and nat = '84000'               then 'Below the Line|Income Taxes'
                          when t_type = 'Below EBITDA'                                  then 'Below the Line|Other Income / (Expense)'
                      end as t_map
                from prop
            )
            , cls as (
                select
                      prop2.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when t_map is not null                then split_part(t_map, '|', 1)
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
                          when t_map is not null                 then split_part(t_map, '|', 2)
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
                          when t_map is not null and nat in ('51050', '51060') and t_type = 'Revenue'
                              then 'COA ACCOUNT_TYPE Revenue overridden to COGS for ' || nat || ' (build 10 Q-03)'
                          when t_map is not null
                              then 'COA ACCOUNT_TYPE ' || t_type || ' by ' || t_how || ' (D-46, build 10 Q-03)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN' and a_h1 is not null
                              then 'LINE_ITEM name as stated section (owner Q-04, stop 3)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                              then 'LINE_ITEM not in the approved map: nothing to derive'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 10 of ACCOUNT_CODE)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop2
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
                      when 'Depreciation & Amortization' then 'Operating'
                      when 'Income Taxes'             then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                      when 'Depreciation & Amortization' then 'Debit'
                      when 'Income Taxes'             then 'Debit'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                      when 'Depreciation & Amortization' then -1
                      when 'Income Taxes'             then -1
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
        --   Digit rule, except the 9 BU 9000 below-the-line accounts the owner
        --   named (build 08 Q-07): 870105 870110 870120 870125 870205 870210 870215
        --   880430 -> H2 Depreciation & Amortization; 890010 -> Income Taxes. H1 stays
        --   Below the Line (digit, D-46).
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
                    , substr(nullif(trim(ext.account_number), ''), 6, 6)                                                as seg2
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
                          when seg2 in ('870105', '870110', '870120', '870125', '870205', '870210', '870215', '880430')
                                                                 then 'Depreciation & Amortization'
                          when seg2 = '890010'                   then 'Income Taxes'
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
                          when seg2 in ('870105', '870110', '870120', '870125', '870205', '870210', '870215', '880430', '890010')
                              then 'section digit ' || digit || ' (H1); H2 by named account ' || seg2 || ' (owner, build 08 Q-07)'
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
                      when 'Depreciation & Amortization' then 'Operating'
                      when 'Income Taxes'             then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                      when 'Depreciation & Amortization' then 'Debit'
                      when 'Income Taxes'             then 'Debit'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                      when 'Depreciation & Amortization' then -1
                      when 'Income Taxes'             then -1
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
        -- Facts: GL_ACTUAL, GL_STAT, and TB_ACTUAL (build 10 Q-05; its keys seed under
        --   the same rules, no mapping change).
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
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table
                from DEV_G2M_AI.STAGING.STG_HERSHA_TB_ACTUAL
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
        --   8 Below the Line); 6 -> the A6 block mapping (build 08 Q-03/Q-05, table in
        --   docs/sources.md): 600-602 COGS, 603-606 Payroll, 607-633 and 638 Operating
        --   Expenses, 635 Other Income / (Expense), 636 D&A, 63004 63009 63010 63014
        --   63015 63019 63020 Income Taxes, 62824 62838 62839 62849 Other Income /
        --   (Expense), 63504 Operating Expenses, 63699 and anything else UNCLASSIFIED;
        --   OI/E, D&A and Income Taxes take H1 Below the Line, the rest H1 Expense.
        --   Block applies where it and the ACCTS parent disagree (Q-12). Expense
        --   without a digit, saved assumption
        --   (currency) and accounts not in META -> Unclassified.
        -- Build 09 rules (owner; docs/findings/M1.md, M4.md), applied after
        --   STATISTIC and in this order (r_class):
        --   IND      member name starts Ind (Ind-*, IndT*; primary META instance)
        --            -> Unclassified (Q-02, Q-07 / B09-D1)
        --   ACE      Adjusted Cash EBITDA (dynamic calc) -> Unclassified (Q-04)
        --   PLAN     site (ENTITY) starts 'Plan ' -> Unclassified, GL included (Q-05, Q-10)
        --   DUES     META expense dues roll-forward (MPLost, RMBase, XferOutBase,
        --            DMBase, PALost, XLSLost, LULost, PRMB*, PDMB*, AALost) -> H1
        --            Statistic, H2 member name (Q-06 / B09-D3)
        --   KPI      META revenue, not an A-code -> H1 Statistic, H2 member name (B09-D4)
        --   A5REV    META revenue A-code outside A4 -> Below the Line / Other Income /
        --            (Expense), Mixed, unsigned (Q-16)
        --   DUES/KPI rows keep RECORD_TYPE AMOUNT; METRIC_UNIT currency (META
        --   DATA_TYPE); AGGREGATION_TYPE STOCK for BegBase_* / EndBase_* (owner
        --   override, Q-13), else FLOW where META TIME_BALANCE is flow.
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
            -- META TIME_BALANCE, primary instance (not shared), one row per member
            -- ----------------------------------------------------------------
            , mtb as (
                select account, min(time_balance) as m_time_balance
                from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
                where 1=1
                  and lower(trim(data_storage)) <> 'shared'
                group by account
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
                    , lower(trim(mtb.m_time_balance))                                        as c_tb
                    , case
                          when ext.k_rtype = 'STATISTIC'                                     then null
                          when startswith(ext.k_acct, 'Ind')                                 then 'IND'
                          when ext.k_acct = 'Adjusted Cash EBITDA'                           then 'ACE'
                          when startswith(ext.k_site, 'Plan ')                               then 'PLAN'
                          when lower(trim(ext.m_type)) = 'expense'
                           and regexp_like(ext.k_acct, '(MPLost|RMBase|XferOutBase|DMBase|PALost|XLSLost|LULost|PRMB|PDMB|AALost).*')
                                                                                             then 'DUES'
                          when lower(trim(ext.m_type)) = 'revenue'
                           and not regexp_like(nullif(trim(ext.account_number), ''), 'A[0-9]{5}') then 'KPI'
                          when lower(trim(ext.m_type)) = 'revenue'
                           and try_to_number(substr(trim(ext.account_number), 2, 1)) <> 4    then 'A5REV'
                      end                                                                    as r_class
                from ext
                left join mtb on mtb.account = ext.k_acct
            )
            , prop6 as (
                select
                      prop.*
                    , case
                          when not (c_type = 'expense' and acct_ok and digit = 6) then null
                          when substr(trim(account_number), 2, 5) in ('63004', '63009', '63010', '63014', '63015', '63019', '63020')
                                                                                   then 'Income Taxes'
                          when substr(trim(account_number), 2, 5) in ('62824', '62838', '62839', '62849')
                                                                                   then 'Other Income / (Expense)'
                          when substr(trim(account_number), 2, 5) = '63504'       then 'Operating Expenses'
                          when substr(trim(account_number), 2, 5) = '63699'       then 'UNCLASSIFIED'
                          when substr(trim(account_number), 2, 3) in ('600', '601', '602')        then 'Cost of Goods Sold'
                          when substr(trim(account_number), 2, 3) in ('603', '604', '605', '606') then 'Payroll'
                          when substr(trim(account_number), 2, 3) between '607' and '633'
                            or substr(trim(account_number), 2, 3) = '638'         then 'Operating Expenses'
                          when substr(trim(account_number), 2, 3) = '635'         then 'Other Income / (Expense)'
                          when substr(trim(account_number), 2, 3) = '636'         then 'Depreciation & Amortization'
                          else 'UNCLASSIFIED'
                      end as h2_6
                from prop
            )
            , cls as (
                select
                      prop6.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when r_class in ('IND', 'ACE', 'PLAN') then 'Unclassified'
                          when r_class in ('DUES', 'KPI')       then 'Statistic'
                          when r_class = 'A5REV'                then 'Below the Line'
                          when c_type = 'asset'                 then 'Balance Sheet'
                          when c_type = 'liability'             then 'Balance Sheet'
                          when c_type = 'equity'                then 'Balance Sheet'
                          when c_type = 'revenue'               then 'Revenue'
                          when h2_6 in ('Other Income / (Expense)', 'Depreciation & Amortization', 'Income Taxes')
                                                                                     then 'Below the Line'
                          when c_type = 'expense' and acct_ok and digit in (5, 6, 7) then 'Expense'
                          when c_type = 'expense' and acct_ok and digit = 8          then 'Below the Line'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'             then k_acct
                          when r_class in ('IND', 'ACE', 'PLAN')  then 'UNCLASSIFIED'
                          when r_class in ('DUES', 'KPI')        then k_acct
                          when r_class = 'A5REV'                 then 'Other Income / (Expense)'
                          when c_type = 'asset'                  then 'Assets'
                          when c_type = 'liability'              then 'Liabilities'
                          when c_type = 'equity'                 then 'Equity'
                          when c_type = 'revenue'                then 'Revenue'
                          when c_type = 'expense' and acct_ok and digit = 5 then 'Cost of Goods Sold'
                          when c_type = 'expense' and acct_ok and digit = 6 then h2_6
                          when c_type = 'expense' and acct_ok and digit = 7 then 'Operating Expenses'
                          when c_type = 'expense' and acct_ok and digit = 8 then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC (META DATA_TYPE non-currency); H2 = account member name'
                          when r_class = 'IND'                   then 'member name starts Ind (Indicated/planning or Ind-Total rollup): Unclassified (build 09 Q-02, Q-07)'
                          when r_class = 'ACE'                   then 'Adjusted Cash EBITDA, dynamic calc rollup: Unclassified (build 09 Q-04)'
                          when r_class = 'PLAN'                  then 'Plan entity ' || k_site || ': planning input, Unclassified (build 09 Q-05, Q-10)'
                          when r_class = 'DUES'                  then 'dues roll-forward, META expense currency: H1 Statistic, RECORD_TYPE AMOUNT kept (build 09 Q-06)'
                          when r_class = 'KPI' and regexp_like(k_acct, '(BegBase|EndBase)_.*')
                              then 'META revenue, not A4 GL: H1 Statistic (B09-D4); AGGREGATION_TYPE STOCK, owner override of META TIME_BALANCE (Q-13)'
                          when r_class = 'KPI'                   then 'META revenue, not A4 GL: H1 Statistic, RECORD_TYPE AMOUNT kept (B09-D4)'
                          when r_class = 'A5REV'                 then 'META revenue A-code outside A4: Other Income / (Expense) (build 09 Q-16)'
                          when c_type is null                    then 'account not in META_ACCOUNT: nothing to derive (owner Q-05)'
                          when c_type in ('asset', 'liability', 'equity', 'revenue')
                              then 'META_ACCOUNT.ACCOUNT_TYPE ' || c_type || ' (stated; owner Q-05)'
                          when c_type = 'expense' and acct_ok and digit = 6
                              then 'META ACCOUNT_TYPE expense; A6 block ' || substr(trim(account_number), 2, 3) || ' mapping (owner, build 08 Q-03/Q-05)'
                          when c_type = 'expense' and acct_ok and digit between 5 and 8
                              then 'META ACCOUNT_TYPE expense; section digit ' || digit || ' (char 2 of A-code; owner Q-05)'
                          when c_type = 'expense'                then 'META ACCOUNT_TYPE expense, no usable A-code digit: Unclassified (owner Q-05)'
                          else 'META ACCOUNT_TYPE ' || c_type || ': no standard section (owner Q-05)'
                      end as seed_source
                from prop6
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
                      when 'Depreciation & Amortization' then 'Operating'
                      when 'Income Taxes'             then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                      when 'Depreciation & Amortization' then 'Debit'
                      when 'Income Taxes'             then 'Debit'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                      when 'Depreciation & Amortization' then -1
                      when 'Income Taxes'             then -1
                  end::number(2,0) as value_sign
                , case when r_class in ('DUES', 'KPI') then 'currency' end::varchar as metric_unit
                , case
                      when r_class in ('DUES', 'KPI') and regexp_like(k_acct, '(BegBase|EndBase)_.*') then 'STOCK'
                      when r_class in ('DUES', 'KPI') and c_tb = 'flow'          then 'FLOW'
                      when h1 = 'Statistic'                                      then 'UNRATIFIED'
                  end as aggregation_type
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

    elseif (:P_LANE = 'ALTERRA') then
        -- ====================================================================
        -- LANE ALTERRA (build 11)
        -- Facts: MONTHLY_FINANCIALS. No account: ACCOUNT_KEY = LINE_ITEM,
        --   DEPARTMENT = SECTION (stated in words; ACCOUNTS states the same).
        -- Order (owner, stop 1 and Q-15): a source subtotal / computed line is
        --   Unclassified (XFRM gives SOURCE_ROLLUP); STATISTIC -> Statistic, H2
        --   the section name; then the section: Revenue -> Revenue; Cost of
        --   Sales -> Cost of Goods Sold; Operating Labor -> Payroll; Operating
        --   Expenses, G&A, Expenses, Undistributed Expenses -> Operating
        --   Expenses, except Undistributed "Other - Commercial Properties" and
        --   "Other - Real Estate" -> Below the Line / Other Income / (Expense)
        --   (Q-07). Ski Butlers segment sections and the null section by line
        --   family (Q-08, Q-15 lone totals): Revenue..., Cost of Sales /
        --   Expenses - Cost of Sales..., Operating Labor / Expenses - Payroll...,
        --   Operating Expenses / Expenses - Departmental Direct... / Expenses -
        --   Other G&A. Ski Butlers "Alterra Resorts" is classified by family
        --   and loses to the resorts' lines in XFRM (D-48).
        -- Q-17: Revenue - Home Owners is a contra line: H2 Revenue, NORMAL_BALANCE
        --   Credit, VALUE_SIGN -1 so it reduces revenue (owner decision; the one
        --   exception to D-13 in this lane).
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows (pacing and dictionaries never feed the seeder)
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , is_subtotal, subtotal_source
                from DEV_G2M_AI.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS
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
                    , boolor_agg(is_subtotal)                                 as m_subtotal
                    , min(subtotal_source)                                    as m_subtotal_source
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- line family, for the Ski Butlers segments and the null section
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , case
                          when k_acct like 'Revenue%'                                                           then 'Revenue'
                          when k_acct = 'Cost of Sales' or k_acct like 'Expenses - Cost of Sales%'             then 'Cost of Goods Sold'
                          when k_acct = 'Operating Labor' or k_acct like 'Expenses - Payroll%'                 then 'Payroll'
                          when k_acct = 'Operating Expenses' or k_acct like 'Expenses - Departmental Direct%'
                            or k_acct = 'Expenses - Other G&A'                                                 then 'Operating Expenses'
                      end as c_family
                from ext
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , cls0 as (
                select
                      prop.*
                    , case
                          when m_subtotal                                           then 'UNCLASSIFIED'
                          when k_rtype = 'STATISTIC'                                then k_dept
                          when k_dept = 'Revenue'                                   then 'Revenue'
                          when k_dept = 'Cost of Sales'                             then 'Cost of Goods Sold'
                          when k_dept = 'Operating Labor'                           then 'Payroll'
                          when k_dept = 'Undistributed Expenses'
                           and k_acct in ('Other - Commercial Properties', 'Other - Real Estate') then 'Other Income / (Expense)'
                          when k_dept in ('Operating Expenses', 'G&A', 'Expenses', 'Undistributed Expenses') then 'Operating Expenses'
                          when k_dept in ('Alterra Resorts', 'Other Resorts', '~BLANK~')
                           and c_family is not null                                 then c_family
                          else 'UNCLASSIFIED'
                      end as h2
                from prop
            )
            , cls as (
                select
                      cls0.*
                    , case
                          when m_subtotal                        then 'Unclassified'
                          when k_rtype = 'STATISTIC'             then 'Statistic'
                          when h2 = 'Revenue'                    then 'Revenue'
                          when h2 = 'Other Income / (Expense)'   then 'Below the Line'
                          when h2 in ('Cost of Goods Sold', 'Payroll', 'Operating Expenses') then 'Expense'
                          else 'Unclassified'
                      end as h1
                    , case
                          when m_subtotal                        then 'source subtotal or computed line (' || m_subtotal_source || '): SOURCE_ROLLUP, not classified'
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; H2 = the source SECTION (D-38)'
                          when k_acct = 'Revenue - Home Owners' and h2 = 'Revenue' then 'SECTION Revenue; contra line, VALUE_SIGN -1 so it reduces revenue (owner Q-17)'
                          when m_subtotal_source = 'lone total (Q-15)' then 'lone total (Q-15): line family ' || h2
                          when k_dept in ('Alterra Resorts', 'Other Resorts', '~BLANK~') and h2 <> 'UNCLASSIFIED'
                                                                 then 'SECTION ' || k_dept || ': line family ' || h2 || ' (owner Q-08)'
                          when h2 = 'Other Income / (Expense)'   then 'SECTION Undistributed Expenses, ' || k_acct || ' (owner Q-07)'
                          when h2 <> 'UNCLASSIFIED'              then 'SECTION ' || k_dept || ' (stated; owner, stop 1)'
                          else 'SECTION ' || k_dept || ': nothing to derive'
                      end as seed_source
                from cls0
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
                , case
                      when h2 = 'Revenue' and k_acct = 'Revenue - Home Owners' then -1
                      when h2 = 'Revenue'                  then 1
                      when h2 = 'Cost of Goods Sold'       then -1
                      when h2 = 'Payroll'                  then -1
                      when h2 = 'Operating Expenses'       then -1
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

    elseif (:P_LANE = 'ATLANTIC_AVIATION') then
        -- ====================================================================
        -- LANE ATLANTIC_AVIATION (build 11)
        -- Facts: OC_DATA. No account: ACCOUNT_KEY = LINE_ITEM. The 18 sites
        --   carry no usable section, so each line is mapped by the section the
        --   lane dictionary (STG_ATLANTIC_AVIATION_ACCOUNTS) states for it under
        --   Total Company (owner, stop 1).
        -- Order: source subtotal / computed / bridge line -> Unclassified (XFRM
        --   gives SOURCE_ROLLUP); Fuel Margin -> Statistic, currency, FLOW (Q-13,
        --   the B09-D4 pattern; RECORD_TYPE stays AMOUNT); STATISTIC -> Statistic,
        --   H2 KPIs - JetA Only; Salaries and Benefits (FBO and Corp) -> Payroll
        --   (Q-09); Corporate Other Income/Expense, the numbered GL lines and One
        --   Time Adjustments -> Below the Line / Other Income / (Expense) (Q-10);
        --   then the dictionary section: Revenue; Cost of Sales -> Cost of Goods
        --   Sold; FBO / Corporate Operating Expenses -> Operating Expenses; Debt
        --   Reporting, Debt Breakdown, Revolver, and Debt's Long-Term / Other
        --   Debt -> Balance Sheet / Liabilities, Cash (Ending Balance) -> Assets.
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows (pacing and dictionaries never feed the seeder)
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , is_subtotal, subtotal_source
                from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_OC_DATA
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
                    , boolor_agg(is_subtotal)                                 as m_subtotal
                    , min(subtotal_source)                                    as m_subtotal_source
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- the lane dictionary: the section stated for each line under Total
            -- Company (one section per line, M1)
            -- ----------------------------------------------------------------
            , dict as (
                select full_account_string as d_line, min(department_description) as d_section
                from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS
                where 1=1
                  and entity_code = 'Total Company'
                group by 1
            )
            , prop as (
                select ext.*, dict.d_section
                from ext
                left join dict
                    on dict.d_line = ext.k_acct
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , cls0 as (
                select
                      prop.*
                    , case
                          when m_subtotal                                                       then 'UNCLASSIFIED'
                          when k_acct = 'Fuel Margin'                                           then 'KPIs - JetA Only'
                          when k_rtype = 'STATISTIC'                                            then 'KPIs - JetA Only'
                          when k_acct in ('Salaries and Benefits', 'Salaries and Benefits - Corp') then 'Payroll'
                          when k_acct = 'Corporate Other Income/Expense'
                            or k_acct = 'One Time Adjustments'
                            or regexp_like(k_acct, '^[0-9]{6} - .*')                            then 'Other Income / (Expense)'
                          when d_section = 'Revenue'                                            then 'Revenue'
                          when d_section = 'Cost of Sales'                                      then 'Cost of Goods Sold'
                          when d_section in ('FBO Operating Expenses', 'Corporate Operating Expenses') then 'Operating Expenses'
                          when k_acct = 'Cash (Ending Balance)'                                 then 'Assets'
                          when d_section in ('Debt Reporting', 'Debt Breakdown', 'Revolver')
                            or (d_section = 'Debt' and k_acct in ('Long-Term Debt', 'Other Debt')) then 'Liabilities'
                          else 'UNCLASSIFIED'
                      end as h2
                from prop
            )
            , cls as (
                select
                      cls0.*
                    , case
                          when m_subtotal                                       then 'Unclassified'
                          when h2 = 'KPIs - JetA Only'                          then 'Statistic'
                          when h2 = 'Revenue'                                   then 'Revenue'
                          when h2 = 'Other Income / (Expense)'                  then 'Below the Line'
                          when h2 in ('Cost of Goods Sold', 'Payroll', 'Operating Expenses') then 'Expense'
                          when h2 in ('Assets', 'Liabilities')                  then 'Balance Sheet'
                          else 'Unclassified'
                      end as h1
                    , case
                          when m_subtotal                       then 'source subtotal, computed or bridge line (' || m_subtotal_source || '): SOURCE_ROLLUP, not classified'
                          when k_acct = 'Fuel Margin'           then 'Fuel Margin: operating metric, currency, FLOW; RECORD_TYPE AMOUNT kept (owner Q-13, B09-D4 pattern)'
                          when k_rtype = 'STATISTIC'            then 'RECORD_TYPE STATISTIC; H2 = the source section KPIs - JetA Only (D-38)'
                          when h2 = 'Payroll'                   then 'Salaries and Benefits: Payroll whatever the section (owner Q-09)'
                          when h2 = 'Other Income / (Expense)'  then k_acct || ': Below the Line (owner Q-10)'
                          when h2 <> 'UNCLASSIFIED'             then 'Total Company dictionary section ' || d_section || ' (owner, stop 1)'
                          when d_section is null                then 'line not in the Total Company dictionary: nothing to derive'
                          else 'dictionary section ' || d_section || ': nothing to derive'
                      end as seed_source
                from cls0
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
                , case when k_acct = 'Fuel Margin' and h1 = 'Statistic' then 'currency' end::varchar as metric_unit
                , case when k_acct = 'Fuel Margin' and h1 = 'Statistic' then 'FLOW' when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
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

    elseif (:P_LANE = 'JW_VENICE') then
        -- ====================================================================
        -- LANE JW_VENICE (build 11; rebuilt build 12, D-44)
        -- Facts: FCAST_ACT_FORECAST, FCAST_BY_PERIOD (DEPARTMENT = SECTION,
        --   ACCOUNT_KEY = LINE_ITEM); FTE, HEADCOUNT (DEPARTMENT = DEPARTMENT_LABEL,
        --   ACCOUNT_KEY = the table subject, Q-04).
        -- Order (owner, stop 1): source subtotal / computed line -> Unclassified
        --   (XFRM gives SOURCE_ROLLUP); STATISTIC -> Statistic, H2 = KEY
        --   STATISTICS or the table subject (FTE, HEADCOUNT); CREDIT CARD EXPENSE
        --   -> Operating Expenses; OPERATING REVENUE, SALES -> Revenue;
        --   UNDISTRIBUTED OPERATING EXP -> Operating Expenses, except NON-OP
        --   INC/EXP EXCL. OWNER EXP. and OWNER INTEREST & INCOME TAX (Q-11) ->
        --   Below the Line / Other Income / (Expense); Isolated / One off costs
        --   -> Below the Line / Other Income / (Expense).
        -- Build 12: + MONTHLY_PL_DEPT (DEPARTMENT = the sheet, ACCOUNT_KEY =
        --   LINE_ITEM). Its keys are all new (none overlap build 11's). Account
        --   blocks of the 6-digit GL code (owner Q-04): 3 Revenue; 4 Cost of
        --   Goods Sold; 51/52/54/56/58 Payroll; 6 Operating Expenses; 7
        --   Operating Expenses except 701110 (replacement reserve, below EBITDA)
        --   -> Below the Line / Other Income / (Expense). STATISTIC -> Statistic,
        --   H2 = the line text.
        -- ====================================================================
        merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
        using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows (pacing and dictionaries never feed the seeder)
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , is_subtotal, subtotal_source, false as is_mpd
                from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , is_subtotal, subtotal_source, false as is_mpd
                from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , is_subtotal, subtotal_source, false as is_mpd
                from DEV_G2M_AI.STAGING.STG_JW_VENICE_FTE
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , is_subtotal, subtotal_source, false as is_mpd
                from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , is_subtotal, subtotal_source, true as is_mpd
                from DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT
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
                    , boolor_agg(is_subtotal)                                 as m_subtotal
                    , min(subtotal_source)                                    as m_subtotal_source
                    , boolor_agg(is_mpd)                                      as m_mpd
                    , split_part(min(account_key), ' | ', 1)                  as m_code
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , cls0 as (
                select
                      ext.*
                    , case
                          when m_subtotal                                         then 'UNCLASSIFIED'
                          when m_mpd and k_rtype = 'STATISTIC'                    then k_acct
                          when m_mpd and m_code = '701110'                        then 'Other Income / (Expense)'
                          when m_mpd and left(m_code, 1) = '3'                    then 'Revenue'
                          when m_mpd and left(m_code, 1) = '4'                    then 'Cost of Goods Sold'
                          when m_mpd and left(m_code, 2) in ('51', '52', '54', '56', '58') then 'Payroll'
                          when m_mpd and left(m_code, 1) in ('6', '7')            then 'Operating Expenses'
                          when m_mpd                                              then 'UNCLASSIFIED'
                          when k_rtype = 'STATISTIC' and k_acct in ('FTE', 'HEADCOUNT') then k_acct
                          when k_rtype = 'STATISTIC'                              then k_dept
                          when k_dept = 'KEY STATISTICS' and k_acct = 'CREDIT CARD EXPENSE' then 'Operating Expenses'
                          when k_dept in ('OPERATING REVENUE', 'SALES')           then 'Revenue'
                          when k_dept = 'UNDISTRIBUTED OPERATING EXP'
                           and k_acct in ('NON-OP INC/EXP EXCL. OWNER EXP.', 'OWNER INTEREST & INCOME TAX') then 'Other Income / (Expense)'
                          when k_dept = 'UNDISTRIBUTED OPERATING EXP'             then 'Operating Expenses'
                          when k_dept = 'Isolated / One off costs (to be input by Marriott)' then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                from ext
            )
            , cls as (
                select
                      cls0.*
                    , case
                          when m_subtotal                       then 'Unclassified'
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when h2 = 'Revenue'                   then 'Revenue'
                          when h2 = 'Other Income / (Expense)'  then 'Below the Line'
                          when h2 = 'Operating Expenses'        then 'Expense'
                          when h2 = 'Cost of Goods Sold'        then 'Expense'
                          when h2 = 'Payroll'                   then 'Expense'
                          else 'Unclassified'
                      end as h1
                    , case
                          when m_subtotal                       then 'source subtotal or computed line (' || m_subtotal_source || '): SOURCE_ROLLUP, not classified'
                          when m_mpd and k_rtype = 'STATISTIC'  then 'MONTHLY_PL_DEPT RECORD_TYPE STATISTIC; H2 = the line text (D-38; build 12)'
                          when m_mpd and m_code = '701110'      then 'MONTHLY_PL_DEPT 701110 replacement reserve: below EBITDA, Below the Line (owner, build 12 Q-04)'
                          when m_mpd and h2 <> 'UNCLASSIFIED'   then 'MONTHLY_PL_DEPT GL block ' || left(m_code, iff(left(m_code, 1) = '5', 2, 1)) || 'xxxxx: ' || h2 || ' (owner, build 12 Q-04)'
                          when m_mpd                            then 'MONTHLY_PL_DEPT ' || m_code || ': no approved block'
                          when k_rtype = 'STATISTIC'            then 'RECORD_TYPE STATISTIC; H2 = ' || h2 || ', the source section or table subject (D-38, Q-04)'
                          when k_acct = 'CREDIT CARD EXPENSE'   then 'KEY STATISTICS CREDIT CARD EXPENSE: money, Operating Expenses (owner, stop 1)'
                          when h2 = 'Other Income / (Expense)' and k_dept = 'UNDISTRIBUTED OPERATING EXP' then k_acct || ': Below the Line (owner Q-11)'
                          when h2 <> 'UNCLASSIFIED'             then 'SECTION ' || k_dept || ' (stated; owner, stop 1)'
                          else 'SECTION ' || k_dept || ': nothing to derive'
                      end as seed_source
                from cls0
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
