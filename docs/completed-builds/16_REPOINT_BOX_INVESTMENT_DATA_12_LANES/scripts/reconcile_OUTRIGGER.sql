execute immediate $$
-- ============================================================================
-- scripts/reconcile_OUTRIGGER.sql
-- M6 deliverable (build 16: repointed to the new CLN.BOX_INVESTMENT_DATA names). Read-only. Never deployed; parity never sees it.
-- For every source table of lane OUTRIGGER, compares row count and the sum of
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
        select 'OUTRIGGER_PACE' t, 'CLN' l, object_construct('ROWS', count(*), 'CY_PACE_OCCUPANCY', coalesce(sum(cy_pace_occupancy), 0), 'CY_PACE_ROOMS', coalesce(sum(cy_pace_rooms), 0), 'CY_PACE_ADR', coalesce(sum(cy_pace_adr), 0), 'CY_PACE_REVENUE', coalesce(sum(cy_pace_revenue), 0), 'LY_PACE_OCCUPANCY', coalesce(sum(ly_pace_occupancy), 0), 'LY_PACE_ROOMS', coalesce(sum(ly_pace_rooms), 0), 'LY_PACE_ADR', coalesce(sum(ly_pace_adr), 0), 'LY_PACE_REVENUE', coalesce(sum(ly_pace_revenue), 0), 'FORECAST_OCCUPANCY', coalesce(sum(forecast_occupancy), 0), 'FORECAST_ROOMS', coalesce(sum(forecast_rooms), 0), 'FORECAST_ADR', coalesce(sum(forecast_adr), 0), 'FORECAST_REVENUE', coalesce(sum(forecast_revenue), 0), 'BUDGET_OCCUPANCY', coalesce(sum(budget_occupancy), 0), 'BUDGET_ROOMS', coalesce(sum(budget_rooms), 0), 'BUDGET_ADR', coalesce(sum(budget_adr), 0), 'BUDGET_REVENUE', coalesce(sum(budget_revenue), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY
        union all
        select 'OUTRIGGER_PACE', 'STG', object_construct('ROWS', count(*), 'CY_PACE_OCCUPANCY', coalesce(sum(cy_pace_occupancy), 0), 'CY_PACE_ROOMS', coalesce(sum(cy_pace_rooms), 0), 'CY_PACE_ADR', coalesce(sum(cy_pace_adr), 0), 'CY_PACE_REVENUE', coalesce(sum(cy_pace_revenue), 0), 'LY_PACE_OCCUPANCY', coalesce(sum(ly_pace_occupancy), 0), 'LY_PACE_ROOMS', coalesce(sum(ly_pace_rooms), 0), 'LY_PACE_ADR', coalesce(sum(ly_pace_adr), 0), 'LY_PACE_REVENUE', coalesce(sum(ly_pace_revenue), 0), 'FORECAST_OCCUPANCY', coalesce(sum(forecast_occupancy), 0), 'FORECAST_ROOMS', coalesce(sum(forecast_rooms), 0), 'FORECAST_ADR', coalesce(sum(forecast_adr), 0), 'FORECAST_REVENUE', coalesce(sum(forecast_revenue), 0), 'BUDGET_OCCUPANCY', coalesce(sum(budget_occupancy), 0), 'BUDGET_ROOMS', coalesce(sum(budget_rooms), 0), 'BUDGET_ADR', coalesce(sum(budget_adr), 0), 'BUDGET_REVENUE', coalesce(sum(budget_revenue), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_OUTRIGGER_PACE
        union all
        select 'OUTRIGGER_PACE', 'XFRM', object_construct('ROWS', count(*), 'CY_PACE_OCCUPANCY', coalesce(sum(cy_pace_occupancy), 0), 'CY_PACE_ROOMS', coalesce(sum(cy_pace_rooms), 0), 'CY_PACE_ADR', coalesce(sum(cy_pace_adr), 0), 'CY_PACE_REVENUE', coalesce(sum(cy_pace_revenue), 0), 'LY_PACE_OCCUPANCY', coalesce(sum(ly_pace_occupancy), 0), 'LY_PACE_ROOMS', coalesce(sum(ly_pace_rooms), 0), 'LY_PACE_ADR', coalesce(sum(ly_pace_adr), 0), 'LY_PACE_REVENUE', coalesce(sum(ly_pace_revenue), 0), 'FORECAST_OCCUPANCY', coalesce(sum(forecast_occupancy), 0), 'FORECAST_ROOMS', coalesce(sum(forecast_rooms), 0), 'FORECAST_ADR', coalesce(sum(forecast_adr), 0), 'FORECAST_REVENUE', coalesce(sum(forecast_revenue), 0), 'BUDGET_OCCUPANCY', coalesce(sum(budget_occupancy), 0), 'BUDGET_ROOMS', coalesce(sum(budget_rooms), 0), 'BUDGET_ADR', coalesce(sum(budget_adr), 0), 'BUDGET_REVENUE', coalesce(sum(budget_revenue), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY'
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
    select 'OUTRIGGER' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'OUTRIGGER', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
