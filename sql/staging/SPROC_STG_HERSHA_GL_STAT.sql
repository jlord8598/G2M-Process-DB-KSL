CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_GL_STAT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HERSHA_GL_STAT
-- Builds STAGING.STG_HERSHA_GL_STAT from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_STAT.
-- Fact table, statistics (owner Q-02).
-- Identity form: wide by category, 2 branches (ACTUAL_*, FORECAST_*), nulls kept:
-- count(staged) = count(source) x 2. Each branch carries its amount and stat.
-- Every row is STATISTIC: the source puts the count in *_AMOUNT (ACTUAL_STAT is
-- 0 on every row), so the branch amount is STAT_VALUE and SOURCE_AMOUNT is null.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = COMPANY_ID; ASSET_NAME = COMPANY_NAME. Revenue books negative; as booked.
-- SOURCE_LINE_KEY: the 7 dimension columns unique on the source (M1) plus the
-- branch; the file path and row are null on a branch whose measure is empty.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HERSHA_GL_STAT as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_STAT
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_STAT'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , ('STATISTIC')::varchar as record_type
        , ('GL_STAT table, ST account: STATISTIC; the count sits in the branch''s _AMOUNT column and is carried as STAT_VALUE (owner Q-02)')::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , null::varchar                                                         as scenario
        , null::float as source_amount
        , unp.m_amount::float as stat_value
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(unp.company_id, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(unp.account_code, '~BLANK~')
            || '|' || coalesce(unp.department_code, '~BLANK~')
            || '|' || coalesce(unp.rev_spend_category, '~BLANK~')
            || '|' || coalesce(unp.job_title_code, '~BLANK~')
            || '|' || coalesce(unp.meal_period_code, '~BLANK~')
            || '|' || unp.measure_column)::varchar                             as source_line_key
        , unp.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , unp.source_folder
        , unp.property_name
        , unp.company_id
        , unp.company_name
        , unp.period_date
        , unp.account_code
        , unp.account_description
        , unp.gl_code
        , unp.department_code
        , unp.department_description
        , unp.rev_spend_category
        , unp.rev_spend_description
        , unp.job_title_code
        , unp.job_description
        , unp.meal_period_code
        , unp.meal_description
        , unp.flag_col_2
        , unp.actual_amount
        , unp.forecast_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
    from unp
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HERSHA_GL_STAT);
    return 'STG_HERSHA_GL_STAT rows=' || v_rows;
end;
$$;
