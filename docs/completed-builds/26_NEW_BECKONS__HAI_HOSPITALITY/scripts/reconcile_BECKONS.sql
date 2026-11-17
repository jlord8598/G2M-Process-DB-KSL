execute immediate $$
-- ============================================================================
-- scripts/reconcile_BECKONS.sql
-- M6 deliverable (build 26, new lane): ACTUALS and BUDGET, long; the measure is the local base amount (SOURCE_AMOUNT, or STAT_VALUE on AROOM / NIGHT / OROOM); the AUD figure is staged only and reconciled CLN = STG.
-- Read-only. Never deployed; parity never sees it.
-- For every source table of lane BECKONS, compares row count and the sum of
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
        select 'BECKONS_INCOME_STATEMENT_ACTUALS' t, 'CLN' l, object_construct('ROWS', count(*), 'BASE', coalesce(sum(transaction_amount_base), 0), 'AUD', coalesce(sum(transaction_amount_aud), 0)) o from CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS
        union all
        select 'BECKONS_INCOME_STATEMENT_ACTUALS', 'STG', object_construct('ROWS', count(*), 'BASE', coalesce(sum(coalesce(source_amount, stat_value, 0)), 0), 'AUD', coalesce(sum(transaction_amount_aud), 0)) from DEV_G2M_AI.STAGING.STG_BECKONS_ACTUALS
        union all
        select 'BECKONS_INCOME_STATEMENT_ACTUALS', 'XFRM', object_construct('ROWS', count(*), 'BASE', coalesce(sum(coalesce(source_amount, stat_value, 0)), 0)) from (select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_INCOME_STATEMENT union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_BALANCE_SHEET union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_OPERATING_METRICS union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_UNKNOWN) where source_table = 'CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS'
        union all
        select 'BECKONS_INCOME_STATEMENT_ACTUALS', 'SEM', object_construct('ROWS', count(*), 'BASE', coalesce(sum(coalesce(source_amount, stat_value, 0)), 0)) from (select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'BECKONS' and source_table = 'CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS'
        union all
        select 'BECKONS_INCOME_STATEMENT_BUDGET' t, 'CLN' l, object_construct('ROWS', count(*), 'BASE', coalesce(sum(budget_amount_base), 0), 'AUD', coalesce(sum(budget_amount_aud), 0)) o from CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_BUDGET
        union all
        select 'BECKONS_INCOME_STATEMENT_BUDGET', 'STG', object_construct('ROWS', count(*), 'BASE', coalesce(sum(coalesce(source_amount, stat_value, 0)), 0), 'AUD', coalesce(sum(budget_amount_aud), 0)) from DEV_G2M_AI.STAGING.STG_BECKONS_BUDGET
        union all
        select 'BECKONS_INCOME_STATEMENT_BUDGET', 'XFRM', object_construct('ROWS', count(*), 'BASE', coalesce(sum(coalesce(source_amount, stat_value, 0)), 0)) from (select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_INCOME_STATEMENT union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_BALANCE_SHEET union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_OPERATING_METRICS union all select source_table, category, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_UNKNOWN) where source_table = 'CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_BUDGET'
        union all
        select 'BECKONS_INCOME_STATEMENT_BUDGET', 'SEM', object_construct('ROWS', count(*), 'BASE', coalesce(sum(coalesce(source_amount, stat_value, 0)), 0)) from (select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, category, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'BECKONS' and source_table = 'CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_BUDGET'
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
    select 'BECKONS' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'BECKONS', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
