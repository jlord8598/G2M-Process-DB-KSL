CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_THIRD_SPACE_PL_MONTHLY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_THIRD_SPACE_PL_MONTHLY  (build 22, new lane)
-- Builds STAGING.STG_THIRD_SPACE_PL_MONTHLY from
-- CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_FIN_PL_MONTHLY. Fact table.
-- Identity form: wide by category, 2 branches (ACTUAL_AMOUNT, FORECAST_AMOUNT),
-- nulls kept: count(staged) = count(source) x 2. Budget: not in landed data.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = ENTITY (clubs, corporate and group entities alike); ASSET_NAME =
-- ENTITY. No account codes: DEPARTMENT = SECTION, ACCOUNT_KEY = LINE_ITEM (as
-- SOURCE_ITEM_ID); classification is by line name, not section (owner Q-09:
-- SECTION is shifted on some lines). REPORT_SHEET (CLUBS / CORP) carried;
-- CLUBS beats CORP under D-48 in transformation (owner Q-08).
-- RECORD_TYPE: the KPIs lines (member counts, adds, losses, freezes, PT
-- sessions, visits) STATISTIC (owner Q-10); else AMOUNT.
-- IS_SUBTOTAL: the source's IS_SUBTOTAL (verified at M1: Revenue - Total equals
-- its detail for 14 / 14 clubs), plus Gross Profit, Club EBITDA, Club Adjusted
-- EBITDA (= revenue - cost of sales, - expenses, + adjustments in 416 / 416
-- club-months) and HOC Adjusted EBITDA (= its total + corporate adjustments,
-- 33 / 33 months), build 22 M3.
-- Build 22 M4: the source-flagged totals that are the only line of their kind
-- (Expenses - Payroll - Total, Total Visits, Total Debt, Total Capex, Total
-- Cash, Total Head Office Costs, Total NFF Central Costs) are detail, as
-- THE_PIG Q-04; Expenses - Total includes payroll (416 / 416 club-months).
-- Owner Q-15 (stop 4): NFF Central Adjusted EBITDA is a computed line, a
-- source rollup.
-- SCENARIO = the branch's measure column name (D-45).
-- SOURCE_SIGN_CONVENTION PRESENTED (revenue and costs positive, M1; D-50).
-- SOURCE_LINE_KEY: sheet | entity | section | line | period | branch (unique).
-- Currency GBP is an owner assumption (Q-06), set in semantic.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_THIRD_SPACE_PL_MONTHLY as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_FIN_PL_MONTHLY
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
    -- cleaned key inputs and per-line rules
    -- ------------------------------------------------------------------------
    , cln as (
        select
              unp.*
            , nullif(trim(unp.entity), '')     as c_site
            , nullif(trim(unp.section), '')    as c_sec
            , nullif(trim(unp.line_item), '')  as c_line
            , coalesce(trim(unp.line_item) in ('Beginning Membership Count', 'Closing Members', 'Membership - Net Freeze', 'Membership Adds', 'Membership Losses', 'Personal Training Sessions', 'Total Visits'), false) as c_is_stat
            , ((coalesce(unp.is_subtotal, false) and not coalesce(trim(unp.line_item) in ('Expenses - Payroll - Total', 'Total Visits', 'Total Debt', 'Total Capex', 'Total Cash', 'Total Head Office Costs', 'Total NFF Central Costs'), false))
               or coalesce(trim(unp.line_item) in ('Gross Profit', 'Club EBITDA', 'Club Adjusted EBITDA', 'HOC Adjusted EBITDA', 'NFF Central Adjusted EBITDA'), false)) as c_sub
        from unp
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'THIRD_SPACE'::varchar                                                as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_FIN_PL_MONTHLY'::varchar     as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.entity::varchar                                                   as asset_name
        , cln.c_sec::varchar                                                    as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_line::varchar                                                   as source_item_id
        , coalesce(cln.c_line, '~BLANK~')::varchar                              as account_key
        , iff(cln.c_is_stat, 'STATISTIC', 'AMOUNT')::varchar                    as record_type
        , iff(cln.c_is_stat, 'KPIs line (member counts, flows, sessions, visits): STATISTIC (owner Q-10)', 'line amount: AMOUNT (build 22 M1)')::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_item::varchar                                                as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_is_stat, null, cln.m_amount)::float                         as source_amount
        , iff(cln.c_is_stat, cln.m_amount, null)::float                         as stat_value
        , 'PRESENTED'::varchar                                                  as source_sign_convention
        , 'presented-positive: revenue and costs positive (build 22 M1, D-50)'::varchar as source_sign_convention_source
        , cln.c_sub::boolean                                                    as is_subtotal
        , (case
              when coalesce(cln.is_subtotal, false) and coalesce(trim(cln.line_item) in ('Expenses - Payroll - Total', 'Total Visits', 'Total Debt', 'Total Capex', 'Total Cash', 'Total Head Office Costs', 'Total NFF Central Costs'), false) then 'source flags a total that is the only line of its kind (no detail beneath): detail (build 22 M4, as THE_PIG Q-04)'
              when coalesce(cln.is_subtotal, false) then 'source IS_SUBTOTAL (verified, build 22 M1)'
              when cln.c_sub and trim(cln.line_item) = 'NFF Central Adjusted EBITDA' then 'computed EBITDA line: source rollup (owner Q-15, build 22 stop 4)'
              when cln.c_sub then 'EBITDA-chain total, ties to its detail in every month (build 22 M3)'
              else 'source IS_SUBTOTAL false'
          end)::varchar                                                         as subtotal_source
        , (coalesce(cln.report_sheet, '~BLANK~')
            || '|' || coalesce(cln.entity, '~BLANK~')
            || '|' || coalesce(cln.section, '~BLANK~')
            || '|' || coalesce(cln.line_item, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.portfolio_name
        , cln.report_sheet
        , cln.entity
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.line_order
        , cln.is_subtotal as src_is_subtotal
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_report_date
        , cln.forecast_report_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.forecast_source_file_path
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_THIRD_SPACE_PL_MONTHLY);
    return 'STG_THIRD_SPACE_PL_MONTHLY rows=' || v_rows;
end;
$$;
