CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_JW_VENICE_FCAST_BY_PERIOD(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_JW_VENICE_FCAST_BY_PERIOD
-- Builds STAGING.STG_JW_VENICE_FCAST_BY_PERIOD from
-- CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD.
-- Fact table: forecast template, prior-year actual by period.
-- Identity form: wide by category, 2 branches (ACTUAL_AMOUNT, FORECAST_AMOUNT),
-- nulls kept: count(staged) = count(source) x 2.
-- No account number: ACCOUNT_KEY = LINE_ITEM as SOURCE_ITEM_ID (D-06).
-- DEPARTMENT = SECTION (ROOMS, SPA, ... occur in two sections, M1).
-- Site = PROPERTY_NAME (one property).
-- RECORD_TYPE derived: SECTION KEY STATISTICS -> STATISTIC, except CREDIT
-- CARD EXPENSE (money); else AMOUNT.
-- IS_SUBTOTAL (owner, stop 1): money lines starting TOTAL or TOT, SECTION
-- DEPARTMENT PROFIT, and the computed lines GOP ... RETAINED PROFIT/(LOSS).
-- KEY STATISTICS lines named TOTAL ... are measures, not subtotals.
-- Build 15 (Q-09): EBITDA EXCLUDING OWNER EXPENSES, this file's spelling of
-- ACT_FORECAST's EBITDA EXCL. OWNER EXPENSES, equals EBITDA in 24 / 24 periods
-- (Q-16 tie test): a computed line.
-- SCENARIO = the branch's measure column name (D-45). Signs as booked.
-- SOURCE_LINE_KEY: SECTION|LINE_ITEM|PERIOD_DATE|branch, unique (M1).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Build 15 (D-50): SOURCE_SIGN_CONVENTION PRESENTED for every row, with its evidence
-- in SOURCE_SIGN_CONVENTION_SOURCE; applied in transformation.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'SECTION KEY STATISTICS: STATISTIC (derived, M1)' else 'SECTION ' || coalesce(unp.section, '~BLANK~') || ': AMOUNT (derived, M1)' end) as c_rtype_source
            , coalesce(unp.section <> 'KEY STATISTICS' and (
                   unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %'
                or unp.section = 'DEPARTMENT PROFIT'
                or unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)', 'EBITDA EXCLUDING OWNER EXPENSES')), false) as c_subtotal
            , (case
                when unp.section = 'KEY STATISTICS' then 'not a subtotal by the M1 rule'
                when unp.section = 'DEPARTMENT PROFIT' then 'SECTION DEPARTMENT PROFIT: computed (M1)'
                when unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %' then 'LINE_ITEM starts TOTAL (M1)'
                when unp.line_item = 'EBITDA EXCLUDING OWNER EXPENSES' then 'computed line: equals EBITDA in 24 / 24 periods (Q-16 tie test, build 15 Q-09)'
                when unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)') then 'computed line (M1)'
                else 'not a subtotal by the M1 rule' end) as c_subtotal_source
            , (coalesce(unp.section::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.section), '')::varchar                                    as department
        , cln.section::varchar                                                   as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(cln.line_item), '')::varchar                                    as source_item_id
        , coalesce(nullif(trim(cln.line_item), ''), '~BLANK~')::varchar               as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , cln.c_rtype_source::varchar                                           as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_item::varchar                                                       as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_amount)::float             as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_amount, null)::float             as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_text
        , cln.forecast_text
        , cln.actual_report_as_of_date
        , cln.forecast_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD);
    return 'STG_JW_VENICE_FCAST_BY_PERIOD rows=' || v_rows;
end;
$$;
