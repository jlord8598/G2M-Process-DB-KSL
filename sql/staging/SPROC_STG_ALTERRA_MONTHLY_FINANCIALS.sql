CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_ALTERRA_MONTHLY_FINANCIALS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_ALTERRA_MONTHLY_FINANCIALS
-- Builds STAGING.STG_ALTERRA_MONTHLY_FINANCIALS from
-- CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_FIN_PL_MONTHLY.
-- Fact table: monthly performance by entity, section and line item.
-- Identity form: wide by category, 3 branches (ACTUAL_AMOUNT, FORECAST_AMOUNT,
-- BUDGET_AMOUNT), nulls kept: count(staged) = count(source) x 3.
-- No account number: ACCOUNT_KEY = LINE_ITEM as SOURCE_ITEM_ID (D-06).
-- DEPARTMENT = SECTION (6 entity / line pairs occur under two sections, M1).
-- Site = ENTITY; ASSET_NAME = ENTITY (the source names no other).
-- RECORD_TYPE derived: SECTION Skier Visits or KPIs -> STATISTIC, else AMOUNT.
-- IS_SUBTOTAL (owner, stop 1, Q-15, Q-16): Ski Butlers SECTION Consolidated;
-- a computed profit line (EBITDA, Departmental Profit, Gross Operating Profit);
-- or a Total line (LINE_ITEM contains Total, except Total Occupied Rooms) that
-- passes the Q-16 data test (CTE q16). A Total that fails it is a lone total
-- (Q-15): not a subtotal, classified by its family at the seeder.
-- SCENARIO = the branch's measure column name (D-45). Signs as booked.
-- SOURCE_LINE_KEY: ENTITY|SECTION|LINE_ITEM|PERIOD_DATE|branch, unique (M1).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_FIN_PL_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, null::varchar as m_path, null::number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- Q-16 data test, on ACTUAL: a Total line is a rollup only when it equals
    -- the sum of its own line family's detail within 1% in at least 95% of its
    -- months. Families are named in M6 (build 11); "Revenue - Home Owners" is a
    -- contra line (Q-17) and enters a family sum negated. Pass 2 counts a
    -- total found lone in pass 1 as detail of the Revenue totals above it.
    -- Read-only on the source; decides IS_SUBTOTAL per entity, section, line.
    -- ------------------------------------------------------------------------
    , m as (
        select src.entity, coalesce(src.section, '~BLANK~') as sec, src.line_item, src.period_date, src.actual_amount as a
        from src
        where 1=1
          and src.actual_amount is not null
    )
    , tl as (
        select * from m
        where 1=1
          and m.line_item ilike '%total%'
          and m.line_item <> 'Total Occupied Rooms'
          and m.line_item not ilike 'Departmental Profit%'
    )
    , dl as (
        select * from m
        where 1=1
          and not (m.line_item ilike '%total%')
          and m.line_item not ilike 'EBITDA%'
          and m.line_item not ilike 'Departmental Profit%'
          and m.line_item <> 'Gross Operating Profit from Operations'
    )
    , p1m as (
        select t.entity, t.sec, t.line_item, t.period_date, t.a
             , coalesce(sum(d.a * case
                      when t.line_item = 'Revenue - Total' and d.line_item like 'Revenue%' then 1
                      when t.line_item = 'Revenue - Total Operations' and d.line_item like 'Revenue%' and d.line_item <> 'Revenue - SG&A' then 1
                      when t.line_item = 'Revenue - Total - Lift' and d.line_item in ('Revenue - Paid Lift Tickets', 'Revenue - Paid Pass') then 1
                      when t.line_item = 'Revenue - Total - Mountain Operations' and d.line_item in ('Revenue - Paid Lift Tickets', 'Revenue - Paid Pass', 'Revenue - Mountain - Other') then 1
                      when t.line_item = 'Revenue - Total - Net Rooms' and d.line_item in ('Revenue - Gross Rooms', 'Revenue - Home Owners') then 1
                      when t.line_item = 'Revenue - Total - Lodging' and d.line_item in ('Revenue - Gross Rooms', 'Revenue - Home Owners', 'Revenue - Other - Rooms') then 1
                      when t.line_item = 'Revenue - Total - Trip' and d.line_item like 'Revenue - Trip%' then 1
                      when t.line_item = 'Expenses - Cost of Sales - Total' and d.line_item like 'Expenses - Cost of Sales - %' then 1
                      when t.line_item = 'Expenses - Payroll - Total' and d.line_item like 'Expenses - Payroll - %' then 1
                      when t.line_item = 'Expenses - Departmental Direct - Total' and d.line_item like 'Expenses - Departmental Direct - %' then 1
                      when t.line_item in ('Expenses - Total G&A', 'Total - Expenses') then 1
                      when t.line_item in ('Undist. Op-Ex - Total', 'Total Undistributed')
                       and d.line_item not in ('Other - Commercial Properties', 'Other - Real Estate') then 1
                      when t.line_item = 'Total Skier Visits' and d.line_item in ('Paid Skier Visits', 'Season Pass Visits', 'Comp Visits', 'Employee Visits', 'Other Visits') then 1
                      else 0
                  end * iff(d.line_item = 'Revenue - Home Owners', -1, 1)), 0) as fam
        from tl t
        left join dl d
            on  d.entity = t.entity and d.sec = t.sec and d.period_date = t.period_date
        group by 1, 2, 3, 4, 5
    )
    , p1 as (
        select entity, sec, line_item
             , (count_if(abs(a - fam) <= greatest(0.01 * abs(a), 0.005)) >= 0.95 * count(*)) as is_rollup
        from p1m
        group by 1, 2, 3
    )
    , p2m as (
        select p1m.entity, p1m.sec, p1m.line_item, p1m.period_date, p1m.a
             , p1m.fam + coalesce(sum(iff(p1m.line_item in ('Revenue - Total', 'Revenue - Total Operations')
                                          and lt.line_item like 'Revenue - Total - %', lt.a, 0)), 0) as fam2
        from p1m
        left join (select p1m.* from p1m join p1 using (entity, sec, line_item) where not p1.is_rollup) lt
            on  lt.entity = p1m.entity and lt.sec = p1m.sec and lt.period_date = p1m.period_date
            and lt.line_item <> p1m.line_item
        group by 1, 2, 3, 4, 5, p1m.fam
    )
    , q16 as (
        select entity, sec, line_item
             , (count_if(abs(a - fam2) <= greatest(0.01 * abs(a), 0.005)) >= 0.95 * count(*)) as q16_rollup
             , count_if(abs(a - fam2) <= greatest(0.01 * abs(a), 0.005)) as q16_months_ok
             , count(*) as q16_months
        from p2m
        group by 1, 2, 3
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case when unp.section in ('Skier Visits', 'KPIs') then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , (case when unp.section in ('Skier Visits', 'KPIs') then 'SECTION ' || unp.section || ': STATISTIC (derived, M1)' else 'SECTION ' || coalesce(unp.section, '~BLANK~') || ': AMOUNT (derived, M1)' end) as c_rtype_source
            , (unp.section is distinct from 'Skier Visits' and unp.section is distinct from 'KPIs'
               and (unp.line_item ilike 'EBITDA%'
                    or unp.line_item ilike 'Departmental Profit%'
                    or unp.section = 'Gross Operating Profit from Operations'
                    or unp.line_item = 'Gross Operating Profit from Operations')) as c_computed
            , (unp.line_item ilike '%total%' and unp.line_item <> 'Total Occupied Rooms') as c_total
            , coalesce(q16.q16_rollup, false) as c_q16_rollup
            , coalesce((unp.entity = 'Ski Butlers' and unp.section = 'Consolidated')
                or c_computed
                or (c_total and c_q16_rollup), false) as c_subtotal
            , (case
                when unp.entity = 'Ski Butlers' and unp.section = 'Consolidated' then 'Ski Butlers Consolidated: rollup of its two segments (M1, 25 of 25)'
                when c_computed then 'computed profit line: EBITDA, Departmental Profit or Gross Operating Profit (M1)'
                when c_total and c_q16_rollup then 'Total line equals its line family in ' || q16.q16_months_ok || ' of ' || q16.q16_months || ' months (Q-16)'
                when c_total then 'lone total (Q-15)'
                else 'not a subtotal by the M1 rule' end) as c_subtotal_source
            , (coalesce(unp.entity::varchar, '~BLANK~')
            || '|' || coalesce(unp.section::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
        left join q16
            on  q16.entity = unp.entity
            and q16.sec = coalesce(unp.section, '~BLANK~')
            and q16.line_item = unp.line_item
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'ALTERRA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_FIN_PL_MONTHLY'::varchar as source_table
        , nullif(trim(cln.entity), '')::varchar                                    as source_site_code
        , cln.entity::varchar                                                      as asset_name
        , nullif(trim(cln.section), '')::varchar                                    as department
        , cln.section::varchar                                                   as department_name
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
        , cln.entity
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.budget_amount
        , cln.actual_text
        , cln.forecast_text
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS);
    return 'STG_ALTERRA_MONTHLY_FINANCIALS rows=' || v_rows;
end;
$$;
