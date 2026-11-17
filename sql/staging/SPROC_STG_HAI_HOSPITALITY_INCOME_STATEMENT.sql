CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HAI_HOSPITALITY_INCOME_STATEMENT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HAI_HOSPITALITY_INCOME_STATEMENT  (build 26, new lane)
-- Builds STAGING.STG_HAI_HOSPITALITY_INCOME_STATEMENT from
-- CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT. Fact table.
-- Identity form: wide by category, 2 branches (AMOUNT_ACTUAL, AMOUNT_BUDGET;
--   owner Q-05), nulls kept: count(staged) = count(source) x 2.
--   Forecast: not in landed data.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Grain: location x fiscal period x calendar month x account (unique, M1). A
--   fiscal period spanning calendar months has one line per month, splitting
--   the period's actual; the lines add, they do not repeat.
-- Site = HH_MST_LOC_KEY (null on 4 lines: the key sentinel applies, owner
--   Q-11); ASSET_NAME = LOCATION_NAME. No department: DEPARTMENT null.
--   ACCOUNT_KEY = ACCOUNT_NUMBER. Every line AMOUNT (no statistic lines).
-- PERIOD_END = PERIOD_END (fiscal period end, a Sunday).
-- SCENARIO = the branch's source column name, AMOUNT_ACTUAL / AMOUNT_BUDGET
--   (D-45; owner Q-05).
-- CURRENCY_CODE USD: owner assumption (Q-07; UCHI and LORO are US brands).
-- SOURCE_SIGN_CONVENTION PRESENTED (sales, costs positive; discounts negative;
--   build 26 M1; D-50). IS_SUBTOTAL false: no total lines (M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HAI_HOSPITALITY_INCOME_STATEMENT as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'AMOUNT_ACTUAL'::varchar as m_scenario, src.amount_actual as m_amount from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'AMOUNT_BUDGET'::varchar as m_scenario, src.amount_budget as m_amount from src
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              unp.*
            , nullif(trim(unp.hh_mst_loc_key), '')  as c_site
            , nullif(trim(unp.account_number), '')  as c_acct
        from unp
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HAI_HOSPITALITY'::varchar                                            as source_lane
        , 'CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT'::varchar        as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.location_name::varchar                                            as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , cln.account_number::varchar                                           as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(cln.c_acct, '~BLANK~')::varchar                              as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every line is money; the source has no statistic lines (build 26 M1)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account_name::varchar                                             as account_desc
        , cln.period_end::date                                                  as period_end
        , cln.m_scenario::varchar                                               as scenario
        , cln.m_amount::float                                                   as source_amount
        , null::float                                                           as stat_value
        , 'USD'::varchar                                                        as currency_code
        , 'PRESENTED'::varchar                                                  as source_sign_convention
        , 'sales and costs positive, discounts negative (build 26 M1; D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'no total lines; every account carries one leaf hierarchy (build 26 M1)'::varchar as subtotal_source
        , (coalesce(cln.hh_mst_loc_key, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_end, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(to_char(cln.calendar_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(cln.account_number, '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.comp_status_period, cln.hh_mst_loc_key, cln.location_name, cln.calendar_date, cln.fiscal_date
        , cln.fiscal_month_year, cln.fiscal_quarter_year, cln.fiscal_period, cln.fiscal_quarter, cln.fiscal_year
        , cln.period_start, cln.period_end as src_period_end, cln.restaurant_flag, cln.location_type, cln.legal_entity_name
        , cln.brand, cln.concept, cln.market, cln.comp_status, cln.comp_status_dynamic, cln.cost_class
        , cln.gl_parent_group, cln.root_account_number, cln.lvl1_account_number, cln.account_number as src_account_number
        , cln.gl_account_name, cln.excel_account_number, cln.excel_account_name, cln.excel_summary_hierarchy
        , cln.hierarchy_level_1, cln.hierarchy_level_2, cln.hierarchy_level_3, cln.hierarchy_level_4, cln.hierarchy_level_5
        , cln.account_name, cln.amount_actual, cln.amount_budget, cln.running_period_number, cln.running_quarter_number
        , cln.sort_order, cln.record_create_date
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HAI_HOSPITALITY_INCOME_STATEMENT);
    return 'STG_HAI_HOSPITALITY_INCOME_STATEMENT rows=' || v_rows;
end;
$$;
