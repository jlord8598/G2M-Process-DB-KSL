execute immediate $$
-- ============================================================================
-- scripts/reconcile_JW_VENICE.sql
-- M6 deliverable (build 15, D-44 rebuild). Read-only. Never deployed.
-- For every in-scope source table of lane JW_VENICE: row count (CLN x the stated
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
        select 'CLN_JW_VENICE_FCAST_ACT_FORECAST' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'TOTAL', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST
        union all
        select 'CLN_JW_VENICE_FCAST_ACT_FORECAST', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
        union all
        select 'CLN_JW_VENICE_FCAST_ACT_FORECAST', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST'
        union all
        select 'CLN_JW_VENICE_FCAST_ACT_FORECAST', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'JW_VENICE' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST'
        union all
        select 'CLN_JW_VENICE_FCAST_BY_PERIOD' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'TOTAL', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD
        union all
        select 'CLN_JW_VENICE_FCAST_BY_PERIOD', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
        union all
        select 'CLN_JW_VENICE_FCAST_BY_PERIOD', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD'
        union all
        select 'CLN_JW_VENICE_FCAST_BY_PERIOD', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'JW_VENICE' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD'
        union all
        select 'CLN_JW_VENICE_FTE' t, 'CLN' l, object_construct('ROWS', count(*) * 4, 'TOTAL', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)+coalesce(sum(previous_forecast_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE
        union all
        select 'CLN_JW_VENICE_FTE', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_JW_VENICE_FTE
        union all
        select 'CLN_JW_VENICE_FTE', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE'
        union all
        select 'CLN_JW_VENICE_FTE', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'JW_VENICE' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE'
        union all
        select 'CLN_JW_VENICE_HEADCOUNT' t, 'CLN' l, object_construct('ROWS', count(*) * 4, 'TOTAL', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)+coalesce(sum(previous_forecast_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT
        union all
        select 'CLN_JW_VENICE_HEADCOUNT', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT
        union all
        select 'CLN_JW_VENICE_HEADCOUNT', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT'
        union all
        select 'CLN_JW_VENICE_HEADCOUNT', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'JW_VENICE' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT'
        union all
        select 'CLN_JW_VENICE_MONTHLY_PL_DEPT' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'TOTAL', coalesce(sum(actual_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT
        union all
        select 'CLN_JW_VENICE_MONTHLY_PL_DEPT', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT
        union all
        select 'CLN_JW_VENICE_MONTHLY_PL_DEPT', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT'
        union all
        select 'CLN_JW_VENICE_MONTHLY_PL_DEPT', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'JW_VENICE' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT'
        union all
        select 'CLN_JW_VENICE_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_ACCOUNTS
        union all
        select 'CLN_JW_VENICE_ACCOUNTS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_JW_VENICE_ACCOUNTS
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
    select 'JW_VENICE' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'JW_VENICE', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
