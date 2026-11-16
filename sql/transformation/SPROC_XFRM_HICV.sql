CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_HICV(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_HICV
-- Builds the five transformation streams for lane HICV from one join (D-23):
--   XFRM_HICV_INCOME_STATEMENT   H1 Revenue, Expense, Below the Line,
--                                 Allocations & Reserves
--   XFRM_HICV_BALANCE_SHEET      H1 Balance Sheet
--   XFRM_HICV_OPERATING_METRICS  H1 Statistic
--   XFRM_HICV_PACING             routed on source, own columns (D-24)
--   XFRM_HICV_UNKNOWN            H1 Unclassified, category unresolved, or the
--                                 losing side of the D-48 rule
-- Build 23 (new lane). Fact rows (STG_HICV_PL, STG_HICV_GL) joined once to the
-- classification on the five-part key, sentinel-coalesced as the seeder.
-- Category (section 6), row by row, from SOURCE_MEASURE: ACTUAL_AMOUNT ->
--   ACTUAL; FORECAST_AMOUNT, PREVIOUS_FORECAST_AMOUNT -> FORECAST;
--   BUDGET_AMOUNT -> BUDGET; anything else unresolved. GL rows are ACTUAL.
-- D-48 (owner Q-03, Q-12): CLN_HICV_FIN_PL_MONTHLY wins every month; a GL row
--   loses where the P&L carries its month, to UNKNOWN as DUPLICATE_DETAIL,
--   keeping H1-H5 and CATEGORY.
-- VALUE (D-50, owner Q-16): PROFIT, VALUE = SOURCE_AMOUNT; null wherever
--   VALUE_SIGN is null. Interest On Senior Notes as booked (N-60).
-- Pacing (owner Q-08): the three weekly report tables, own columns, AS_OF_DATE
--   = SNAPSHOT_DATE. Build 23 stop 4 (owner Q-23): BLOCK_HEADER, the header
--   line of the block each line sits in (a header follows a gap of two or more
--   blank lines on its tab), so its stated unit can be filled down.
-- SCENARIO verbatim; SOURCE_AMOUNT and STAT_VALUE unchanged. No filter, no
-- aggregation. The scratch table is dropped before return.
-- Built from the lane-independent text of SPROC_XFRM_BEAUMIER.
-- ============================================================================
declare
    v_is  integer;
    v_bs  integer;
    v_om  integer;
    v_pc  integer;
    v_un  integer;
begin
    create or replace temporary table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_HICV_ROWS as
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
             , is_subtotal, subtotal_source, source_line_key, source_table, source_measure as measure_column
             , source_sign_convention, source_sign_convention_source, currency_code
        from DEV_G2M_AI.STAGING.STG_HICV_PL
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, source_measure as measure_column
             , source_sign_convention, source_sign_convention_source, currency_code
        from DEV_G2M_AI.STAGING.STG_HICV_GL
    )
    -- ------------------------------------------------------------------------
    -- category, row by row
    -- ------------------------------------------------------------------------
    , cat as (
        select
              fact.*
            , case
                  when fact.measure_column = 'ACTUAL_AMOUNT'            then 'ACTUAL'
                  when fact.measure_column = 'FORECAST_AMOUNT'          then 'FORECAST'
                  when fact.measure_column = 'PREVIOUS_FORECAST_AMOUNT' then 'FORECAST'
                  when fact.measure_column = 'BUDGET_AMOUNT'            then 'BUDGET'
              end as category
            , coalesce(fact.measure_column, '~BLANK~') as category_input
            , (fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_GL_MONTHLY'
               and max(iff(fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_PL_MONTHLY', 1, 0))
                       over (partition by fact.period_end) = 1)::boolean as d48_loses
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
        , cat.currency_code::varchar                           as currency_code
        , cls.aggregation_type::varchar                        as aggregation_type
        , case
              when cat.d48_loses                                    then 'DUPLICATE_DETAIL'
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_INCOME_STATEMENT as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_HICV_ROWS
    where 1=1
      and unknown_reason is null
      and h1 in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves');

    -- ------------------------------------------------------------------------
    -- balance sheet
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_BALANCE_SHEET as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_HICV_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Balance Sheet';

    -- ------------------------------------------------------------------------
    -- operating metrics
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_OPERATING_METRICS as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_HICV_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Statistic';

    -- ------------------------------------------------------------------------
    -- unknown: H1-H5 kept where the account resolved, nulled where it did not
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_UNKNOWN as
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
        , source_sign_convention, source_sign_convention_source, currency_code
        , unknown_reason, unresolved_category_value
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_HICV_ROWS
    where 1=1
      and (unknown_reason is not null
           or h1 is null
           or h1 not in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves', 'Balance Sheet', 'Statistic'));

    -- ------------------------------------------------------------------------
    -- pacing: routed on source, own columns (D-24), never classified
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_PACING as
    with
    -- ------------------------------------------------------------------------
    -- the three weekly tables, own columns
    -- ------------------------------------------------------------------------
    pace as (
    select
              :P_RUN_ID::varchar as run_id
            , source_lane
            , source_table
            , snapshot_date_clean::date as as_of_date
            , snapshot_source::varchar as as_of_source
            , site
            , site_source
            , source_line_key
            , source_folder
            , portfolio_name
            , snapshot_date
            , report_tab
            , section
            , line_item
            , period_window
            , period_date
            , line_order
            , source_is_subtotal
            , actual_amount
            , budget_amount
            , actual_text
            , budget_text
            , actual_source
            , file_date
            , source_file_path
            , actual_source_cell
        from DEV_G2M_AI.STAGING.STG_HICV_KPI_WEEKLY
        where 1=1
        union all
        select
              :P_RUN_ID::varchar as run_id
            , source_lane
            , source_table
            , snapshot_date_clean::date as as_of_date
            , snapshot_source::varchar as as_of_source
            , site
            , site_source
            , source_line_key
            , source_folder
            , portfolio_name
            , snapshot_date
            , report_tab
            , section
            , line_item
            , period_window
            , period_date
            , line_order
            , source_is_subtotal
            , actual_amount
            , budget_amount
            , actual_text
            , budget_text
            , actual_source
            , file_date
            , source_file_path
            , actual_source_cell
        from DEV_G2M_AI.STAGING.STG_HICV_TREND_WEEKLY
        where 1=1
        union all
        select
              :P_RUN_ID::varchar as run_id
            , source_lane
            , source_table
            , snapshot_date_clean::date as as_of_date
            , snapshot_source::varchar as as_of_source
            , site
            , site_source
            , source_line_key
            , source_folder
            , portfolio_name
            , snapshot_date
            , report_tab
            , section
            , line_item
            , period_window
            , period_date
            , line_order
            , source_is_subtotal
            , actual_amount
            , budget_amount
            , actual_text
            , budget_text
            , actual_source
            , file_date
            , source_file_path
            , actual_source_cell
        from DEV_G2M_AI.STAGING.STG_HICV_RESERVATIONS_WEEKLY
        where 1=1
    )
    -- ------------------------------------------------------------------------
    -- block headers (owner Q-23): on each tab, a line whose LINE_ORDER follows
    -- a gap of two or more blank lines opens a block; it holds for every line
    -- down to the next header. The layout is one line item per LINE_ORDER in
    -- every snapshot, window and vantage (M6), so the blocks are unambiguous.
    -- A line above the tab's first header has no block header (null).
    -- ------------------------------------------------------------------------
    , orders as (
        select distinct source_table, report_tab, line_order, line_item
        from pace
        where 1=1
    )
    , heads as (
        select
              source_table, report_tab, line_order, line_item
            , coalesce(line_order - lag(line_order) over (partition by source_table, report_tab order by line_order), 0) >= 3 as is_header
        from orders
    )
    , blocks as (
        select
              h.source_table, h.report_tab, h.line_order
            , last_value(iff(h.is_header, h.line_item, null)) ignore nulls
                  over (partition by h.source_table, h.report_tab order by h.line_order rows between unbounded preceding and current row) as block_header
            , last_value(iff(h.is_header, h.line_order, null)) ignore nulls
                  over (partition by h.source_table, h.report_tab order by h.line_order rows between unbounded preceding and current row) as block_header_line_order
        from heads h
    )
    select
          pace.*
        , b.block_header::varchar            as block_header
        , b.block_header_line_order::number  as block_header_line_order
    from pace
    left join blocks b
        on  b.source_table = pace.source_table
        and b.report_tab   = pace.report_tab
        and b.line_order   = pace.line_order
    where 1=1;

    drop table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_HICV_ROWS;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_UNKNOWN);
    return 'XFRM_HICV is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
