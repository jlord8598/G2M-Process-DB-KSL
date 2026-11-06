CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_OUTRIGGER(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_OUTRIGGER
-- Builds the five transformation streams for lane OUTRIGGER (D-23). Pacing-only
-- lane (owner, build 14 Q-06): no fact table, so the four H1-routed streams
-- (INCOME_STATEMENT, BALANCE_SHEET, OPERATING_METRICS, UNKNOWN) are created
-- empty with the standard columns, and XFRM_OUTRIGGER_PACING carries every pace row
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING as
    select
          :P_RUN_ID::varchar as run_id
        , source_lane::varchar as source_lane
        , source_table::varchar as source_table
        , source_folder::varchar as source_folder
        , property_group::varchar as property_group
        , snapshot_date::date as snapshot_date
        , property_name::varchar as property_name
        , segment::varchar as segment
        , stay_month::date as stay_month
        , stay_month_label::varchar as stay_month_label
        , cy_pace_occupancy::number(38,12) as cy_pace_occupancy
        , cy_pace_rooms::number(38,6) as cy_pace_rooms
        , cy_pace_adr::number(38,6) as cy_pace_adr
        , cy_pace_revenue::number(38,6) as cy_pace_revenue
        , ly_pace_occupancy::number(38,12) as ly_pace_occupancy
        , ly_pace_rooms::number(38,6) as ly_pace_rooms
        , ly_pace_adr::number(38,6) as ly_pace_adr
        , ly_pace_revenue::number(38,6) as ly_pace_revenue
        , forecast_occupancy::number(38,12) as forecast_occupancy
        , forecast_rooms::number(38,6) as forecast_rooms
        , forecast_adr::number(38,6) as forecast_adr
        , forecast_revenue::number(38,6) as forecast_revenue
        , budget_occupancy::number(38,12) as budget_occupancy
        , budget_rooms::number(38,6) as budget_rooms
        , budget_adr::number(38,6) as budget_adr
        , budget_revenue::number(38,6) as budget_revenue
        , report_filters::varchar as report_filters
        , export_layout::varchar as export_layout
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_OUTRIGGER_PACE
    where 1=1;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN);
    return 'XFRM_OUTRIGGER is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
