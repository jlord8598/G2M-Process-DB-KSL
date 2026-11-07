CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_JW_VENICE_MONTHLY_PL_DEPT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_JW_VENICE_MONTHLY_PL_DEPT
-- Builds STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT from
-- CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT.
-- Fact table: the monthly departmental P&L (AUG - PL.xlsm), 17 sheets.
-- Identity form: wide by category, 2 branches (ACTUAL_AMOUNT, BUDGET_AMOUNT),
-- nulls kept: count(staged) = count(source) x 2. FORECAST_AMOUNT is always
-- null in the source (M1) and has no branch; it is carried raw.
-- Key: SITE = PROPERTY_NAME; DEPARTMENT = DEPARTMENT (the sheet);
-- ACCOUNT_KEY = LINE_ITEM as SOURCE_ITEM_ID (D-06). Joins 100% to ACCOUNTS.
-- RECORD_TYPE derived: 98xxxx hours accounts, 4-digit statistic codes and the
-- named statistics -> STATISTIC; GL accounts and named money lines -> AMOUNT.
-- IS_SUBTOTAL: every named money line (Q-16, M1: each equals its family in
-- 100% of cells) and the four named hours lines. TOT_HTL is NOT marked: its
-- GL-account rows are the lane's detail (owner Q-09); the department sheets
-- and the YTD rows lose to it under D-48 in transformation.
-- SCENARIO (D-45): the ACTUAL branch carries ACTUAL_SOURCE_SCENARIO verbatim
-- (ACTUAL, LAST YEAR); the BUDGET branch carries BUDGET_AMOUNT.
-- PERIOD_TYPE (MONTH, YTD) is carried raw on every row and in SOURCE_LINE_KEY.
-- The source's DEPARTMENT and IS_SUBTOTAL are carried as SRC_DEPARTMENT and
-- SRC_IS_SUBTOTAL. Signs as booked.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Build 15 (D-50): SOURCE_SIGN_CONVENTION PRESENTED for every row, with its evidence
-- in SOURCE_SIGN_CONVENTION_SOURCE; applied in transformation.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, src.actual_source_scenario::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_cell as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.budget_source_file_path as m_path, src.budget_source_cell as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '98[0-9]{4}')
                    or regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?')
                    or unp.line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House') then 'STATISTIC'
                  else 'AMOUNT' end) as c_rtype
            , (case
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '98[0-9]{4}') then 'LINE_ITEM 98xxxx hours account: STATISTIC (derived, M1)'
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?') then 'LINE_ITEM 4-digit statistic code: STATISTIC (derived, M1)'
                  when unp.line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House') then 'LINE_ITEM named statistic: STATISTIC (derived, M1)'
                  else 'LINE_ITEM GL account or named money line: AMOUNT (derived, M1)' end) as c_rtype_source
            , (case
                  when unp.line_item in ('Non-management', 'Contract Labor', 'HOURS & HRS POR', 'HOURS (incl. NE Mgrs) & HRS POR') then true
                  when c_rtype = 'AMOUNT' and not regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{6}') then true
                  else false end) as c_subtotal
            , (case
                  when unp.line_item in ('Non-management', 'Contract Labor', 'HOURS & HRS POR', 'HOURS (incl. NE Mgrs) & HRS POR') then 'named hours line: total of its 98xxxx accounts (M3)'
                  when c_rtype = 'AMOUNT' and not regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{6}') then 'named money line: equals its family (Q-16, M1: 100% of cells)'
                  else 'GL account or statistic: detail' end) as c_subtotal_source
            , (coalesce(unp.department::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_order::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.period_type::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department), '')::varchar                                    as department
        , cln.department::varchar                                                   as department_name
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
        , cln.department as src_department
        , cln.is_rollup
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.period_type
        , cln.line_order
        , cln.is_subtotal as src_is_subtotal
        , cln.actual_amount
        , cln.forecast_amount
        , cln.budget_amount
        , cln.actual_source_scenario
        , cln.actual_report_as_of_date
        , cln.budget_report_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_cell
        , cln.budget_source_file_path
        , cln.budget_source_cell
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT);
    return 'STG_JW_VENICE_MONTHLY_PL_DEPT rows=' || v_rows;
end;
$$;
