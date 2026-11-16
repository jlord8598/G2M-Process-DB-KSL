CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HICV_TREND_WEEKLY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HICV_TREND_WEEKLY
-- Builds STAGING.STG_HICV_TREND_WEEKLY from
-- CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_TREND_WEEKLY.
-- Pacing (owner Q-08): routed to the PACING stream and SEM_AI_PACING; never
-- feeds the seeder (D-37). Build 23 (new lane HICV).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- As-of: SNAPSHOT_DATE on the row, distinct from the period (M1). The report
-- is portfolio-level: the source names no site, so SITE is null.
-- PERIOD_WINDOW (WEEK / MTD / YTD) and ACTUAL_SOURCE (CY / PY; PY stored as
-- actual dated one year earlier) carried verbatim. IS_SUBTOTAL is stated by
-- the source and carried as SOURCE_IS_SUBTOTAL.
-- Measures ACTUAL_AMOUNT and BUDGET_AMOUNT as booked; ACTUAL_TEXT and
-- BUDGET_TEXT carried verbatim. Units as the line states them (M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HICV_TREND_WEEKLY as
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HICV'::varchar                                                       as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_TREND_WEEKLY'::varchar            as source_table
        , null::varchar                                                         as site
        , 'the report is portfolio-level; the source names no site (M1)'::varchar as site_source
        , src.snapshot_date::date                                               as snapshot_date_clean
        , 'SNAPSHOT_DATE on the row (M1)'::varchar                              as snapshot_source
        , (coalesce(src.source_file_path, '~BLANK~') || '|' || to_char(src.snapshot_date, 'YYYY-MM-DD') || '|' || coalesce(src.report_tab, '~BLANK~') || '|' || coalesce(src.section, '~BLANK~') || '|' || coalesce(src.line_item, '~BLANK~') || '|' || coalesce(src.period_window, '~BLANK~') || '|' || coalesce(to_char(src.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.portfolio_name
        , src.snapshot_date
        , src.report_tab
        , src.section
        , src.line_item
        , src.period_window
        , src.period_date
        , src.line_order
        , src.is_subtotal                                                       as source_is_subtotal
        , src.actual_amount
        , src.budget_amount
        , src.actual_text
        , src.budget_text
        , src.actual_source
        , src.file_date
        , src.source_file_path
        , src.actual_source_cell
    from CLN.BOX_INVESTMENT_DATA.CLN_HICV_OPS_TREND_WEEKLY src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HICV_TREND_WEEKLY);
    return 'STG_HICV_TREND_WEEKLY rows=' || v_rows;
end;
$$;
