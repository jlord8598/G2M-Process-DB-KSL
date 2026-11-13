execute immediate $$
-- ============================================================================
-- scripts/reconcile_THIRD_SPACE.sql
-- M6 deliverable (build 22, new lane): PL_MONTHLY x2 by branch (ACTUAL / FORECAST; no budget column landed), the dictionary by row count;
-- a statistic row's value is STAT_VALUE, every other row's SOURCE_AMOUNT.
-- Read-only. Never deployed; parity never sees it.
-- For every source table of lane THIRD_SPACE, compares row count and the sum of
-- every numeric column across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pace tables), by SOURCE_TABLE
--   SEM   the six semantic tables (facts), by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names are taken from the deployed staging code: facts ACTUAL_AMOUNT
-- -> SOURCE_AMOUNT (AMT) or STAT_VALUE (STAT, statistic rows); pace tables carry
-- every source column verbatim.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    m as (
        select 'THIRD_SPACE_FIN_PL_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'ACTUAL', coalesce(sum(actual_amount), 0), 'FORECAST', coalesce(sum(forecast_amount), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_FIN_PL_MONTHLY
        union all
        select 'THIRD_SPACE_FIN_PL_MONTHLY', 'STG', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(measure_column = 'ACTUAL', coalesce(source_amount, stat_value, 0), 0)), 0), 'FORECAST', coalesce(sum(iff(measure_column = 'FORECAST', coalesce(source_amount, stat_value, 0), 0)), 0)) from DEV_G2M_AI.STAGING.STG_THIRD_SPACE_PL_MONTHLY
        union all
        select 'THIRD_SPACE_FIN_PL_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', coalesce(source_amount, stat_value, 0), 0)), 0), 'FORECAST', coalesce(sum(iff(category = 'FORECAST', coalesce(source_amount, stat_value, 0), 0)), 0)) from (select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_INCOME_STATEMENT union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_BALANCE_SHEET union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_OPERATING_METRICS union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_FIN_PL_MONTHLY'
        union all
        select 'THIRD_SPACE_FIN_PL_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', coalesce(source_amount, stat_value, 0), 0)), 0), 'FORECAST', coalesce(sum(iff(category = 'FORECAST', coalesce(source_amount, stat_value, 0), 0)), 0)) from (select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'THIRD_SPACE' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_FIN_PL_MONTHLY'
        union all
        select 'THIRD_SPACE_REF_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) o from CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_REF_ACCOUNTS
        union all
        select 'THIRD_SPACE_REF_ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_THIRD_SPACE_ACCOUNTS
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
    select 'THIRD_SPACE' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'THIRD_SPACE', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
