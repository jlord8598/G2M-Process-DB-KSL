execute immediate $$
-- ============================================================================
-- scripts/reconcile_HHG.sql
-- M6 deliverable (build 19: + OPS_MEMBERSHIP_MONTHLY; TR12 description fill). Read-only. Never deployed.
-- For every in-scope source table of lane HHG: row count (CLN x the stated
-- unpivot multiplier) and every numeric measure across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pace tables), by SOURCE_TABLE
--   SEM   the six semantic tables (facts), by SOURCE_TABLE
-- Fact tables: AMT and STAT where the CLN columns state the split; otherwise
-- TOTAL (SOURCE_AMOUNT + STAT_VALUE against the sum of the CLN measure columns,
-- where staging splits each row by RECORD_TYPE). Pace tables: every numeric
-- column. Dictionaries: rows.
-- SOURCE_AMOUNT is reconciled, never VALUE (D-50 changes VALUE, not the amount).
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    m as (
        select 'CLN_HERITAGE_GOLF_FIN_PL_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'TOTAL', coalesce(sum(amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY
        union all
        select 'CLN_HERITAGE_GOLF_FIN_PL_MONTHLY', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA
        union all
        select 'CLN_HERITAGE_GOLF_FIN_PL_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'
        union all
        select 'CLN_HERITAGE_GOLF_FIN_PL_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HHG' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'
        union all
        select 'CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'TOTAL', coalesce(sum(amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS
        union all
        select 'CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN
        union all
        select 'CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS'
        union all
        select 'CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HHG' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS'
        union all
        select 'CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'AMT', 0, 'STAT', coalesce(sum(rounds_count),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY
        union all
        select 'CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL
        union all
        select 'CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY', 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY'
        union all
        select 'CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY', 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HHG' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY'
        union all
        select 'CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'TOTAL', coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY
        union all
        select 'CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_HHG_BUDGET_BY_CLUB
        union all
        select 'CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'
        union all
        select 'CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HHG' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'
        union all
        select 'CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'AMT', 0, 'STAT', coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY
        union all
        select 'CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_HHG_MEMBERSHIP_MONTHLY
        union all
        select 'CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY'
        union all
        select 'CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HHG' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY'
        union all
        select 'CLN_HERITAGE_GOLF_REF_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS
        union all
        select 'CLN_HERITAGE_GOLF_REF_ACCOUNTS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_HHG_ACCOUNTS
        union all
        select 'CLN_HERITAGE_GOLF_REF_PROPERTIES' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTIES
        union all
        select 'CLN_HERITAGE_GOLF_REF_PROPERTIES', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_HHG_ASSET_CODES
        union all
        select 'CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS
        union all
        select 'CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_HHG_CHART_OF_ACCOUNTS
        union all
        select 'CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS
        union all
        select 'CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_HHG_CLUB_LIST
        union all
        select 'CLN_HERITAGE_GOLF_REF_DEPARTMENTS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_DEPARTMENTS
        union all
        select 'CLN_HERITAGE_GOLF_REF_DEPARTMENTS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_HHG_DEPARTMENT_KEY
        union all
        select 'CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS
        union all
        select 'CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_HHG_REFERENCES
        union all
        select 'CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING
        union all
        select 'CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_HHG_TR12_ACCOUNTS
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = 'CLN',  f.value::float, null)) as cln
            , max(iff(m.l = 'STG',  f.value::float, null)) as stg
            , max(iff(m.l = 'XFRM', f.value::float, null)) as xfrm
            , max(iff(m.l = 'SEM',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then 'FAIL'
                  when stg  is null or abs(stg  - cln) > 0.005        then 'FAIL'
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then 'FAIL'
                  when sem  is not null and abs(sem  - cln) > 0.005   then 'FAIL'
                  else 'PASS'
              end as status
        from r
    )
    select 'HHG' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'HHG', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
