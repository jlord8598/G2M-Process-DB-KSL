CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_JW_VENICE_HEADCOUNT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_JW_VENICE_HEADCOUNT
-- Builds STAGING.STG_JW_VENICE_HEADCOUNT from
-- CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT.
-- Fact table: HEADCOUNT by department label and month.
-- Identity form: wide by category, 4 branches (ACTUAL_AMOUNT, FORECAST_AMOUNT,
-- PREVIOUS_FORECAST_AMOUNT, BUDGET_AMOUNT), nulls kept:
-- count(staged) = count(source) x 4.
-- Key (owner, Q-04): DEPARTMENT = DEPARTMENT_LABEL; ACCOUNT_KEY = 'HEADCOUNT', the
-- table subject, as SOURCE_ITEM_ID. Site = PROPERTY_NAME.
-- RECORD_TYPE: STATISTIC on every row (a staff count); value in STAT_VALUE.
-- IS_SUBTOTAL: the source IS_SUBTOTAL (carried as SRC_IS_SUBTOTAL); structure
-- only, not verified against contiguous blocks (M1).
-- The source DEPARTMENT_NAME is carried as SRC_DEPARTMENT_NAME.
-- SCENARIO = the branch's measure column name (D-45).
-- SOURCE_LINE_KEY: DEPARTMENT_LABEL|PERIOD_DATE|branch, unique (M1).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'PREVIOUS_FORECAST'::varchar as measure_column, 'PREVIOUS_FORECAST_AMOUNT'::varchar as m_scenario, src.previous_forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , 'STATISTIC' as c_rtype
            , 'table HEADCOUNT: STATISTIC on every row (derived, M1)' as c_rtype_source
            , coalesce(unp.is_subtotal, false) as c_subtotal
            , (case when unp.is_subtotal then 'source IS_SUBTOTAL (structure only, M1)' else 'source IS_SUBTOTAL false' end) as c_subtotal_source
            , (coalesce(unp.department_label::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department_label), '')::varchar                                    as department
        , cln.department_name::varchar                                                   as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim('HEADCOUNT'), '')::varchar                                    as source_item_id
        , coalesce(nullif(trim('HEADCOUNT'), ''), '~BLANK~')::varchar               as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , cln.c_rtype_source::varchar                                           as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.department_label::varchar                                                       as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_amount)::float             as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_amount, null)::float             as stat_value
        , cln.c_subtotal::boolean                                               as is_subtotal
        , cln.c_subtotal_source::varchar                                        as subtotal_source
        , cln.c_line_key::varchar                                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        , cln.m_path::varchar                                                   as measure_source_file_path
        , cln.m_row::varchar                                                    as measure_source_row
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.department_code
        , cln.department_name as src_department_name
        , cln.is_subtotal as src_is_subtotal
        , cln.department_label
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.previous_forecast_amount
        , cln.budget_amount
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT);
    return 'STG_JW_VENICE_HEADCOUNT rows=' || v_rows;
end;
$$;
