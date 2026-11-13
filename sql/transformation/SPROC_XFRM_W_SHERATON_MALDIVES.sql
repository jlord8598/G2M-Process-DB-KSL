CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_W_SHERATON_MALDIVES(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_W_SHERATON_MALDIVES  (build 22, new lane)
-- Builds the five transformation streams for lane W_SHERATON_MALDIVES from one
-- join (D-23). Built from the lane-independent text of SPROC_XFRM_JW_VENICE.
-- Facts: PL_MONTHLY, PL_OWNER, PL_SUMMARY, BALANCE_SHEET. Category from the
-- branch (MEASURE_COLUMN): ACTUAL, FORECAST, BUDGET; anything else unresolved.
-- UNKNOWN_REASON: SOURCE_ROLLUP for a source subtotal or computed line on an
-- Unclassified key; DUPLICATE_DETAIL for a classified row that loses D-48
-- (owner Q-04, as JW_VENICE), keeping H1-H5. A row loses when:
--   (a) it is a FIN_PL_SUMMARY PERIOD_TYPE MONTH line that FIN_PL_MONTHLY also
--       carries (same hotel, section, line, month, branch); the summary
--       holds five of them under another name or section, each equal to its
--       twin on every branch (build 22 M4): OWNER EXPENSE = Owner Expenses,
--       Other Owner Expense = Owner Activity, and UNDISTRIBUTED Liability
--       Insurance / Land Min Rent Exp 701101 / Fixed Rent Expense = the
--       VALIDATION OF PROFIT CON lines;
--   (b) its PERIOD_TYPE is YTD (FIN_PL_SUMMARY and FIN_PL_OWNER);
--   (c) it is a "<line> | <line> | #n" repeat (the first line beats it).
-- FIN_PL_OWNER MONTH lines are 1BST5's only P&L and stay. Pacing: none (empty).
-- VALUE follows SOURCE_SIGN_CONVENTION (D-50): PRESENTED (P&L), DEBIT (BS).
-- No filter, no aggregation. The scratch table is dropped before return.
-- ============================================================================
declare
    v_is  integer;
    v_bs  integer;
    v_om  integer;
    v_pc  integer;
    v_un  integer;
begin
    create or replace temporary table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_W_SHERATON_MALDIVES_ROWS as
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
             , period_type_std::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_MONTHLY
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , period_type_std::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_OWNER
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , period_type_std::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_SUMMARY
        union all
        select source_lane, source_site_code, asset_name, department, department_name
             , account_number, stat_account, account_key, record_type, record_type_source
             , stat_unit_family, account_desc, period_end, scenario, source_amount, stat_value
             , is_subtotal, subtotal_source, source_line_key, source_table, measure_column
             , source_sign_convention, source_sign_convention_source
             , 'MONTH'::varchar as period_type
        from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_BALANCE_SHEET
    )
    -- ------------------------------------------------------------------------
    -- FIN_PL_MONTHLY lines (D-48 rule a)
    -- ------------------------------------------------------------------------
    , mk as (
        select distinct source_site_code as m_site, department as m_sec, account_key as m_line, period_end as m_period, measure_column as m_branch
        from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_MONTHLY
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
                  when fact.source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_W_SHERATON_MALDIVES_FIN_PL_SUMMARY' and fact.period_type = 'MONTH'
                   and exists (select 1 from mk where mk.m_site = fact.source_site_code
                               and mk.m_sec = iff(fact.department = 'UNDISTRIBUTED OPERATING EXP' and fact.account_key in ('Liability Insurance', 'Land Min Rent Exp 701101', 'Fixed Rent Expense'), 'VALIDATION OF PROFIT CON', fact.department)
                               and mk.m_line = decode(fact.account_key, 'OWNER EXPENSE', 'Owner Expenses', 'Other Owner Expense', 'Owner Activity', fact.account_key)
                               and mk.m_period = fact.period_end and mk.m_branch = fact.measure_column) then true
                  when fact.period_type = 'YTD'                                                     then true
                  when fact.account_key like '%| #%'                                                then true
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
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_INCOME_STATEMENT as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_W_SHERATON_MALDIVES_ROWS
    where 1=1
      and unknown_reason is null
      and h1 in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves');

    -- ------------------------------------------------------------------------
    -- balance sheet
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_BALANCE_SHEET as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_W_SHERATON_MALDIVES_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Balance Sheet';

    -- ------------------------------------------------------------------------
    -- operating metrics
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_OPERATING_METRICS as
    select *
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_W_SHERATON_MALDIVES_ROWS
    where 1=1
      and unknown_reason is null
      and h1 = 'Statistic';

    -- ------------------------------------------------------------------------
    -- unknown: H1-H5 kept where the account resolved, nulled where it did not
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_UNKNOWN as
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
    from DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_W_SHERATON_MALDIVES_ROWS
    where 1=1
      and (unknown_reason is not null
           or h1 is null
           or h1 not in ('Revenue', 'Expense', 'Below the Line', 'Allocations & Reserves', 'Balance Sheet', 'Statistic'));

    -- ------------------------------------------------------------------------
    -- pacing: the lane has no pacing source (M1); the stream is built empty
    -- ------------------------------------------------------------------------
    create or replace table DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_PACING (
          run_id        varchar
        , source_lane   varchar
        , source_table  varchar
    );

    drop table DEV_G2M_AI.TRANSFORMATION.TMP_XFRM_W_SHERATON_MALDIVES_ROWS;

    v_is := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_INCOME_STATEMENT);
    v_bs := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_BALANCE_SHEET);
    v_om := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_OPERATING_METRICS);
    v_pc := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_PACING);
    v_un := (select count(*) from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_UNKNOWN);
    return 'XFRM_W_SHERATON_MALDIVES is=' || v_is || ' bs=' || v_bs || ' om=' || v_om || ' pacing=' || v_pc || ' unknown=' || v_un;
end;
$$;
