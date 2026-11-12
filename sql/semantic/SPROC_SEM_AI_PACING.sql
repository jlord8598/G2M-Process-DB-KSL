CREATE OR REPLACE PROCEDURE DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_PACING(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_SEM_AI_PACING  (build 17, D-51)
-- Builds SEMANTIC.SEM_AI_PACING from every lane's XFRM_{LANE}_PACING: one
-- self-contained block per lane between BEGIN LANE / END LANE markers (D-36).
-- Long: one row per pacing row x metric column, UNPIVOT INCLUDE NULLS over the
-- metric columns each source table populates (owner Q-01). VALUE is the cell as
-- stored: never scaled, signed or recomputed. No aggregation.
-- METRIC_NAME is the source column verbatim. METRIC_UNIT / IS_ADDITIVE per the
-- stop 1 mapping: ROOMS and CURRENCY additive; RATE (ADR, AVG_RATE), RATIO
-- (OUTRIGGER occupancy) and PERCENT_CHANGE (THE_PIG *_CHANGE) not additive;
-- BEAUMIER OCCUPANCY* = ROOMS (owner Q-02); KSL / PEREGRINE EVENTS QTY
-- 'COUNT', additive: the source states no unit (owner Q-10, N-43).
-- IS_LATEST_SNAPSHOT: SNAPSHOT_DATE = max per lane, site and source table.
-- Build 19 (owner item 11): JW_VENICE added, two blocks. PACE_OTB_DAILY: DAY
-- grain, OCCUPANCY RATIO not additive (values to 1.99, N-47), room counts ROOMS;
-- SOURCE_LINE_KEY file | row. PACE_SEGMENT_MONTHLY: MONTH grain, VANTAGE =
-- REPORT_BLOCK (OTB / PICK-UP), ROOM_NIGHTS ROOMS, ROOM_REVENUE CURRENCY, ADR RATE
-- not additive; SOURCE_LINE_KEY SNAPSHOT_DATE | REPORT_BLOCK | MARKET_SEGMENT |
-- STAY_MONTH (file | row is not unique on this wide sheet, M3).
-- SNAPSHOT_DATE: BEAUMIER FILE_DATE (Q-02; BUSINESS_DATE in ATTRIBUTES);
-- EVENTS stay = EVENT_DATE, STAY_GRAIN 'EVENT' (Q-04).
-- SOURCE_LINE_KEY: SOURCE_FILE_PATH | SOURCE_ROW_NUMBER (unique, M3); null for
-- KSL_SELECT_SERVICE and PEREGRINE_RESORTS, which have no unique line id
-- (owner Q-08 b, N-42); their LINE_SEQ is carried in ATTRIBUTES.
-- ATTRIBUTES: every other column of the stream as stored (Q-05), RUN_ID and
-- the metric columns excepted.
-- The two WHEREs: NEWBURY CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS stays in XFRM only
-- (owner Q-03); and an all-null cell of a column a table is not declared to
-- populate is not emitted. A table not in the declared list keeps every cell,
-- and a non-null value is always kept, so no stored value is dropped.
-- Columns skipped (all null in the current data, owner Q-01):
--   KSL_SELECT_SERVICE CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS: AMT, AVG_RATE
--   KSL_SELECT_SERVICE CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS: AMT_FOOD, AMT_BEV, AMT_RENT, AMT_RSRC, AMT_MISC, AMT_TOTAL
--   KSL_SELECT_SERVICE CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT: AMT_FOOD, AMT_BEV, AMT_RENT, AMT_RSRC, AMT_MISC, AMT_TOTAL
--   NEWBURY CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST: RATE_VALUE, AVAILABLE_ROOMS
--   NEWBURY CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY: RATE_VALUE
--   NEWBURY CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY: RATE_VALUE
--   PEREGRINE_RESORTS CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS: AMT, AVG_RATE
--   PEREGRINE_RESORTS CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS: AMT_FOOD, AMT_BEV, AMT_RENT, AMT_RSRC, AMT_MISC, AMT_TOTAL
--   PEREGRINE_RESORTS CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT: AMT_FOOD, AMT_BEV, AMT_RENT, AMT_RSRC, AMT_MISC, AMT_TOTAL
--   UNDER_CANVAS CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY: TODAY_ROOMS_COMMIT, TODAY_ROOM_REVENUE_COMMIT, TODAY_ROOMS_COMMIT_PICKUP_7_DAY, TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, STLY_DATE_ROOMS_COMMIT, STLY_DATE_ROOM_REVENUE_COMMIT, STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, FINAL_LY_DATE_ROOMS_COMMIT, FINAL_LY_DATE_ROOM_REVENUE_COMMIT, FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOMS_COMMIT, ST2Y_DATE_ROOM_REVENUE_COMMIT, ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, STLY_DOW_ROOMS_COMMIT, STLY_DOW_ROOM_REVENUE_COMMIT, STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, FINAL_LY_DOW_ROOMS_COMMIT, FINAL_LY_DOW_ROOM_REVENUE_COMMIT, FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY
--   UNDER_CANVAS CLN_UNDER_CANVAS_PACE_OTB_MONTHLY: TODAY_ROOMS_COMMIT_PICKUP_7_DAY, STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOMS_COMMIT, ST2Y_DATE_ROOM_REVENUE_COMMIT, ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, TODAY_CANCELED_REVENUE, TODAY_CANCELED_ROOMS, STLY_CANCELED_REVENUE, STLY_CANCELED_ROOMS
--   UNDER_CANVAS CLN_UNDER_CANVAS_PACE_OTB_WEEKLY: TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, STLY_DOW_ROOMS_COMMIT, STLY_DOW_ROOM_REVENUE_COMMIT, STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, FINAL_LY_DOW_ROOMS_COMMIT, FINAL_LY_DOW_ROOM_REVENUE_COMMIT, FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, TODAY_CANCELED_REVENUE, TODAY_CANCELED_ROOMS, STLY_CANCELED_REVENUE, STLY_CANCELED_ROOMS
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.SEMANTIC.SEM_AI_PACING as
    -- BEGIN LANE ALTERRA
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'TODAY'
            when 'TODAY_ROOM_REVENUE_OTB' then 'TODAY'
            when 'STLY_DOW_ROOMS_COMMIT' then 'STLY_DOW'
            when 'STLY_DOW_ROOM_REVENUE_OTB' then 'STLY_DOW'
            when 'ST2Y_DOW_ROOMS_COMMIT' then 'ST2Y_DOW'
            when 'ST2Y_DOW_ROOM_REVENUE_OTB' then 'ST2Y_DOW'
          end)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_OTB' then 'CURRENCY'
            when 'STLY_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DOW_ROOM_REVENUE_OTB' then 'CURRENCY'
            when 'ST2Y_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'ST2Y_DOW_ROOM_REVENUE_OTB' then 'CURRENCY'
          end)::varchar as metric_unit
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then true
            when 'TODAY_ROOM_REVENUE_OTB' then true
            when 'STLY_DOW_ROOMS_COMMIT' then true
            when 'STLY_DOW_ROOM_REVENUE_OTB' then true
            when 'ST2Y_DOW_ROOMS_COMMIT' then true
            when 'ST2Y_DOW_ROOM_REVENUE_OTB' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_OTB' then 'CURRENCY'
            when 'STLY_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DOW_ROOM_REVENUE_OTB' then 'CURRENCY'
            when 'ST2Y_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'ST2Y_DOW_ROOM_REVENUE_OTB' then 'CURRENCY'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , hotel_name as site
            , null as site_name
            , snapshot_date as snapshot_date
            , 'SNAPSHOT_DATE' as snapshot_source
            , date_trunc('month', stay_month) as stay_period_start
            , stay_month as stay_period_end
            , 'MONTH' as stay_grain
            , market_segment_category as segment
            , 'MARKET_SEGMENT_CATEGORY' as segment_source
            , null as booking_status
            , 'UNCONFIRMED' as currency_code
            , source_file_path || '|' || source_row_number as source_line_key
            , null as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'TODAY_ROOMS_COMMIT', 'TODAY_ROOM_REVENUE_OTB', 'STLY_DOW_ROOMS_COMMIT', 'STLY_DOW_ROOM_REVENUE_OTB', 'ST2Y_DOW_ROOMS_COMMIT', 'ST2Y_DOW_ROOM_REVENUE_OTB') as attributes
            , TODAY_ROOMS_COMMIT::float as TODAY_ROOMS_COMMIT
            , TODAY_ROOM_REVENUE_OTB::float as TODAY_ROOM_REVENUE_OTB
            , STLY_DOW_ROOMS_COMMIT::float as STLY_DOW_ROOMS_COMMIT
            , STLY_DOW_ROOM_REVENUE_OTB::float as STLY_DOW_ROOM_REVENUE_OTB
            , ST2Y_DOW_ROOMS_COMMIT::float as ST2Y_DOW_ROOMS_COMMIT
            , ST2Y_DOW_ROOM_REVENUE_OTB::float as ST2Y_DOW_ROOM_REVENUE_OTB
        from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_PACING
        where 1=1
    ) unpivot include nulls (value for metric_name in (TODAY_ROOMS_COMMIT, TODAY_ROOM_REVENUE_OTB, STLY_DOW_ROOMS_COMMIT, STLY_DOW_ROOM_REVENUE_OTB, ST2Y_DOW_ROOMS_COMMIT, ST2Y_DOW_ROOM_REVENUE_OTB))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY', 'TODAY_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY', 'TODAY_ROOM_REVENUE_OTB'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY', 'STLY_DOW_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY', 'STLY_DOW_ROOM_REVENUE_OTB'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY', 'ST2Y_DOW_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY', 'ST2Y_DOW_ROOM_REVENUE_OTB'))
           or source_table not in ('CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY')
           or value is not null)
    -- END LANE ALTERRA
    union all
    -- BEGIN LANE BEAUMIER
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (case metric_name
            when 'OCCUPANCY' then 'CURRENT'
            when 'ROOMS_REVENUE' then 'CURRENT'
            when 'OCCUPANCY_N_1' then 'N_1'
            when 'ROOMS_REVENUE_N_1' then 'N_1'
            when 'OCCUPANCY_N_2' then 'N_2'
            when 'ROOMS_REVENUE_N_2' then 'N_2'
            when 'OCCUPANCY_N_3' then 'N_3'
            when 'ROOMS_REVENUE_N_3' then 'N_3'
            when 'OCCUPANCY_N_4' then 'N_4'
            when 'ROOMS_REVENUE_N_4' then 'N_4'
            when 'OCCUPANCY_N_5' then 'N_5'
            when 'ROOMS_REVENUE_N_5' then 'N_5'
          end)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'OCCUPANCY' then 'ROOMS'
            when 'ROOMS_REVENUE' then 'ROOMS'
            when 'OCCUPANCY_N_1' then 'ROOMS'
            when 'ROOMS_REVENUE_N_1' then 'ROOMS'
            when 'OCCUPANCY_N_2' then 'ROOMS'
            when 'ROOMS_REVENUE_N_2' then 'ROOMS'
            when 'OCCUPANCY_N_3' then 'ROOMS'
            when 'ROOMS_REVENUE_N_3' then 'ROOMS'
            when 'OCCUPANCY_N_4' then 'ROOMS'
            when 'ROOMS_REVENUE_N_4' then 'ROOMS'
            when 'OCCUPANCY_N_5' then 'ROOMS'
            when 'ROOMS_REVENUE_N_5' then 'ROOMS'
          end)::varchar as metric_unit
        , (case metric_name
            when 'OCCUPANCY' then true
            when 'ROOMS_REVENUE' then true
            when 'OCCUPANCY_N_1' then true
            when 'ROOMS_REVENUE_N_1' then true
            when 'OCCUPANCY_N_2' then true
            when 'ROOMS_REVENUE_N_2' then true
            when 'OCCUPANCY_N_3' then true
            when 'ROOMS_REVENUE_N_3' then true
            when 'OCCUPANCY_N_4' then true
            when 'ROOMS_REVENUE_N_4' then true
            when 'OCCUPANCY_N_5' then true
            when 'ROOMS_REVENUE_N_5' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'OCCUPANCY' then 'ROOMS'
            when 'ROOMS_REVENUE' then 'ROOMS'
            when 'OCCUPANCY_N_1' then 'ROOMS'
            when 'ROOMS_REVENUE_N_1' then 'ROOMS'
            when 'OCCUPANCY_N_2' then 'ROOMS'
            when 'ROOMS_REVENUE_N_2' then 'ROOMS'
            when 'OCCUPANCY_N_3' then 'ROOMS'
            when 'ROOMS_REVENUE_N_3' then 'ROOMS'
            when 'OCCUPANCY_N_4' then 'ROOMS'
            when 'ROOMS_REVENUE_N_4' then 'ROOMS'
            when 'OCCUPANCY_N_5' then 'ROOMS'
            when 'ROOMS_REVENUE_N_5' then 'ROOMS'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , hotel_name as site
            , null as site_name
            , file_date::date as snapshot_date
            , 'FILE_DATE' as snapshot_source
            , date_trunc('month', stay_month) as stay_period_start
            , stay_month as stay_period_end
            , 'MONTH' as stay_grain
            , report_type as segment
            , 'REPORT_TYPE' as segment_source
            , null as booking_status
            , currency as currency_code
            , source_file_path || '|' || source_row_number as source_line_key
            , null as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'OCCUPANCY', 'ROOMS_REVENUE', 'OCCUPANCY_N_1', 'ROOMS_REVENUE_N_1', 'OCCUPANCY_N_2', 'ROOMS_REVENUE_N_2', 'OCCUPANCY_N_3', 'ROOMS_REVENUE_N_3', 'OCCUPANCY_N_4', 'ROOMS_REVENUE_N_4', 'OCCUPANCY_N_5', 'ROOMS_REVENUE_N_5') as attributes
            , OCCUPANCY::float as OCCUPANCY
            , ROOMS_REVENUE::float as ROOMS_REVENUE
            , OCCUPANCY_N_1::float as OCCUPANCY_N_1
            , ROOMS_REVENUE_N_1::float as ROOMS_REVENUE_N_1
            , OCCUPANCY_N_2::float as OCCUPANCY_N_2
            , ROOMS_REVENUE_N_2::float as ROOMS_REVENUE_N_2
            , OCCUPANCY_N_3::float as OCCUPANCY_N_3
            , ROOMS_REVENUE_N_3::float as ROOMS_REVENUE_N_3
            , OCCUPANCY_N_4::float as OCCUPANCY_N_4
            , ROOMS_REVENUE_N_4::float as ROOMS_REVENUE_N_4
            , OCCUPANCY_N_5::float as OCCUPANCY_N_5
            , ROOMS_REVENUE_N_5::float as ROOMS_REVENUE_N_5
        from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_PACING
        where 1=1
    ) unpivot include nulls (value for metric_name in (OCCUPANCY, ROOMS_REVENUE, OCCUPANCY_N_1, ROOMS_REVENUE_N_1, OCCUPANCY_N_2, ROOMS_REVENUE_N_2, OCCUPANCY_N_3, ROOMS_REVENUE_N_3, OCCUPANCY_N_4, ROOMS_REVENUE_N_4, OCCUPANCY_N_5, ROOMS_REVENUE_N_5))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'OCCUPANCY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'ROOMS_REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'OCCUPANCY_N_1'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'ROOMS_REVENUE_N_1'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'OCCUPANCY_N_2'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'ROOMS_REVENUE_N_2'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'OCCUPANCY_N_3'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'ROOMS_REVENUE_N_3'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'OCCUPANCY_N_4'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'ROOMS_REVENUE_N_4'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'OCCUPANCY_N_5'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 'ROOMS_REVENUE_N_5'))
           or source_table not in ('CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY')
           or value is not null)
    -- END LANE BEAUMIER
    union all
    -- BEGIN LANE JW_VENICE
    -- block 1: CLN_JW_VENICE_PACE_OTB_DAILY (OTB by stay date; no vantage column)
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , vantage_src::varchar              as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'OCCUPANCY' then 'RATIO'
            when 'ROOMS_TRANSIENT' then 'ROOMS'
            when 'ROOMS_GROUP_DEDUCT' then 'ROOMS'
            when 'ROOMS_COMP_HOUSE' then 'ROOMS'
            when 'ROOMS_TOTAL' then 'ROOMS'
          end)::varchar as metric_unit
        , (case metric_name
            when 'OCCUPANCY' then false
            when 'ROOMS_TRANSIENT' then true
            when 'ROOMS_GROUP_DEDUCT' then true
            when 'ROOMS_COMP_HOUSE' then true
            when 'ROOMS_TOTAL' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'OCCUPANCY' then 'RATIO'
            when 'ROOMS_TRANSIENT' then 'ROOMS'
            when 'ROOMS_GROUP_DEDUCT' then 'ROOMS'
            when 'ROOMS_COMP_HOUSE' then 'ROOMS'
            when 'ROOMS_TOTAL' then 'ROOMS'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , property_name as site
            , null as site_name
            , snapshot_date as snapshot_date
            , 'SNAPSHOT_DATE' as snapshot_source
            , stay_date as stay_period_start
            , stay_date as stay_period_end
            , 'DAY' as stay_grain
            , null as segment
            , null as segment_source
            , null as vantage_src
            , source_file_path || '|' || source_row_number as source_line_key
            , null as booking_status
            , 'USD' as currency_code
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'OCCUPANCY', 'ROOMS_TRANSIENT', 'ROOMS_GROUP_DEDUCT', 'ROOMS_COMP_HOUSE', 'ROOMS_TOTAL') as attributes
            , OCCUPANCY::float as OCCUPANCY
            , ROOMS_TRANSIENT::float as ROOMS_TRANSIENT
            , ROOMS_GROUP_DEDUCT::float as ROOMS_GROUP_DEDUCT
            , ROOMS_COMP_HOUSE::float as ROOMS_COMP_HOUSE
            , ROOMS_TOTAL::float as ROOMS_TOTAL
        from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING
        where 1=1
          -- this block reads only its own table's rows (the other block reads the rest)
          and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_PACE_OTB_DAILY'
    ) unpivot include nulls (value for metric_name in (OCCUPANCY, ROOMS_TRANSIENT, ROOMS_GROUP_DEDUCT, ROOMS_COMP_HOUSE, ROOMS_TOTAL))
    where 1=1
    union all
    -- block 2: CLN_JW_VENICE_PACE_SEGMENT_MONTHLY (VANTAGE = REPORT_BLOCK, OTB / PICK-UP)
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , vantage_src::varchar              as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'ROOM_NIGHTS' then 'ROOMS'
            when 'ROOM_REVENUE' then 'CURRENCY'
            when 'ADR' then 'RATE'
          end)::varchar as metric_unit
        , (case metric_name
            when 'ROOM_NIGHTS' then true
            when 'ROOM_REVENUE' then true
            when 'ADR' then false
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'ROOM_NIGHTS' then 'ROOMS'
            when 'ROOM_REVENUE' then 'CURRENCY'
            when 'ADR' then 'RATE'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , property_name as site
            , null as site_name
            , snapshot_date as snapshot_date
            , 'SNAPSHOT_DATE' as snapshot_source
            , date_trunc('month', stay_month) as stay_period_start
            , stay_month as stay_period_end
            , 'MONTH' as stay_grain
            , market_segment as segment
            , 'MARKET_SEGMENT' as segment_source
            , report_block as vantage_src
            , snapshot_date || '|' || report_block || '|' || market_segment || '|' || stay_month as source_line_key
            , null as booking_status
            , 'USD' as currency_code
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'ROOM_NIGHTS', 'ROOM_REVENUE', 'ADR') as attributes
            , ROOM_NIGHTS::float as ROOM_NIGHTS
            , ROOM_REVENUE::float as ROOM_REVENUE
            , ADR::float as ADR
        from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING
        where 1=1
          -- this block reads only its own table's rows (the other block reads the rest)
          and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_PACE_SEGMENT_MONTHLY'
    ) unpivot include nulls (value for metric_name in (ROOM_NIGHTS, ROOM_REVENUE, ADR))
    where 1=1
    -- END LANE JW_VENICE
    union all
    
-- BEGIN LANE KSL_SELECT_SERVICE
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (null)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'QTY' then iff(stay_grain = 'EVENT', 'COUNT', 'ROOMS')
            when 'AMT' then 'CURRENCY'
            when 'AVG_RATE' then 'RATE'
            when 'AMT_FOOD' then 'CURRENCY'
            when 'AMT_BEV' then 'CURRENCY'
            when 'AMT_RENT' then 'CURRENCY'
            when 'AMT_RSRC' then 'CURRENCY'
            when 'AMT_MISC' then 'CURRENCY'
            when 'AMT_TOTAL' then 'CURRENCY'
          end)::varchar as metric_unit
        , (case metric_name
            when 'QTY' then true
            when 'AMT' then true
            when 'AVG_RATE' then false
            when 'AMT_FOOD' then true
            when 'AMT_BEV' then true
            when 'AMT_RENT' then true
            when 'AMT_RSRC' then true
            when 'AMT_MISC' then true
            when 'AMT_TOTAL' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'QTY' then iff(stay_grain = 'EVENT', 'COUNT', 'ROOMS')
            when 'AMT' then 'CURRENCY'
            when 'AVG_RATE' then 'RATE'
            when 'AMT_FOOD' then 'CURRENCY'
            when 'AMT_BEV' then 'CURRENCY'
            when 'AMT_RENT' then 'CURRENCY'
            when 'AMT_RSRC' then 'CURRENCY'
            when 'AMT_MISC' then 'CURRENCY'
            when 'AMT_TOTAL' then 'CURRENCY'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , site_tag as site
            , site_name as site_name
            , as_of_date as snapshot_date
            , 'AS_OF_DATE' as snapshot_source
            , coalesce(occupancy_date, event_date) as stay_period_start
            , coalesce(occupancy_date, event_date) as stay_period_end
            , iff(occupancy_date is null, 'EVENT', 'DAY') as stay_grain
            , market_segment_code as segment
            , 'MARKET_SEGMENT_CODE' as segment_source
            , status as booking_status
            , 'USD' as currency_code
            , null as source_line_key
            , null as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'QTY', 'AMT', 'AVG_RATE', 'AMT_FOOD', 'AMT_BEV', 'AMT_RENT', 'AMT_RSRC', 'AMT_MISC', 'AMT_TOTAL') as attributes
            , QTY::float as QTY
            , AMT::float as AMT
            , AVG_RATE::float as AVG_RATE
            , AMT_FOOD::float as AMT_FOOD
            , AMT_BEV::float as AMT_BEV
            , AMT_RENT::float as AMT_RENT
            , AMT_RSRC::float as AMT_RSRC
            , AMT_MISC::float as AMT_MISC
            , AMT_TOTAL::float as AMT_TOTAL
        from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING
        where 1=1
    ) unpivot include nulls (value for metric_name in (QTY, AMT, AVG_RATE, AMT_FOOD, AMT_BEV, AMT_RENT, AMT_RSRC, AMT_MISC, AMT_TOTAL))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'QTY'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'AMT_FOOD'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'AMT_BEV'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'AMT_RENT'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'AMT_RSRC'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'AMT_MISC'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'AMT_TOTAL'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS', 'QTY'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS', 'AMT'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS', 'AVG_RATE'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT', 'QTY'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT', 'AMT'),
              ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT', 'AVG_RATE'))
           or source_table not in ('CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS', 'CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS', 'CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT')
           or value is not null)
    -- END LANE KSL_SELECT_SERVICE
    union all
    -- BEGIN LANE NEWBURY
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (vantage_src)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'ROOMS' then 'ROOMS'
            when 'REVENUE' then 'CURRENCY'
            when 'AVAILABLE_ROOMS' then 'ROOMS'
          end)::varchar as metric_unit
        , (case metric_name
            when 'ROOMS' then true
            when 'REVENUE' then true
            when 'AVAILABLE_ROOMS' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'ROOMS' then 'ROOMS'
            when 'REVENUE' then 'CURRENCY'
            when 'AVAILABLE_ROOMS' then 'ROOMS'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , hotel_id as site
            , hotel_name as site_name
            , coalesce(report_date, file_report_date) as snapshot_date
            , iff(report_date is not null, 'REPORT_DATE', 'FILE_REPORT_DATE') as snapshot_source
            , stay_date as stay_period_start
            , stay_date as stay_period_end
            , 'DAY' as stay_grain
            , market_segment as segment
            , 'MARKET_SEGMENT' as segment_source
            , null as booking_status
            , 'USD' as currency_code
            , source_file_path || '|' || source_row_number as source_line_key
            , coalesce(data_type, scenario) as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'RATE_VALUE', 'ROOMS', 'REVENUE', 'AVAILABLE_ROOMS') as attributes
            , ROOMS::float as ROOMS
            , REVENUE::float as REVENUE
            , AVAILABLE_ROOMS::float as AVAILABLE_ROOMS
        from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING
        where 1=1
        and source_table <> 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS'  -- owner Q-03 (build 17): rate shops stay in XFRM only
    ) unpivot include nulls (value for metric_name in (ROOMS, REVENUE, AVAILABLE_ROOMS))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST', 'ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST', 'REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY', 'ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY', 'REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY', 'AVAILABLE_ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY', 'ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY', 'REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY', 'AVAILABLE_ROOMS'))
           or source_table not in ('CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST', 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY', 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY')
           or value is not null)
    -- END LANE NEWBURY
    union all
    -- BEGIN LANE OUTRIGGER
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (case metric_name
            when 'CY_PACE_OCCUPANCY' then 'CY_PACE'
            when 'CY_PACE_ROOMS' then 'CY_PACE'
            when 'CY_PACE_ADR' then 'CY_PACE'
            when 'CY_PACE_REVENUE' then 'CY_PACE'
            when 'LY_PACE_OCCUPANCY' then 'LY_PACE'
            when 'LY_PACE_ROOMS' then 'LY_PACE'
            when 'LY_PACE_ADR' then 'LY_PACE'
            when 'LY_PACE_REVENUE' then 'LY_PACE'
            when 'FORECAST_OCCUPANCY' then 'FORECAST'
            when 'FORECAST_ROOMS' then 'FORECAST'
            when 'FORECAST_ADR' then 'FORECAST'
            when 'FORECAST_REVENUE' then 'FORECAST'
            when 'BUDGET_OCCUPANCY' then 'BUDGET'
            when 'BUDGET_ROOMS' then 'BUDGET'
            when 'BUDGET_ADR' then 'BUDGET'
            when 'BUDGET_REVENUE' then 'BUDGET'
          end)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'CY_PACE_OCCUPANCY' then 'RATIO'
            when 'CY_PACE_ROOMS' then 'ROOMS'
            when 'CY_PACE_ADR' then 'RATE'
            when 'CY_PACE_REVENUE' then 'CURRENCY'
            when 'LY_PACE_OCCUPANCY' then 'RATIO'
            when 'LY_PACE_ROOMS' then 'ROOMS'
            when 'LY_PACE_ADR' then 'RATE'
            when 'LY_PACE_REVENUE' then 'CURRENCY'
            when 'FORECAST_OCCUPANCY' then 'RATIO'
            when 'FORECAST_ROOMS' then 'ROOMS'
            when 'FORECAST_ADR' then 'RATE'
            when 'FORECAST_REVENUE' then 'CURRENCY'
            when 'BUDGET_OCCUPANCY' then 'RATIO'
            when 'BUDGET_ROOMS' then 'ROOMS'
            when 'BUDGET_ADR' then 'RATE'
            when 'BUDGET_REVENUE' then 'CURRENCY'
          end)::varchar as metric_unit
        , (case metric_name
            when 'CY_PACE_OCCUPANCY' then false
            when 'CY_PACE_ROOMS' then true
            when 'CY_PACE_ADR' then false
            when 'CY_PACE_REVENUE' then true
            when 'LY_PACE_OCCUPANCY' then false
            when 'LY_PACE_ROOMS' then true
            when 'LY_PACE_ADR' then false
            when 'LY_PACE_REVENUE' then true
            when 'FORECAST_OCCUPANCY' then false
            when 'FORECAST_ROOMS' then true
            when 'FORECAST_ADR' then false
            when 'FORECAST_REVENUE' then true
            when 'BUDGET_OCCUPANCY' then false
            when 'BUDGET_ROOMS' then true
            when 'BUDGET_ADR' then false
            when 'BUDGET_REVENUE' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'CY_PACE_OCCUPANCY' then 'RATIO'
            when 'CY_PACE_ROOMS' then 'ROOMS'
            when 'CY_PACE_ADR' then 'RATE'
            when 'CY_PACE_REVENUE' then 'CURRENCY'
            when 'LY_PACE_OCCUPANCY' then 'RATIO'
            when 'LY_PACE_ROOMS' then 'ROOMS'
            when 'LY_PACE_ADR' then 'RATE'
            when 'LY_PACE_REVENUE' then 'CURRENCY'
            when 'FORECAST_OCCUPANCY' then 'RATIO'
            when 'FORECAST_ROOMS' then 'ROOMS'
            when 'FORECAST_ADR' then 'RATE'
            when 'FORECAST_REVENUE' then 'CURRENCY'
            when 'BUDGET_OCCUPANCY' then 'RATIO'
            when 'BUDGET_ROOMS' then 'ROOMS'
            when 'BUDGET_ADR' then 'RATE'
            when 'BUDGET_REVENUE' then 'CURRENCY'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , property_name as site
            , null as site_name
            , snapshot_date as snapshot_date
            , 'SNAPSHOT_DATE' as snapshot_source
            , date_trunc('month', stay_month) as stay_period_start
            , stay_month as stay_period_end
            , 'MONTH' as stay_grain
            , segment as segment
            , 'SEGMENT' as segment_source
            , null as booking_status
            , 'USD' as currency_code
            , source_file_path || '|' || source_row_number as source_line_key
            , null as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'CY_PACE_OCCUPANCY', 'CY_PACE_ROOMS', 'CY_PACE_ADR', 'CY_PACE_REVENUE', 'LY_PACE_OCCUPANCY', 'LY_PACE_ROOMS', 'LY_PACE_ADR', 'LY_PACE_REVENUE', 'FORECAST_OCCUPANCY', 'FORECAST_ROOMS', 'FORECAST_ADR', 'FORECAST_REVENUE', 'BUDGET_OCCUPANCY', 'BUDGET_ROOMS', 'BUDGET_ADR', 'BUDGET_REVENUE') as attributes
            , CY_PACE_OCCUPANCY::float as CY_PACE_OCCUPANCY
            , CY_PACE_ROOMS::float as CY_PACE_ROOMS
            , CY_PACE_ADR::float as CY_PACE_ADR
            , CY_PACE_REVENUE::float as CY_PACE_REVENUE
            , LY_PACE_OCCUPANCY::float as LY_PACE_OCCUPANCY
            , LY_PACE_ROOMS::float as LY_PACE_ROOMS
            , LY_PACE_ADR::float as LY_PACE_ADR
            , LY_PACE_REVENUE::float as LY_PACE_REVENUE
            , FORECAST_OCCUPANCY::float as FORECAST_OCCUPANCY
            , FORECAST_ROOMS::float as FORECAST_ROOMS
            , FORECAST_ADR::float as FORECAST_ADR
            , FORECAST_REVENUE::float as FORECAST_REVENUE
            , BUDGET_OCCUPANCY::float as BUDGET_OCCUPANCY
            , BUDGET_ROOMS::float as BUDGET_ROOMS
            , BUDGET_ADR::float as BUDGET_ADR
            , BUDGET_REVENUE::float as BUDGET_REVENUE
        from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING
        where 1=1
    ) unpivot include nulls (value for metric_name in (CY_PACE_OCCUPANCY, CY_PACE_ROOMS, CY_PACE_ADR, CY_PACE_REVENUE, LY_PACE_OCCUPANCY, LY_PACE_ROOMS, LY_PACE_ADR, LY_PACE_REVENUE, FORECAST_OCCUPANCY, FORECAST_ROOMS, FORECAST_ADR, FORECAST_REVENUE, BUDGET_OCCUPANCY, BUDGET_ROOMS, BUDGET_ADR, BUDGET_REVENUE))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'CY_PACE_OCCUPANCY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'CY_PACE_ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'CY_PACE_ADR'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'CY_PACE_REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'LY_PACE_OCCUPANCY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'LY_PACE_ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'LY_PACE_ADR'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'LY_PACE_REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'FORECAST_OCCUPANCY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'FORECAST_ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'FORECAST_ADR'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'FORECAST_REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'BUDGET_OCCUPANCY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'BUDGET_ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'BUDGET_ADR'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY', 'BUDGET_REVENUE'))
           or source_table not in ('CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY')
           or value is not null)
    -- END LANE OUTRIGGER
    union all
    -- BEGIN LANE PEREGRINE_RESORTS
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (null)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'QTY' then iff(stay_grain = 'EVENT', 'COUNT', 'ROOMS')
            when 'AMT' then 'CURRENCY'
            when 'AVG_RATE' then 'RATE'
            when 'AMT_FOOD' then 'CURRENCY'
            when 'AMT_BEV' then 'CURRENCY'
            when 'AMT_RENT' then 'CURRENCY'
            when 'AMT_RSRC' then 'CURRENCY'
            when 'AMT_MISC' then 'CURRENCY'
            when 'AMT_TOTAL' then 'CURRENCY'
          end)::varchar as metric_unit
        , (case metric_name
            when 'QTY' then true
            when 'AMT' then true
            when 'AVG_RATE' then false
            when 'AMT_FOOD' then true
            when 'AMT_BEV' then true
            when 'AMT_RENT' then true
            when 'AMT_RSRC' then true
            when 'AMT_MISC' then true
            when 'AMT_TOTAL' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'QTY' then iff(stay_grain = 'EVENT', 'COUNT', 'ROOMS')
            when 'AMT' then 'CURRENCY'
            when 'AVG_RATE' then 'RATE'
            when 'AMT_FOOD' then 'CURRENCY'
            when 'AMT_BEV' then 'CURRENCY'
            when 'AMT_RENT' then 'CURRENCY'
            when 'AMT_RSRC' then 'CURRENCY'
            when 'AMT_MISC' then 'CURRENCY'
            when 'AMT_TOTAL' then 'CURRENCY'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , site_tag as site
            , site_name as site_name
            , as_of_date as snapshot_date
            , 'AS_OF_DATE' as snapshot_source
            , coalesce(occupancy_date, event_date) as stay_period_start
            , coalesce(occupancy_date, event_date) as stay_period_end
            , iff(occupancy_date is null, 'EVENT', 'DAY') as stay_grain
            , market_segment_code as segment
            , 'MARKET_SEGMENT_CODE' as segment_source
            , status as booking_status
            , 'USD' as currency_code
            , null as source_line_key
            , null as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'QTY', 'AMT', 'AVG_RATE', 'AMT_FOOD', 'AMT_BEV', 'AMT_RENT', 'AMT_RSRC', 'AMT_MISC', 'AMT_TOTAL') as attributes
            , QTY::float as QTY
            , AMT::float as AMT
            , AVG_RATE::float as AVG_RATE
            , AMT_FOOD::float as AMT_FOOD
            , AMT_BEV::float as AMT_BEV
            , AMT_RENT::float as AMT_RENT
            , AMT_RSRC::float as AMT_RSRC
            , AMT_MISC::float as AMT_MISC
            , AMT_TOTAL::float as AMT_TOTAL
        from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING
        where 1=1
    ) unpivot include nulls (value for metric_name in (QTY, AMT, AVG_RATE, AMT_FOOD, AMT_BEV, AMT_RENT, AMT_RSRC, AMT_MISC, AMT_TOTAL))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'QTY'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'AMT_FOOD'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'AMT_BEV'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'AMT_RENT'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'AMT_RSRC'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'AMT_MISC'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'AMT_TOTAL'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS', 'QTY'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS', 'AMT'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS', 'AVG_RATE'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT', 'QTY'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT', 'AMT'),
              ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT', 'AVG_RATE'))
           or source_table not in ('CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS', 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS', 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT')
           or value is not null)
    -- END LANE PEREGRINE_RESORTS
    union all
    -- BEGIN LANE THE_PIG
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'TODAY'
            when 'TODAY_ROOM_REVENUE_COMMIT' then 'TODAY'
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then 'TODAY'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'TODAY'
            when 'STLY_DATE_ROOMS_COMMIT' then 'STLY_DATE'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then 'STLY_DATE'
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'STLY_DATE'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'STLY_DATE'
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then 'FINAL_LY_DATE'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then 'FINAL_LY_DATE'
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'FINAL_LY_DATE'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'FINAL_LY_DATE'
            when 'ST2Y_DATE_ROOMS_COMMIT' then 'ST2Y_DATE'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then 'ST2Y_DATE'
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ST2Y_DATE'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'ST2Y_DATE'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'TODAY_VS_STLY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'TODAY_VS_FINAL_LY_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF' then 'TODAY_VS_ST2Y_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE' then 'TODAY_VS_ST2Y_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'TODAY_VS_ST2Y_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'TODAY_VS_ST2Y_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'TODAY_VS_ST2Y_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'TODAY_VS_ST2Y_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'TODAY_VS_ST2Y_DATE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'TODAY_VS_ST2Y_DATE'
          end)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF' then 'ROOMS'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'CURRENCY'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'ROOMS'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'CURRENCY'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF' then 'ROOMS'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'CURRENCY'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'ROOMS'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'CURRENCY'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF' then 'ROOMS'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'CURRENCY'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'ROOMS'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'CURRENCY'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
          end)::varchar as metric_unit
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then true
            when 'TODAY_ROOM_REVENUE_COMMIT' then true
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'STLY_DATE_ROOMS_COMMIT' then true
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then true
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then true
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then true
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'ST2Y_DATE_ROOMS_COMMIT' then true
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then true
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF' then true
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE' then false
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF' then true
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then false
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then true
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then false
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then true
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then false
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF' then true
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE' then false
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF' then true
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then false
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then true
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then false
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then true
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then false
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF' then true
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE' then false
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF' then true
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE' then false
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then true
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then false
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then true
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then false
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF' then 'ROOMS'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'CURRENCY'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'ROOMS'
            when 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'CURRENCY'
            when 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF' then 'ROOMS'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'CURRENCY'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'ROOMS'
            when 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'CURRENCY'
            when 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF' then 'ROOMS'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF' then 'CURRENCY'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF' then 'ROOMS'
            when 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF' then 'CURRENCY'
            when 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE' then 'PERCENT_CHANGE'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , hotel_name as site
            , null as site_name
            , snapshot_date as snapshot_date
            , 'SNAPSHOT_DATE' as snapshot_source
            , date_trunc('month', stay_month) as stay_period_start
            , stay_month as stay_period_end
            , 'MONTH' as stay_grain
            , market_segment as segment
            , 'MARKET_SEGMENT' as segment_source
            , null as booking_status
            , 'GBP' as currency_code
            , source_file_path || '|' || source_row_number as source_line_key
            , null as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'TODAY_ROOMS_COMMIT', 'TODAY_ROOM_REVENUE_COMMIT', 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY', 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'STLY_DATE_ROOMS_COMMIT', 'STLY_DATE_ROOM_REVENUE_COMMIT', 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'FINAL_LY_DATE_ROOMS_COMMIT', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'ST2Y_DATE_ROOMS_COMMIT', 'ST2Y_DATE_ROOM_REVENUE_COMMIT', 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY', 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE') as attributes
            , TODAY_ROOMS_COMMIT::float as TODAY_ROOMS_COMMIT
            , TODAY_ROOM_REVENUE_COMMIT::float as TODAY_ROOM_REVENUE_COMMIT
            , TODAY_ROOMS_COMMIT_PICKUP_7_DAY::float as TODAY_ROOMS_COMMIT_PICKUP_7_DAY
            , TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , STLY_DATE_ROOMS_COMMIT::float as STLY_DATE_ROOMS_COMMIT
            , STLY_DATE_ROOM_REVENUE_COMMIT::float as STLY_DATE_ROOM_REVENUE_COMMIT
            , STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY::float as STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY
            , STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , FINAL_LY_DATE_ROOMS_COMMIT::float as FINAL_LY_DATE_ROOMS_COMMIT
            , FINAL_LY_DATE_ROOM_REVENUE_COMMIT::float as FINAL_LY_DATE_ROOM_REVENUE_COMMIT
            , FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY::float as FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY
            , FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , ST2Y_DATE_ROOMS_COMMIT::float as ST2Y_DATE_ROOMS_COMMIT
            , ST2Y_DATE_ROOM_REVENUE_COMMIT::float as ST2Y_DATE_ROOM_REVENUE_COMMIT
            , ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY::float as ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY
            , ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF::float as TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF
            , TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE::float as TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE
            , TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF::float as TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF
            , TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE::float as TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE
            , TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF::float as TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF
            , TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE::float as TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE
            , TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF::float as TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF
            , TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE::float as TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE
            , TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF::float as TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF
            , TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE::float as TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE
            , TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF::float as TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF
            , TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE::float as TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE
            , TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF::float as TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF
            , TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE::float as TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE
            , TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF::float as TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF
            , TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE::float as TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE
            , TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF::float as TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF
            , TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE::float as TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE
            , TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF::float as TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF
            , TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE::float as TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE
            , TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF::float as TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF
            , TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE::float as TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE
            , TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF::float as TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF
            , TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE::float as TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE
        from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_PACING
        where 1=1
    ) unpivot include nulls (value for metric_name in (TODAY_ROOMS_COMMIT, TODAY_ROOM_REVENUE_COMMIT, TODAY_ROOMS_COMMIT_PICKUP_7_DAY, TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, STLY_DATE_ROOMS_COMMIT, STLY_DATE_ROOM_REVENUE_COMMIT, STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, FINAL_LY_DATE_ROOMS_COMMIT, FINAL_LY_DATE_ROOM_REVENUE_COMMIT, FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOMS_COMMIT, ST2Y_DATE_ROOM_REVENUE_COMMIT, ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF, TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE, TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF, TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE, TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF, TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE, TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF, TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE, TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF, TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE, TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF, TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE, TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF, TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE, TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF, TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE, TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF, TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE, TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF, TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE, TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF, TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE, TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF, TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'ST2Y_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'ST2Y_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 'TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'))
           or source_table not in ('CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY')
           or value is not null)
    -- END LANE THE_PIG
    union all
    -- BEGIN LANE UNDER_CANVAS
    select
          :P_RUN_ID::varchar                as run_id
        , source_lane::varchar              as source_lane
        , site::varchar                     as site
        , site_name::varchar                as site_name
        , snapshot_date::date               as snapshot_date
        , snapshot_source::varchar          as snapshot_source
        , stay_period_start::date           as stay_period_start
        , stay_period_end::date             as stay_period_end
        , stay_grain::varchar               as stay_grain
        , segment::varchar                  as segment
        , segment_source::varchar           as segment_source
        , booking_status::varchar           as booking_status
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'TODAY'
            when 'TODAY_ROOM_REVENUE_COMMIT' then 'TODAY'
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then 'TODAY'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'TODAY'
            when 'STLY_DATE_ROOMS_COMMIT' then 'STLY_DATE'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then 'STLY_DATE'
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'STLY_DATE'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'STLY_DATE'
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then 'FINAL_LY_DATE'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then 'FINAL_LY_DATE'
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'FINAL_LY_DATE'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'FINAL_LY_DATE'
            when 'ST2Y_DATE_ROOMS_COMMIT' then 'ST2Y_DATE'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then 'ST2Y_DATE'
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ST2Y_DATE'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'ST2Y_DATE'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'TODAY'
            when 'STLY_DOW_ROOMS_COMMIT' then 'STLY_DOW'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT' then 'STLY_DOW'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'STLY_DOW'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'STLY_DOW'
            when 'FINAL_LY_DOW_ROOMS_COMMIT' then 'FINAL_LY_DOW'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT' then 'FINAL_LY_DOW'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'FINAL_LY_DOW'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'FINAL_LY_DOW'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'STLY_DATE'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'FINAL_LY_DATE'
            when 'TODAY_CANCELED_REVENUE' then 'TODAY'
            when 'TODAY_CANCELED_ROOMS' then 'TODAY'
            when 'STLY_CANCELED_REVENUE' then 'STLY'
            when 'STLY_CANCELED_ROOMS' then 'STLY'
          end)::varchar as vantage
        , metric_name::varchar              as metric_name
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'STLY_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'FINAL_LY_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'TODAY_CANCELED_REVENUE' then 'CURRENCY'
            when 'TODAY_CANCELED_ROOMS' then 'ROOMS'
            when 'STLY_CANCELED_REVENUE' then 'CURRENCY'
            when 'STLY_CANCELED_ROOMS' then 'ROOMS'
          end)::varchar as metric_unit
        , (case metric_name
            when 'TODAY_ROOMS_COMMIT' then true
            when 'TODAY_ROOM_REVENUE_COMMIT' then true
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'STLY_DATE_ROOMS_COMMIT' then true
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then true
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then true
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then true
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'ST2Y_DATE_ROOMS_COMMIT' then true
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then true
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then true
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then true
            when 'STLY_DOW_ROOMS_COMMIT' then true
            when 'STLY_DOW_ROOM_REVENUE_COMMIT' then true
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then true
            when 'FINAL_LY_DOW_ROOMS_COMMIT' then true
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT' then true
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then true
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then true
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then true
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then true
            when 'TODAY_CANCELED_REVENUE' then true
            when 'TODAY_CANCELED_ROOMS' then true
            when 'STLY_CANCELED_REVENUE' then true
            when 'STLY_CANCELED_ROOMS' then true
          end)::boolean as is_additive
        , value::float                      as value
        , iff((case metric_name
            when 'TODAY_ROOMS_COMMIT' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY' then 'ROOMS'
            when 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'STLY_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'FINAL_LY_DOW_ROOMS_COMMIT' then 'ROOMS'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT' then 'CURRENCY'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY' then 'CURRENCY'
            when 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY' then 'CURRENCY'
            when 'TODAY_CANCELED_REVENUE' then 'CURRENCY'
            when 'TODAY_CANCELED_ROOMS' then 'ROOMS'
            when 'STLY_CANCELED_REVENUE' then 'CURRENCY'
            when 'STLY_CANCELED_ROOMS' then 'ROOMS'
          end) in ('CURRENCY', 'RATE'), currency_code, null)::varchar as currency_code
        , (snapshot_date = max(snapshot_date) over (partition by site, source_table))::boolean as is_latest_snapshot
        , source_table::varchar             as source_table
        , source_line_key::varchar          as source_line_key
        , attributes::object                as attributes
    from (
        select
              source_lane
            , source_table
            , hotel_name as site
            , null as site_name
            , snapshot_date as snapshot_date
            , 'SNAPSHOT_DATE' as snapshot_source
            , date_trunc('month', stay_month) as stay_period_start
            , stay_month as stay_period_end
            , 'MONTH' as stay_grain
            , market_segment as segment
            , 'MARKET_SEGMENT' as segment_source
            , null as booking_status
            , 'USD' as currency_code
            , source_file_path || '|' || source_row_number as source_line_key
            , null as vantage_src
            , object_delete(object_construct_keep_null(*), 'RUN_ID', 'TODAY_ROOMS_COMMIT', 'TODAY_ROOM_REVENUE_COMMIT', 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY', 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'STLY_DATE_ROOMS_COMMIT', 'STLY_DATE_ROOM_REVENUE_COMMIT', 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'FINAL_LY_DATE_ROOMS_COMMIT', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT', 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'ST2Y_DATE_ROOMS_COMMIT', 'ST2Y_DATE_ROOM_REVENUE_COMMIT', 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY', 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', 'STLY_DOW_ROOMS_COMMIT', 'STLY_DOW_ROOM_REVENUE_COMMIT', 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', 'FINAL_LY_DOW_ROOMS_COMMIT', 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT', 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY', 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY', 'TODAY_CANCELED_REVENUE', 'TODAY_CANCELED_ROOMS', 'STLY_CANCELED_REVENUE', 'STLY_CANCELED_ROOMS') as attributes
            , TODAY_ROOMS_COMMIT::float as TODAY_ROOMS_COMMIT
            , TODAY_ROOM_REVENUE_COMMIT::float as TODAY_ROOM_REVENUE_COMMIT
            , TODAY_ROOMS_COMMIT_PICKUP_7_DAY::float as TODAY_ROOMS_COMMIT_PICKUP_7_DAY
            , TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , STLY_DATE_ROOMS_COMMIT::float as STLY_DATE_ROOMS_COMMIT
            , STLY_DATE_ROOM_REVENUE_COMMIT::float as STLY_DATE_ROOM_REVENUE_COMMIT
            , STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY::float as STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY
            , STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , FINAL_LY_DATE_ROOMS_COMMIT::float as FINAL_LY_DATE_ROOMS_COMMIT
            , FINAL_LY_DATE_ROOM_REVENUE_COMMIT::float as FINAL_LY_DATE_ROOM_REVENUE_COMMIT
            , FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY::float as FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY
            , FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , ST2Y_DATE_ROOMS_COMMIT::float as ST2Y_DATE_ROOMS_COMMIT
            , ST2Y_DATE_ROOM_REVENUE_COMMIT::float as ST2Y_DATE_ROOM_REVENUE_COMMIT
            , ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY::float as ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY
            , ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY::float as TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY
            , STLY_DOW_ROOMS_COMMIT::float as STLY_DOW_ROOMS_COMMIT
            , STLY_DOW_ROOM_REVENUE_COMMIT::float as STLY_DOW_ROOM_REVENUE_COMMIT
            , STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY::float as STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY
            , FINAL_LY_DOW_ROOMS_COMMIT::float as FINAL_LY_DOW_ROOMS_COMMIT
            , FINAL_LY_DOW_ROOM_REVENUE_COMMIT::float as FINAL_LY_DOW_ROOM_REVENUE_COMMIT
            , FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY::float as FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY
            , FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY::float as FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY
            , STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY::float as STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY
            , FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY::float as FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY
            , TODAY_CANCELED_REVENUE::float as TODAY_CANCELED_REVENUE
            , TODAY_CANCELED_ROOMS::float as TODAY_CANCELED_ROOMS
            , STLY_CANCELED_REVENUE::float as STLY_CANCELED_REVENUE
            , STLY_CANCELED_ROOMS::float as STLY_CANCELED_ROOMS
        from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING
        where 1=1
    ) unpivot include nulls (value for metric_name in (TODAY_ROOMS_COMMIT, TODAY_ROOM_REVENUE_COMMIT, TODAY_ROOMS_COMMIT_PICKUP_7_DAY, TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, STLY_DATE_ROOMS_COMMIT, STLY_DATE_ROOM_REVENUE_COMMIT, STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, FINAL_LY_DATE_ROOMS_COMMIT, FINAL_LY_DATE_ROOM_REVENUE_COMMIT, FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY, FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOMS_COMMIT, ST2Y_DATE_ROOM_REVENUE_COMMIT, ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY, ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, STLY_DOW_ROOMS_COMMIT, STLY_DOW_ROOM_REVENUE_COMMIT, STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, FINAL_LY_DOW_ROOMS_COMMIT, FINAL_LY_DOW_ROOM_REVENUE_COMMIT, FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY, FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY, TODAY_CANCELED_REVENUE, TODAY_CANCELED_ROOMS, STLY_CANCELED_REVENUE, STLY_CANCELED_ROOMS))
    where 1=1
      -- keep every cell of a declared (table, column); a cell outside the declared
      -- list only when it holds a value, so no stored value is ever dropped (Q-01)
      and ((source_table, metric_name) in (
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY', 'TODAY_CANCELED_REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY', 'TODAY_CANCELED_ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY', 'STLY_CANCELED_REVENUE'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY', 'STLY_CANCELED_ROOMS'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'TODAY_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'TODAY_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DOW_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DOW_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DOW_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'TODAY_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'TODAY_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'TODAY_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'STLY_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'STLY_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'FINAL_LY_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'ST2Y_DATE_ROOMS_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'ST2Y_DATE_ROOM_REVENUE_COMMIT'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'),
              ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY', 'ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'))
           or source_table not in ('CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY', 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY', 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY')
           or value is not null)
    -- END LANE UNDER_CANVAS
    ;

    v_rows := (select count(*) from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING);
    return 'SEM_AI_PACING rows=' || v_rows;
end;
$$;
