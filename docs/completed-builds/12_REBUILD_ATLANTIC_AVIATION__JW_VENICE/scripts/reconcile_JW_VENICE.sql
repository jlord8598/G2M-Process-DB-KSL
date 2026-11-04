execute immediate $$
-- ============================================================================
-- scripts/reconcile_JW_VENICE.sql
-- M6 deliverable (build 11, new lane; build 12, D-44 rebuild). Read-only. Never deployed; parity never sees it.
-- For every source table of lane JW_VENICE, compares row count and the sum of
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
--   FCAST_ACT_FORECAST, FCAST_BY_PERIOD  wide, 2 branches: ROWS = count(*) x 2;
--              ACTUAL_/FORECAST_AMOUNT -> SOURCE_AMOUNT (AMT), or STAT_VALUE (STAT)
--              for SECTION KEY STATISTICS except CREDIT CARD EXPENSE.
--   FTE, HEADCOUNT  wide, 4 branches: ROWS = count(*) x 4; ACTUAL_/FORECAST_/
--              PREVIOUS_FORECAST_/BUDGET_AMOUNT -> STAT_VALUE (STAT).
--   MONTHLY_PL_DEPT  wide, 2 branches (build 12): ROWS = count(*) x 2;
--              ACTUAL_/BUDGET_AMOUNT -> STAT_VALUE (STAT) where the staging
--              rule says STATISTIC (98xxxx hours accounts, 4-digit statistic
--              codes, the named statistic lines), else SOURCE_AMOUNT (AMT).
--              FORECAST_AMOUNT is null on every row and has no branch.
--   CAPEX      out of scope (Q-05; build 12 Q-08): not staged, not reconciled.
-- The lane has no pacing source: XFRM_JW_VENICE_PACING is empty by design (M1).
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
        -- FCAST_ACT_FORECAST
        select 'FCAST_ACT_FORECAST' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'AMT', sum(iff((section = 'KEY STATISTICS' and line_item <> 'CREDIT CARD EXPENSE'), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0))), 'STAT', sum(iff((section = 'KEY STATISTICS' and line_item <> 'CREDIT CARD EXPENSE'), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST
        union all
        select 'FCAST_ACT_FORECAST', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
        union all
        -- FCAST_BY_PERIOD
        select 'FCAST_BY_PERIOD' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'AMT', sum(iff((section = 'KEY STATISTICS' and line_item <> 'CREDIT CARD EXPENSE'), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0))), 'STAT', sum(iff((section = 'KEY STATISTICS' and line_item <> 'CREDIT CARD EXPENSE'), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD
        union all
        select 'FCAST_BY_PERIOD', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
        union all
        -- FTE
        select 'FTE' t, 'CLN' l, object_construct('ROWS', count(*) * 4, 'AMT', 0, 'STAT', sum(coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(previous_forecast_amount, 0) + coalesce(budget_amount, 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE
        union all
        select 'FTE', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_FTE
        union all
        -- HEADCOUNT
        select 'HEADCOUNT' t, 'CLN' l, object_construct('ROWS', count(*) * 4, 'AMT', 0, 'STAT', sum(coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(previous_forecast_amount, 0) + coalesce(budget_amount, 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT
        union all
        select 'HEADCOUNT', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT
        union all
        -- MONTHLY_PL_DEPT (build 12)
        select 'MONTHLY_PL_DEPT' t, 'CLN' l, object_construct('ROWS', count(*) * 2, 'AMT', sum(iff((regexp_like(split_part(line_item, ' | ', 1), '98[0-9]{4}') or regexp_like(split_part(line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?') or line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House')), 0, coalesce(actual_amount, 0) + coalesce(budget_amount, 0))), 'STAT', sum(iff((regexp_like(split_part(line_item, ' | ', 1), '98[0-9]{4}') or regexp_like(split_part(line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?') or line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House')), coalesce(actual_amount, 0) + coalesce(budget_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT
        union all
        select 'MONTHLY_PL_DEPT', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, 'CLN_JW_VENICE_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, 'CLN_JW_VENICE_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'JW_VENICE'
        group by source_table
        union all
        -- dictionary ACCOUNTS
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_JW_VENICE_ACCOUNTS
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
