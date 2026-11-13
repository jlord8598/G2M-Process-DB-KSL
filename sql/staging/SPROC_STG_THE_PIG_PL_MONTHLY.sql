CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_THE_PIG_PL_MONTHLY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_THE_PIG_PL_MONTHLY  (build 21)
-- Builds STAGING.STG_THE_PIG_PL_MONTHLY from
-- CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_FIN_PL_MONTHLY. Fact table.
-- Identity form: wide by category, 2 branches (ACTUAL_AMOUNT, FORECAST_AMOUNT),
-- nulls kept: count(staged) = count(source) x 2. BUDGET_AMOUNT holds no value
-- (not in landed data, owner Q-05, N-54); carried raw, not unpivoted.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = HOTEL_CODE (OL "Online, Staff Houses, Central" is a site like any
-- other); ASSET_NAME = HOTEL_NAME. ACCOUNT_LINE_NUMBER is <letter><5 digits>-
-- <3-digit department>: DEPARTMENT = the part after the dash (structural);
-- ACCOUNT_KEY = ACCOUNT_LINE_NUMBER.
-- RECORD_TYPE: C00001-050 Occupancy %, C00008-050 Sold Rooms and C00010-050
-- Available Rooms STATISTIC (value in STAT_VALUE); every other line AMOUNT
-- (owner, build 21 M1: the C prefix is not statistics-only).
-- IS_SUBTOTAL false on every line: the "Total ..." lines (C00850-650 / -700,
-- P300x0-998) are the only lines for their department, so detail (owner Q-04).
-- ACCOUNT_DESC from STG_THE_PIG_ACCOUNTS on entity + account string (every
-- line matches; equal to ACCOUNT_LINE_NAME, M1).
-- SCENARIO = the branch's measure column name (D-45). CURRENCY 'British Pound'
-- carried raw; semantic states CURRENCY_CODE 'GBP' (owner Q-06).
-- SOURCE_SIGN_CONVENTION PRESENTED (revenue and costs positive, M1; D-50).
-- SOURCE_LINE_KEY: file | row | period | branch (unique; file | row alone is
-- not, the sheet is wide by month).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_THE_PIG_PL_MONTHLY as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_FIN_PL_MONTHLY
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount from src
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              unp.*
            , nullif(trim(unp.hotel_code), '')                                as c_site
            , nullif(trim(unp.account_line_number), '')                       as c_acct
            , nullif(split_part(trim(unp.account_line_number), '-', 2), '')   as c_dept
            , coalesce(trim(unp.account_line_number) in ('C00001-050', 'C00008-050', 'C00010-050'), false) as c_is_stat
        from unp
    )
    -- ------------------------------------------------------------------------
    -- account description dictionary, unique on entity + string (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.entity_code
            , a.full_account_string
            , a.account_description
        from DEV_G2M_AI.STAGING.STG_THE_PIG_ACCOUNTS a
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'THE_PIG'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_FIN_PL_MONTHLY'::varchar      as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.hotel_name::varchar                                               as asset_name
        , cln.c_dept::varchar                                                   as department
        , null::varchar                                                         as department_name
        , cln.account_line_number::varchar                                      as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(cln.c_acct, '~BLANK~')::varchar                              as account_key
        , iff(cln.c_is_stat, 'STATISTIC', 'AMOUNT')::varchar                    as record_type
        , iff(cln.c_is_stat
            , 'line ' || cln.account_line_number || ' (' || cln.account_line_name || '): STATISTIC (owner, build 21 M1)'
            , 'every line but C00001 / C00008 / C00010-050: AMOUNT (owner, build 21 M1)')::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_is_stat, null, cln.m_amount)::float                         as source_amount
        , iff(cln.c_is_stat, cln.m_amount, null)::float                         as stat_value
        , 'PRESENTED'::varchar                                                  as source_sign_convention
        , 'presented-positive: Jan-Sep revenue 46.5M, cost of sales 7.4M, both positive (build 21 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , '"Total ..." lines are the only lines for their department: detail (owner Q-04)'::varchar as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.portfolio_name
        , cln.hotel_code
        , cln.hotel_name
        , cln.account_line_number
        , cln.account_line_name
        , cln.period_date
        , cln.currency
        , cln.actual_amount
        , cln.forecast_amount
        , cln.budget_amount
        , cln.actual_run_ts
        , cln.forecast_run_ts
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join acct
        on  acct.entity_code         = cln.hotel_code
        and acct.full_account_string = cln.account_line_number
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_THE_PIG_PL_MONTHLY);
    return 'STG_THE_PIG_PL_MONTHLY rows=' || v_rows;
end;
$$;
