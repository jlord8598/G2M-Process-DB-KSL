execute immediate $$
-- ============================================================================
-- scripts/reconcile_ALTERRA.sql
-- M6 deliverable (build 11, new lane). Read-only. Never deployed; parity never sees it.
-- For every source table of lane ALTERRA, compares row count and the sum of
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
--   MONTHLY_FINANCIALS  wide by category, 3 branches: CLN ROWS = count(*) x 3;
--              ACTUAL_/FORECAST_/BUDGET_AMOUNT -> SOURCE_AMOUNT (AMT), or STAT_VALUE
--              (STAT) where SECTION is Skier Visits or KPIs. The D-48 losing
--              rows (Ski Butlers "Alterra Resorts") sit in UNKNOWN and are
--              counted there, so CLN = XFRM = SEM still holds.
--   PACE_BY_STAY_MONTH  long, pacing: CLN = STG = XFRM_ALTERRA_PACING on every
--              numeric column.
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
        -- MONTHLY_FINANCIALS
        select 'MONTHLY_FINANCIALS' t, 'CLN' l, object_construct('ROWS', count(*) * 3, 'AMT', sum(iff(section in ('Skier Visits', 'KPIs'), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0))), 'STAT', sum(iff(section in ('Skier Visits', 'KPIs'), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_MONTHLY_FINANCIALS
        union all
        select 'MONTHLY_FINANCIALS', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, 'CLN_ALTERRA_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, 'CLN_ALTERRA_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'ALTERRA'
        group by source_table
        union all
        -- pacing PACE_BY_STAY_MONTH: CLN, STG and XFRM PACING, every numeric column
        select 'PACE_BY_STAY_MONTH', 'CLN', object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', sum(today_rooms_commit), 'TODAY_ROOM_REVENUE_OTB', sum(today_room_revenue_otb), 'STLY_DOW_ROOMS_COMMIT', sum(stly_dow_rooms_commit), 'STLY_DOW_ROOM_REVENUE_OTB', sum(stly_dow_room_revenue_otb), 'ST2Y_DOW_ROOMS_COMMIT', sum(st2y_dow_rooms_commit), 'ST2Y_DOW_ROOM_REVENUE_OTB', sum(st2y_dow_room_revenue_otb)) from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_BY_STAY_MONTH
        union all
        select 'PACE_BY_STAY_MONTH', 'STG', object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', sum(today_rooms_commit), 'TODAY_ROOM_REVENUE_OTB', sum(today_room_revenue_otb), 'STLY_DOW_ROOMS_COMMIT', sum(stly_dow_rooms_commit), 'STLY_DOW_ROOM_REVENUE_OTB', sum(stly_dow_room_revenue_otb), 'ST2Y_DOW_ROOMS_COMMIT', sum(st2y_dow_rooms_commit), 'ST2Y_DOW_ROOM_REVENUE_OTB', sum(st2y_dow_room_revenue_otb)) from DEV_G2M_AI.STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH
        union all
        select 'PACE_BY_STAY_MONTH', 'XFRM', object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', sum(today_rooms_commit), 'TODAY_ROOM_REVENUE_OTB', sum(today_room_revenue_otb), 'STLY_DOW_ROOMS_COMMIT', sum(stly_dow_rooms_commit), 'STLY_DOW_ROOM_REVENUE_OTB', sum(stly_dow_room_revenue_otb), 'ST2Y_DOW_ROOMS_COMMIT', sum(st2y_dow_rooms_commit), 'ST2Y_DOW_ROOM_REVENUE_OTB', sum(st2y_dow_room_revenue_otb)) from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_PACING
        union all
        -- dictionary ACCOUNTS
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_ALTERRA_ACCOUNTS
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
    select 'ALTERRA' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'ALTERRA', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
