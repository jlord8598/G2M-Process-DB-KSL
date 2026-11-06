CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_THE_PIG(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_THE_PIG
-- Builds the five transformation streams for lane THE_PIG (D-23). Pacing-only
-- lane (owner, build 14 Q-06): no fact table, so the four H1-routed streams
-- (INCOME_STATEMENT, BALANCE_SHEET, OPERATING_METRICS, UNKNOWN) are created
-- empty with the standard columns, and XFRM_THE_PIG_PACING carries every pace row
-- in its own shape (D-24), as-of SNAPSHOT_DATE. Nothing is classified; the
-- lane has no classification keys (D-37). No filter, no aggregation.
-- ============================================================================
declare
    v_is  integer;
    v_bs  integer;
    v_om  integer;
    v_pc  integer;
    v_un  integer;
begin
    -- ------------------------------------------------------------------------
    -- the four H1-routed streams: no fact source, created empty
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT (
          run_id                         varchar
        , source_lane                    varchar
        , source_site_code               varchar
        , asset_name                     varchar
        , department                     varchar
        , department_name                varchar
        , account_number                 varchar
        , stat_account                   varchar
        , account_key                    varchar
        , record_type                    varchar
        , record_type_source             varchar
        , stat_unit_family               varchar
        , account_desc                   varchar
        , period_end                     date
        , category                       varchar
        , scenario                       varchar
        , h1                             varchar
        , h2                             varchar
        , h3                             varchar
        , h4                             varchar
        , h5                             varchar
        , p_l_section                    varchar
        , normal_balance                 varchar
        , is_subtotal                    boolean
        , subtotal_source                varchar
        , source_amount                  float
        , stat_value                     float
        , source_line_key                varchar
        , source_table                   varchar
        , value_sign                     number(2,0)
        , value                          float
        , metric_unit                    varchar
        , aggregation_type               varchar
        , unknown_reason                 varchar
        , unresolved_category_value      varchar
    );
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET (
          run_id                         varchar
        , source_lane                    varchar
        , source_site_code               varchar
        , asset_name                     varchar
        , department                     varchar
        , department_name                varchar
        , account_number                 varchar
        , stat_account                   varchar
        , account_key                    varchar
        , record_type                    varchar
        , record_type_source             varchar
        , stat_unit_family               varchar
        , account_desc                   varchar
        , period_end                     date
        , category                       varchar
        , scenario                       varchar
        , h1                             varchar
        , h2                             varchar
        , h3                             varchar
        , h4                             varchar
        , h5                             varchar
        , p_l_section                    varchar
        , normal_balance                 varchar
        , is_subtotal                    boolean
        , subtotal_source                varchar
        , source_amount                  float
        , stat_value                     float
        , source_line_key                varchar
        , source_table                   varchar
        , value_sign                     number(2,0)
        , value                          float
        , metric_unit                    varchar
        , aggregation_type               varchar
        , unknown_reason                 varchar
        , unresolved_category_value      varchar
    );
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS (
          run_id                         varchar
        , source_lane                    varchar
        , source_site_code               varchar
        , asset_name                     varchar
        , department                     varchar
        , department_name                varchar
        , account_number                 varchar
        , stat_account                   varchar
        , account_key                    varchar
        , record_type                    varchar
        , record_type_source             varchar
        , stat_unit_family               varchar
        , account_desc                   varchar
        , period_end                     date
        , category                       varchar
        , scenario                       varchar
        , h1                             varchar
        , h2                             varchar
        , h3                             varchar
        , h4                             varchar
        , h5                             varchar
        , p_l_section                    varchar
        , normal_balance                 varchar
        , is_subtotal                    boolean
        , subtotal_source                varchar
        , source_amount                  float
        , stat_value                     float
        , source_line_key                varchar
        , source_table                   varchar
        , value_sign                     number(2,0)
        , value                          float
        , metric_unit                    varchar
        , aggregation_type               varchar
        , unknown_reason                 varchar
        , unresolved_category_value      varchar
    );
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_UNKNOWN (
          run_id                         varchar
        , source_lane                    varchar
        , source_site_code               varchar
        , asset_name                     varchar
        , department                     varchar
        , department_name                varchar
        , account_number                 varchar
        , stat_account                   varchar
        , account_key                    varchar
        , record_type                    varchar
        , record_type_source             varchar
        , stat_unit_family               varchar
        , account_desc                   varchar
        , period_end                     date
        , category                       varchar
        , scenario                       varchar
        , h1                             varchar
        , h2                             varchar
        , h3                             varchar
        , h4                             varchar
        , h5                             varchar
        , p_l_section                    varchar
        , normal_balance                 varchar
        , is_subtotal                    boolean
        , subtotal_source                varchar
        , source_amount                  float
        , stat_value                     float
        , source_line_key                varchar
        , source_table                   varchar
        , value_sign                     number(2,0)
        , value                          float
        , metric_unit                    varchar
        , aggregation_type               varchar
        , unknown_reason                 varchar
        , unresolved_category_value      varchar
    );

    -- ------------------------------------------------------------------------
    -- pacing: routed on source, own columns (D-24), never classified; the
    -- union of the lane's pace tables, a typed null where a table lacks a column
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_PACING as
    select
          :P_RUN_ID::varchar as run_id
        , source_lane::varchar as source_lane
        , source_table::varchar as source_table
        , source_folder::varchar as source_folder
        , property_name::varchar as property_name
        , snapshot_date::date as snapshot_date
        , hotel_name::varchar as hotel_name
        , stay_month::date as stay_month
        , stay_month_label::varchar as stay_month_label
        , market_segment::varchar as market_segment
        , today_rooms_commit::number(38,12) as today_rooms_commit
        , today_room_revenue_commit::number(38,12) as today_room_revenue_commit
        , today_rooms_commit_pickup_7_day::number(38,12) as today_rooms_commit_pickup_7_day
        , today_room_revenue_commit_pickup_7_day::number(38,12) as today_room_revenue_commit_pickup_7_day
        , stly_date_rooms_commit::number(38,12) as stly_date_rooms_commit
        , stly_date_room_revenue_commit::number(38,12) as stly_date_room_revenue_commit
        , stly_date_rooms_commit_pickup_7_day::number(38,12) as stly_date_rooms_commit_pickup_7_day
        , stly_date_room_revenue_commit_pickup_7_day::number(38,12) as stly_date_room_revenue_commit_pickup_7_day
        , final_ly_date_rooms_commit::number(38,12) as final_ly_date_rooms_commit
        , final_ly_date_room_revenue_commit::number(38,12) as final_ly_date_room_revenue_commit
        , final_ly_date_rooms_commit_pickup_7_day::number(38,12) as final_ly_date_rooms_commit_pickup_7_day
        , final_ly_date_room_revenue_commit_pickup_7_day::number(38,12) as final_ly_date_room_revenue_commit_pickup_7_day
        , st2y_date_rooms_commit::number(38,12) as st2y_date_rooms_commit
        , st2y_date_room_revenue_commit::number(38,12) as st2y_date_room_revenue_commit
        , st2y_date_rooms_commit_pickup_7_day::number(38,12) as st2y_date_rooms_commit_pickup_7_day
        , st2y_date_room_revenue_commit_pickup_7_day::number(38,12) as st2y_date_room_revenue_commit_pickup_7_day
        , today_vs_stly_date_rooms_commit_diff::number(38,12) as today_vs_stly_date_rooms_commit_diff
        , today_vs_stly_date_rooms_commit_change::number(38,12) as today_vs_stly_date_rooms_commit_change
        , today_vs_stly_date_room_revenue_commit_diff::number(38,12) as today_vs_stly_date_room_revenue_commit_diff
        , today_vs_stly_date_room_revenue_commit_change::number(38,12) as today_vs_stly_date_room_revenue_commit_change
        , today_vs_stly_date_rooms_commit_pickup_7_day_diff::number(38,12) as today_vs_stly_date_rooms_commit_pickup_7_day_diff
        , today_vs_stly_date_rooms_commit_pickup_7_day_change::number(38,12) as today_vs_stly_date_rooms_commit_pickup_7_day_change
        , today_vs_stly_date_room_revenue_commit_pickup_7_day_diff::number(38,12) as today_vs_stly_date_room_revenue_commit_pickup_7_day_diff
        , today_vs_stly_date_room_revenue_commit_pickup_7_day_change::number(38,12) as today_vs_stly_date_room_revenue_commit_pickup_7_day_change
        , today_vs_final_ly_date_rooms_commit_diff::number(38,12) as today_vs_final_ly_date_rooms_commit_diff
        , today_vs_final_ly_date_rooms_commit_change::number(38,12) as today_vs_final_ly_date_rooms_commit_change
        , today_vs_final_ly_date_room_revenue_commit_diff::number(38,12) as today_vs_final_ly_date_room_revenue_commit_diff
        , today_vs_final_ly_date_room_revenue_commit_change::number(38,12) as today_vs_final_ly_date_room_revenue_commit_change
        , today_vs_final_ly_date_rooms_commit_pickup_7_day_diff::number(38,12) as today_vs_final_ly_date_rooms_commit_pickup_7_day_diff
        , today_vs_final_ly_date_rooms_commit_pickup_7_day_change::number(38,12) as today_vs_final_ly_date_rooms_commit_pickup_7_day_change
        , today_vs_final_ly_date_room_revenue_commit_pickup_7_day_diff::number(38,12) as today_vs_final_ly_date_room_revenue_commit_pickup_7_day_diff
        , today_vs_final_ly_date_room_revenue_commit_pickup_7_day_change::number(38,12) as today_vs_final_ly_date_room_revenue_commit_pickup_7_day_change
        , today_vs_st2y_date_rooms_commit_diff::number(38,12) as today_vs_st2y_date_rooms_commit_diff
        , today_vs_st2y_date_rooms_commit_change::number(38,12) as today_vs_st2y_date_rooms_commit_change
        , today_vs_st2y_date_room_revenue_commit_diff::number(38,12) as today_vs_st2y_date_room_revenue_commit_diff
        , today_vs_st2y_date_room_revenue_commit_change::number(38,12) as today_vs_st2y_date_room_revenue_commit_change
        , today_vs_st2y_date_rooms_commit_pickup_7_day_diff::number(38,12) as today_vs_st2y_date_rooms_commit_pickup_7_day_diff
        , today_vs_st2y_date_rooms_commit_pickup_7_day_change::number(38,12) as today_vs_st2y_date_rooms_commit_pickup_7_day_change
        , today_vs_st2y_date_room_revenue_commit_pickup_7_day_diff::number(38,12) as today_vs_st2y_date_room_revenue_commit_pickup_7_day_diff
        , today_vs_st2y_date_room_revenue_commit_pickup_7_day_change::number(38,12) as today_vs_st2y_date_room_revenue_commit_pickup_7_day_change
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_THIS_YEAR
    where 1=1
    union all
    select
          :P_RUN_ID::varchar as run_id
        , source_lane::varchar
        , source_table::varchar
        , source_folder::varchar
        , property_name::varchar
        , snapshot_date::date
        , hotel_name::varchar
        , stay_month::date
        , stay_month_label::varchar
        , market_segment::varchar
        , today_rooms_commit::number(38,12)
        , today_room_revenue_commit::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , stly_date_rooms_commit::number(38,12)
        , stly_date_room_revenue_commit::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , final_ly_date_rooms_commit::number(38,12)
        , final_ly_date_room_revenue_commit::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , st2y_date_rooms_commit::number(38,12)
        , st2y_date_room_revenue_commit::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , today_vs_stly_date_rooms_commit_diff::number(38,12)
        , today_vs_stly_date_rooms_commit_change::number(38,12)
        , today_vs_stly_date_room_revenue_commit_diff::number(38,12)
        , today_vs_stly_date_room_revenue_commit_change::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , today_vs_final_ly_date_rooms_commit_diff::number(38,12)
        , today_vs_final_ly_date_rooms_commit_change::number(38,12)
        , today_vs_final_ly_date_room_revenue_commit_diff::number(38,12)
        , today_vs_final_ly_date_room_revenue_commit_change::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , today_vs_st2y_date_rooms_commit_diff::number(38,12)
        , today_vs_st2y_date_rooms_commit_change::number(38,12)
        , today_vs_st2y_date_room_revenue_commit_diff::number(38,12)
        , today_vs_st2y_date_room_revenue_commit_change::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , null::number(38,12)
        , file_date::timestamp_tz
        , source_file_path::varchar
        , source_row_number::number(38,0)
    from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_NEXT_YEAR
    where 1=1;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_UNKNOWN);
    return 'XFRM_THE_PIG is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
