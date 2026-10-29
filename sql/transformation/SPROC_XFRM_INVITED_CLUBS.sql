CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_INVITED_CLUBS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_INVITED_CLUBS
-- Builds the five transformation streams for lane INVITED_CLUBS from one join (D-23):
--   XFRM_INVITED_CLUBS_INCOME_STATEMENT   H1 Revenue, Expense, Below the Line,
--                                 Allocations & Reserves
--   XFRM_INVITED_CLUBS_BALANCE_SHEET      H1 Balance Sheet
--   XFRM_INVITED_CLUBS_OPERATING_METRICS  H1 Statistic
--   XFRM_INVITED_CLUBS_PACING             routed on source, own columns (D-24)
--   XFRM_INVITED_CLUBS_UNKNOWN            H1 Unclassified, or category unresolved
-- Fact rows joined once to the classification on the five-part key,
-- sentinel-coalesced identically to the seeder.
-- Category (section 6), row by row, from MEASURE_COLUMN: ACTUAL_AMOUNT ->
--   ACTUAL, FORECAST_AMOUNT -> FORECAST, BUDGET_AMOUNT -> BUDGET; anything
--   else unresolved. Fact: ESSBASE_EXTRACT (51.3M staged rows).
-- Pacing: the lane has no pacing source (M1); XFRM_INVITED_CLUBS_PACING is
-- built empty with RUN_ID, SOURCE_LANE, SOURCE_TABLE so the stream exists.
-- SCENARIO is carried verbatim; category never replaces it (D-17).
-- VALUE = SOURCE_AMOUNT * VALUE_SIGN. SOURCE_AMOUNT and STAT_VALUE unchanged.
-- UNKNOWN_REASON (build 08 Q-06, CLAUDE.md section 4): an Unclassified account
--   with a resolved category is SOURCE_ROLLUP (Ind-Total*, also IS_SUBTOTAL),
--   PLANNING_INPUT (other Ind-*, META ACCOUNT_TYPE saved assumption),
--   DUPLICATE_DETAIL (*_Wages_*_Dollars, 103.9% of A60351-A60355, Q-14), else
--   UNCLASSIFIED_ACCOUNT. Category also unresolved stays BOTH.
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
    create or replace temporary table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_INVITED_CLUBS_ROWS as
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
             , meta_account_type
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
    )
    -- ------------------------------------------------------------------------
    -- category, row by row
    -- ------------------------------------------------------------------------
    , cat as (
        select
              fact.*
            , case
                  when fact.measure_column = 'ACTUAL_AMOUNT'   then 'ACTUAL'
                  when fact.measure_column = 'FORECAST_AMOUNT' then 'FORECAST'
                  when fact.measure_column = 'BUDGET_AMOUNT'   then 'BUDGET'
              end as category
            , coalesce(fact.measure_column, '~BLANK~') as category_input
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
              when cls.h1 = 'Unclassified' and startswith(cat.account_key, 'Ind-Total')
                                                                    then 'SOURCE_ROLLUP'
              when cls.h1 = 'Unclassified' and startswith(cat.account_key, 'Ind-')
                                                                    then 'PLANNING_INPUT'
              when cls.h1 = 'Unclassified' and regexp_like(cat.account_key, '.*_Wages_.*_Dollars')
                                                                    then 'DUPLICATE_DETAIL'
              when cls.h1 = 'Unclassified' and lower(trim(cat.meta_account_type)) = 'saved assumption'
                                                                    then 'PLANNING_INPUT'
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_INVITED_CLUBS_ROWS
    where 1=1
      and unknown_reason is null
      and h1 in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves');

    -- ------------------------------------------------------------------------
    -- balance sheet
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_INVITED_CLUBS_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Balance Sheet';

    -- ------------------------------------------------------------------------
    -- operating metrics
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_INVITED_CLUBS_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Statistic';

    -- ------------------------------------------------------------------------
    -- unknown: H1-H5 kept where the account resolved, nulled where it did not
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN as
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
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_INVITED_CLUBS_ROWS
    where 1=1
      and (unknown_reason is not null
           or h1 is null
           or h1 not in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves', 'Balance Sheet', 'Statistic'));

    -- ------------------------------------------------------------------------
    -- pacing: the lane has no pacing source (M1); the stream is built empty
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_PACING (
          run_id        varchar
        , source_lane   varchar
        , source_table  varchar
    );

    drop table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_INVITED_CLUBS_ROWS;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN);
    return 'XFRM_INVITED_CLUBS is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
