CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_ATLANTIC_AVIATION_OC_DATA(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_ATLANTIC_AVIATION_OC_DATA
-- Builds STAGING.STG_ATLANTIC_AVIATION_OC_DATA from
-- CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_OC_DATA.
-- Fact table: OfficeConnect quarterly template, entity x line item x month.
-- Identity form: wide by category, 3 branches (ACTUAL_AMOUNT, FORECAST_AMOUNT,
-- BUDGET_AMOUNT), nulls kept: count(staged) = count(source) x 3.
-- No account number: ACCOUNT_KEY = LINE_ITEM as SOURCE_ITEM_ID (D-06).
-- DEPARTMENT = SECTION as stored (the 18 sites carry KPIs - JetA Only on every
-- row; reported at M1, not repaired). Site = ENTITY.
-- RECORD_TYPE derived: Landings, Trips, Gallons, MPG -> STATISTIC; else AMOUNT.
-- Fuel Margin stays AMOUNT (owner, Q-13; routed to metrics by the seeder).
-- IS_SUBTOTAL: the source IS_SUBTOTAL, or a computed / bridge line (owner,
-- stop 1, Q-10; on Total Company the Debt-section bridge line is named plain
-- Revenue), or LINE_ITEM starting Total, or a Total Company (IS_ROLLUP)
-- row of a line item that a site also carries (owner, Q-02).
-- The source's IS_SUBTOTAL is carried as SRC_IS_SUBTOTAL.
-- SCENARIO = the branch's measure column name (D-45). Signs as booked.
-- SOURCE_UNIT_SCALE (build 12, Q-07): 1000 for dollar lines and Gallons, 1 for
-- MPG, Landings, Trips. Values stay as booked here; XFRM applies the scale.
-- SOURCE_LINE_KEY: ENTITY|SECTION|LINE_ITEM|PERIOD_DATE|branch, unique (M1).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_OC_DATA as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_OC_DATA
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_cell as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_source_file_path as m_path, src.forecast_source_cell as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.budget_source_file_path as m_path, src.budget_source_cell as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case when unp.line_item in ('Landings', 'Trips', 'Gallons', 'MPG') then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , (case when unp.line_item in ('Landings', 'Trips', 'Gallons', 'MPG') then 'LINE_ITEM ' || unp.line_item || ': STATISTIC (derived, M1)' else 'LINE_ITEM: AMOUNT (derived, M1)' end) as c_rtype_source
            , max(iff(not unp.is_rollup, 1, 0)) over (partition by unp.line_item) as c_site_line
            -- Q-07 (build 12): the template states (000's). Dollar lines (every
            -- AMOUNT line, Fuel Margin included) and Gallons are in thousands
            -- (Fuel Revenue / Gallons = 5.11 per gallon as stored); MPG, Landings
            -- and Trips are carried as booked (N-17). Staging keeps the source
            -- value; transformation multiplies by SOURCE_UNIT_SCALE.
            , (case when unp.line_item in ('Landings', 'Trips', 'MPG') then 1 else 1000 end)::number(10,0) as c_scale
            , (case when unp.line_item in ('Landings', 'Trips', 'MPG') then 'as booked: not proven in thousands (owner Q-07; N-17)'
                    when unp.line_item = 'Gallons' then 'template header (000''s); proven: Fuel Revenue / Gallons = 5.11 per gallon as stored (Q-07)'
                    else 'template header (000''s): dollar measure (Q-07)' end)::varchar as c_scale_source
            , coalesce(unp.is_subtotal
                or unp.line_item in ('Fuel Gross Profit', 'Rent Gross Profit', 'Service Gross Profit', 'Other Gross Profit', 'Pre-Corporate OpEx EBITDA', 'Adj. EBITDA', 'Unadjusted EBITDA', 'OfficeConnect EBITDA', 'Net Debt', 'Check', 'Check - Debt', 'Check total vs all pieces', 'Revenue | Revenue | #2', 'Revenue | Revenue | #3', 'COS', 'COS | COS | #2', 'OpEx', 'OpEx | OpEx | #2', 'Non-Cash', 'Operating One-Times')
                or (unp.section = 'Debt' and unp.line_item = 'Revenue')
                or unp.line_item ilike 'Total%'
                or (unp.is_rollup and max(iff(not unp.is_rollup, 1, 0)) over (partition by unp.line_item) = 1), false) as c_subtotal
            , (case
                when unp.is_subtotal then 'source IS_SUBTOTAL'
                when unp.line_item in ('Fuel Gross Profit', 'Rent Gross Profit', 'Service Gross Profit', 'Other Gross Profit', 'Pre-Corporate OpEx EBITDA', 'Adj. EBITDA', 'Unadjusted EBITDA', 'OfficeConnect EBITDA', 'Net Debt', 'Check', 'Check - Debt', 'Check total vs all pieces', 'Revenue | Revenue | #2', 'Revenue | Revenue | #3', 'COS', 'COS | COS | #2', 'OpEx', 'OpEx | OpEx | #2', 'Non-Cash', 'Operating One-Times') then 'computed or bridge line (M1, Q-10)'
                when unp.section = 'Debt' and unp.line_item = 'Revenue' then 'Debt-section bridge line (M1, Q-10)'
                when unp.line_item ilike 'Total%' then 'LINE_ITEM starts Total (M1)'
                when unp.is_rollup and max(iff(not unp.is_rollup, 1, 0)) over (partition by unp.line_item) = 1 then 'Total Company (IS_ROLLUP) row of a line the sites carry (Q-02)'
                else 'not a subtotal by the M1 rule' end) as c_subtotal_source
            , (coalesce(unp.entity::varchar, '~BLANK~')
            || '|' || coalesce(unp.section::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'ATLANTIC_AVIATION'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_OC_DATA'::varchar as source_table
        , nullif(trim(cln.entity), '')::varchar                                    as source_site_code
        , cln.entity::varchar                                                      as asset_name
        , nullif(trim(cln.section), '')::varchar                                    as department
        , null::varchar::varchar                                                   as department_name
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
        , cln.c_scale::number(10,0)                                            as source_unit_scale
        , cln.c_scale_source::varchar                                          as source_unit_scale_source
        , cln.measure_column::varchar                                           as measure_column
        , cln.m_path::varchar                                                   as measure_source_file_path
        , cln.m_row::varchar                                                    as measure_source_row
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.entity
        , cln.is_rollup
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.line_order
        , cln.is_subtotal as src_is_subtotal
        , cln.is_hidden_row
        , cln.actual_amount
        , cln.forecast_amount
        , cln.budget_amount
        , cln.actual_text
        , cln.forecast_text
        , cln.budget_text
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.budget_file_report_month
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_cell
        , cln.forecast_source_file_path
        , cln.forecast_source_cell
        , cln.budget_source_file_path
        , cln.budget_source_cell
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_OC_DATA);
    return 'STG_ATLANTIC_AVIATION_OC_DATA rows=' || v_rows;
end;
$$;
