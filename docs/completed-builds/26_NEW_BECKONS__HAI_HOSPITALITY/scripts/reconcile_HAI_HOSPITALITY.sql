execute immediate $$
-- ============================================================================
-- scripts/reconcile_HAI_HOSPITALITY.sql
-- M6 deliverable (build 26, new lane): INCOME_STATEMENT x2 by branch (AMOUNT_ACTUAL -> ACTUAL, AMOUNT_BUDGET -> BUDGET).
-- Read-only. Never deployed; parity never sees it.
-- For every source table of lane HAI_HOSPITALITY, compares row count and the sum of
-- every numeric column across
--   CLN   CLN.DATA_SHARE source table
--   STG   its staging table
--   XFRM  the four H1-routed streams, by SOURCE_TABLE
--   SEM   the six semantic tables, by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names are taken from the deployed staging code.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    m as (
        select 'HAI_HOSPITALITY_INCOME_STATEMENT' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'ACTUAL', coalesce(sum(amount_actual), 0), 'BUDGET', coalesce(sum(amount_budget), 0)) o from CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT
        union all
        select 'HAI_HOSPITALITY_INCOME_STATEMENT', 'STG', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(measure_column = 'ACTUAL', source_amount, 0)), 0), 'BUDGET', coalesce(sum(iff(measure_column = 'BUDGET', source_amount, 0)), 0)) from DEV_G2M_AI.STAGING.STG_HAI_HOSPITALITY_INCOME_STATEMENT
        union all
        select 'HAI_HOSPITALITY_INCOME_STATEMENT', 'XFRM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', source_amount, 0)), 0), 'BUDGET', coalesce(sum(iff(category = 'BUDGET', source_amount, 0)), 0)) from (select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_INCOME_STATEMENT union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_BALANCE_SHEET union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_OPERATING_METRICS union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_UNKNOWN) where source_table = 'CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT'
        union all
        select 'HAI_HOSPITALITY_INCOME_STATEMENT', 'SEM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', source_amount, 0)), 0), 'BUDGET', coalesce(sum(iff(category = 'BUDGET', source_amount, 0)), 0)) from (select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HAI_HOSPITALITY' and source_table = 'CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT'
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
    select 'HAI_HOSPITALITY' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'HAI_HOSPITALITY', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
