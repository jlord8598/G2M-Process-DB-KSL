CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_PEREGRINE_RESORTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_PEREGRINE_RESORTS
-- Builds the five transformation streams for lane PEREGRINE_RESORTS from one
-- join (D-23):
--   XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT   H1 Revenue, Expense,
--                                              Below the Line,
--                                              Allocations & Reserves
--   XFRM_PEREGRINE_RESORTS_BALANCE_SHEET      H1 Balance Sheet
--   XFRM_PEREGRINE_RESORTS_OPERATING_METRICS  H1 Statistic
--   XFRM_PEREGRINE_RESORTS_PACING             the three pace tables, own shape
--   XFRM_PEREGRINE_RESORTS_UNKNOWN            H1 Unclassified, or category
--                                              unresolved
-- Fact rows: the four fact staging tables, joined once to the classification
-- on the five-part key, sentinel-coalesced identically to the seeder.
-- Category (section 6), row by row:
--   DAILY_EXTENDED, LEDGER_BATCHES, DAILY_LABOR  by SOURCE_TABLE -> ACTUAL
--   MONTHLY_EXTENDED  FCID -> STG DATASETS: IS_ACTUALS -> ACTUAL; else exact
--                     scenario name: Budget, Budget 2 -> BUDGET;
--                     Primary Forecast, Forecast 2, Forecast 3 -> FORECAST;
--                     Flex, RMS - OneYield, RMS - HiltonGRO/IDeaS,
--                     5 Year Plan 2026 Final -> FORECAST (Q-04, owner);
--                     anything else unresolved
-- SCENARIO is carried verbatim; category never replaces it (D-17).
-- VALUE = SOURCE_AMOUNT * VALUE_SIGN. SOURCE_AMOUNT and STAT_VALUE unchanged.
-- No filter, no aggregation. The scratch table is dropped before return.
-- ============================================================================
declare
    v_is  integer;
    v_bs  integer;
    v_om  integer;
    v_pc  integer;
    v_un  integer;
begin
    create or replace temporary table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_PEREGRINE_RESORTS_ROWS as
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
             , is_subtotal, subtotal_source, source_line_key, source_table, null::number as fcid
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, fcid
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, null::number as fcid
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, null::number as fcid
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR
    )
    -- ------------------------------------------------------------------------
    -- scenario dictionary, unique on FCID (docs/sources.md)
    -- ------------------------------------------------------------------------
    , ds as (
        select fcid, scenario_name, is_actuals
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DATASETS
    )
    -- ------------------------------------------------------------------------
    -- category, row by row
    -- ------------------------------------------------------------------------
    , cat as (
        select
              fact.*
            , case
                  when fact.source_table in ( 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED'
                                            , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES'
                                            , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR' )
                      then 'ACTUAL'
                  when fact.source_table = 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED' and ds.is_actuals
                      then 'ACTUAL'
                  when fact.source_table = 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED'
                       and ds.scenario_name in ('Budget', 'Budget 2')
                      then 'BUDGET'
                  when fact.source_table = 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED'
                       and ds.scenario_name in ('Primary Forecast', 'Forecast 2', 'Forecast 3')
                      then 'FORECAST'
                  when fact.source_table = 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED'
                       and ds.scenario_name in ( 'Flex', 'RMS - OneYield', 'RMS - HiltonGRO/IDeaS'
                                               , '5 Year Plan 2026 Final' )
                      then 'FORECAST'
              end as category
            , case
                  when fact.source_table = 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED'
                      then coalesce(ds.scenario_name, 'FCID ' || coalesce(to_char(fact.fcid), '~BLANK~'))
                  else fact.source_table
              end as category_input
        from fact
        left join ds
            on ds.fcid = fact.fcid
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_PEREGRINE_RESORTS_ROWS
    where 1=1
      and unknown_reason is null
      and h1 in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves');

    -- ------------------------------------------------------------------------
    -- balance sheet
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_PEREGRINE_RESORTS_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Balance Sheet';

    -- ------------------------------------------------------------------------
    -- operating metrics
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_PEREGRINE_RESORTS_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Statistic';

    -- ------------------------------------------------------------------------
    -- unknown: H1-H5 kept where the account resolved, nulled where it did not
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN as
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
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_PEREGRINE_RESORTS_ROWS
    where 1=1
      and (unknown_reason is not null
           or h1 is null
           or h1 not in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves', 'Balance Sheet', 'Statistic'));

    -- ------------------------------------------------------------------------
    -- pacing: routed on source, own columns (D-24), never classified
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING as
    select
          :P_RUN_ID::varchar as run_id, source_lane, source_table, tenant, site_tag, site_name
        , as_of_date, occupancy_date, null::date as event_date, days_out
        , account_code, account_name, booking_code, booking_name
        , null::varchar as event_code, null::varchar as event_name
        , null::varchar as event_type_code, null::varchar as event_type_name
        , market_segment_code, market_segment_name, sales_manager_code, sales_manager_name
        , qty, amt, avg_rate
        , null::float as amt_food, null::float as amt_bev, null::float as amt_rent
        , null::float as amt_rsrc, null::float as amt_misc, null::float as amt_total
        , status, line_seq, source_insert_date, dw_updated_date, cur_load_date
    from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS
    where 1=1
    union all
    select
          :P_RUN_ID::varchar, source_lane, source_table, tenant, site_tag, site_name
        , as_of_date, occupancy_date, null::date, days_out
        , account_code, account_name, booking_code, booking_name
        , null::varchar, null::varchar
        , null::varchar, null::varchar
        , market_segment_code, market_segment_name, sales_manager_code, sales_manager_name
        , qty, amt, avg_rate
        , null::float, null::float, null::float
        , null::float, null::float, null::float
        , status, line_seq, source_insert_date, dw_updated_date, cur_load_date
    from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT
    where 1=1
    union all
    select
          :P_RUN_ID::varchar, source_lane, source_table, tenant, site_tag, site_name
        , as_of_date, null::date, event_date, days_out
        , account_code, account_name, booking_code, booking_name
        , event_code, event_name
        , event_type_code, event_type_name
        , market_segment_code, market_segment_name, sales_manager_code, sales_manager_name
        , qty, null::float, null::float
        , amt_food, amt_bev, amt_rent
        , amt_rsrc, amt_misc, amt_total
        , status, line_seq, source_insert_date, dw_updated_date, cur_load_date
    from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS
    where 1=1;

    drop table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_PEREGRINE_RESORTS_ROWS;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN);
    return 'XFRM_PEREGRINE_RESORTS is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
