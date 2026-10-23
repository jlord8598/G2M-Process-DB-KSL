CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_FULL_YEAR_PL(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_FULL_YEAR_PL
-- Builds STAGING.STG_DAVIDSON_FULL_YEAR_PL from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL. Fact table.
-- Identity form: wide by category, 2 branches (ACTUAL_*, FORECAST_*), nulls kept:
-- count(staged) = count(source) x 2.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim;
-- the 12,684 rows repeating a line's dimensions are distinct source rows (M1).
-- Site = HOTEL_CODE, null on the IS_ROLLUP rows; ASSET_NAME = HOTEL_NAME (fact).
-- No account code: department = SECTION, ACCOUNT_KEY = LINE_ITEM (SOURCE_ITEM_ID,
-- trimmed and repeated spaces collapsed, nothing else; owner Q-05). No
-- department names.
-- RECORD_TYPE: the SUMMARY sheet's hotel-heading sections ("XXXXXX - name",
-- "[group]") hold ADR, occupancy, rooms and RevPar lines: STATISTIC; every
-- other line AMOUNT (Q-06). The branch amount is SOURCE_AMOUNT on AMOUNT rows
-- and STAT_VALUE on STATISTIC.
-- SCENARIO = the branch's measure column name (D-45).
-- IS_SUBTOTAL (Q-08): IS_ROLLUP; else a SUMMARY amount line (verified on one
-- line pair at M1, 204 of 204); else an AMOUNT LINE_ITEM whose first word is
-- Total (the statistic Total RevPar is a rate, not a sum of lines).
-- ACCOUNT_DESC from STG_DAVIDSON_ACCOUNTS, MIN per entity + string + source
-- table; the entity is HOTEL_CODE, or HOTEL_NAME on a roll-up (as the source's
-- dictionary keys it).
-- SOURCE_LINE_KEY: hotel, hotel name, sheet, section, line, period and the
-- four file/row pointers (unique at M1) plus branch.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_FULL_YEAR_PL as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL
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
            , nullif(trim(unp.hotel_code), '')                                   as c_site
            , nullif(trim(unp.section), '')                                      as c_dept
            , null::varchar                                                      as c_acct
            , null::varchar                                                      as c_stat
            , nullif(regexp_replace(trim(unp.line_item), ' {2,}', ' '), '')      as c_item
            , (unp.report_sheet = 'SUMMARY'
                and regexp_like(unp.section, '^\\[.*\\]$|^[A-Z]{6} ?-.*'))      as c_is_stat
            , regexp_like(unp.line_item, '^ *total( .*)?$', 'i')                 as c_total_word
        from unp
    )
    -- ------------------------------------------------------------------------
    -- account description dictionary, one value per string (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.entity_code
            , a.full_account_string
            , min(a.account_description) as account_description
        from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNTS a
        where 1=1
          and a.raw_source_table = 'CLN_DAVIDSON_FULL_YEAR_PL'
        group by a.entity_code, a.full_account_string
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'DAVIDSON'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL'::varchar          as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.hotel_name::varchar                                               as asset_name
        , cln.c_dept::varchar                                                   as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_is_stat then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_is_stat
                  then 'SUMMARY hotel-heading section: STATISTIC (rule; Q-06)'
              else 'not a SUMMARY hotel-heading section: AMOUNT (rule; Q-06)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_is_stat, null, cln.m_amount)::float                         as source_amount
        , iff(cln.c_is_stat, cln.m_amount, null)::float                         as stat_value
        , (coalesce(cln.is_rollup, false)
            or (cln.report_sheet = 'SUMMARY' and not cln.c_is_stat)
            or (coalesce(cln.c_total_word, false) and not cln.c_is_stat))::boolean as is_subtotal
        , case
              when cln.is_rollup
                  then 'IS_ROLLUP: source roll-up row (source flag; Q-08)'
              when cln.report_sheet = 'SUMMARY' and not cln.c_is_stat
                   and cln.line_item in ('Gross Operating Profit', 'EBITDA', 'EBITDA LESS REPLACEMENT RESERVE')
                  then 'SUMMARY computed line (GOP / EBITDA): subtotal (owner Q-08)'
              when cln.report_sheet = 'SUMMARY' and not cln.c_is_stat
                  then 'SUMMARY sheet amount line: total of ALL_DEPARTMENT (verified on one line pair; Q-08)'
              when cln.c_total_word and not cln.c_is_stat
                  then 'LINE_ITEM first word Total: source total line (structure; Q-08)'
              else 'not a roll-up, SUMMARY line or Total line'
          end::varchar                                                          as subtotal_source
        , (coalesce(cln.hotel_code, '~BLANK~')
            || '|' || coalesce(cln.hotel_name, '~BLANK~')
            || '|' || coalesce(cln.report_sheet, '~BLANK~')
            || '|' || coalesce(cln.section, '~BLANK~')
            || '|' || coalesce(cln.line_item, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(cln.actual_source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.actual_source_row_number), '~BLANK~')
            || '|' || coalesce(cln.forecast_source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.forecast_source_row_number), '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.hotel_code
        , cln.hotel_name
        , cln.is_rollup
        , cln.report_sheet
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_report_as_of_date
        , cln.forecast_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    left join acct
        on  acct.entity_code         = coalesce(cln.hotel_code, cln.hotel_name)
        and acct.full_account_string = cln.line_item
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_FULL_YEAR_PL);
    return 'STG_DAVIDSON_FULL_YEAR_PL rows=' || v_rows;
end;
$$;
