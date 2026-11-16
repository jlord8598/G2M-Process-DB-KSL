execute immediate $$
-- ============================================================================
-- scripts/reconcile_HICV_DEV1.sql (DEV1 copy: DEV_G2M_AI. -> DEV1.)
-- M6 deliverable (build 23). New lane HICV.
-- Read-only. Never deployed; parity never sees it.
-- For every source table of lane HICV, compares row count and the sum of every
-- numeric column across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pace tables), by SOURCE_TABLE
--   SEM   the six semantic tables (facts) or SEM_AI_PACING (pace), by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names are taken from the deployed staging code:
--   FIN_PL_MONTHLY x4: ACTUAL_AMOUNT, FORECAST_AMOUNT, PREVIOUS_FORECAST_AMOUNT,
--   BUDGET_AMOUNT -> SOURCE_AMOUNT by SOURCE_MEASURE; in XFRM and SEM the two
--   forecasts are told apart by SCENARIO (FORENOV / FORECAST_AMOUNT,
--   FOREOCT / PREVIOUS_FORECAST_AMOUNT).
--   FIN_GL_MONTHLY: ACTUAL_AMOUNT -> SOURCE_AMOUNT (every row in UNKNOWN, D-48).
--   Pace tables: ACTUAL_AMOUNT, BUDGET_AMOUNT verbatim; SEM_AI_PACING rows / k.
--   Dictionaries: row count and numeric columns, CLN = STG.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    m as (
        select 'HICV_FIN_PL_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*) * 4, 'ACTUAL', coalesce(sum(actual_amount), 0), 'FORECAST', coalesce(sum(forecast_amount), 0), 'PREVIOUS_FORECAST', coalesce(sum(previous_forecast_amount), 0), 'BUDGET', coalesce(sum(budget_amount), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_PL_MONTHLY
        union all
        select 'HICV_FIN_PL_MONTHLY', 'STG', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(source_measure = 'ACTUAL_AMOUNT', coalesce(source_amount, stat_value, 0), 0)), 0), 'FORECAST', coalesce(sum(iff(source_measure = 'FORECAST_AMOUNT', coalesce(source_amount, stat_value, 0), 0)), 0), 'PREVIOUS_FORECAST', coalesce(sum(iff(source_measure = 'PREVIOUS_FORECAST_AMOUNT', coalesce(source_amount, stat_value, 0), 0)), 0), 'BUDGET', coalesce(sum(iff(source_measure = 'BUDGET_AMOUNT', coalesce(source_amount, stat_value, 0), 0)), 0)) from DEV1.STAGING.STG_HICV_PL
        union all
        select 'HICV_FIN_PL_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', coalesce(source_amount, stat_value, 0), 0)), 0), 'FORECAST', coalesce(sum(iff(scenario in ('FORENOV', 'FORECAST_AMOUNT'), coalesce(source_amount, stat_value, 0), 0)), 0), 'PREVIOUS_FORECAST', coalesce(sum(iff(scenario in ('FOREOCT', 'PREVIOUS_FORECAST_AMOUNT'), coalesce(source_amount, stat_value, 0), 0)), 0), 'BUDGET', coalesce(sum(iff(category = 'BUDGET', coalesce(source_amount, stat_value, 0), 0)), 0)) from (select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_INCOME_STATEMENT union all select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_BALANCE_SHEET union all select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_OPERATING_METRICS union all select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_PL_MONTHLY'
        union all
        select 'HICV_FIN_PL_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', coalesce(source_amount, stat_value, 0), 0)), 0), 'FORECAST', coalesce(sum(iff(scenario in ('FORENOV', 'FORECAST_AMOUNT'), coalesce(source_amount, stat_value, 0), 0)), 0), 'PREVIOUS_FORECAST', coalesce(sum(iff(scenario in ('FOREOCT', 'PREVIOUS_FORECAST_AMOUNT'), coalesce(source_amount, stat_value, 0), 0)), 0), 'BUDGET', coalesce(sum(iff(category = 'BUDGET', coalesce(source_amount, stat_value, 0), 0)), 0)) from (select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HICV' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_PL_MONTHLY'
        union all
        select 'HICV_FIN_GL_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'ACTUAL', coalesce(sum(actual_amount), 0), 'SOURCE_LINES_COMBINED', coalesce(sum(source_lines_combined), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_GL_MONTHLY
        union all
        select 'HICV_FIN_GL_MONTHLY', 'STG', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(source_amount), 0), 'SOURCE_LINES_COMBINED', coalesce(sum(source_lines_combined), 0)) from DEV1.STAGING.STG_HICV_GL
        union all
        select 'HICV_FIN_GL_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', coalesce(source_amount, stat_value, 0), 0)), 0)) from (select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_INCOME_STATEMENT union all select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_BALANCE_SHEET union all select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_OPERATING_METRICS union all select source_table, category, scenario, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_HICV_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_GL_MONTHLY'
        union all
        select 'HICV_FIN_GL_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'ACTUAL', coalesce(sum(iff(category = 'ACTUAL', coalesce(source_amount, stat_value, 0), 0)), 0)) from (select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, category, scenario, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'HICV' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_GL_MONTHLY'
        union all
        select 'HICV_OPS_KPI_WEEKLY' t, 'CLN' l, object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount), 'BUDGET_AMOUNT', coalesce(sum(budget_amount), 0), 'BUDGET_AMOUNT_NONNULL', count(budget_amount)) o from CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_KPI_WEEKLY
        union all
        select 'HICV_OPS_KPI_WEEKLY', 'STG', object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount), 'BUDGET_AMOUNT', coalesce(sum(budget_amount), 0), 'BUDGET_AMOUNT_NONNULL', count(budget_amount)) from DEV1.STAGING.STG_HICV_KPI_WEEKLY
        union all
        select 'HICV_OPS_KPI_WEEKLY', 'XFRM', object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount), 'BUDGET_AMOUNT', coalesce(sum(budget_amount), 0), 'BUDGET_AMOUNT_NONNULL', count(budget_amount)) from DEV1.TRANSFORMATION.XFRM_HICV_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_KPI_WEEKLY'
        union all
        select 'HICV_OPS_KPI_WEEKLY', 'SEM', object_construct('ROWS', count(*) / 2, 'ACTUAL_AMOUNT', coalesce(sum(iff(metric_name = 'ACTUAL_AMOUNT', value, 0)), 0), 'ACTUAL_AMOUNT_NONNULL', count(iff(metric_name = 'ACTUAL_AMOUNT', value, null)), 'BUDGET_AMOUNT', coalesce(sum(iff(metric_name = 'BUDGET_AMOUNT', value, 0)), 0), 'BUDGET_AMOUNT_NONNULL', count(iff(metric_name = 'BUDGET_AMOUNT', value, null))) from DEV1.SEMANTIC.SEM_AI_PACING where source_lane = 'HICV' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_KPI_WEEKLY'
        union all
        select 'HICV_OPS_TREND_WEEKLY' t, 'CLN' l, object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount), 'BUDGET_AMOUNT', coalesce(sum(budget_amount), 0), 'BUDGET_AMOUNT_NONNULL', count(budget_amount)) o from CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_TREND_WEEKLY
        union all
        select 'HICV_OPS_TREND_WEEKLY', 'STG', object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount), 'BUDGET_AMOUNT', coalesce(sum(budget_amount), 0), 'BUDGET_AMOUNT_NONNULL', count(budget_amount)) from DEV1.STAGING.STG_HICV_TREND_WEEKLY
        union all
        select 'HICV_OPS_TREND_WEEKLY', 'XFRM', object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount), 'BUDGET_AMOUNT', coalesce(sum(budget_amount), 0), 'BUDGET_AMOUNT_NONNULL', count(budget_amount)) from DEV1.TRANSFORMATION.XFRM_HICV_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_TREND_WEEKLY'
        union all
        select 'HICV_OPS_TREND_WEEKLY', 'SEM', object_construct('ROWS', count(*) / 2, 'ACTUAL_AMOUNT', coalesce(sum(iff(metric_name = 'ACTUAL_AMOUNT', value, 0)), 0), 'ACTUAL_AMOUNT_NONNULL', count(iff(metric_name = 'ACTUAL_AMOUNT', value, null)), 'BUDGET_AMOUNT', coalesce(sum(iff(metric_name = 'BUDGET_AMOUNT', value, 0)), 0), 'BUDGET_AMOUNT_NONNULL', count(iff(metric_name = 'BUDGET_AMOUNT', value, null))) from DEV1.SEMANTIC.SEM_AI_PACING where source_lane = 'HICV' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_TREND_WEEKLY'
        union all
        select 'HICV_PACE_RESERVATIONS_WEEKLY' t, 'CLN' l, object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount)) o from CLN.BOX_INVESTMENT_DATA.CLN_HICV_PACE_RESERVATIONS_WEEKLY
        union all
        select 'HICV_PACE_RESERVATIONS_WEEKLY', 'STG', object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount)) from DEV1.STAGING.STG_HICV_RESERVATIONS_WEEKLY
        union all
        select 'HICV_PACE_RESERVATIONS_WEEKLY', 'XFRM', object_construct('ROWS', count(*), 'ACTUAL_AMOUNT', coalesce(sum(actual_amount), 0), 'ACTUAL_AMOUNT_NONNULL', count(actual_amount)) from DEV1.TRANSFORMATION.XFRM_HICV_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_PACE_RESERVATIONS_WEEKLY'
        union all
        select 'HICV_PACE_RESERVATIONS_WEEKLY', 'SEM', object_construct('ROWS', count(*) / 1, 'ACTUAL_AMOUNT', coalesce(sum(iff(metric_name = 'ACTUAL_AMOUNT', value, 0)), 0), 'ACTUAL_AMOUNT_NONNULL', count(iff(metric_name = 'ACTUAL_AMOUNT', value, null))) from DEV1.SEMANTIC.SEM_AI_PACING where source_lane = 'HICV' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_PACE_RESERVATIONS_WEEKLY'
        union all
        select 'HICV_REF_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*), 'ROW_COUNT', coalesce(sum(row_count), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_ACCOUNTS
        union all
        select 'HICV_REF_ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', coalesce(sum(ref_row_count), 0)) from DEV1.STAGING.STG_HICV_ACCOUNTS
        union all
        select 'HICV_REF_PROPERTY_ROOM_KEYS' t, 'CLN' l, object_construct('ROWS', count(*), 'ROOM_KEYS', coalesce(sum(room_keys), 0), 'UNITS', coalesce(sum(units), 0), 'CURRENT_KEYS', coalesce(sum(current_keys), 0), 'BEDROOMS', coalesce(sum(bedrooms), 0), 'IHG_COUNT', coalesce(sum(ihg_count), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_PROPERTY_ROOM_KEYS
        union all
        select 'HICV_REF_PROPERTY_ROOM_KEYS', 'STG', object_construct('ROWS', count(*), 'ROOM_KEYS', coalesce(sum(room_keys), 0), 'UNITS', coalesce(sum(units), 0), 'CURRENT_KEYS', coalesce(sum(current_keys), 0), 'BEDROOMS', coalesce(sum(bedrooms), 0), 'IHG_COUNT', coalesce(sum(ihg_count), 0)) from DEV1.STAGING.STG_HICV_ROOM_KEYS
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
    select 'HICV' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'HICV', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
