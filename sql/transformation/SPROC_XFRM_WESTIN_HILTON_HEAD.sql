CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_WESTIN_HILTON_HEAD(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_WESTIN_HILTON_HEAD  (build 22, new lane)
-- Builds the five transformation streams for lane WESTIN_HILTON_HEAD (D-23).
-- Pace-only this build (owner Q-02; the P&L waits for a chart of accounts,
-- N-55): the four H1-routed streams are created empty with the standard
-- columns, and XFRM_WESTIN_HILTON_HEAD_PACING carries every group-pace line in
-- its own shape (D-24), as-of SNAPSHOT_DATE. Nothing is classified (D-37).
-- Built from the lane-independent text of SPROC_XFRM_OUTRIGGER.
-- No filter, no aggregation.
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_INCOME_STATEMENT (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_BALANCE_SHEET (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_OPERATING_METRICS (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_UNKNOWN (
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_PACING as
    select
          :P_RUN_ID::varchar as run_id
        , source_lane::varchar as source_lane
        , source_table::varchar as source_table
        , source_folder
        , portfolio_name
        , snapshot_date
        , business_unit
        , operating_unit
        , department_code
        , metric
        , as_of
        , period_date
        , amount
        , source_rows_combined
        , file_date
        , source_file_path
        , source_row_number
    from DEV_G2M_AI.STAGING.STG_WESTIN_HILTON_HEAD_PACE_GROUP
    where 1=1;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_UNKNOWN);
    return 'XFRM_WESTIN_HILTON_HEAD is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
