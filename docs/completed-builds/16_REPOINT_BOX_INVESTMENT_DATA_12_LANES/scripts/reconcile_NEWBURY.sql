execute immediate $$
-- ============================================================================
-- scripts/reconcile_NEWBURY.sql
-- M6 deliverable (build 16: repointed to the new CLN.BOX_INVESTMENT_DATA names). Read-only. Never deployed.
-- For every in-scope source table of lane NEWBURY: row count (CLN x the stated
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
        select 'CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*) * 3, 'TOTAL', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY
        union all
        select 'CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY', 'STG', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
        union all
        select 'CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY'
        union all
        select 'CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'TOTAL', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'NEWBURY' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY'
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'AMT', coalesce(sum(revenue),0), 'STAT', coalesce(sum(rooms),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET', 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET'
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET', 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'NEWBURY' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET'
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'AMT', coalesce(sum(revenue),0), 'STAT', coalesce(sum(rooms),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL', 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL'
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL', 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'NEWBURY' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL'
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST' t, 'CLN' l, object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST', 'STG', object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST', 'XFRM', object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST'
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS' t, 'CLN' l, object_construct('ROWS', count(*), 'RATE_VALUE', coalesce(sum(rate_value), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS', 'STG', object_construct('ROWS', count(*), 'RATE_VALUE', coalesce(sum(rate_value), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS', 'XFRM', object_construct('ROWS', count(*), 'RATE_VALUE', coalesce(sum(rate_value), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS'
        union all
        select 'CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY' t, 'CLN' l, object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'AVAILABLE_ROOMS', coalesce(sum(available_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY
        union all
        select 'CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY', 'STG', object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'AVAILABLE_ROOMS', coalesce(sum(available_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_1DAY_PICKUP
        union all
        select 'CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY', 'XFRM', object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'AVAILABLE_ROOMS', coalesce(sum(available_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY'
        union all
        select 'CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY' t, 'CLN' l, object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'AVAILABLE_ROOMS', coalesce(sum(available_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY
        union all
        select 'CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY', 'STG', object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'AVAILABLE_ROOMS', coalesce(sum(available_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP
        union all
        select 'CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY', 'XFRM', object_construct('ROWS', count(*), 'ROOMS', coalesce(sum(rooms), 0), 'REVENUE', coalesce(sum(revenue), 0), 'AVAILABLE_ROOMS', coalesce(sum(available_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY'
        union all
        select 'CLN_NEWBURY_BOSTON_REF_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_REF_ACCOUNTS
        union all
        select 'CLN_NEWBURY_BOSTON_REF_ACCOUNTS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_NEWBURY_ACCOUNTS
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO
        union all
        select 'CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO
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
    select 'NEWBURY' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'NEWBURY', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
