CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_W_SHERATON_MALDIVES_PL_MONTHLY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_W_SHERATON_MALDIVES_PL_MONTHLY  (build 22, new lane)
-- Builds STAGING.STG_W_SHERATON_MALDIVES_PL_MONTHLY from
-- CLN.BOX_INVESTMENT_DATA.CLN_W_SHERATON_MALDIVES_FIN_PL_MONTHLY. Fact table.
-- Identity form: wide by category, 3 branches (ACTUAL_AMOUNT, FORECAST_AMOUNT,
-- BUDGET_AMOUNT), nulls kept: count(staged) = count(source) x 3.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = HOTEL_CODE; ASSET_NAME = HOTEL_NAME. No account codes: DEPARTMENT =
-- SECTION, ACCOUNT_KEY = LINE_ITEM (as SOURCE_ITEM_ID), as JW_VENICE's report
-- tables. PERIOD_TYPE 'MONTH' (the table is monthly); D-48 in transformation.
-- RECORD_TYPE: SECTION KEY STATISTICS, GOP MARGIN (a ratio) and the hours /
-- sales-per-hour validation lines STATISTIC; else AMOUNT.
-- IS_SUBTOTAL (owner Q-05, Q-11, Q-12): the named totals that tie to their
-- detail in every month (build 22 M2); DEPARTMENT PROFIT "TOTAL FOOD & BEVERAGE"
-- and "TOTAL NON-OP INC/EXP", which never tie because the source does not show
-- all of their detail (Q-11, N-57); and the VALIDATION OF PROFIT CON lines that
-- restate another line or are all zero (Q-12). Every other line, "| #2"
-- repeats included (D-48 in transformation), false.
-- Owner Q-15 (build 22 stop 4): every DEPARTMENT PROFIT line (repeats
-- included) is a computed departmental profit and a source rollup, as JW_VENICE. Owner Q-13: the control-
-- check lines (ALL ACTIVITY IN 048X, ALL ACTIVITY IN 0490, DIFFERENCE OF UNALL PFT) are source rollups too; the
-- other non-restating validation lines stay detail. Build 22 M4: Owner
-- Expenses is the group line of Owner Activity (equal 24 / 24 months).
-- Stop 4: Non-Operating Income-Expenses is the group line of the three Q-13
-- VALIDATION lines (equal in 36 / 36 populated month-branches), a subtotal.
-- SCENARIO = the branch's measure column name (D-45); ACTUAL_SOURCE_SCENARIO raw.
-- SOURCE_SIGN_CONVENTION PRESENTED (revenue and costs positive, M1; D-50).
-- SOURCE_LINE_KEY: hotel | section | line | period | period type | branch
-- (unique, M1). Currency USD is an owner assumption (Q-06), set in semantic.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_MONTHLY as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_W_SHERATON_MALDIVES_FIN_PL_MONTHLY
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount from src
        union all
        select src.*, 'BUDGET'::varchar   as measure_column, 'BUDGET_AMOUNT'::varchar   as m_scenario, src.budget_amount   as m_amount from src
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs and per-line rules
    -- ------------------------------------------------------------------------
    , cln as (
        select
              unp.*
            , nullif(trim(unp.hotel_code), '')  as c_site
            , nullif(trim(unp.section), '')     as c_sec
            , nullif(trim(unp.line_item), '')   as c_line
        from unp
    )
    , cln2 as (
        select
              cln.*
            , (cln.c_sec = 'KEY STATISTICS' or cln.c_line = 'GOP MARGIN'
               or (cln.c_sec = 'VALIDATION OF PROFIT CON' and cln.c_line in ('TOTAL HOURS WORKED MGR HOURS', 'TOTAL HOURS WORKED incl MANAGER HRS', 'SALES / HOUR WORKED incl MANAGER HRS'))) as c_is_stat
            , case
                  when cln.c_sec = 'DEPARTMENT PROFIT' then true
                  when cln.c_line like '%| #%' then false
                  when cln.c_sec <> 'KEY STATISTICS' and cln.c_sec <> 'VALIDATION OF PROFIT CON'
                       and cln.c_line in ('RESTAURANTS', 'LOUNGES', 'LEISURE/RECREATION', 'LEISURE / RECREATION', 'SPA', 'OTHER DEPTS', 'MINOR OPERATED', 'MISCELLANEOUS INCOME', 'GIFT SHOPS', 'ADMINISTRATIVE & GENERAL', 'NON-OP INC/EXP EXCL. OWNER EXP.', 'TOTAL FOOD & BEVERAGE', 'TOTAL OTHER OPERATED', 'TOTAL OPERATING REVENUE', 'TOTAL DEPARTMENTAL PROFIT', 'TOTAL UNDISTRIBUTED OP EXP', 'TOTAL MANAGEMENT FEES', 'GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA LESS REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'TOTAL NON-OP INC/EXP') then true
              when cln.c_sec = 'VALIDATION OF PROFIT CON' and cln.c_line in ('ABOVE MI PROFIT CON', 'ALL ACTIVITY IN 0690', 'ALL ACTIVITY IN 0691', 'BMF INCOME', 'FF-E Escrow Expense', 'IMF INCOME', 'Incentive Fee Expense', 'Net To Owner', 'OTHER MI INC/(EXP)', 'Other Owner Expense', 'Royalty Fee Expense', 'SUBTOTAL') then true
                  when cln.c_sec = 'VALIDATION OF PROFIT CON' and cln.c_line in ('ALL ACTIVITY IN 048X', 'ALL ACTIVITY IN 0490', 'DIFFERENCE OF UNALL PFT') then true
                  when cln.c_sec = 'UNDISTRIBUTED OPERATING EXP' and cln.c_line = 'Owner Expenses' then true
                  when cln.c_sec = 'UNDISTRIBUTED OPERATING EXP' and cln.c_line = 'Non-Operating Income-Expenses' then true
                  else false
              end as c_sub
        from cln
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'W_SHERATON_MALDIVES'::varchar                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_W_SHERATON_MALDIVES_FIN_PL_MONTHLY'::varchar      as source_table
        , cln2.c_site::varchar                                                  as source_site_code
        , cln2.hotel_name::varchar                                              as asset_name
        , cln2.c_sec::varchar                                                   as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln2.c_line::varchar                                                  as source_item_id
        , coalesce(cln2.c_line, '~BLANK~')::varchar                             as account_key
        , iff(cln2.c_is_stat, 'STATISTIC', 'AMOUNT')::varchar                   as record_type
        , iff(cln2.c_is_stat, 'KEY STATISTICS section, GOP MARGIN or a validation hours line: STATISTIC (build 22 M1)', 'line amount: AMOUNT (build 22 M1)')::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln2.line_item::varchar                                               as account_desc
        , cln2.period_date::date                                                as period_end
        , cln2.m_scenario::varchar                                              as scenario
        , iff(cln2.c_is_stat, null, cln2.m_amount)::float                       as source_amount
        , iff(cln2.c_is_stat, cln2.m_amount, null)::float                       as stat_value
        , 'PRESENTED'::varchar                                                  as source_sign_convention
        , 'presented-positive: revenue and costs positive (build 22 M1, D-50)'::varchar as source_sign_convention_source
        , cln2.c_sub::boolean                                                   as is_subtotal
        , (case
              when cln2.c_sec = 'DEPARTMENT PROFIT' and cln2.c_line <> 'TOTAL FOOD & BEVERAGE' then 'DEPARTMENT PROFIT: computed departmental profit, source rollup (owner Q-15, as JW_VENICE)'
              when cln2.c_line like '%| #%' then 'repeat of an earlier line: D-48 in transformation'
              when cln2.c_sub and cln2.c_sec = 'VALIDATION OF PROFIT CON' and cln2.c_line in ('ALL ACTIVITY IN 048X', 'ALL ACTIVITY IN 0490', 'DIFFERENCE OF UNALL PFT') then 'control-check line: source rollup (owner Q-13, build 22)'
              when cln2.c_sub and cln2.c_sec = 'VALIDATION OF PROFIT CON' then 'validation line restating another line or all zero (owner Q-12, build 22 M3)'
              when cln2.c_sub and cln2.c_line in ('TOTAL NON-OP INC/EXP') then 'named total; does not tie, the source does not show all its detail (owner Q-11, N-57)'
              when cln2.c_sub and cln2.c_sec = 'DEPARTMENT PROFIT' and cln2.c_line = 'TOTAL FOOD & BEVERAGE' then 'named total; does not tie, the source does not show all its detail (owner Q-11, N-57)'
              when cln2.c_sub then 'named total, ties to its detail in every month (owner Q-05, build 22 M2)'
              else 'not a total by name, or a total that does not tie (detail)'
          end)::varchar                                                         as subtotal_source
        , (coalesce(cln2.hotel_code, '~BLANK~')
            || '|' || coalesce(cln2.section, '~BLANK~')
            || '|' || coalesce(cln2.line_item, '~BLANK~')
            || '|' || coalesce(to_char(cln2.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || 'MONTH'
            || '|' || cln2.measure_column)::varchar                             as source_line_key
        , cln2.measure_column::varchar                                          as measure_column
        , 'MONTH'::varchar                                as period_type_std
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln2.source_folder
        , cln2.portfolio_name
        , cln2.hotel_code
        , cln2.hotel_name
        , cln2.section
        , cln2.line_item
        , cln2.period_date
        , cln2.line_order
        , cln2.is_subtotal as src_is_subtotal
        , cln2.actual_amount
        , cln2.forecast_amount
        , cln2.budget_amount
        , cln2.actual_source_scenario
        , cln2.report_date
        , cln2.file_date
        , cln2.source_file_path
    from cln2
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_MONTHLY);
    return 'STG_W_SHERATON_MALDIVES_PL_MONTHLY rows=' || v_rows;
end;
$$;
