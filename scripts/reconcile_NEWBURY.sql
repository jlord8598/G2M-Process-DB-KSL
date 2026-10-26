execute immediate $$
-- ============================================================================
-- scripts/reconcile_NEWBURY.sql
-- M6 deliverable (rerun unchanged in build 07; source columns unchanged). Read-only. Never deployed; parity never sees it.
-- For every source table of lane NEWBURY, compares row count and the sum of
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
--   TRIAL_BALANCE  wide, 3 columns unpivoted: CLN ROWS = count(*) x 3;
--                  ACTUAL_, FORECAST_, BUDGET_AMOUNT on VALUE_TYPE Amount ->
--                  SOURCE_AMOUNT (AMT), on VALUE_TYPE STAT -> STAT_VALUE (STAT)
--   OPERATING_STATS_BGT, _PYACT  REVENUE -> SOURCE_AMOUNT (AMT),
--                  ROOMS -> STAT_VALUE (STAT) (D-29)
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
        -- TRIAL_BALANCE -----------------------------------------------------
        select 'TRIAL_BALANCE' t, 'CLN' l, object_construct('ROWS', count(*) * 3, 'AMT', sum(iff(upper(trim(value_type)) = 'STAT', 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0))), 'STAT', sum(iff(upper(trim(value_type)) = 'STAT', coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE
        union all
        select 'TRIAL_BALANCE', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
        union all
        -- OPERATING_STATS_BGT -----------------------------------------------
        select 'OPERATING_STATS_BGT' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', sum(revenue), 'STAT', sum(rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT
        union all
        select 'OPERATING_STATS_BGT', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value), 'SOURCE_ROW_NUMBER', sum(source_row_number))
        from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
        union all
        -- OPERATING_STATS_PYACT ---------------------------------------------
        select 'OPERATING_STATS_PYACT' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', sum(revenue), 'STAT', sum(rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT
        union all
        select 'OPERATING_STATS_PYACT', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value), 'SOURCE_ROW_NUMBER', sum(source_row_number))
        from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
        union all
        -- facts in XFRM, four H1-routed streams, by source table --------------
        select split_part(source_table, 'CLN_NEWBURY_BOSTON_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table ----------------
        select split_part(source_table, 'CLN_NEWBURY_BOSTON_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'NEWBURY'
        group by source_table
        union all
        -- pacing OPERATING_STATS_FCST ---------------------------------------
        select 'OPERATING_STATS_FCST', 'CLN', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST
        union all
        select 'OPERATING_STATS_FCST', 'STG', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST
        union all
        select 'OPERATING_STATS_FCST', 'XFRM', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST'
        union all
        -- pacing OPERATING_STATS_SHOPS --------------------------------------
        select 'OPERATING_STATS_SHOPS', 'CLN', object_construct('ROWS', count(*), 'RATE_VALUE', sum(rate_value), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS
        union all
        select 'OPERATING_STATS_SHOPS', 'STG', object_construct('ROWS', count(*), 'RATE_VALUE', sum(rate_value), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS
        union all
        select 'OPERATING_STATS_SHOPS', 'XFRM', object_construct('ROWS', count(*), 'RATE_VALUE', sum(rate_value), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS'
        union all
        -- pacing OTB_1DAY_PICKUP --------------------------------------------
        select 'OTB_1DAY_PICKUP', 'CLN', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'AVAILABLE_ROOMS', sum(available_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP
        union all
        select 'OTB_1DAY_PICKUP', 'STG', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'AVAILABLE_ROOMS', sum(available_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_1DAY_PICKUP
        union all
        select 'OTB_1DAY_PICKUP', 'XFRM', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'AVAILABLE_ROOMS', sum(available_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP'
        union all
        -- pacing OTB_3DAY_PICKUP --------------------------------------------
        select 'OTB_3DAY_PICKUP', 'CLN', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'AVAILABLE_ROOMS', sum(available_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP
        union all
        select 'OTB_3DAY_PICKUP', 'STG', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'AVAILABLE_ROOMS', sum(available_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP
        union all
        select 'OTB_3DAY_PICKUP', 'XFRM', object_construct('ROWS', count(*), 'ROOMS', sum(rooms), 'REVENUE', sum(revenue), 'AVAILABLE_ROOMS', sum(available_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP'
        union all
        -- dictionary ACCOUNTS -----------------------------------------------
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_NEWBURY_ACCOUNTS
        union all
        -- dictionary OPERATING_STATS_EVENTSANDOOO ---------------------------
        select 'OPERATING_STATS_EVENTSANDOOO', 'CLN', object_construct('ROWS', count(*), 'OUT_OF_ORDER_ROOMS', sum(out_of_order_rooms), 'OVERBOOK_ROOMS', sum(overbook_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO
        union all
        select 'OPERATING_STATS_EVENTSANDOOO', 'STG', object_construct('ROWS', count(*), 'OUT_OF_ORDER_ROOMS', sum(out_of_order_rooms), 'OVERBOOK_ROOMS', sum(overbook_rooms), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO
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
