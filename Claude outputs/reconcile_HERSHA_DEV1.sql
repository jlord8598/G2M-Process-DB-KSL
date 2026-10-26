execute immediate $$
-- ============================================================================
-- scripts/reconcile_HERSHA.sql
-- M6 deliverable (rerun unchanged in build 06; source columns unchanged). Read-only. Never deployed; parity never sees it.
-- For every source table of lane HERSHA, compares row count and the sum of
-- every numeric column across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pacing tables),
--         grouped by SOURCE_TABLE
--   SEM   the six semantic tables (facts), grouped by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names are taken from the deployed staging code:
--   GL_ACTUAL  wide by category, 2 branches: CLN ROWS = count(*) x 2;
--              ACTUAL_/FORECAST_AMOUNT (GL_CODE not Stat) -> SOURCE_AMOUNT (AMT),
--              ACTUAL_/FORECAST_STAT -> STAT_VALUE (STAT)
--   GL_STAT    2 branches; ACTUAL_/FORECAST_AMOUNT -> STAT_VALUE (STAT) (owner Q-02)
-- The lane has no pacing source: XFRM_HERSHA_PACING is empty by design (M1).
-- every other numeric column is carried verbatim under its own name.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    -- ------------------------------------------------------------------------
    -- measures per table per layer, as objects keyed by metric
    -- ------------------------------------------------------------------------
    m as (
        -- GL_ACTUAL
        select 'GL_ACTUAL' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'AMT', sum(iff(upper(trim(gl_code)) = 'STAT', 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0))), 'STAT', sum(coalesce(actual_stat, 0) + coalesce(forecast_stat, 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_ACTUAL
        union all
        select 'GL_ACTUAL', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV1.STAGING.STG_HERSHA_GL_ACTUAL
        union all
        -- GL_STAT
        select 'GL_STAT' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'STAT', sum(coalesce(actual_amount, 0) + coalesce(forecast_amount, 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_STAT
        union all
        select 'GL_STAT', 'STG', object_construct('ROWS', count(*), 'STAT', coalesce(sum(stat_value), 0))
        from DEV1.STAGING.STG_HERSHA_GL_STAT
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, 'CLN_HERSHA_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HERSHA_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, 'CLN_HERSHA_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'HERSHA'
        group by source_table
        union all
        -- dictionary ACCOUNTS
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV1.STAGING.STG_HERSHA_ACCOUNTS
    )
    -- ------------------------------------------------------------------------
    -- one row per table per metric, layers side by side
    -- ------------------------------------------------------------------------
    , r as (
        select
              m.t                                        as source_table
            , f.key::varchar                             as metric
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
    select 'HERSHA' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'HERSHA', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
