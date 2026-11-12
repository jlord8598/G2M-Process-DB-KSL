CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_GL_ACTUAL(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HERSHA_GL_ACTUAL
-- Builds STAGING.STG_HERSHA_GL_ACTUAL from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY.
-- Fact table.
-- Identity form: wide by category, 3 branches (ACTUAL_*, FORECAST_*, BUDGET_*), nulls
-- kept: count(staged) = count(source) x 3 (build 19; was x 2). Each branch carries its amount and its
-- stat on one row (D-29), so money and its statistic stay together.
-- RECORD_TYPE stated by GL_CODE: Stat -> STATISTIC, else AMOUNT.
-- STAT_UNIT_FAMILY null: the source states no unit for a stat.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = COMPANY_ID; ASSET_NAME = COMPANY_NAME. Revenue books negative; as booked.
-- SOURCE_LINE_KEY: the 7 dimension columns unique on the source (M1) plus the
-- branch; the file path and row are null on a branch whose measure is empty.
-- SCENARIO = the name of the branch's defining measure column, ACTUAL_AMOUNT,
-- FORECAST_AMOUNT or BUDGET_AMOUNT: the source names no scenario (D-45, build 06 Q-03).
-- Build 15 (D-50): SOURCE_SIGN_CONVENTION DEBIT for every row, with its evidence
-- in SOURCE_SIGN_CONVENTION_SOURCE; applied in transformation.
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- Build 19 (owner Q-06, N-36): the BUDGET branch is added and the build 16
-- temporary WHERE is removed; every source row is read. Budget books DEBIT like
-- actual and forecast (revenue 4xxx -325.0M; 5xxx-7xxx positive; build 19 M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HERSHA_GL_ACTUAL as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select source_folder, portfolio_name as property_name, * exclude (source_folder) from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
        union all
        select src.*, 'BUDGET'::varchar   as measure_column, 'BUDGET_AMOUNT'::varchar   as m_scenario, src.budget_amount   as m_amount, src.budget_stat   as m_stat, src.budget_source_file_path   as m_path, src.budget_source_row_number   as m_row from src
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'STATISTIC' else 'AMOUNT' end)::varchar as record_type
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'GL_CODE Stat: STATISTIC (stated by the source)' else 'GL_CODE ' || coalesce(unp.gl_code, '~BLANK~') || ': AMOUNT, branch stat carried as STAT_VALUE (stated; D-29)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , unp.m_scenario::varchar                                               as scenario
        , unp.m_amount::float as source_amount
        , unp.m_stat::float as stat_value
        , 'DEBIT'::varchar                                                    as source_sign_convention
        , 'debit-positive: TB revenue (4xxx) negative in 108 / 108 entity-months, 5xxx-7xxx positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , unp.actual_amount
        , unp.forecast_amount
        , unp.budget_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.budget_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.budget_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
        , unp.budget_source_file_path
        , unp.budget_source_row_number
    from unp
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HERSHA_GL_ACTUAL);
    return 'STG_HERSHA_GL_ACTUAL rows=' || v_rows;
end;
$$;
