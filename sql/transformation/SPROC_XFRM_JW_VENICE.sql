CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_JW_VENICE(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_JW_VENICE
-- Builds the five transformation streams for lane JW_VENICE from one join (D-23):
--   XFRM_JW_VENICE_INCOME_STATEMENT   H1 Revenue, Expense, Below the Line,
--                               Allocations & Reserves
--   XFRM_JW_VENICE_BALANCE_SHEET      H1 Balance Sheet
--   XFRM_JW_VENICE_OPERATING_METRICS  H1 Statistic
--   XFRM_JW_VENICE_PACING             routed on source, own columns (D-24)
--   XFRM_JW_VENICE_UNKNOWN            H1 Unclassified, or category unresolved, or
--                               the losing row of a D-48 precedence rule
-- Fact rows joined once to the classification on the five-part key,
-- sentinel-coalesced identically to the seeder. Facts: FCAST_ACT_FORECAST, FCAST_BY_PERIOD, FTE, HEADCOUNT,
-- MONTHLY_PL_DEPT (build 12, D-44 rebuild).
-- Category (section 6), row by row, from the branch (MEASURE_COLUMN):
--   ACTUAL, FORECAST, BUDGET -> themselves;
--   PREVIOUS_FORECAST -> FORECAST, its scenario PREVIOUS_FORECAST_AMOUNT kept; anything else unresolved.
-- UNKNOWN_REASON: SOURCE_ROLLUP for a source subtotal or computed line
--   (IS_SUBTOTAL, key Unclassified at the seeder); UNCLASSIFIED_ACCOUNT for any
--   other Unclassified key.
-- Source precedence (D-48, owner build 12): a classified row that loses goes to
-- UNKNOWN as DUPLICATE_DETAIL, keeping H1-H5; an unclassified row keeps its own
-- reason (SOURCE_ROLLUP / UNCLASSIFIED_ACCOUNT). The row loses when:
--   (Q-02) FCAST_ACT_FORECAST or FCAST_BY_PERIOD, ACTUAL, period 2025-08 or
--          2026-08: MONTHLY_PL_DEPT beats it; every other FCAST month stays;
--   (Q-03) MONTHLY_PL_DEPT PERIOD_TYPE YTD: MONTH beats it;
--   (Q-09) MONTHLY_PL_DEPT department sheet other than TOT_HTL: TOT_HTL's
--          GL-account rows are the detail;
--   (Q-11) MONTHLY_PL_DEPT repeated 98xxxx hours block ('<code> | <text> | #n'):
--          the first block beats it.
-- Pacing (build 19, owner item 11): PACE_OTB_DAILY and PACE_SEGMENT_MONTHLY
--   (as-of SNAPSHOT_DATE), unioned in their own columns.
-- Build 19 (owner Q-10): CAPEX added as a fact (MEASURE_COLUMN ACTUAL -> ACTUAL);
--   its keys are Statistic / FIN_CAPEX, so it routes to operating metrics.
-- SCENARIO is carried verbatim; category never replaces it (D-17).
-- SOURCE_AMOUNT and STAT_VALUE unchanged.
-- No filter, no aggregation. The scratch table is dropped before return.
-- Built from the lane-independent text of SPROC_XFRM_JW_VENICE.
-- Build 15 (D-50, owner Q-03): VALUE follows the staged SOURCE_SIGN_CONVENTION:
--   DEBIT -SOURCE_AMOUNT, PROFIT SOURCE_AMOUNT, PRESENTED SOURCE_AMOUNT x
--   VALUE_SIGN; null wherever VALUE_SIGN is null. This lane: PRESENTED (every table).
--   SOURCE_SIGN_CONVENTION and its source are carried on every stream.
-- Build 16: source-table literals use the new CLN.BOX_INVESTMENT_DATA names
-- (CLN_UTIL_TABLE_MAP); same tables, same rows, logic unchanged.
-- ============================================================================
declare
    v_is  integer;
    v_bs  integer;
    v_om  integer;
    v_pc  integer;
    v_un  integer;
begin
    create or replace temporary table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_JW_VENICE_ROWS as
    with
    -- ------------------------------------------------------------------------
    -- CLASSIFICATION SOURCE: swap to the master at promotion
    -- ------------------------------------------------------------------------
    cls as (
        select
              source_lane
            , source_site_code
            , department
            , account_key
            , record_type
            , h1
            , h2
            , h3
            , h4
            , h5
            , p_l_section
            , normal_balance
            , value_sign
            , metric_unit
            , aggregation_type
        from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION
    )
    -- ------------------------------------------------------------------------
    -- fact staging rows
    -- ------------------------------------------------------------------------
    , fact as (
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , false as is_mpd, null::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , false as is_mpd, null::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , false as is_mpd, null::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_FTE
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , false as is_mpd, null::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , true as is_mpd, period_type::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , false as is_mpd, null::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_JW_VENICE_CAPEX
    )
    -- ------------------------------------------------------------------------
    -- category, row by row, from the branch; D-48 flag
    -- ------------------------------------------------------------------------
    , cat as (
        select
              fact.*
            , case
                  when fact.measure_column = 'ACTUAL'            then 'ACTUAL'
                  when fact.measure_column = 'FORECAST'          then 'FORECAST'
                  when fact.measure_column = 'PREVIOUS_FORECAST' then 'FORECAST'
                  when fact.measure_column = 'BUDGET'            then 'BUDGET'
              end as category
            , coalesce(fact.measure_column, '~BLANK~') as category_input
            , (case
                  when not fact.is_mpd
                   and fact.source_table in ('CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY', 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY')
                   and fact.measure_column = 'ACTUAL'
                   and fact.period_end in ('2025-08-31'::date, '2026-08-31'::date)  then true
                  when fact.is_mpd and fact.period_type = 'YTD'                   then true
                  when fact.is_mpd and fact.department <> 'TOT_HTL'               then true
                  when fact.is_mpd and regexp_like(fact.account_key, '98[0-9]{4} [|] .* [|] #[0-9]+') then true
                  else false
              end)::boolean as d48_loses
        from fact
        where 1=1
    )
    -- ------------------------------------------------------------------------
    -- the one join to the classification
    -- ------------------------------------------------------------------------
    select
          :P_RUN_ID::varchar                                   as run_id
        , cat.source_lane::varchar                             as source_lane
        , cat.source_site_code::varchar                        as source_site_code
        , cat.asset_name::varchar                              as asset_name
        , cat.department::varchar                              as department
        , cat.department_name::varchar                         as department_name
        , cat.account_number::varchar                          as account_number
        , cat.stat_account::varchar                            as stat_account
        , cat.account_key::varchar                             as account_key
        , cat.record_type::varchar                             as record_type
        , cat.record_type_source::varchar                      as record_type_source
        , cat.stat_unit_family::varchar                        as stat_unit_family
        , cat.account_desc::varchar                            as account_desc
        , cat.period_end::date                                 as period_end
        , cat.category::varchar                                as category
        , cat.scenario::varchar                                as scenario
        , cls.h1::varchar                                      as h1
        , cls.h2::varchar                                      as h2
        , cls.h3::varchar                                      as h3
        , cls.h4::varchar                                      as h4
        , cls.h5::varchar                                      as h5
        , cls.p_l_section::varchar                             as p_l_section
        , cls.normal_balance::varchar                          as normal_balance
        , cat.is_subtotal::boolean                             as is_subtotal
        , cat.subtotal_source::varchar                         as subtotal_source
        , cat.source_amount::float                             as source_amount
        , cat.stat_value::float                                as stat_value
        , cat.source_line_key::varchar                         as source_line_key
        , cat.source_table::varchar                            as source_table
        , cls.value_sign::number(2,0)                          as value_sign
        , (case
              when cls.value_sign is null                          then null
              when cat.source_sign_convention = 'DEBIT'            then -cat.source_amount
              when cat.source_sign_convention = 'PROFIT'           then cat.source_amount
              else cat.source_amount * cls.value_sign
          end)::float                                   as value
        , cls.metric_unit::varchar                             as metric_unit
        , cat.source_sign_convention::varchar                  as source_sign_convention
        , cat.source_sign_convention_source::varchar           as source_sign_convention_source
        , cls.aggregation_type::varchar                        as aggregation_type
        , case
              when cat.d48_loses and cls.h1 <> 'Unclassified'       then 'DUPLICATE_DETAIL'
              when cls.h1 = 'Unclassified' and cat.category is null then 'BOTH'
              when cls.h1 = 'Unclassified' and cat.is_subtotal      then 'SOURCE_ROLLUP'
              when cls.h1 = 'Unclassified'                          then 'UNCLASSIFIED_ACCOUNT'
              when cat.category is null                             then 'UNRESOLVED_CATEGORY'
          end::varchar                                         as unknown_reason
        , case
              when cat.category is null then cat.category_input
          end::varchar                                         as unresolved_category_value
    from cat
    left join cls
        on  cls.source_lane      = coalesce(nullif(trim(cat.source_lane), ''), '~BLANK~')
        and cls.source_site_code = coalesce(nullif(trim(cat.source_site_code), ''), '~BLANK~')
        and cls.department       = coalesce(nullif(trim(cat.department), ''), '~BLANK~')
        and cls.account_key      = coalesce(nullif(trim(cat.account_key), ''), '~BLANK~')
        and cls.record_type      = coalesce(nullif(trim(cat.record_type), ''), '~BLANK~')
    where 1=1;

    -- ------------------------------------------------------------------------
    -- income statement
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_JW_VENICE_ROWS
    where 1=1
      and unknown_reason is null
      and h1 in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves');

    -- ------------------------------------------------------------------------
    -- balance sheet
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_JW_VENICE_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Balance Sheet';

    -- ------------------------------------------------------------------------
    -- operating metrics
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_JW_VENICE_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Statistic';

    -- ------------------------------------------------------------------------
    -- unknown: H1-H5 kept where the account resolved, nulled where it did not
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN as
    select
          run_id, source_lane, source_site_code, asset_name, department, department_name
        , account_number, stat_account, account_key, record_type, record_type_source
        , stat_unit_family, account_desc, period_end, category, scenario
        , iff(h1 = 'Unclassified', null, h1)::varchar as h1
        , iff(h1 = 'Unclassified', null, h2)::varchar as h2
        , iff(h1 = 'Unclassified', null, h3)::varchar as h3
        , iff(h1 = 'Unclassified', null, h4)::varchar as h4
        , iff(h1 = 'Unclassified', null, h5)::varchar as h5
        , p_l_section, normal_balance, is_subtotal, subtotal_source
        , source_amount, stat_value, source_line_key, source_table
        , value_sign, value, metric_unit, aggregation_type
        , source_sign_convention, source_sign_convention_source
        , unknown_reason, unresolved_category_value
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_JW_VENICE_ROWS
    where 1=1
      and (unknown_reason is not null
           or h1 is null
           or h1 not in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves', 'Balance Sheet', 'Statistic'));

    -- ------------------------------------------------------------------------
    -- pacing: routed on source, own columns (D-24), never classified; the
    -- union of the lane's pace tables, a typed null where a table lacks a
    -- column (build 19: PACE_OTB_DAILY, PACE_SEGMENT_MONTHLY)
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING as
    select
          :P_RUN_ID::varchar as run_id
        , source_lane::varchar as source_lane
        , source_table::varchar as source_table
        , source_folder::varchar as source_folder
        , property_name::varchar as property_name
        , snapshot_date::date as snapshot_date
        , stay_date::date as stay_date
        , day_of_week::varchar as day_of_week
        , occupancy::number(38,6) as occupancy
        , rooms_transient::number(38,6) as rooms_transient
        , rooms_group_deduct::number(38,6) as rooms_group_deduct
        , rooms_comp_house::number(38,6) as rooms_comp_house
        , rooms_total::number(38,6) as rooms_total
        , null::varchar as report_block
        , null::varchar as market_segment
        , null::date as stay_month
        , null::number(38,6) as room_nights
        , null::number(38,6) as room_revenue
        , null::number(38,6) as adr
        , null::varchar as source_tab
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_JW_VENICE_PACE_OTB_DAILY
    where 1=1
    union all
    select
          :P_RUN_ID::varchar as run_id
        , source_lane::varchar as source_lane
        , source_table::varchar as source_table
        , source_folder::varchar as source_folder
        , property_name::varchar as property_name
        , snapshot_date::date as snapshot_date
        , null::date as stay_date
        , null::varchar as day_of_week
        , null::number(38,6) as occupancy
        , null::number(38,6) as rooms_transient
        , null::number(38,6) as rooms_group_deduct
        , null::number(38,6) as rooms_comp_house
        , null::number(38,6) as rooms_total
        , report_block::varchar as report_block
        , market_segment::varchar as market_segment
        , stay_month::date as stay_month
        , room_nights::number(38,6) as room_nights
        , room_revenue::number(38,6) as room_revenue
        , adr::number(38,6) as adr
        , source_tab::varchar as source_tab
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_JW_VENICE_PACE_SEGMENT_MONTHLY
    where 1=1;

    drop table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_JW_VENICE_ROWS;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN);
    return 'XFRM_JW_VENICE is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
