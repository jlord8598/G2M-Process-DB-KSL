CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_NEWBURY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_NEWBURY
-- Builds the five transformation streams for lane NEWBURY from one join (D-23):
--   XFRM_NEWBURY_INCOME_STATEMENT   H1 Revenue, Expense, Below the Line,
--                                 Allocations & Reserves
--   XFRM_NEWBURY_BALANCE_SHEET      H1 Balance Sheet
--   XFRM_NEWBURY_OPERATING_METRICS  H1 Statistic
--   XFRM_NEWBURY_PACING             routed on source, own columns (D-24)
--   XFRM_NEWBURY_UNKNOWN            H1 Unclassified, or category unresolved
-- Fact rows: the three fact staging tables, joined once to the classification
-- on the five-part key, sentinel-coalesced identically to the seeder.
-- Category (section 6), row by row:
--   TRIAL_BALANCE          MEASURE_COLUMN ACTUAL_AMOUNT -> ACTUAL,
--                          BUDGET_AMOUNT -> BUDGET, FORECAST_AMOUNT -> FORECAST
--   OPERATING_STATS_BGT    SCENARIO Budget -> BUDGET (owner Q-12)
--   OPERATING_STATS_PYACT  SCENARIO Actual -> ACTUAL (owner Q-12)
--   anything else unresolved
-- SCENARIO is carried verbatim; category never replaces it (D-17).
-- VALUE = SOURCE_AMOUNT * VALUE_SIGN. SOURCE_AMOUNT and STAT_VALUE unchanged.
-- No filter, no aggregation. The scratch table is dropped before return.
-- Built from the lane-independent text of SPROC_XFRM_PEREGRINE_RESORTS.
-- ============================================================================
declare
    v_is  integer;
    v_bs  integer;
    v_om  integer;
    v_pc  integer;
    v_un  integer;
begin
    create or replace temporary table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_NEWBURY_ROWS as
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
        from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, null::varchar as measure_column
        from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, null::varchar as measure_column
        from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
    )
    -- ------------------------------------------------------------------------
    -- category, row by row
    -- ------------------------------------------------------------------------
    , cat as (
        select
              fact.*
            , case
                  when fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE' and fact.measure_column = 'ACTUAL_AMOUNT'
                      then 'ACTUAL'
                  when fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE' and fact.measure_column = 'BUDGET_AMOUNT'
                      then 'BUDGET'
                  when fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE' and fact.measure_column = 'FORECAST_AMOUNT'
                      then 'FORECAST'
                  when fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT' and fact.scenario = 'Budget'
                      then 'BUDGET'
                  when fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT' and fact.scenario = 'Actual'
                      then 'ACTUAL'
              end as category
            , case
                  when fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE' then coalesce(fact.measure_column, '~BLANK~')
                  else coalesce(fact.scenario, '~BLANK~')
              end as category_input
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
        , (cat.source_amount * cls.value_sign)::float          as value
        , cls.metric_unit::varchar                             as metric_unit
        , cls.aggregation_type::varchar                        as aggregation_type
        , case
              when cls.h1 = 'Unclassified' and cat.category is null then 'BOTH'
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_NEWBURY_ROWS
    where 1=1
      and unknown_reason is null
      and h1 in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves');

    -- ------------------------------------------------------------------------
    -- balance sheet
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_NEWBURY_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Balance Sheet';

    -- ------------------------------------------------------------------------
    -- operating metrics
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_NEWBURY_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Statistic';

    -- ------------------------------------------------------------------------
    -- unknown: H1-H5 kept where the account resolved, nulled where it did not
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN as
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
        , unknown_reason, unresolved_category_value
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_NEWBURY_ROWS
    where 1=1
      and (unknown_reason is not null
           or h1 is null
           or h1 not in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves', 'Balance Sheet', 'Statistic'));

    -- ------------------------------------------------------------------------
    -- pacing: routed on source, own columns (D-24), never classified.
    -- Four sources, one stream (Q-20): the union of their columns, each source
    -- filling its own and null elsewhere. AS_OF_DATE is the source's own
    -- as-of column, named in AS_OF_SOURCE: OTB REPORT_DATE, FCST
    -- FILE_REPORT_DATE (owner Q-12), SHOPS REPORTED_DATE (owner Q-13).
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING as
    select
          :P_RUN_ID::varchar as run_id
        , source_lane
        , source_table
        , file_report_date::date as as_of_date
        , 'FILE_REPORT_DATE'::varchar as as_of_source
        , source_folder::varchar as source_folder
        , property_name::varchar as property_name
        , hotel_id::varchar as hotel_id
        , null::varchar as hotel_name
        , null::varchar as shop_hotel_id
        , null::varchar as comp_hotel_name
        , null::date as report_date
        , null::date as reported_date
        , stay_date::date as stay_date
        , scenario::varchar as scenario
        , year_month::varchar as year_month
        , null::varchar as market_segment
        , null::varchar as ota
        , null::boolean as is_bar
        , null::number(38,6) as rate_value
        , null::varchar as room_name
        , null::varchar as room_type
        , null::varchar as rate_comment
        , rooms::number(38,6) as rooms
        , revenue::number(38,6) as revenue
        , null::number(38,6) as available_rooms
        , null::varchar as postpd
        , null::varchar as data_source
        , null::varchar as data_type
        , file_report_date::date as file_report_date
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST
    where 1=1
    union all
    select
          :P_RUN_ID::varchar as run_id
        , source_lane
        , source_table
        , reported_date::date as as_of_date
        , 'REPORTED_DATE'::varchar as as_of_source
        , source_folder::varchar as source_folder
        , property_name::varchar as property_name
        , null::varchar as hotel_id
        , null::varchar as hotel_name
        , shop_hotel_id::varchar as shop_hotel_id
        , comp_hotel_name::varchar as comp_hotel_name
        , null::date as report_date
        , reported_date::date as reported_date
        , stay_date::date as stay_date
        , null::varchar as scenario
        , null::varchar as year_month
        , null::varchar as market_segment
        , ota::varchar as ota
        , is_bar::boolean as is_bar
        , rate_value::number(38,6) as rate_value
        , room_name::varchar as room_name
        , room_type::varchar as room_type
        , rate_comment::varchar as rate_comment
        , null::number(38,6) as rooms
        , null::number(38,6) as revenue
        , null::number(38,6) as available_rooms
        , null::varchar as postpd
        , null::varchar as data_source
        , null::varchar as data_type
        , file_report_date::date as file_report_date
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS
    where 1=1
    union all
    select
          :P_RUN_ID::varchar as run_id
        , source_lane
        , source_table
        , report_date::date as as_of_date
        , 'REPORT_DATE'::varchar as as_of_source
        , source_folder::varchar as source_folder
        , property_name::varchar as property_name
        , hotel_id::varchar as hotel_id
        , hotel_name::varchar as hotel_name
        , null::varchar as shop_hotel_id
        , null::varchar as comp_hotel_name
        , report_date::date as report_date
        , null::date as reported_date
        , stay_date::date as stay_date
        , null::varchar as scenario
        , year_month::varchar as year_month
        , market_segment::varchar as market_segment
        , null::varchar as ota
        , null::boolean as is_bar
        , null::number(38,6) as rate_value
        , null::varchar as room_name
        , null::varchar as room_type
        , null::varchar as rate_comment
        , rooms::number(38,6) as rooms
        , revenue::number(38,6) as revenue
        , available_rooms::number(38,6) as available_rooms
        , postpd::varchar as postpd
        , data_source::varchar as data_source
        , data_type::varchar as data_type
        , file_report_date::date as file_report_date
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_1DAY_PICKUP
    where 1=1
    union all
    select
          :P_RUN_ID::varchar as run_id
        , source_lane
        , source_table
        , report_date::date as as_of_date
        , 'REPORT_DATE'::varchar as as_of_source
        , source_folder::varchar as source_folder
        , property_name::varchar as property_name
        , hotel_id::varchar as hotel_id
        , hotel_name::varchar as hotel_name
        , null::varchar as shop_hotel_id
        , null::varchar as comp_hotel_name
        , report_date::date as report_date
        , null::date as reported_date
        , stay_date::date as stay_date
        , null::varchar as scenario
        , year_month::varchar as year_month
        , market_segment::varchar as market_segment
        , null::varchar as ota
        , null::boolean as is_bar
        , null::number(38,6) as rate_value
        , null::varchar as room_name
        , null::varchar as room_type
        , null::varchar as rate_comment
        , rooms::number(38,6) as rooms
        , revenue::number(38,6) as revenue
        , available_rooms::number(38,6) as available_rooms
        , postpd::varchar as postpd
        , data_source::varchar as data_source
        , data_type::varchar as data_type
        , file_report_date::date as file_report_date
        , file_date::timestamp_tz as file_date
        , source_file_path::varchar as source_file_path
        , source_row_number::number(38,0) as source_row_number
    from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP
    where 1=1
    ;

    drop table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_NEWBURY_ROWS;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN);
    return 'XFRM_NEWBURY is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
