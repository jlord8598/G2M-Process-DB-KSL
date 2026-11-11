execute immediate $$
-- ============================================================================
-- scripts/reconcile_UNDER_CANVAS.sql
-- M6 deliverable (build 16: repointed to the new CLN.BOX_INVESTMENT_DATA names). Read-only. Never deployed; parity never sees it.
-- For every source table of lane UNDER_CANVAS, compares row count and the sum of
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
        select 'FIN_GL_DETAIL_REVENUE' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', coalesce(sum(actual_amount), 0), 'STAT', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE
        union all
        select 'FIN_GL_DETAIL_REVENUE', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE
        union all
        select 'FIN_GL_DETAIL_OPEX' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', coalesce(sum(actual_amount), 0), 'STAT', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_OPEX
        union all
        select 'FIN_GL_DETAIL_OPEX', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES
        union all
        select 'FIN_GL_DETAIL_NON_OPEX' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', coalesce(sum(actual_amount), 0), 'STAT', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_NON_OPEX
        union all
        select 'FIN_GL_DETAIL_NON_OPEX', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES
        union all
        select 'OPS_STATS_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', 0, 'STAT', coalesce(sum(actual_amount), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_OPS_STATS_MONTHLY
        union all
        select 'OPS_STATS_MONTHLY', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS
        union all
        select 'FIN_PL_SUMMARY' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', coalesce(sum(iff(line_item in ('Days Open', '# of Tents/Rooms', 'Rooms Available', 'Rooms Sold', 'Occupancy %', 'Average Daily Rate', 'Revenue per Available Room', 'Operating CPORs', 'Non-Operating CPORs', 'Adjusted GOP %', 'Adjusted EBITDA Margin %'), 0, actual_amount)), 0), 'STAT', coalesce(sum(iff(line_item in ('Days Open', '# of Tents/Rooms', 'Rooms Available', 'Rooms Sold', 'Occupancy %', 'Average Daily Rate', 'Revenue per Available Room', 'Operating CPORs', 'Non-Operating CPORs', 'Adjusted GOP %', 'Adjusted EBITDA Margin %'), actual_amount, 0)), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_PL_SUMMARY
        union all
        select 'FIN_PL_SUMMARY', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL
        union all
        select split_part(source_table, 'CLN_UNDER_CANVAS_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN) group by source_table
        union all
        select split_part(source_table, 'CLN_UNDER_CANVAS_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'UNDER_CANVAS' group by source_table
        union all
        select 'PACE_OTB_WEEKLY' t, 'CLN' l, object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', coalesce(sum(today_rooms_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT', coalesce(sum(today_room_revenue_commit), 0), 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(today_rooms_commit_pickup_7_day), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), 'STLY_DATE_ROOMS_COMMIT', coalesce(sum(stly_date_rooms_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(stly_date_room_revenue_commit), 0), 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOMS_COMMIT', coalesce(sum(final_ly_date_rooms_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_date_room_revenue_commit), 0), 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), 'ST2Y_DATE_ROOMS_COMMIT', coalesce(sum(st2y_date_rooms_commit), 0), 'ST2Y_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(st2y_date_room_revenue_commit), 0), 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY
        union all
        select 'PACE_OTB_WEEKLY', 'STG', object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', coalesce(sum(today_rooms_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT', coalesce(sum(today_room_revenue_commit), 0), 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(today_rooms_commit_pickup_7_day), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), 'STLY_DATE_ROOMS_COMMIT', coalesce(sum(stly_date_rooms_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(stly_date_room_revenue_commit), 0), 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOMS_COMMIT', coalesce(sum(final_ly_date_rooms_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_date_room_revenue_commit), 0), 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), 'ST2Y_DATE_ROOMS_COMMIT', coalesce(sum(st2y_date_rooms_commit), 0), 'ST2Y_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(st2y_date_room_revenue_commit), 0), 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_WEEKLY_PACE
        union all
        select 'PACE_OTB_WEEKLY', 'XFRM', object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', coalesce(sum(today_rooms_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT', coalesce(sum(today_room_revenue_commit), 0), 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(today_rooms_commit_pickup_7_day), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), 'STLY_DATE_ROOMS_COMMIT', coalesce(sum(stly_date_rooms_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(stly_date_room_revenue_commit), 0), 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOMS_COMMIT', coalesce(sum(final_ly_date_rooms_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_date_room_revenue_commit), 0), 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), 'ST2Y_DATE_ROOMS_COMMIT', coalesce(sum(st2y_date_rooms_commit), 0), 'ST2Y_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(st2y_date_room_revenue_commit), 0), 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY'
        union all
        select 'PACE_OTB_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', coalesce(sum(today_rooms_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT', coalesce(sum(today_room_revenue_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(today_room_revenue_commit_pickup_28_day), 0), 'STLY_DOW_ROOMS_COMMIT', coalesce(sum(stly_dow_rooms_commit), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT', coalesce(sum(stly_dow_room_revenue_commit), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_dow_room_revenue_commit_pickup_7_day), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(stly_dow_room_revenue_commit_pickup_28_day), 0), 'FINAL_LY_DOW_ROOMS_COMMIT', coalesce(sum(final_ly_dow_rooms_commit), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_dow_room_revenue_commit), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_28_day), 0), 'STLY_DATE_ROOMS_COMMIT', coalesce(sum(stly_date_rooms_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(stly_date_room_revenue_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_28_day), 0), 'FINAL_LY_DATE_ROOMS_COMMIT', coalesce(sum(final_ly_date_rooms_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_date_room_revenue_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_28_day), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY
        union all
        select 'PACE_OTB_MONTHLY', 'STG', object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', coalesce(sum(today_rooms_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT', coalesce(sum(today_room_revenue_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(today_room_revenue_commit_pickup_28_day), 0), 'STLY_DOW_ROOMS_COMMIT', coalesce(sum(stly_dow_rooms_commit), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT', coalesce(sum(stly_dow_room_revenue_commit), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_dow_room_revenue_commit_pickup_7_day), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(stly_dow_room_revenue_commit_pickup_28_day), 0), 'FINAL_LY_DOW_ROOMS_COMMIT', coalesce(sum(final_ly_dow_rooms_commit), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_dow_room_revenue_commit), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_28_day), 0), 'STLY_DATE_ROOMS_COMMIT', coalesce(sum(stly_date_rooms_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(stly_date_room_revenue_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_28_day), 0), 'FINAL_LY_DATE_ROOMS_COMMIT', coalesce(sum(final_ly_date_rooms_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_date_room_revenue_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_28_day), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_DUETTO_DATA
        union all
        select 'PACE_OTB_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'TODAY_ROOMS_COMMIT', coalesce(sum(today_rooms_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT', coalesce(sum(today_room_revenue_commit), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(today_room_revenue_commit_pickup_28_day), 0), 'STLY_DOW_ROOMS_COMMIT', coalesce(sum(stly_dow_rooms_commit), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT', coalesce(sum(stly_dow_room_revenue_commit), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_dow_room_revenue_commit_pickup_7_day), 0), 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(stly_dow_room_revenue_commit_pickup_28_day), 0), 'FINAL_LY_DOW_ROOMS_COMMIT', coalesce(sum(final_ly_dow_rooms_commit), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_dow_room_revenue_commit), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_28_day), 0), 'STLY_DATE_ROOMS_COMMIT', coalesce(sum(stly_date_rooms_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(stly_date_room_revenue_commit), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(stly_date_room_revenue_commit_pickup_28_day), 0), 'FINAL_LY_DATE_ROOMS_COMMIT', coalesce(sum(final_ly_date_rooms_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', coalesce(sum(final_ly_date_room_revenue_commit), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', coalesce(sum(final_ly_date_room_revenue_commit_pickup_28_day), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY'
        union all
        select 'PACE_CANCELLATIONS_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*), 'TODAY_CANCELED_REVENUE', coalesce(sum(today_canceled_revenue), 0), 'TODAY_CANCELED_ROOMS', coalesce(sum(today_canceled_rooms), 0), 'STLY_CANCELED_REVENUE', coalesce(sum(stly_canceled_revenue), 0), 'STLY_CANCELED_ROOMS', coalesce(sum(stly_canceled_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY
        union all
        select 'PACE_CANCELLATIONS_MONTHLY', 'STG', object_construct('ROWS', count(*), 'TODAY_CANCELED_REVENUE', coalesce(sum(today_canceled_revenue), 0), 'TODAY_CANCELED_ROOMS', coalesce(sum(today_canceled_rooms), 0), 'STLY_CANCELED_REVENUE', coalesce(sum(stly_canceled_revenue), 0), 'STLY_CANCELED_ROOMS', coalesce(sum(stly_canceled_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CANCELLATIONS
        union all
        select 'PACE_CANCELLATIONS_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'TODAY_CANCELED_REVENUE', coalesce(sum(today_canceled_revenue), 0), 'TODAY_CANCELED_ROOMS', coalesce(sum(today_canceled_rooms), 0), 'STLY_CANCELED_REVENUE', coalesce(sum(stly_canceled_revenue), 0), 'STLY_CANCELED_ROOMS', coalesce(sum(stly_canceled_rooms), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY'
        union all
        select 'REF_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_REF_ACCOUNTS
        union all
        select 'REF_ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_ACCOUNTS
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
    select 'UNDER_CANVAS' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'UNDER_CANVAS', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
