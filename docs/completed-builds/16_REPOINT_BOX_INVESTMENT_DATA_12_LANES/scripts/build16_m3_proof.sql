-- Build 16 M3 proof: old model query (view) vs new model query (table), one statement
select m, o_rows, n_rows, o_hash, n_hash, (o_rows=n_rows and o_hash=n_hash) same from (
select 'STG_ALTERRA_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'ALTERRA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'ALTERRA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_ALTERRA_MONTHLY_FINANCIALS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_MONTHLY_FINANCIALS','CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_FIN_PL_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "ENTITY", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_MONTHLY_FINANCIALS
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
          'PROOF'::varchar                                                    as run_id
        , 'ALTERRA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_MONTHLY_FINANCIALS'::varchar as source_table
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
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "ENTITY", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
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
          'PROOF'::varchar                                                    as run_id
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
    where 1=1
)) n
union all
select 'STG_ALTERRA_PACE_BY_STAY_MONTH' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_BY_STAY_MONTH','CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "DESTINATION", "HOTEL_NAME", "STAY_MONTH", "STAY_MONTH_LABEL", "MARKET_SEGMENT_CATEGORY", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_OTB", "STLY_DOW_ROOMS_COMMIT", "STLY_DOW_ROOM_REVENUE_OTB", "ST2Y_DOW_ROOMS_COMMIT", "ST2Y_DOW_ROOM_REVENUE_OTB", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'ALTERRA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_BY_STAY_MONTH'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_BY_STAY_MONTH src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "DESTINATION", "HOTEL_NAME", "STAY_MONTH", "STAY_MONTH_LABEL", "MARKET_SEGMENT_CATEGORY", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_OTB", "STLY_DOW_ROOMS_COMMIT", "STLY_DOW_ROOM_REVENUE_OTB", "ST2Y_DOW_ROOMS_COMMIT", "ST2Y_DOW_ROOM_REVENUE_OTB", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'ALTERRA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY) src
    where 1=1
)) n
union all
select 'STG_ATLANTIC_AVIATION_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'ATLANTIC_AVIATION'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'ATLANTIC_AVIATION'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_ATLANTIC_AVIATION_OC_DATA' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_OC_DATA','CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_FIN_PL_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_UNIT_SCALE", "SOURCE_UNIT_SCALE_SOURCE", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "ENTITY", "IS_ROLLUP", "SECTION", "LINE_ITEM", "PERIOD_DATE", "LINE_ORDER", "SRC_IS_SUBTOTAL", "IS_HIDDEN_ROW", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "BUDGET_TEXT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "BUDGET_FILE_REPORT_MONTH", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_CELL", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_CELL", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_CELL") h from (
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
          'PROOF'::varchar                                                    as run_id
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
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_UNIT_SCALE", "SOURCE_UNIT_SCALE_SOURCE", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "ENTITY", "IS_ROLLUP", "SECTION", "LINE_ITEM", "PERIOD_DATE", "LINE_ORDER", "SRC_IS_SUBTOTAL", "IS_HIDDEN_ROW", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "BUDGET_TEXT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "BUDGET_FILE_REPORT_MONTH", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_CELL", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_CELL", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_CELL") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_FIN_PL_MONTHLY)
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
          'PROOF'::varchar                                                    as run_id
        , 'ATLANTIC_AVIATION'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_FIN_PL_MONTHLY'::varchar as source_table
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
    where 1=1
)) n
union all
select 'STG_BEAUMIER_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_BEAUMIER_BP' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BP','CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_FORECAST_VERSIONS',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "CURRENCY_CODE", "CURRENCY_CODE_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "PERIOD_DATE", "LINE_ITEM", "AMOUNT", "PL_LINE", "PL_SECTION", "SEASON", "EBITDA_GROUP", "COL_9", "INCL_FLAG", "PERIOD_FLAG", "YTD_YTG", "WINTER_GROUP", "SUMMER_GROUP", "LANDING_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    select
          'PROOF'::varchar                                                    as run_id
        , 'BEAUMIER'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BP'::varchar as source_table
        , nullif(trim(src.hotel_code), '')::varchar                             as source_site_code
        , loc.hotel_name::varchar                                               as asset_name
        , case
              when loc.hotel_name is not null
                  then 'STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE; ENTITY_TYPE ' || coalesce(loc.entity_type, '~BLANK~') || ' (build 07 Q-03)'
          end::varchar                                                          as asset_name_source
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(src.line_item), '')::varchar                              as source_item_id
        , coalesce(nullif(trim(src.line_item), ''), '~BLANK~')::varchar         as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every line item is a money line (M1)'::varchar                       as record_type_source
        , null::varchar                                                         as stat_unit_family
        , src.line_item::varchar                                                as account_desc
        , src.period_date::date                                                 as period_end
        , src.scenario::varchar                                                 as scenario
        , src.amount::float                                                     as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                   as source_sign_convention
        , 'profit-signed: revenue positive, every cost H2 negative; HIERARCHY subtracts costs as stated (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , coalesce(cur.currency, 'UNCONFIRMED')::varchar                       as currency_code
        , case
              when cur.currency is not null
                  then 'STG_BEAUMIER_CANCELLATIONS.CURRENCY on LOCATION_MAP.HOTEL_NAME; one currency per hotel (N-19, build 15 Q-06)'
              else 'no currency stated for this entity (build 15 Q-06)'
          end::varchar                                                          as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(src.source_file_path, '~BLANK~') || '|' || coalesce(to_char(src.source_row_number), '~BLANK~') || '|' || coalesce(to_char(src.period_date, 'YYYY-MM-DD'), '~BLANK~') || '|' || coalesce(src.scenario, '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.property_name
        , src.hotel_code
        , src.period_date
        , src.line_item
        , src.amount
        , src.pl_line
        , src.pl_section
        , src.season
        , src.ebitda_group
        , src.col_9
        , src.incl_flag
        , src.period_flag
        , src.ytd_ytg
        , src.winter_group
        , src.summer_group
        , src.landing_group
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BP src
    left join DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP loc
        on  loc.hotel_code = src.hotel_code
    left join (
        -- currency per hotel name; every hotel states exactly one (build 15 M1)
        select hotel_name, min(currency) as currency
        from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
        group by hotel_name
        having count(distinct currency) = 1
    ) cur
        on  cur.hotel_name = loc.hotel_name
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "CURRENCY_CODE", "CURRENCY_CODE_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "PERIOD_DATE", "LINE_ITEM", "AMOUNT", "PL_LINE", "PL_SECTION", "SEASON", "EBITDA_GROUP", "COL_9", "INCL_FLAG", "PERIOD_FLAG", "YTD_YTG", "WINTER_GROUP", "SUMMER_GROUP", "LANDING_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    select
          'PROOF'::varchar                                                    as run_id
        , 'BEAUMIER'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_FORECAST_VERSIONS'::varchar as source_table
        , nullif(trim(src.hotel_code), '')::varchar                             as source_site_code
        , loc.hotel_name::varchar                                               as asset_name
        , case
              when loc.hotel_name is not null
                  then 'STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE; ENTITY_TYPE ' || coalesce(loc.entity_type, '~BLANK~') || ' (build 07 Q-03)'
          end::varchar                                                          as asset_name_source
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(src.line_item), '')::varchar                              as source_item_id
        , coalesce(nullif(trim(src.line_item), ''), '~BLANK~')::varchar         as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every line item is a money line (M1)'::varchar                       as record_type_source
        , null::varchar                                                         as stat_unit_family
        , src.line_item::varchar                                                as account_desc
        , src.period_date::date                                                 as period_end
        , src.scenario::varchar                                                 as scenario
        , src.amount::float                                                     as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                   as source_sign_convention
        , 'profit-signed: revenue positive, every cost H2 negative; HIERARCHY subtracts costs as stated (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , coalesce(cur.currency, 'UNCONFIRMED')::varchar                       as currency_code
        , case
              when cur.currency is not null
                  then 'STG_BEAUMIER_CANCELLATIONS.CURRENCY on LOCATION_MAP.HOTEL_NAME; one currency per hotel (N-19, build 15 Q-06)'
              else 'no currency stated for this entity (build 15 Q-06)'
          end::varchar                                                          as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(src.source_file_path, '~BLANK~') || '|' || coalesce(to_char(src.source_row_number), '~BLANK~') || '|' || coalesce(to_char(src.period_date, 'YYYY-MM-DD'), '~BLANK~') || '|' || coalesce(src.scenario, '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.property_name
        , src.hotel_code
        , src.period_date
        , src.line_item
        , src.amount
        , src.pl_line
        , src.pl_section
        , src.season
        , src.ebitda_group
        , src.col_9
        , src.incl_flag
        , src.period_flag
        , src.ytd_ytg
        , src.winter_group
        , src.summer_group
        , src.landing_group
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_FORECAST_VERSIONS) src
    left join DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP loc
        on  loc.hotel_code = src.hotel_code
    left join (
        -- currency per hotel name; every hotel states exactly one (build 15 M1)
        select hotel_name, min(currency) as currency
        from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
        group by hotel_name
        having count(distinct currency) = 1
    ) cur
        on  cur.hotel_name = loc.hotel_name
    where 1=1
)) n
union all
select 'STG_BEAUMIER_BUDGET' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BUDGET','CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "CURRENCY_CODE", "CURRENCY_CODE_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "PERIOD_DATE", "LINE_ITEM", "AMOUNT", "PL_LINE", "PL_LINE_2", "PL_SECTION", "SEASON", "EBITDA_GROUP", "COL_9", "INCL_FLAG", "PERIOD_FLAG", "YTD_YTG", "WINTER_GROUP", "SUMMER_GROUP", "LANDING_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    select
          'PROOF'::varchar                                                    as run_id
        , 'BEAUMIER'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BUDGET'::varchar as source_table
        , nullif(trim(src.hotel_code), '')::varchar                             as source_site_code
        , loc.hotel_name::varchar                                               as asset_name
        , case
              when loc.hotel_name is not null
                  then 'STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE; ENTITY_TYPE ' || coalesce(loc.entity_type, '~BLANK~') || ' (build 07 Q-03)'
          end::varchar                                                          as asset_name_source
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(src.line_item), '')::varchar                              as source_item_id
        , coalesce(nullif(trim(src.line_item), ''), '~BLANK~')::varchar         as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every line item is a money line (M1)'::varchar                       as record_type_source
        , null::varchar                                                         as stat_unit_family
        , src.line_item::varchar                                                as account_desc
        , src.period_date::date                                                 as period_end
        , src.scenario::varchar                                                 as scenario
        , src.amount::float                                                     as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                   as source_sign_convention
        , 'profit-signed: revenue positive, every cost H2 negative; HIERARCHY subtracts costs as stated (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , coalesce(cur.currency, 'UNCONFIRMED')::varchar                       as currency_code
        , case
              when cur.currency is not null
                  then 'STG_BEAUMIER_CANCELLATIONS.CURRENCY on LOCATION_MAP.HOTEL_NAME; one currency per hotel (N-19, build 15 Q-06)'
              else 'no currency stated for this entity (build 15 Q-06)'
          end::varchar                                                          as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(src.source_file_path, '~BLANK~') || '|' || coalesce(to_char(src.source_row_number), '~BLANK~') || '|' || coalesce(to_char(src.period_date, 'YYYY-MM-DD'), '~BLANK~') || '|' || coalesce(src.scenario, '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.property_name
        , src.hotel_code
        , src.period_date
        , src.line_item
        , src.amount
        , src.pl_line
        , src.pl_line_2
        , src.pl_section
        , src.season
        , src.ebitda_group
        , src.col_9
        , src.incl_flag
        , src.period_flag
        , src.ytd_ytg
        , src.winter_group
        , src.summer_group
        , src.landing_group
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BUDGET src
    left join DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP loc
        on  loc.hotel_code = src.hotel_code
    left join (
        -- currency per hotel name; every hotel states exactly one (build 15 M1)
        select hotel_name, min(currency) as currency
        from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
        group by hotel_name
        having count(distinct currency) = 1
    ) cur
        on  cur.hotel_name = loc.hotel_name
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "CURRENCY_CODE", "CURRENCY_CODE_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "PERIOD_DATE", "LINE_ITEM", "AMOUNT", "PL_LINE", "PL_LINE_2", "PL_SECTION", "SEASON", "EBITDA_GROUP", "COL_9", "INCL_FLAG", "PERIOD_FLAG", "YTD_YTG", "WINTER_GROUP", "SUMMER_GROUP", "LANDING_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    select
          'PROOF'::varchar                                                    as run_id
        , 'BEAUMIER'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY'::varchar as source_table
        , nullif(trim(src.hotel_code), '')::varchar                             as source_site_code
        , loc.hotel_name::varchar                                               as asset_name
        , case
              when loc.hotel_name is not null
                  then 'STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE; ENTITY_TYPE ' || coalesce(loc.entity_type, '~BLANK~') || ' (build 07 Q-03)'
          end::varchar                                                          as asset_name_source
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(src.line_item), '')::varchar                              as source_item_id
        , coalesce(nullif(trim(src.line_item), ''), '~BLANK~')::varchar         as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every line item is a money line (M1)'::varchar                       as record_type_source
        , null::varchar                                                         as stat_unit_family
        , src.line_item::varchar                                                as account_desc
        , src.period_date::date                                                 as period_end
        , src.scenario::varchar                                                 as scenario
        , src.amount::float                                                     as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                   as source_sign_convention
        , 'profit-signed: revenue positive, every cost H2 negative; HIERARCHY subtracts costs as stated (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , coalesce(cur.currency, 'UNCONFIRMED')::varchar                       as currency_code
        , case
              when cur.currency is not null
                  then 'STG_BEAUMIER_CANCELLATIONS.CURRENCY on LOCATION_MAP.HOTEL_NAME; one currency per hotel (N-19, build 15 Q-06)'
              else 'no currency stated for this entity (build 15 Q-06)'
          end::varchar                                                          as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(src.source_file_path, '~BLANK~') || '|' || coalesce(to_char(src.source_row_number), '~BLANK~') || '|' || coalesce(to_char(src.period_date, 'YYYY-MM-DD'), '~BLANK~') || '|' || coalesce(src.scenario, '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.property_name
        , src.hotel_code
        , src.period_date
        , src.line_item
        , src.amount
        , src.pl_line
        , src.pl_line_2
        , src.pl_section
        , src.season
        , src.ebitda_group
        , src.col_9
        , src.incl_flag
        , src.period_flag
        , src.ytd_ytg
        , src.winter_group
        , src.summer_group
        , src.landing_group
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY) src
    left join DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP loc
        on  loc.hotel_code = src.hotel_code
    left join (
        -- currency per hotel name; every hotel states exactly one (build 15 M1)
        select hotel_name, min(currency) as currency
        from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
        group by hotel_name
        having count(distinct currency) = 1
    ) cur
        on  cur.hotel_name = loc.hotel_name
    where 1=1
)) n
union all
select 'STG_BEAUMIER_CANCELLATIONS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_CANCELLATIONS','CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "REPORT_TYPE", "HOTEL_NAME", "CURRENCY", "BUSINESS_DATE", "STAY_MONTH", "OCCUPANCY", "ROOMS_REVENUE", "OCCUPANCY_N_1", "ROOMS_REVENUE_N_1", "OCCUPANCY_N_2", "ROOMS_REVENUE_N_2", "OCCUPANCY_N_3", "ROOMS_REVENUE_N_3", "OCCUPANCY_N_4", "ROOMS_REVENUE_N_4", "OCCUPANCY_N_5", "ROOMS_REVENUE_N_5", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_CANCELLATIONS'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_CANCELLATIONS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "REPORT_TYPE", "HOTEL_NAME", "CURRENCY", "BUSINESS_DATE", "STAY_MONTH", "OCCUPANCY", "ROOMS_REVENUE", "OCCUPANCY_N_1", "ROOMS_REVENUE_N_1", "OCCUPANCY_N_2", "ROOMS_REVENUE_N_2", "OCCUPANCY_N_3", "ROOMS_REVENUE_N_3", "OCCUPANCY_N_4", "ROOMS_REVENUE_N_4", "OCCUPANCY_N_5", "ROOMS_REVENUE_N_5", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY) src
    where 1=1
)) n
union all
select 'STG_BEAUMIER_HIERARCHY' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_HIERARCHY','CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_HIERARCHY_PL_LINE',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "LINE_ITEM", "LEVEL_4", "LEVEL_3", "LEVEL_2", "LEVEL_1", "LEVEL_0", "PROJECTION_GROUP", "PL_GROUP", "LINE_TYPE", "FB_GROUP", "DEPARTMENT", "INDEX_4", "INDEX_3", "INDEX_2", "INDEX_1", "INDEX_0", "INDEX_DEPARTMENT", "INDEX_PL", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_HIERARCHY'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_HIERARCHY src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "LINE_ITEM", "LEVEL_4", "LEVEL_3", "LEVEL_2", "LEVEL_1", "LEVEL_0", "PROJECTION_GROUP", "PL_GROUP", "LINE_TYPE", "FB_GROUP", "DEPARTMENT", "INDEX_4", "INDEX_3", "INDEX_2", "INDEX_1", "INDEX_0", "INDEX_DEPARTMENT", "INDEX_PL", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_HIERARCHY_PL_LINE'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_HIERARCHY_PL_LINE) src
    where 1=1
)) n
union all
select 'STG_BEAUMIER_LOCATION_MAP' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP','CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_PROPERTIES',source_table), "HOTEL_CODE", "HOTEL_NAME", "ENTITY_TYPE") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "HOTEL_CODE", "HOTEL_NAME", "ENTITY_TYPE") h from (
    select
          'PROOF'::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_PROPERTIES'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_PROPERTIES src
    where 1=1
)) n
union all
select 'STG_DAVIDSON_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "RAW_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'DAVIDSON'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as raw_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "RAW_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'DAVIDSON'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as raw_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_DAVIDSON_FULL_YEAR_PL' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL','CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "HOTEL_NAME", "IS_ROLLUP", "REPORT_SHEET", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_REPORT_AS_OF_DATE", "FORECAST_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
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
          'PROOF'::varchar                                                    as run_id
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
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "HOTEL_NAME", "IS_ROLLUP", "REPORT_SHEET", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_REPORT_AS_OF_DATE", "FORECAST_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY)
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
          and a.raw_source_table = 'CLN_DAVIDSON_FIN_PL_SUMMARY'
        group by a.entity_code, a.full_account_string
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'DAVIDSON'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY'::varchar          as source_table
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
    where 1=1
)) n
union all
select 'STG_DAVIDSON_HOTEL_MONTHLY_REPORT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT','CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "NATURAL_ACCOUNT", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "HOTEL_NAME", "LINE_CLASS", "LINE_TYPE", "ACCOUNT", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT
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
    , cln0 as (
        select
              unp.*
            , nullif(trim(unp.hotel_code), '')                                   as c_site
            , nullif(trim(unp.account), '')                                      as c_acct
            , null::varchar                                                      as c_stat
            , nullif(trim(unp.line_class), '')                                   as c_item
            , iff(regexp_count(unp.account, '-') = 5, nullif(split_part(unp.account, '-', 1), ''), null) as c_dept
            , iff(regexp_count(unp.account, '-') = 5, nullif(split_part(unp.account, '-', 2), ''), null) as c_natural
            , upper(trim(unp.line_class)) in ('ADR', 'ROOMS')                    as c_is_class_stat
        from unp
    )
    -- ------------------------------------------------------------------------
    -- statistic rule: LINE_CLASS ADR/Rooms, or natural account 9000-9990
    -- (owner Q-07, from data; source owner to confirm)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              cln0.*
            , (cln0.c_is_class_stat
                or coalesce(left(cln0.c_natural, 1) = '9', false))               as c_is_stat
        from cln0
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
          and a.raw_source_table = 'CLN_DAVIDSON_HOTEL_MONTHLY_REPORT'
        group by a.entity_code, a.full_account_string
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'DAVIDSON'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT'::varchar  as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.hotel_name::varchar                                               as asset_name
        , cln.c_dept::varchar                                                   as department
        , null::varchar                                                         as department_name
        , cln.account::varchar                                                  as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_is_stat then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_is_class_stat
                  then 'LINE_CLASS ' || cln.line_class || ': STATISTIC (stated by the source class; Q-06)'
              when cln.c_natural = '9990'
                  then 'natural account 9990 (LAOFF/STOFF): stat-ledger offset, STATISTIC, adds to no total (owner Q-07, from data; source owner to confirm)'
              when cln.c_is_stat
                  then 'natural account ' || cln.c_natural || ' (9000-9990): STATISTIC (owner Q-07, from data; source owner to confirm)'
              else 'LINE_CLASS ' || coalesce(cln.line_class, '~BLANK~') || ': AMOUNT (Q-06)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_is_stat, null, cln.m_amount)::float                         as source_amount
        , iff(cln.c_is_stat, cln.m_amount, null)::float                         as stat_value
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.hotel_code, '~BLANK~')
            || '|' || coalesce(cln.line_class, '~BLANK~')
            || '|' || coalesce(cln.account, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        , cln.c_natural::varchar                                                as natural_account
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.hotel_code
        , cln.hotel_name
        , cln.line_class
        , cln.line_type
        , cln.account
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    left join acct
        on  acct.entity_code         = cln.hotel_code
        and acct.full_account_string = coalesce(cln.account, cln.line_class)
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "NATURAL_ACCOUNT", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_CODE", "HOTEL_NAME", "LINE_CLASS", "LINE_TYPE", "ACCOUNT", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY)
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
    , cln0 as (
        select
              unp.*
            , nullif(trim(unp.hotel_code), '')                                   as c_site
            , nullif(trim(unp.account), '')                                      as c_acct
            , null::varchar                                                      as c_stat
            , nullif(trim(unp.line_class), '')                                   as c_item
            , iff(regexp_count(unp.account, '-') = 5, nullif(split_part(unp.account, '-', 1), ''), null) as c_dept
            , iff(regexp_count(unp.account, '-') = 5, nullif(split_part(unp.account, '-', 2), ''), null) as c_natural
            , upper(trim(unp.line_class)) in ('ADR', 'ROOMS')                    as c_is_class_stat
        from unp
    )
    -- ------------------------------------------------------------------------
    -- statistic rule: LINE_CLASS ADR/Rooms, or natural account 9000-9990
    -- (owner Q-07, from data; source owner to confirm)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              cln0.*
            , (cln0.c_is_class_stat
                or coalesce(left(cln0.c_natural, 1) = '9', false))               as c_is_stat
        from cln0
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
          and a.raw_source_table = 'CLN_DAVIDSON_FIN_PL_MONTHLY'
        group by a.entity_code, a.full_account_string
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'DAVIDSON'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY'::varchar  as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.hotel_name::varchar                                               as asset_name
        , cln.c_dept::varchar                                                   as department
        , null::varchar                                                         as department_name
        , cln.account::varchar                                                  as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_is_stat then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_is_class_stat
                  then 'LINE_CLASS ' || cln.line_class || ': STATISTIC (stated by the source class; Q-06)'
              when cln.c_natural = '9990'
                  then 'natural account 9990 (LAOFF/STOFF): stat-ledger offset, STATISTIC, adds to no total (owner Q-07, from data; source owner to confirm)'
              when cln.c_is_stat
                  then 'natural account ' || cln.c_natural || ' (9000-9990): STATISTIC (owner Q-07, from data; source owner to confirm)'
              else 'LINE_CLASS ' || coalesce(cln.line_class, '~BLANK~') || ': AMOUNT (Q-06)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_is_stat, null, cln.m_amount)::float                         as source_amount
        , iff(cln.c_is_stat, cln.m_amount, null)::float                         as stat_value
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.hotel_code, '~BLANK~')
            || '|' || coalesce(cln.line_class, '~BLANK~')
            || '|' || coalesce(cln.account, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        , cln.c_natural::varchar                                                as natural_account
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.hotel_code
        , cln.hotel_name
        , cln.line_class
        , cln.line_type
        , cln.account
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    left join acct
        on  acct.entity_code         = cln.hotel_code
        and acct.full_account_string = coalesce(cln.account, cln.line_class)
    where 1=1
)) n
union all
select 'STG_HERSHA_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HERSHA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HERSHA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_HERSHA_GL_ACTUAL' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_ACTUAL','CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "COMPANY_ID", "COMPANY_NAME", "PERIOD_DATE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "GL_CODE", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "REV_SPEND_CATEGORY", "REV_SPEND_DESCRIPTION", "JOB_TITLE_CODE", "JOB_DESCRIPTION", "MEAL_PERIOD_CODE", "MEAL_DESCRIPTION", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_STAT", "FORECAST_STAT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_ACTUAL
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_ACTUAL'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'STATISTIC' else 'AMOUNT' end)::varchar as record_type
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'GL_CODE Stat: STATISTIC (stated by the source)' else 'GL_CODE ' || coalesce(unp.gl_code, '~BLANK~') || ': AMOUNT, branch stat carried as STAT_VALUE (stated; D-29)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , unp.m_scenario::varchar                                               as scenario
        , unp.m_amount::float as source_amount
        , unp.m_stat::float as stat_value
        , 'DEBIT'::varchar                                                    as source_sign_convention
        , 'debit-positive: TB revenue (4xxx) negative in 108 / 108 entity-months, 5xxx-7xxx positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(unp.company_id, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(unp.account_code, '~BLANK~')
            || '|' || coalesce(unp.department_code, '~BLANK~')
            || '|' || coalesce(unp.rev_spend_category, '~BLANK~')
            || '|' || coalesce(unp.job_title_code, '~BLANK~')
            || '|' || coalesce(unp.meal_period_code, '~BLANK~')
            || '|' || unp.measure_column)::varchar                             as source_line_key
        , unp.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , unp.source_folder
        , unp.property_name
        , unp.company_id
        , unp.company_name
        , unp.period_date
        , unp.account_code
        , unp.account_description
        , unp.gl_code
        , unp.department_code
        , unp.department_description
        , unp.rev_spend_category
        , unp.rev_spend_description
        , unp.job_title_code
        , unp.job_description
        , unp.meal_period_code
        , unp.meal_description
        , unp.actual_amount
        , unp.forecast_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
    from unp
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "COMPANY_ID", "COMPANY_NAME", "PERIOD_DATE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "GL_CODE", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "REV_SPEND_CATEGORY", "REV_SPEND_DESCRIPTION", "JOB_TITLE_CODE", "JOB_DESCRIPTION", "MEAL_PERIOD_CODE", "MEAL_DESCRIPTION", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_STAT", "FORECAST_STAT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select source_folder, portfolio_name as property_name, * exclude (source_folder) from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY where actual_amount is not null or forecast_amount is not null or actual_stat is not null or forecast_stat is not null)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'STATISTIC' else 'AMOUNT' end)::varchar as record_type
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'GL_CODE Stat: STATISTIC (stated by the source)' else 'GL_CODE ' || coalesce(unp.gl_code, '~BLANK~') || ': AMOUNT, branch stat carried as STAT_VALUE (stated; D-29)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , unp.m_scenario::varchar                                               as scenario
        , unp.m_amount::float as source_amount
        , unp.m_stat::float as stat_value
        , 'DEBIT'::varchar                                                    as source_sign_convention
        , 'debit-positive: TB revenue (4xxx) negative in 108 / 108 entity-months, 5xxx-7xxx positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(unp.company_id, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(unp.account_code, '~BLANK~')
            || '|' || coalesce(unp.department_code, '~BLANK~')
            || '|' || coalesce(unp.rev_spend_category, '~BLANK~')
            || '|' || coalesce(unp.job_title_code, '~BLANK~')
            || '|' || coalesce(unp.meal_period_code, '~BLANK~')
            || '|' || unp.measure_column)::varchar                             as source_line_key
        , unp.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , unp.source_folder
        , unp.property_name
        , unp.company_id
        , unp.company_name
        , unp.period_date
        , unp.account_code
        , unp.account_description
        , unp.gl_code
        , unp.department_code
        , unp.department_description
        , unp.rev_spend_category
        , unp.rev_spend_description
        , unp.job_title_code
        , unp.job_description
        , unp.meal_period_code
        , unp.meal_description
        , unp.actual_amount
        , unp.forecast_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
    from unp
    where 1=1
)) n
union all
select 'STG_HERSHA_GL_STAT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_STAT','CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_OPS_STATS_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "COMPANY_ID", "COMPANY_NAME", "PERIOD_DATE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "GL_CODE", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "REV_SPEND_CATEGORY", "REV_SPEND_DESCRIPTION", "JOB_TITLE_CODE", "JOB_DESCRIPTION", "MEAL_PERIOD_CODE", "MEAL_DESCRIPTION", "FLAG_COL_2", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_STAT", "FORECAST_STAT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_STAT
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_GL_STAT'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , ('STATISTIC')::varchar as record_type
        , ('GL_STAT table, ST account: STATISTIC; the count sits in the branch''s _AMOUNT column and is carried as STAT_VALUE (owner Q-02)')::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , unp.m_scenario::varchar                                               as scenario
        , null::float as source_amount
        , unp.m_amount::float as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(unp.company_id, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(unp.account_code, '~BLANK~')
            || '|' || coalesce(unp.department_code, '~BLANK~')
            || '|' || coalesce(unp.rev_spend_category, '~BLANK~')
            || '|' || coalesce(unp.job_title_code, '~BLANK~')
            || '|' || coalesce(unp.meal_period_code, '~BLANK~')
            || '|' || unp.measure_column)::varchar                             as source_line_key
        , unp.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , unp.source_folder
        , unp.property_name
        , unp.company_id
        , unp.company_name
        , unp.period_date
        , unp.account_code
        , unp.account_description
        , unp.gl_code
        , unp.department_code
        , unp.department_description
        , unp.rev_spend_category
        , unp.rev_spend_description
        , unp.job_title_code
        , unp.job_description
        , unp.meal_period_code
        , unp.meal_description
        , unp.flag_col_2
        , unp.actual_amount
        , unp.forecast_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
    from unp
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "COMPANY_ID", "COMPANY_NAME", "PERIOD_DATE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "GL_CODE", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "REV_SPEND_CATEGORY", "REV_SPEND_DESCRIPTION", "JOB_TITLE_CODE", "JOB_DESCRIPTION", "MEAL_PERIOD_CODE", "MEAL_DESCRIPTION", "FLAG_COL_2", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_STAT", "FORECAST_STAT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select source_folder, portfolio_name as property_name, * exclude (source_folder) from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_OPS_STATS_MONTHLY where preferred_row)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_OPS_STATS_MONTHLY'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , ('STATISTIC')::varchar as record_type
        , ('GL_STAT table, ST account: STATISTIC; the count sits in the branch''s _AMOUNT column and is carried as STAT_VALUE (owner Q-02)')::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , unp.m_scenario::varchar                                               as scenario
        , null::float as source_amount
        , unp.m_amount::float as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(unp.company_id, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(unp.account_code, '~BLANK~')
            || '|' || coalesce(unp.department_code, '~BLANK~')
            || '|' || coalesce(unp.rev_spend_category, '~BLANK~')
            || '|' || coalesce(unp.job_title_code, '~BLANK~')
            || '|' || coalesce(unp.meal_period_code, '~BLANK~')
            || '|' || unp.measure_column)::varchar                             as source_line_key
        , unp.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , unp.source_folder
        , unp.property_name
        , unp.company_id
        , unp.company_name
        , unp.period_date
        , unp.account_code
        , unp.account_description
        , unp.gl_code
        , unp.department_code
        , unp.department_description
        , unp.rev_spend_category
        , unp.rev_spend_description
        , unp.job_title_code
        , unp.job_description
        , unp.meal_period_code
        , unp.meal_description
        , unp.flag_col_2
        , unp.actual_amount
        , unp.forecast_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
    from unp
    where 1=1
)) n
union all
select 'STG_HERSHA_TB_ACTUAL' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_TB_ACTUAL','CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_TRIAL_BALANCE',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "COMPANY_ID", "COMPANY_NAME", "PERIOD_DATE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "GL_CODE", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "REV_SPEND_CATEGORY", "REV_SPEND_DESCRIPTION", "JOB_TITLE_CODE", "JOB_DESCRIPTION", "MEAL_PERIOD_CODE", "MEAL_DESCRIPTION", "FLAG_COL_1", "FLAG_COL_2", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_STAT", "FORECAST_STAT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_TB_ACTUAL
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_TB_ACTUAL'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'STATISTIC' else 'AMOUNT' end)::varchar as record_type
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'GL_CODE Stat: STATISTIC (stated by the source)' else 'GL_CODE ' || coalesce(unp.gl_code, '~BLANK~') || ': AMOUNT, branch stat carried as STAT_VALUE (stated; D-29)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , unp.m_scenario::varchar                                               as scenario
        , unp.m_amount::float as source_amount
        , unp.m_stat::float as stat_value
        , 'DEBIT'::varchar                                                    as source_sign_convention
        , 'debit-positive: revenue (4xxx) negative in 108 / 108 entity-months, 5xxx-7xxx positive in 106-108 / 108 (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(unp.company_id, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(unp.account_code, '~BLANK~')
            || '|' || coalesce(unp.department_code, '~BLANK~')
            || '|' || coalesce(unp.rev_spend_category, '~BLANK~')
            || '|' || coalesce(unp.job_title_code, '~BLANK~')
            || '|' || coalesce(unp.meal_period_code, '~BLANK~')
            || '|' || unp.measure_column)::varchar                             as source_line_key
        , unp.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , unp.source_folder
        , unp.property_name
        , unp.company_id
        , unp.company_name
        , unp.period_date
        , unp.account_code
        , unp.account_description
        , unp.gl_code
        , unp.department_code
        , unp.department_description
        , unp.rev_spend_category
        , unp.rev_spend_description
        , unp.job_title_code
        , unp.job_description
        , unp.meal_period_code
        , unp.meal_description
        , unp.flag_col_1
        , unp.flag_col_2
        , unp.actual_amount
        , unp.forecast_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
    from unp
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "COMPANY_ID", "COMPANY_NAME", "PERIOD_DATE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "GL_CODE", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "REV_SPEND_CATEGORY", "REV_SPEND_DESCRIPTION", "JOB_TITLE_CODE", "JOB_DESCRIPTION", "MEAL_PERIOD_CODE", "MEAL_DESCRIPTION", "FLAG_COL_1", "FLAG_COL_2", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_STAT", "FORECAST_STAT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select source_folder, portfolio_name as property_name, * exclude (source_folder) from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_TRIAL_BALANCE)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure pair, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar   as measure_column, 'ACTUAL_AMOUNT'::varchar   as m_scenario, src.actual_amount   as m_amount, src.actual_stat   as m_stat, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_stat as m_stat, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HERSHA'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_TRIAL_BALANCE'::varchar as source_table
        , nullif(trim(unp.company_id), '')::varchar                             as source_site_code
        , unp.company_name::varchar                                             as asset_name
        , nullif(trim(unp.department_code), '')::varchar                        as department
        , unp.department_description::varchar                                   as department_name
        , unp.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(unp.account_code), ''), '~BLANK~')::varchar      as account_key
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'STATISTIC' else 'AMOUNT' end)::varchar as record_type
        , (case when upper(trim(unp.gl_code)) = 'STAT' then 'GL_CODE Stat: STATISTIC (stated by the source)' else 'GL_CODE ' || coalesce(unp.gl_code, '~BLANK~') || ': AMOUNT, branch stat carried as STAT_VALUE (stated; D-29)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , unp.account_description::varchar                                      as account_desc
        , unp.period_date::date                                                 as period_end
        , unp.m_scenario::varchar                                               as scenario
        , unp.m_amount::float as source_amount
        , unp.m_stat::float as stat_value
        , 'DEBIT'::varchar                                                    as source_sign_convention
        , 'debit-positive: revenue (4xxx) negative in 108 / 108 entity-months, 5xxx-7xxx positive in 106-108 / 108 (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(unp.company_id, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(unp.account_code, '~BLANK~')
            || '|' || coalesce(unp.department_code, '~BLANK~')
            || '|' || coalesce(unp.rev_spend_category, '~BLANK~')
            || '|' || coalesce(unp.job_title_code, '~BLANK~')
            || '|' || coalesce(unp.meal_period_code, '~BLANK~')
            || '|' || unp.measure_column)::varchar                             as source_line_key
        , unp.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , unp.source_folder
        , unp.property_name
        , unp.company_id
        , unp.company_name
        , unp.period_date
        , unp.account_code
        , unp.account_description
        , unp.gl_code
        , unp.department_code
        , unp.department_description
        , unp.rev_spend_category
        , unp.rev_spend_description
        , unp.job_title_code
        , unp.job_description
        , unp.meal_period_code
        , unp.meal_description
        , unp.flag_col_1
        , unp.flag_col_2
        , unp.actual_amount
        , unp.forecast_amount
        , unp.actual_stat
        , unp.forecast_stat
        , unp.actual_file_date
        , unp.forecast_file_date
        , unp.actual_source_file_path
        , unp.actual_source_row_number
        , unp.forecast_source_file_path
        , unp.forecast_source_row_number
    from unp
    where 1=1
)) n
union all
select 'STG_HHG_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_HHG_ASSET_CODES' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ASSET_CODES','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTIES',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "CLUB_NUMBER", "CLUB_CODE", "CLUB_NAME", "ACQUISITION_DATE", "REGIONAL_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ASSET_CODES'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ASSET_CODES src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "CLUB_NUMBER", "CLUB_CODE", "CLUB_NAME", "ACQUISITION_DATE", "REGIONAL_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTIES'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTIES) src
    where 1=1
)) n
union all
select 'STG_HHG_BUDGET_BY_CLUB' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_BUDGET_BY_CLUB','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "PARENT_CODE", "SOURCE_FOLDER", "PROPERTY_NAME", "ACCOUNT_CODE", "CLUB_NUMBER", "DEPARTMENT_CODE", "NATURAL_ACCOUNT", "CORRECTED_DEPARTMENT", "CONSOL_KEY", "REGION_KEY", "GROUP_KEY", "SS_DEV_KEY", "PERIOD_DATE", "BUDGET_AMOUNT", "BUDGET_VERSION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_BUDGET_BY_CLUB
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.account_code), '')                     as c_acct
            , null::varchar                                          as c_stat
            , null::varchar                                          as c_item
            , nullif(split_part(trim(src.account_code), '-', 1), '') as c_site
            , nullif(split_part(trim(src.account_code), '-', 2), '') as c_dept
        from src
    )
    -- ------------------------------------------------------------------------
    -- account description dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.source_table
            , a.account_description
            , a.department_description
            , a.parent_code
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS a
    )
    -- ------------------------------------------------------------------------
    -- club name by GL entity, unique on CLUB_NUMBER (build 10 M1)
    -- ------------------------------------------------------------------------
    , refs as (
        select
              r.club_number
            , r.club_name
        from DEV_G2M_AI.STAGING.STG_HHG_ASSET_CODES r
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_BUDGET_BY_CLUB'::varchar        as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , refs.club_name::varchar                                               as asset_name
        , case
              when refs.club_name is not null
                  then 'STG_HHG_ASSET_CODES.CLUB_NAME on entity = CLUB_NUMBER (build 10 Q-02)'
          end::varchar                                                          as asset_name_source
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                 as department_name
        , cln.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_dept = '999' then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_dept = '999'
                  then 'department 999: STATISTIC (dept 999, section 9, all whole numbers; owner Q-01)'
              else 'department not 999: AMOUNT (no stating column; M1)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.budget_version::varchar                                           as scenario
        , iff(cln.c_dept = '999', null, cln.budget_amount)::float               as source_amount
        , iff(cln.c_dept = '999', cln.budget_amount, null)::float               as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: Revenue 418,366,403, Labor 127,140,272, Cost of Sales 40,047,115, all positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        , acct.parent_code::varchar                                             as parent_code
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.account_code
        , cln.club_number
        , cln.department_code
        , cln.natural_account
        , cln.corrected_department
        , cln.consol_key
        , cln.region_key
        , cln.group_key
        , cln.ss_dev_key
        , cln.period_date
        , cln.budget_amount
        , cln.budget_version
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.account_code
        and acct.source_table = 'CLN_HERITAGE_GOLF_BUDGET_BY_CLUB'
    left join refs
        on  refs.club_number = cln.c_site
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "PARENT_CODE", "SOURCE_FOLDER", "PROPERTY_NAME", "ACCOUNT_CODE", "CLUB_NUMBER", "DEPARTMENT_CODE", "NATURAL_ACCOUNT", "CORRECTED_DEPARTMENT", "CONSOL_KEY", "REGION_KEY", "GROUP_KEY", "SS_DEV_KEY", "PERIOD_DATE", "BUDGET_AMOUNT", "BUDGET_VERSION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.account_code), '')                     as c_acct
            , null::varchar                                          as c_stat
            , null::varchar                                          as c_item
            , nullif(split_part(trim(src.account_code), '-', 1), '') as c_site
            , nullif(split_part(trim(src.account_code), '-', 2), '') as c_dept
        from src
    )
    -- ------------------------------------------------------------------------
    -- account description dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.source_table
            , a.account_description
            , a.department_description
            , a.parent_code
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS) a
    )
    -- ------------------------------------------------------------------------
    -- club name by GL entity, unique on CLUB_NUMBER (build 10 M1)
    -- ------------------------------------------------------------------------
    , refs as (
        select
              r.club_number
            , r.club_name
        from DEV_G2M_AI.STAGING.STG_HHG_ASSET_CODES r
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'::varchar        as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , refs.club_name::varchar                                               as asset_name
        , case
              when refs.club_name is not null
                  then 'STG_HHG_ASSET_CODES.CLUB_NAME on entity = CLUB_NUMBER (build 10 Q-02)'
          end::varchar                                                          as asset_name_source
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                 as department_name
        , cln.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_dept = '999' then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_dept = '999'
                  then 'department 999: STATISTIC (dept 999, section 9, all whole numbers; owner Q-01)'
              else 'department not 999: AMOUNT (no stating column; M1)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.budget_version::varchar                                           as scenario
        , iff(cln.c_dept = '999', null, cln.budget_amount)::float               as source_amount
        , iff(cln.c_dept = '999', cln.budget_amount, null)::float               as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: Revenue 418,366,403, Labor 127,140,272, Cost of Sales 40,047,115, all positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        , acct.parent_code::varchar                                             as parent_code
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.account_code
        , cln.club_number
        , cln.department_code
        , cln.natural_account
        , cln.corrected_department
        , cln.consol_key
        , cln.region_key
        , cln.group_key
        , cln.ss_dev_key
        , cln.period_date
        , cln.budget_amount
        , cln.budget_version
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.account_code
        and acct.source_table = 'CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'
    left join refs
        on  refs.club_number = cln.c_site
    where 1=1
)) n
union all
select 'STG_HHG_CHART_OF_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CHART_OF_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ACCOUNT_TEMPLATE", "DEPARTMENT_CODE", "DEPARTMENT_NAME", "NATURAL_ACCOUNT", "ACCOUNT_DESCRIPTION", "ACCOUNT_TYPE", "PL_SECTION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CHART_OF_ACCOUNTS'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CHART_OF_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ACCOUNT_TEMPLATE", "DEPARTMENT_CODE", "DEPARTMENT_NAME", "NATURAL_ACCOUNT", "ACCOUNT_DESCRIPTION", "ACCOUNT_TYPE", "PL_SECTION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_HHG_CLUB_LIST' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "CLUB_NAME", "CLUB_CODE", "ACQUISITION_DATE", "STATUS_2022", "STATUS_2023", "STATUS_2024", "STATUS_2025", "STATUS_2026", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "CLUB_NAME", "CLUB_CODE", "ACQUISITION_DATE", "STATUS_2022", "STATUS_2023", "STATUS_2024", "STATUS_2025", "STATUS_2026", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS) src
    where 1=1
)) n
union all
select 'STG_HHG_DEPARTMENT_KEY' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_DEPARTMENT_KEY','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_DEPARTMENTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "DEPARTMENT_CODE", "DEPARTMENT_NAME", "ACCOUNT_COUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_DEPARTMENT_KEY'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_DEPARTMENT_KEY src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "DEPARTMENT_CODE", "DEPARTMENT_NAME", "ACCOUNT_COUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_DEPARTMENTS'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_DEPARTMENTS) src
    where 1=1
)) n
union all
select 'STG_HHG_FORECAST_ANAPLAN' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "LOCATION", "LINE_ITEM", "PERIOD_DATE", "AMOUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.location), '')  as c_site
            , null::varchar                   as c_acct
            , null::varchar                   as c_stat
            , nullif(trim(src.line_item), '') as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.location::varchar                                                 as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every Anaplan line item is a money line (M1)'::varchar               as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_item::varchar                                                as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.amount::float                                                     as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                   as source_sign_convention
        , 'profit-signed: revenue positive, COGS / Payroll / OpEx negative (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , (cln.location = '+All Regions')::boolean                              as is_subtotal
        , case
              when cln.location = '+All Regions'
                  then 'LOCATION +All Regions: sum of the other locations, verified 360 of 360 cells (M1, Q-05)'
              else 'LOCATION is a single club'
          end::varchar                                                          as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.location
        , cln.line_item
        , cln.period_date
        , cln.amount
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "LOCATION", "LINE_ITEM", "PERIOD_DATE", "AMOUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.location), '')  as c_site
            , null::varchar                   as c_acct
            , null::varchar                   as c_stat
            , nullif(trim(src.line_item), '') as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.location::varchar                                                 as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every Anaplan line item is a money line (M1)'::varchar               as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_item::varchar                                                as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.amount::float                                                     as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                   as source_sign_convention
        , 'profit-signed: revenue positive, COGS / Payroll / OpEx negative (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , (cln.location = '+All Regions')::boolean                              as is_subtotal
        , case
              when cln.location = '+All Regions'
                  then 'LOCATION +All Regions: sum of the other locations, verified 360 of 360 cells (M1, Q-05)'
              else 'LOCATION is a single club'
          end::varchar                                                          as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.location
        , cln.line_item
        , cln.period_date
        , cln.amount
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_HHG_REFERENCES' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REFERENCES','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "CLUB_CODE", "CLUB_NAME", "CLUB_NUMBER", "WORKSHEET_CODE", "WORKSHEET_FOLDER_URL", "WORKSHEET_FILE_NAME", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REFERENCES'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REFERENCES src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "CLUB_CODE", "CLUB_NAME", "CLUB_NUMBER", "WORKSHEET_CODE", "WORKSHEET_FOLDER_URL", "WORKSHEET_FILE_NAME", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS) src
    where 1=1
)) n
union all
select 'STG_HHG_ROUNDS_DETAIL' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "ROUND_DATE", "CLUB_CODE", "ROUNDS_COUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.club_code), '') as c_site
            , null::varchar                   as c_acct
            , null::varchar                   as c_stat
            , null::varchar                   as c_item
        from src
    )
    -- ------------------------------------------------------------------------
    -- club name dictionary, unique on CLUB_CODE (M1)
    -- ------------------------------------------------------------------------
    , club as (
        select
              c.club_code
            , c.club_name
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST c
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL'::varchar    as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , club.club_name::varchar                                               as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'STATISTIC'::varchar                                                  as record_type
        , 'ROUNDS_COUNT is a count of rounds played: STATISTIC (owner Q-07)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , null::varchar                                                         as account_desc
        , cln.round_date::date                                                  as period_end
        , 'CLN_HERITAGE_GOLF_ROUNDS_DETAIL'::varchar                            as scenario
        , null::float                                                           as source_amount
        , cln.rounds_count::float                                               as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: rounds and revenue as stated (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(cln.club_code, '~BLANK~'))::varchar             as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.round_date
        , cln.club_code
        , cln.rounds_count
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join club
        on  club.club_code = cln.club_code
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "ROUND_DATE", "CLUB_CODE", "ROUNDS_COUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.club_code), '') as c_site
            , null::varchar                   as c_acct
            , null::varchar                   as c_stat
            , null::varchar                   as c_item
        from src
    )
    -- ------------------------------------------------------------------------
    -- club name dictionary, unique on CLUB_CODE (M1)
    -- ------------------------------------------------------------------------
    , club as (
        select
              c.club_code
            , c.club_name
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS) c
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY'::varchar    as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , club.club_name::varchar                                               as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'STATISTIC'::varchar                                                  as record_type
        , 'ROUNDS_COUNT is a count of rounds played: STATISTIC (owner Q-07)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , null::varchar                                                         as account_desc
        , cln.round_date::date                                                  as period_end
        , 'CLN_HERITAGE_GOLF_ROUNDS_DETAIL'::varchar                            as scenario
        , null::float                                                           as source_amount
        , cln.rounds_count::float                                               as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: rounds and revenue as stated (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(cln.club_code, '~BLANK~'))::varchar             as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.round_date
        , cln.club_code
        , cln.rounds_count
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join club
        on  club.club_code = cln.club_code
    where 1=1
)) n
union all
select 'STG_HHG_TR12_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "LOCATION_CODE", "IS_CONSOLIDATED_SHEET", "ROW_TYPE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "REPORT_SECTION", "LINE_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_ACCOUNTS'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "LOCATION_CODE", "IS_CONSOLIDATED_SHEET", "ROW_TYPE", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "REPORT_SECTION", "LINE_GROUP", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING) src
    where 1=1
)) n
union all
select 'STG_HHG_TR12_DATA' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA','CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "PARENT_CODE", "SOURCE_FOLDER", "PROPERTY_NAME", "ACCOUNT_CODE", "PERIOD_DATE", "AMOUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.account_code), '')                     as c_acct
            , null::varchar                                          as c_stat
            , null::varchar                                          as c_item
            , nullif(split_part(trim(src.account_code), '-', 1), '') as c_site
            , nullif(split_part(trim(src.account_code), '-', 2), '') as c_dept
        from src
    )
    -- ------------------------------------------------------------------------
    -- account description dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.source_table
            , a.account_description
            , a.department_description
            , a.parent_code
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS a
    )
    -- ------------------------------------------------------------------------
    -- club name by GL entity, unique on CLUB_NUMBER (build 10 M1)
    -- ------------------------------------------------------------------------
    , refs as (
        select
              r.club_number
            , r.club_name
        from DEV_G2M_AI.STAGING.STG_HHG_ASSET_CODES r
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA'::varchar        as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , refs.club_name::varchar                                               as asset_name
        , case
              when refs.club_name is not null
                  then 'STG_HHG_ASSET_CODES.CLUB_NAME on entity = CLUB_NUMBER (build 10 Q-02)'
          end::varchar                                                          as asset_name_source
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                 as department_name
        , cln.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_dept = '999' then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_dept = '999'
                  then 'department 999: STATISTIC (dept 999, section 9, all whole numbers; owner Q-01)'
              else 'department not 999: AMOUNT (no stating column; M1)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , iff(cln.c_dept = '999', null, cln.amount)::float                      as source_amount
        , iff(cln.c_dept = '999', cln.amount, null)::float                      as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        , acct.parent_code::varchar                                             as parent_code
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.account_code
        , cln.period_date
        , cln.amount
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.account_code
        and acct.source_table = 'CLN_HERITAGE_GOLF_TR12_DATA'
    left join refs
        on  refs.club_number = cln.c_site
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "ASSET_NAME_SOURCE", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "PARENT_CODE", "SOURCE_FOLDER", "PROPERTY_NAME", "ACCOUNT_CODE", "PERIOD_DATE", "AMOUNT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.account_code), '')                     as c_acct
            , null::varchar                                          as c_stat
            , null::varchar                                          as c_item
            , nullif(split_part(trim(src.account_code), '-', 1), '') as c_site
            , nullif(split_part(trim(src.account_code), '-', 2), '') as c_dept
        from src
    )
    -- ------------------------------------------------------------------------
    -- account description dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.source_table
            , a.account_description
            , a.department_description
            , a.parent_code
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS) a
    )
    -- ------------------------------------------------------------------------
    -- club name by GL entity, unique on CLUB_NUMBER (build 10 M1)
    -- ------------------------------------------------------------------------
    , refs as (
        select
              r.club_number
            , r.club_name
        from DEV_G2M_AI.STAGING.STG_HHG_ASSET_CODES r
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'::varchar        as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , refs.club_name::varchar                                               as asset_name
        , case
              when refs.club_name is not null
                  then 'STG_HHG_ASSET_CODES.CLUB_NAME on entity = CLUB_NUMBER (build 10 Q-02)'
          end::varchar                                                          as asset_name_source
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                 as department_name
        , cln.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_dept = '999' then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_dept = '999'
                  then 'department 999: STATISTIC (dept 999, section 9, all whole numbers; owner Q-01)'
              else 'department not 999: AMOUNT (no stating column; M1)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , iff(cln.c_dept = '999', null, cln.amount)::float                      as source_amount
        , iff(cln.c_dept = '999', cln.amount, null)::float                      as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        , acct.parent_code::varchar                                             as parent_code
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.account_code
        , cln.period_date
        , cln.amount
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.account_code
        and acct.source_table = 'CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'
    left join refs
        on  refs.club_number = cln.c_site
    where 1=1
)) n
union all
select 'STG_INVITED_CLUBS_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNT_TYPE", "META_MATCHED", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNT_TYPE", "META_MATCHED", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_INVITED_CLUBS_ESSBASE_EXTRACT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ESSBASE_EXTRACT','CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_FIN_GL_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "META_ACCOUNT_TYPE", "META_DATA_TYPE", "SOURCE_FOLDER", "PROPERTY_NAME", "REPORT_LEVEL", "ENTITY", "ACCOUNT", "SUBACCOUNT", "LOCATION", "VERSION_NAME", "DAY_OF_MONTH", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "FORECAST_VERSION", "BUDGET_AMOUNT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ESSBASE_EXTRACT
    )
    -- ------------------------------------------------------------------------
    -- unpivot: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL_AMOUNT'::varchar   as measure_column, src.actual_amount   as m_value, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row, null::varchar             as m_version from src
        union all
        select src.*, 'FORECAST_AMOUNT'::varchar as measure_column, src.forecast_amount as m_value, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row, src.forecast_version as m_version from src
        union all
        select src.*, 'BUDGET_AMOUNT'::varchar   as measure_column, src.budget_amount   as m_value, src.budget_source_file_path   as m_path, src.budget_source_row_number   as m_row, null::varchar             as m_version from src
    )
    -- ------------------------------------------------------------------------
    -- dictionaries, one row per member (MIN)
    -- ------------------------------------------------------------------------
    , acct as (
        select account, min(account_type) as account_type, min(data_type) as data_type, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
        group by account
    )
    , ent as (
        select entity, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY
        group by entity
    )
    , dept as (
        select department, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
        group by department
    )
    , cln as (
        select
              unp.*
            , acct.account_type
            , acct.data_type
            , acct.alias_default as account_description
            , ent.alias_default  as entity_description
            , dept.alias_default as department_description
            , iff(lower(trim(acct.data_type)) = 'non-currency', 'STATISTIC', 'AMOUNT') as c_rtype
        from unp
        left join acct on acct.account = unp.account
        left join ent  on ent.entity = unp.entity
        left join dept on dept.department = unp.department
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'INVITED_CLUBS'::varchar                                              as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ESSBASE_EXTRACT'::varchar as source_table
        , nullif(trim(cln.entity), '')::varchar                                 as source_site_code
        , cln.entity_description::varchar                                       as asset_name
        , cln.department::varchar                                               as department
        , cln.department_description::varchar                                   as department_name
        , cln.account::varchar                                                  as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(cln.account), ''), '~BLANK~')::varchar           as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , case
              when cln.data_type is null then 'account not in META_ACCOUNT: AMOUNT (owner Q-05)'
              else 'META_ACCOUNT.DATA_TYPE ' || cln.data_type || ': ' || cln.c_rtype || ' (stated by the source)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account_description::varchar                                      as account_desc
        , cln.period_date::date                                                 as period_end
        , (cln.version_name || iff(cln.m_version is not null, ' | ' || cln.m_version, ''))::varchar as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_value)::float              as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_value, null)::float              as stat_value
        , (cln.report_level = 'EBITDA_SUMMARY' or startswith(cln.account, 'Ind-Total')
           or cln.account in ('Ind-Adjusted Cash EBITDA', 'Ind-Club Operating Profit'))::boolean as is_subtotal
        , case
              when cln.report_level = 'EBITDA_SUMMARY'
                  then 'REPORT_LEVEL EBITDA_SUMMARY: computed Adjusted Cash EBITDA rollup, by structure (owner Q-01)'
              when startswith(cln.account, 'Ind-Total')
                  then 'ACCOUNT Ind-Total*: source rollup of the Ind- members, verified by sum at M1 (build 08 Q-06)'
              when cln.account in ('Ind-Adjusted Cash EBITDA', 'Ind-Club Operating Profit')
                  then 'ACCOUNT Ind-Adjusted Cash EBITDA / Ind-Club Operating Profit: Indicated Calculations rollup, by structure (build 09 Q-04)'
              when cln.day_of_month = 'TotalDOMEnter'
                  then 'DAY_OF_MONTH TotalDOMEnter: borderline, equals Day01-31 in 76 pct of groups; not flagged (owner Q-01)'
              else 'REPORT_LEVEL DETAIL'
          end::varchar                                                          as subtotal_source
        , (cln.report_level || '|' || cln.entity || '|' || cln.account || '|' || cln.department
            || '|' || cln.subaccount || '|' || cln.location || '|' || cln.version_name
            || '|' || cln.day_of_month || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || cln.measure_column)::varchar                            as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        , cln.account_type::varchar                                             as meta_account_type
        , cln.data_type::varchar                                                as meta_data_type
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (DEPARTMENT above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.report_level
        , cln.entity
        , cln.account
        , cln.subaccount
        , cln.location
        , cln.version_name
        , cln.day_of_month
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.forecast_version
        , cln.budget_amount
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
        , cln.budget_source_file_path
        , cln.budget_source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "META_ACCOUNT_TYPE", "META_DATA_TYPE", "SOURCE_FOLDER", "PROPERTY_NAME", "REPORT_LEVEL", "ENTITY", "ACCOUNT", "SUBACCOUNT", "LOCATION", "VERSION_NAME", "DAY_OF_MONTH", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "FORECAST_VERSION", "BUDGET_AMOUNT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_FIN_GL_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- unpivot: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL_AMOUNT'::varchar   as measure_column, src.actual_amount   as m_value, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row, null::varchar             as m_version from src
        union all
        select src.*, 'FORECAST_AMOUNT'::varchar as measure_column, src.forecast_amount as m_value, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row, src.forecast_version as m_version from src
        union all
        select src.*, 'BUDGET_AMOUNT'::varchar   as measure_column, src.budget_amount   as m_value, src.budget_source_file_path   as m_path, src.budget_source_row_number   as m_row, null::varchar             as m_version from src
    )
    -- ------------------------------------------------------------------------
    -- dictionaries, one row per member (MIN)
    -- ------------------------------------------------------------------------
    , acct as (
        select account, min(account_type) as account_type, min(data_type) as data_type, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
        group by account
    )
    , ent as (
        select entity, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY
        group by entity
    )
    , dept as (
        select department, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
        group by department
    )
    , cln as (
        select
              unp.*
            , acct.account_type
            , acct.data_type
            , acct.alias_default as account_description
            , ent.alias_default  as entity_description
            , dept.alias_default as department_description
            , iff(lower(trim(acct.data_type)) = 'non-currency', 'STATISTIC', 'AMOUNT') as c_rtype
        from unp
        left join acct on acct.account = unp.account
        left join ent  on ent.entity = unp.entity
        left join dept on dept.department = unp.department
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'INVITED_CLUBS'::varchar                                              as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_FIN_GL_MONTHLY'::varchar as source_table
        , nullif(trim(cln.entity), '')::varchar                                 as source_site_code
        , cln.entity_description::varchar                                       as asset_name
        , cln.department::varchar                                               as department
        , cln.department_description::varchar                                   as department_name
        , cln.account::varchar                                                  as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(cln.account), ''), '~BLANK~')::varchar           as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , case
              when cln.data_type is null then 'account not in META_ACCOUNT: AMOUNT (owner Q-05)'
              else 'META_ACCOUNT.DATA_TYPE ' || cln.data_type || ': ' || cln.c_rtype || ' (stated by the source)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account_description::varchar                                      as account_desc
        , cln.period_date::date                                                 as period_end
        , (cln.version_name || iff(cln.m_version is not null, ' | ' || cln.m_version, ''))::varchar as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_value)::float              as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_value, null)::float              as stat_value
        , (cln.report_level = 'EBITDA_SUMMARY' or startswith(cln.account, 'Ind-Total')
           or cln.account in ('Ind-Adjusted Cash EBITDA', 'Ind-Club Operating Profit'))::boolean as is_subtotal
        , case
              when cln.report_level = 'EBITDA_SUMMARY'
                  then 'REPORT_LEVEL EBITDA_SUMMARY: computed Adjusted Cash EBITDA rollup, by structure (owner Q-01)'
              when startswith(cln.account, 'Ind-Total')
                  then 'ACCOUNT Ind-Total*: source rollup of the Ind- members, verified by sum at M1 (build 08 Q-06)'
              when cln.account in ('Ind-Adjusted Cash EBITDA', 'Ind-Club Operating Profit')
                  then 'ACCOUNT Ind-Adjusted Cash EBITDA / Ind-Club Operating Profit: Indicated Calculations rollup, by structure (build 09 Q-04)'
              when cln.day_of_month = 'TotalDOMEnter'
                  then 'DAY_OF_MONTH TotalDOMEnter: borderline, equals Day01-31 in 76 pct of groups; not flagged (owner Q-01)'
              else 'REPORT_LEVEL DETAIL'
          end::varchar                                                          as subtotal_source
        , (cln.report_level || '|' || cln.entity || '|' || cln.account || '|' || cln.department
            || '|' || cln.subaccount || '|' || cln.location || '|' || cln.version_name
            || '|' || cln.day_of_month || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || cln.measure_column)::varchar                            as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        , cln.account_type::varchar                                             as meta_account_type
        , cln.data_type::varchar                                                as meta_data_type
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (DEPARTMENT above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.report_level
        , cln.entity
        , cln.account
        , cln.subaccount
        , cln.location
        , cln.version_name
        , cln.day_of_month
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.forecast_version
        , cln.budget_amount
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
        , cln.budget_source_file_path
        , cln.budget_source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_INVITED_CLUBS_META_ACCOUNT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ACCOUNT','CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ACCOUNT',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ACCOUNT", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "ACCOUNT_TYPE", "TIME_BALANCE", "SKIP_VALUE", "EXCHANGE_RATE_TYPE", "VARIANCE_REPORTING", "SOURCE_PLAN_TYPE", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "PLAN_TYPE_CAPPLAN", "AGGREGATION_CAPPLAN", "DATA_STORAGE_CAPPLAN", "FORMULA_CAPPLAN", "SOLVE_ORDER_CAPPLAN", "FORMULA_DESCRIPTION_CAPPLAN", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ACCOUNT'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ACCOUNT src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ACCOUNT", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "ACCOUNT_TYPE", "TIME_BALANCE", "SKIP_VALUE", "EXCHANGE_RATE_TYPE", "VARIANCE_REPORTING", "SOURCE_PLAN_TYPE", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "PLAN_TYPE_CAPPLAN", "AGGREGATION_CAPPLAN", "DATA_STORAGE_CAPPLAN", "FORMULA_CAPPLAN", "SOLVE_ORDER_CAPPLAN", "FORMULA_DESCRIPTION_CAPPLAN", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ACCOUNT'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ACCOUNT) src
    where 1=1
)) n
union all
select 'STG_INVITED_CLUBS_META_DEPARTMENT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_DEPARTMENT','CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_DEPARTMENT',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "DEPARTMENT", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_DEPARTMENT'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_DEPARTMENT src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "DEPARTMENT", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_DEPARTMENT'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_DEPARTMENT) src
    where 1=1
)) n
union all
select 'STG_INVITED_CLUBS_META_ENTITY' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ENTITY','CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ENTITY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "BASE_CURRENCY", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "PLAN_TYPE_CAPPLAN", "AGGREGATION_CAPPLAN", "DATA_STORAGE_CAPPLAN", "FORMULA_CAPPLAN", "SOLVE_ORDER_CAPPLAN", "FORMULA_DESCRIPTION_CAPPLAN", "LIFECYCLEPY", "LIFECYCLECY", "LIFECYCLEPQ", "SEGMENTATION", "CLUBTYPE", "STATE", "SPIRIT_CAPITAL_INVESTMENT", "SPIRIT_OWNERSHIP", "PLANENT", "EXT_SEGMENTATION", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ENTITY'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ENTITY src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "BASE_CURRENCY", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "PLAN_TYPE_CAPPLAN", "AGGREGATION_CAPPLAN", "DATA_STORAGE_CAPPLAN", "FORMULA_CAPPLAN", "SOLVE_ORDER_CAPPLAN", "FORMULA_DESCRIPTION_CAPPLAN", "LIFECYCLEPY", "LIFECYCLECY", "LIFECYCLEPQ", "SEGMENTATION", "CLUBTYPE", "STATE", "SPIRIT_CAPITAL_INVESTMENT", "SPIRIT_OWNERSHIP", "PLANENT", "EXT_SEGMENTATION", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ENTITY'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ENTITY) src
    where 1=1
)) n
union all
select 'STG_INVITED_CLUBS_META_LOCATION' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_LOCATION','CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_LOCATION',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "LOCATION", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_LOCATION'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_LOCATION src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "LOCATION", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_LOCATION'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_LOCATION) src
    where 1=1
)) n
union all
select 'STG_INVITED_CLUBS_META_SUBACCOUNT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_SUBACCOUNT','CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_SUBACCOUNT',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SUBACCOUNT", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_SUBACCOUNT'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_SUBACCOUNT src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SUBACCOUNT", "PARENT", "ALIAS_DEFAULT", "VALID_FOR_CONSOLIDATIONS", "DATA_STORAGE", "TWO_PASS_CALCULATION", "DESCRIPTION", "FORMULA", "FORMULA_DESCRIPTION", "UDA", "SMART_LIST", "DATA_TYPE", "HIERARCHY_TYPE", "ENABLE_FOR_DYNAMIC_CHILDREN", "NUMBER_OF_POSSIBLE_DYNAMIC_CHILDREN", "ACCESS_GRANTED_TO_MEMBER_CREATOR", "ALLOW_UPPER_LEVEL_ENTITY_INPUT", "PROCESS_MANAGEMENT_ENABLED", "UUID", "DATA_ID", "OLD_NAME", "OLD_UNIQUE_NAME", "PLAN_TYPE_FINPLAN", "AGGREGATION_FINPLAN", "DATA_STORAGE_FINPLAN", "FORMULA_FINPLAN", "SOLVE_ORDER_FINPLAN", "FORMULA_DESCRIPTION_FINPLAN", "PLAN_TYPE_FINRPT", "AGGREGATION_FINRPT", "DATA_STORAGE_FINRPT", "FORMULA_FINRPT", "SOLVE_ORDER_FINRPT", "FORMULA_DESCRIPTION_FINRPT", "OPERATION", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_SUBACCOUNT'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_SUBACCOUNT) src
    where 1=1
)) n
union all
select 'STG_JW_VENICE_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'JW_VENICE'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'JW_VENICE'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_JW_VENICE_FCAST_ACT_FORECAST' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST','CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "ACTUAL_REPORT_AS_OF_DATE", "FORECAST_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'SECTION KEY STATISTICS: STATISTIC (derived, M1)' else 'SECTION ' || coalesce(unp.section, '~BLANK~') || ': AMOUNT (derived, M1)' end) as c_rtype_source
            , coalesce(unp.section <> 'KEY STATISTICS' and (
                   unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %'
                or unp.section = 'DEPARTMENT PROFIT'
                or unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)')), false) as c_subtotal
            , (case
                when unp.section = 'KEY STATISTICS' then 'not a subtotal by the M1 rule'
                when unp.section = 'DEPARTMENT PROFIT' then 'SECTION DEPARTMENT PROFIT: computed (M1)'
                when unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %' then 'LINE_ITEM starts TOTAL (M1)'
                when unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)') then 'computed line (M1)'
                else 'not a subtotal by the M1 rule' end) as c_subtotal_source
            , (coalesce(unp.section::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
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
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_text
        , cln.forecast_text
        , cln.actual_report_as_of_date
        , cln.forecast_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "ACTUAL_REPORT_AS_OF_DATE", "FORECAST_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY where source_object = 'REPORT_CELLS: JW_VENICE_FCAST_ACT_FORECAST')
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'SECTION KEY STATISTICS: STATISTIC (derived, M1)' else 'SECTION ' || coalesce(unp.section, '~BLANK~') || ': AMOUNT (derived, M1)' end) as c_rtype_source
            , coalesce(unp.section <> 'KEY STATISTICS' and (
                   unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %'
                or unp.section = 'DEPARTMENT PROFIT'
                or unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)')), false) as c_subtotal
            , (case
                when unp.section = 'KEY STATISTICS' then 'not a subtotal by the M1 rule'
                when unp.section = 'DEPARTMENT PROFIT' then 'SECTION DEPARTMENT PROFIT: computed (M1)'
                when unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %' then 'LINE_ITEM starts TOTAL (M1)'
                when unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)') then 'computed line (M1)'
                else 'not a subtotal by the M1 rule' end) as c_subtotal_source
            , (coalesce(unp.section::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
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
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_text
        , cln.forecast_text
        , cln.actual_report_as_of_date
        , cln.forecast_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_JW_VENICE_FCAST_BY_PERIOD' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD','CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "ACTUAL_REPORT_AS_OF_DATE", "FORECAST_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'SECTION KEY STATISTICS: STATISTIC (derived, M1)' else 'SECTION ' || coalesce(unp.section, '~BLANK~') || ': AMOUNT (derived, M1)' end) as c_rtype_source
            , coalesce(unp.section <> 'KEY STATISTICS' and (
                   unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %'
                or unp.section = 'DEPARTMENT PROFIT'
                or unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)', 'EBITDA EXCLUDING OWNER EXPENSES')), false) as c_subtotal
            , (case
                when unp.section = 'KEY STATISTICS' then 'not a subtotal by the M1 rule'
                when unp.section = 'DEPARTMENT PROFIT' then 'SECTION DEPARTMENT PROFIT: computed (M1)'
                when unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %' then 'LINE_ITEM starts TOTAL (M1)'
                when unp.line_item = 'EBITDA EXCLUDING OWNER EXPENSES' then 'computed line: equals EBITDA in 24 / 24 periods (Q-16 tie test, build 15 Q-09)'
                when unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)') then 'computed line (M1)'
                else 'not a subtotal by the M1 rule' end) as c_subtotal_source
            , (coalesce(unp.section::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
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
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_text
        , cln.forecast_text
        , cln.actual_report_as_of_date
        , cln.forecast_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "SECTION", "LINE_ITEM", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "ACTUAL_TEXT", "FORECAST_TEXT", "ACTUAL_REPORT_AS_OF_DATE", "FORECAST_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY where source_object = 'REPORT_CELLS: JW_VENICE_FCAST_BY_PERIOD')
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , (case when unp.section = 'KEY STATISTICS' and unp.line_item <> 'CREDIT CARD EXPENSE' then 'SECTION KEY STATISTICS: STATISTIC (derived, M1)' else 'SECTION ' || coalesce(unp.section, '~BLANK~') || ': AMOUNT (derived, M1)' end) as c_rtype_source
            , coalesce(unp.section <> 'KEY STATISTICS' and (
                   unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %'
                or unp.section = 'DEPARTMENT PROFIT'
                or unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)', 'EBITDA EXCLUDING OWNER EXPENSES')), false) as c_subtotal
            , (case
                when unp.section = 'KEY STATISTICS' then 'not a subtotal by the M1 rule'
                when unp.section = 'DEPARTMENT PROFIT' then 'SECTION DEPARTMENT PROFIT: computed (M1)'
                when unp.line_item ilike 'TOTAL%' or unp.line_item ilike 'TOT %' then 'LINE_ITEM starts TOTAL (M1)'
                when unp.line_item = 'EBITDA EXCLUDING OWNER EXPENSES' then 'computed line: equals EBITDA in 24 / 24 periods (Q-16 tie test, build 15 Q-09)'
                when unp.line_item in ('GROSS OPERATING PROFIT', 'INCOME BEFORE NON-OP INC/EXP', 'EBITDA EXCL. OWNER EXPENSES', 'EBITDA', 'EBITDA Less REPLACEMENT RESV', 'NET DUE TO/(FROM) OWNER', 'RETAINED PROFIT/(LOSS)') then 'computed line (M1)'
                else 'not a subtotal by the M1 rule' end) as c_subtotal_source
            , (coalesce(unp.section::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
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
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.actual_text
        , cln.forecast_text
        , cln.actual_report_as_of_date
        , cln.forecast_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_JW_VENICE_FTE' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE','CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_FTE',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "DEPARTMENT_CODE", "SRC_DEPARTMENT_NAME", "SRC_IS_SUBTOTAL", "DEPARTMENT_LABEL", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "PREVIOUS_FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'PREVIOUS_FORECAST'::varchar as measure_column, 'PREVIOUS_FORECAST_AMOUNT'::varchar as m_scenario, src.previous_forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , 'STATISTIC' as c_rtype
            , 'table FTE: STATISTIC on every row (derived, M1)' as c_rtype_source
            , coalesce(unp.is_subtotal, false) as c_subtotal
            , (case when unp.is_subtotal then 'source IS_SUBTOTAL (structure only, M1)' else 'source IS_SUBTOTAL false' end) as c_subtotal_source
            , (coalesce(unp.department_label::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department_label), '')::varchar                                    as department
        , cln.department_name::varchar                                                   as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim('FTE'), '')::varchar                                    as source_item_id
        , coalesce(nullif(trim('FTE'), ''), '~BLANK~')::varchar               as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , cln.c_rtype_source::varchar                                           as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.department_label::varchar                                                       as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_amount)::float             as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_amount, null)::float             as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.department_code
        , cln.department_name as src_department_name
        , cln.is_subtotal as src_is_subtotal
        , cln.department_label
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.previous_forecast_amount
        , cln.budget_amount
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "DEPARTMENT_CODE", "SRC_DEPARTMENT_NAME", "SRC_IS_SUBTOTAL", "DEPARTMENT_LABEL", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "PREVIOUS_FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_FTE)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'PREVIOUS_FORECAST'::varchar as measure_column, 'PREVIOUS_FORECAST_AMOUNT'::varchar as m_scenario, src.previous_forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , 'STATISTIC' as c_rtype
            , 'table FTE: STATISTIC on every row (derived, M1)' as c_rtype_source
            , coalesce(unp.is_subtotal, false) as c_subtotal
            , (case when unp.is_subtotal then 'source IS_SUBTOTAL (structure only, M1)' else 'source IS_SUBTOTAL false' end) as c_subtotal_source
            , (coalesce(unp.department_label::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_FTE'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department_label), '')::varchar                                    as department
        , cln.department_name::varchar                                                   as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim('FTE'), '')::varchar                                    as source_item_id
        , coalesce(nullif(trim('FTE'), ''), '~BLANK~')::varchar               as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , cln.c_rtype_source::varchar                                           as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.department_label::varchar                                                       as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_amount)::float             as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_amount, null)::float             as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.department_code
        , cln.department_name as src_department_name
        , cln.is_subtotal as src_is_subtotal
        , cln.department_label
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.previous_forecast_amount
        , cln.budget_amount
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_JW_VENICE_HEADCOUNT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT','CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_HEADCOUNT',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "DEPARTMENT_CODE", "SRC_DEPARTMENT_NAME", "SRC_IS_SUBTOTAL", "DEPARTMENT_LABEL", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "PREVIOUS_FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'PREVIOUS_FORECAST'::varchar as measure_column, 'PREVIOUS_FORECAST_AMOUNT'::varchar as m_scenario, src.previous_forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , 'STATISTIC' as c_rtype
            , 'table HEADCOUNT: STATISTIC on every row (derived, M1)' as c_rtype_source
            , coalesce(unp.is_subtotal, false) as c_subtotal
            , (case when unp.is_subtotal then 'source IS_SUBTOTAL (structure only, M1)' else 'source IS_SUBTOTAL false' end) as c_subtotal_source
            , (coalesce(unp.department_label::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department_label), '')::varchar                                    as department
        , cln.department_name::varchar                                                   as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim('HEADCOUNT'), '')::varchar                                    as source_item_id
        , coalesce(nullif(trim('HEADCOUNT'), ''), '~BLANK~')::varchar               as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , cln.c_rtype_source::varchar                                           as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.department_label::varchar                                                       as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_amount)::float             as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_amount, null)::float             as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.department_code
        , cln.department_name as src_department_name
        , cln.is_subtotal as src_is_subtotal
        , cln.department_label
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.previous_forecast_amount
        , cln.budget_amount
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "DEPARTMENT_CODE", "SRC_DEPARTMENT_NAME", "SRC_IS_SUBTOTAL", "DEPARTMENT_LABEL", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "PREVIOUS_FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_FILE_REPORT_MONTH", "FORECAST_FILE_REPORT_MONTH", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_HEADCOUNT)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, 'ACTUAL_AMOUNT'::varchar as m_scenario, src.actual_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'FORECAST'::varchar as measure_column, 'FORECAST_AMOUNT'::varchar as m_scenario, src.forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'PREVIOUS_FORECAST'::varchar as measure_column, 'PREVIOUS_FORECAST_AMOUNT'::varchar as m_scenario, src.previous_forecast_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.source_file_path as m_path, src.source_row_number as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , 'STATISTIC' as c_rtype
            , 'table HEADCOUNT: STATISTIC on every row (derived, M1)' as c_rtype_source
            , coalesce(unp.is_subtotal, false) as c_subtotal
            , (case when unp.is_subtotal then 'source IS_SUBTOTAL (structure only, M1)' else 'source IS_SUBTOTAL false' end) as c_subtotal_source
            , (coalesce(unp.department_label::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_HEADCOUNT'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department_label), '')::varchar                                    as department
        , cln.department_name::varchar                                                   as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim('HEADCOUNT'), '')::varchar                                    as source_item_id
        , coalesce(nullif(trim('HEADCOUNT'), ''), '~BLANK~')::varchar               as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , cln.c_rtype_source::varchar                                           as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.department_label::varchar                                                       as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.m_scenario::varchar                                               as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_amount)::float             as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_amount, null)::float             as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.department_code
        , cln.department_name as src_department_name
        , cln.is_subtotal as src_is_subtotal
        , cln.department_label
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.previous_forecast_amount
        , cln.budget_amount
        , cln.actual_file_report_month
        , cln.forecast_file_report_month
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_JW_VENICE_MONTHLY_PL_DEPT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT','CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_DEPARTMENT',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "SRC_DEPARTMENT", "IS_ROLLUP", "SECTION", "LINE_ITEM", "PERIOD_DATE", "PERIOD_TYPE", "LINE_ORDER", "SRC_IS_SUBTOTAL", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_SOURCE_SCENARIO", "ACTUAL_REPORT_AS_OF_DATE", "BUDGET_REPORT_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_CELL", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_CELL") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, src.actual_source_scenario::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_cell as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.budget_source_file_path as m_path, src.budget_source_cell as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '98[0-9]{4}')
                    or regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?')
                    or unp.line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House') then 'STATISTIC'
                  else 'AMOUNT' end) as c_rtype
            , (case
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '98[0-9]{4}') then 'LINE_ITEM 98xxxx hours account: STATISTIC (derived, M1)'
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?') then 'LINE_ITEM 4-digit statistic code: STATISTIC (derived, M1)'
                  when unp.line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House') then 'LINE_ITEM named statistic: STATISTIC (derived, M1)'
                  else 'LINE_ITEM GL account or named money line: AMOUNT (derived, M1)' end) as c_rtype_source
            , (case
                  when unp.line_item in ('Non-management', 'Contract Labor', 'HOURS & HRS POR', 'HOURS (incl. NE Mgrs) & HRS POR') then true
                  when c_rtype = 'AMOUNT' and not regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{6}') then true
                  else false end) as c_subtotal
            , (case
                  when unp.line_item in ('Non-management', 'Contract Labor', 'HOURS & HRS POR', 'HOURS (incl. NE Mgrs) & HRS POR') then 'named hours line: total of its 98xxxx accounts (M3)'
                  when c_rtype = 'AMOUNT' and not regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{6}') then 'named money line: equals its family (Q-16, M1: 100% of cells)'
                  else 'GL account or statistic: detail' end) as c_subtotal_source
            , (coalesce(unp.department::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_order::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.period_type::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department), '')::varchar                                    as department
        , cln.department::varchar                                                   as department_name
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
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.department as src_department
        , cln.is_rollup
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.period_type
        , cln.line_order
        , cln.is_subtotal as src_is_subtotal
        , cln.actual_amount
        , cln.forecast_amount
        , cln.budget_amount
        , cln.actual_source_scenario
        , cln.actual_report_as_of_date
        , cln.budget_report_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_cell
        , cln.budget_source_file_path
        , cln.budget_source_cell
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "MEASURE_SOURCE_FILE_PATH", "MEASURE_SOURCE_ROW", "SOURCE_FOLDER", "PROPERTY_NAME", "SRC_DEPARTMENT", "IS_ROLLUP", "SECTION", "LINE_ITEM", "PERIOD_DATE", "PERIOD_TYPE", "LINE_ORDER", "SRC_IS_SUBTOTAL", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "ACTUAL_SOURCE_SCENARIO", "ACTUAL_REPORT_AS_OF_DATE", "BUDGET_REPORT_AS_OF_DATE", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_CELL", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_CELL") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_DEPARTMENT)
    )
    -- ------------------------------------------------------------------------
    -- unpivot by category: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL'::varchar as measure_column, src.actual_source_scenario::varchar as m_scenario, src.actual_amount as m_amount, src.actual_source_file_path as m_path, src.actual_source_cell as m_row from src
        union all
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount, src.budget_source_file_path as m_path, src.budget_source_cell as m_row from src
    )
    -- ------------------------------------------------------------------------
    -- per-row derivations
    -- ------------------------------------------------------------------------
    , cln as (
        select unp.*
            , (case
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '98[0-9]{4}')
                    or regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?')
                    or unp.line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House') then 'STATISTIC'
                  else 'AMOUNT' end) as c_rtype
            , (case
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '98[0-9]{4}') then 'LINE_ITEM 98xxxx hours account: STATISTIC (derived, M1)'
                  when regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{4}(-[0-9]{4})?') then 'LINE_ITEM 4-digit statistic code: STATISTIC (derived, M1)'
                  when unp.line_item in ('Rooms Sold', 'Total Rooms', 'TOTAL OCC ROOMS & OCC PT', 'DEPARTMENT VOLUME', 'Non-management', 'Contract Labor', 'HOURS & HRS POR', 'Non-management | Non-management | #2', 'Contract Labor | Contract Labor | #2', 'SALES/HOUR', 'Non-management*', 'Contract Labor | Contract Labor | #3', 'AVERAGE RATE*', 'NUMBER OF MANAGERS', 'NUMBER OF SUPERVISORS', 'NUMBER OF NON-MANAGER ASSOCIATES', 'HOURS (incl. NE Mgrs) & HRS POR', 'SALES/HOUR (incl. NE Mgrs)', 'AVERAGE RATE (incl. NE Mgrs)', '% TO TOT WAGES', 'CONTROLLABLES CPV', 'DEPARTMENT CPV', 'Total Guests in House') then 'LINE_ITEM named statistic: STATISTIC (derived, M1)'
                  else 'LINE_ITEM GL account or named money line: AMOUNT (derived, M1)' end) as c_rtype_source
            , (case
                  when unp.line_item in ('Non-management', 'Contract Labor', 'HOURS & HRS POR', 'HOURS (incl. NE Mgrs) & HRS POR') then true
                  when c_rtype = 'AMOUNT' and not regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{6}') then true
                  else false end) as c_subtotal
            , (case
                  when unp.line_item in ('Non-management', 'Contract Labor', 'HOURS & HRS POR', 'HOURS (incl. NE Mgrs) & HRS POR') then 'named hours line: total of its 98xxxx accounts (M3)'
                  when c_rtype = 'AMOUNT' and not regexp_like(split_part(unp.line_item, ' | ', 1), '[0-9]{6}') then 'named money line: equals its family (Q-16, M1: 100% of cells)'
                  else 'GL account or statistic: detail' end) as c_subtotal_source
            , (coalesce(unp.department::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_order::varchar, '~BLANK~')
            || '|' || coalesce(unp.line_item::varchar, '~BLANK~')
            || '|' || coalesce(to_char(unp.period_date, 'YYYY-MM-DD')::varchar, '~BLANK~')
            || '|' || coalesce(unp.period_type::varchar, '~BLANK~')
            || '|' || coalesce(unp.measure_column::varchar, '~BLANK~'))::varchar as c_line_key
        from unp
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                     as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_DEPARTMENT'::varchar as source_table
        , nullif(trim(cln.property_name), '')::varchar                                    as source_site_code
        , cln.property_name::varchar                                                      as asset_name
        , nullif(trim(cln.department), '')::varchar                                    as department
        , cln.department::varchar                                                   as department_name
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
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
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
        , cln.department as src_department
        , cln.is_rollup
        , cln.section
        , cln.line_item
        , cln.period_date
        , cln.period_type
        , cln.line_order
        , cln.is_subtotal as src_is_subtotal
        , cln.actual_amount
        , cln.forecast_amount
        , cln.budget_amount
        , cln.actual_source_scenario
        , cln.actual_report_as_of_date
        , cln.budget_report_as_of_date
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_cell
        , cln.budget_source_file_path
        , cln.budget_source_cell
    from cln
    where 1=1
)) n
union all
select 'STG_NEWBURY_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_NEWBURY_OPERATING_STATS_BGT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_ID", "STAY_DATE", "ROOMS", "REVENUE", "YEAR_MONTH", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.hotel_id), '') as c_site
            , null::varchar                  as c_acct
            , null::varchar                  as c_stat
            , null::varchar                  as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'NEWBURY'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.property_name::varchar                                            as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'row carries REVENUE (money) and ROOMS (statistic): AMOUNT, STAT_UNIT_FAMILY set (owner Q-12, D-29)'::varchar as record_type_source
        , 'ROOMS'::varchar                                                      as stat_unit_family
        , null::varchar                                                         as account_desc
        , cln.stay_date::date                                                   as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.revenue::float                                                    as source_amount
        , cln.rooms::float                                                      as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.hotel_id
        , cln.stay_date
        , cln.rooms
        , cln.revenue
        , cln.year_month
        , cln.file_report_date
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_ID", "STAY_DATE", "ROOMS", "REVENUE", "YEAR_MONTH", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.hotel_id), '') as c_site
            , null::varchar                  as c_acct
            , null::varchar                  as c_stat
            , null::varchar                  as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'NEWBURY'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.property_name::varchar                                            as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'row carries REVENUE (money) and ROOMS (statistic): AMOUNT, STAT_UNIT_FAMILY set (owner Q-12, D-29)'::varchar as record_type_source
        , 'ROOMS'::varchar                                                      as stat_unit_family
        , null::varchar                                                         as account_desc
        , cln.stay_date::date                                                   as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.revenue::float                                                    as source_amount
        , cln.rooms::float                                                      as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.hotel_id
        , cln.stay_date
        , cln.rooms
        , cln.revenue
        , cln.year_month
        , cln.file_report_date
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "OCC_DATE", "DAILY_EVENT", "OUT_OF_ORDER_ROOMS", "OVERBOOK_ROOMS", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "OCC_DATE", "DAILY_EVENT", "OUT_OF_ORDER_ROOMS", "OVERBOOK_ROOMS", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO) src
    where 1=1
)) n
union all
select 'STG_NEWBURY_OPERATING_STATS_FCST' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "STAY_DATE", "SCENARIO", "ROOMS", "REVENUE", "YEAR_MONTH", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "STAY_DATE", "SCENARIO", "ROOMS", "REVENUE", "YEAR_MONTH", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST) src
    where 1=1
)) n
union all
select 'STG_NEWBURY_OPERATING_STATS_PYACT' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_ID", "STAY_DATE", "ROOMS", "REVENUE", "YEAR_MONTH", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.hotel_id), '') as c_site
            , null::varchar                  as c_acct
            , null::varchar                  as c_stat
            , null::varchar                  as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'NEWBURY'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.property_name::varchar                                            as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'row carries REVENUE (money) and ROOMS (statistic): AMOUNT, STAT_UNIT_FAMILY set (owner Q-12, D-29)'::varchar as record_type_source
        , 'ROOMS'::varchar                                                      as stat_unit_family
        , null::varchar                                                         as account_desc
        , cln.stay_date::date                                                   as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.revenue::float                                                    as source_amount
        , cln.rooms::float                                                      as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.hotel_id
        , cln.stay_date
        , cln.rooms
        , cln.revenue
        , cln.year_month
        , cln.file_report_date
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "SOURCE_FOLDER", "PROPERTY_NAME", "HOTEL_ID", "STAY_DATE", "ROOMS", "REVENUE", "YEAR_MONTH", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.hotel_id), '') as c_site
            , null::varchar                  as c_acct
            , null::varchar                  as c_stat
            , null::varchar                  as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'NEWBURY'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.property_name::varchar                                            as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'row carries REVENUE (money) and ROOMS (statistic): AMOUNT, STAT_UNIT_FAMILY set (owner Q-12, D-29)'::varchar as record_type_source
        , 'ROOMS'::varchar                                                      as stat_unit_family
        , null::varchar                                                         as account_desc
        , cln.stay_date::date                                                   as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.revenue::float                                                    as source_amount
        , cln.rooms::float                                                      as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'statistic values as stated; no money sign (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.hotel_id
        , cln.stay_date
        , cln.rooms
        , cln.revenue
        , cln.year_month
        , cln.file_report_date
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    where 1=1
)) n
union all
select 'STG_NEWBURY_OPERATING_STATS_SHOPS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SHOP_HOTEL_ID", "COMP_HOTEL_NAME", "REPORTED_DATE", "STAY_DATE", "OTA", "IS_BAR", "RATE_VALUE", "ROOM_NAME", "ROOM_TYPE", "RATE_COMMENT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SHOP_HOTEL_ID", "COMP_HOTEL_NAME", "REPORTED_DATE", "STAY_DATE", "OTA", "IS_BAR", "RATE_VALUE", "ROOM_NAME", "ROOM_TYPE", "RATE_COMMENT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS) src
    where 1=1
)) n
union all
select 'STG_NEWBURY_OTB_1DAY_PICKUP' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "HOTEL_NAME", "REPORT_DATE", "STAY_DATE", "YEAR_MONTH", "MARKET_SEGMENT", "ROOMS", "REVENUE", "AVAILABLE_ROOMS", "POSTPD", "DATA_SOURCE", "DATA_TYPE", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "HOTEL_NAME", "REPORT_DATE", "STAY_DATE", "YEAR_MONTH", "MARKET_SEGMENT", "ROOMS", "REVENUE", "AVAILABLE_ROOMS", "POSTPD", "DATA_SOURCE", "DATA_TYPE", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY) src
    where 1=1
)) n
union all
select 'STG_NEWBURY_OTB_3DAY_PICKUP' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "HOTEL_NAME", "REPORT_DATE", "STAY_DATE", "YEAR_MONTH", "MARKET_SEGMENT", "ROOMS", "REVENUE", "AVAILABLE_ROOMS", "POSTPD", "DATA_SOURCE", "DATA_TYPE", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "HOTEL_ID", "HOTEL_NAME", "REPORT_DATE", "STAY_DATE", "YEAR_MONTH", "MARKET_SEGMENT", "ROOMS", "REVENUE", "AVAILABLE_ROOMS", "POSTPD", "DATA_SOURCE", "DATA_TYPE", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY) src
    where 1=1
)) n
union all
select 'STG_NEWBURY_TRIAL_BALANCE' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_REF_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE','CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "NODE_TYPE", "SRC_DEPARTMENT", "ACCOUNT", "SUBACCOUNT", "SRC_ACCOUNT_KEY", "BUSINESS_UNIT", "FULL_ACCOUNT_KEY", "VALUE_TYPE", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "FORECAST_VERSION", "BUDGET_AMOUNT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_FILE_EXPORT_TS", "FORECAST_FILE_EXPORT_TS", "BUDGET_FILE_EXPORT_TS", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE
    )
    -- ------------------------------------------------------------------------
    -- unpivot: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL_AMOUNT'::varchar   as measure_column, src.actual_amount   as measure_value, 'ACTUAL_AMOUNT'::varchar   as measure_scenario from src
        union all
        select src.*, 'FORECAST_AMOUNT'::varchar as measure_column, src.forecast_amount as measure_value, coalesce(nullif(src.forecast_version, ''), 'FORECAST_AMOUNT')::varchar as measure_scenario from src
        union all
        select src.*, 'BUDGET_AMOUNT'::varchar   as measure_column, src.budget_amount   as measure_value, 'BUDGET_AMOUNT'::varchar   as measure_scenario from src
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              unp.*
            , nullif(trim(unp.business_unit), '')                        as c_site
            , nullif(trim(unp.full_account_key), '')                     as c_acct
            , null::varchar                                              as c_stat
            , null::varchar                                              as c_item
            , nullif(split_part(trim(unp.full_account_key), '-', 1), '') as c_dept
            , upper(trim(unp.value_type))                                as c_vtype
        from unp
    )
    -- ------------------------------------------------------------------------
    -- account dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.account_description
            , a.department_description
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_ACCOUNTS a
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'NEWBURY'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE'::varchar   as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.property_name::varchar                                            as asset_name
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                  as department_name
        , cln.full_account_key::varchar                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case cln.c_vtype
              when 'AMOUNT' then 'AMOUNT'
              when 'STAT'   then 'STATISTIC'
              else cln.c_vtype
          end::varchar                                                          as record_type
        , ('VALUE_TYPE ' || coalesce(cln.value_type, '~BLANK~') || ' (stated by the source, M1)')::varchar as record_type_source
        , iff(cln.c_vtype = 'STAT', cln.subaccount, null)::varchar              as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.measure_scenario::varchar                                         as scenario
        , iff(cln.c_vtype = 'STAT', null, cln.measure_value)::float             as source_amount
        , iff(cln.c_vtype = 'STAT', cln.measure_value, null)::float             as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue (4xxx) and costs (5xxx-7xxx) both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , coalesce(cln.node_type <> 'Leaf', false)::boolean                     as is_subtotal
        , ('NODE_TYPE ' || coalesce(cln.node_type, '~BLANK~') || ': subtotal unless Leaf (M1)')::varchar as subtotal_source
        , (coalesce(cln.full_account_key, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(cln.value_type, '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (two renamed, see header)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.node_type
        , cln.department                as src_department
        , cln.account
        , cln.subaccount
        , cln.account_key               as src_account_key
        , cln.business_unit
        , cln.full_account_key
        , cln.value_type
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.forecast_version
        , cln.budget_amount
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_file_export_ts
        , cln.forecast_file_export_ts
        , cln.budget_file_export_ts
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
        , cln.budget_source_file_path
        , cln.budget_source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.full_account_key
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "SOURCE_SIGN_CONVENTION", "SOURCE_SIGN_CONVENTION_SOURCE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PROPERTY_NAME", "NODE_TYPE", "SRC_DEPARTMENT", "ACCOUNT", "SUBACCOUNT", "SRC_ACCOUNT_KEY", "BUSINESS_UNIT", "FULL_ACCOUNT_KEY", "VALUE_TYPE", "PERIOD_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "FORECAST_VERSION", "BUDGET_AMOUNT", "ACTUAL_FILE_DATE", "FORECAST_FILE_DATE", "BUDGET_FILE_DATE", "ACTUAL_FILE_EXPORT_TS", "FORECAST_FILE_EXPORT_TS", "BUDGET_FILE_EXPORT_TS", "ACTUAL_SOURCE_FILE_PATH", "ACTUAL_SOURCE_ROW_NUMBER", "FORECAST_SOURCE_FILE_PATH", "FORECAST_SOURCE_ROW_NUMBER", "BUDGET_SOURCE_FILE_PATH", "BUDGET_SOURCE_ROW_NUMBER") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- unpivot: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL_AMOUNT'::varchar   as measure_column, src.actual_amount   as measure_value, 'ACTUAL_AMOUNT'::varchar   as measure_scenario from src
        union all
        select src.*, 'FORECAST_AMOUNT'::varchar as measure_column, src.forecast_amount as measure_value, coalesce(nullif(src.forecast_version, ''), 'FORECAST_AMOUNT')::varchar as measure_scenario from src
        union all
        select src.*, 'BUDGET_AMOUNT'::varchar   as measure_column, src.budget_amount   as measure_value, 'BUDGET_AMOUNT'::varchar   as measure_scenario from src
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              unp.*
            , nullif(trim(unp.business_unit), '')                        as c_site
            , nullif(trim(unp.full_account_key), '')                     as c_acct
            , null::varchar                                              as c_stat
            , null::varchar                                              as c_item
            , nullif(split_part(trim(unp.full_account_key), '-', 1), '') as c_dept
            , upper(trim(unp.value_type))                                as c_vtype
        from unp
    )
    -- ------------------------------------------------------------------------
    -- account dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.account_description
            , a.department_description
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_REF_ACCOUNTS) a
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'NEWBURY'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY'::varchar   as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.property_name::varchar                                            as asset_name
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                  as department_name
        , cln.full_account_key::varchar                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case cln.c_vtype
              when 'AMOUNT' then 'AMOUNT'
              when 'STAT'   then 'STATISTIC'
              else cln.c_vtype
          end::varchar                                                          as record_type
        , ('VALUE_TYPE ' || coalesce(cln.value_type, '~BLANK~') || ' (stated by the source, M1)')::varchar as record_type_source
        , iff(cln.c_vtype = 'STAT', cln.subaccount, null)::varchar              as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.measure_scenario::varchar                                         as scenario
        , iff(cln.c_vtype = 'STAT', null, cln.measure_value)::float             as source_amount
        , iff(cln.c_vtype = 'STAT', cln.measure_value, null)::float             as stat_value
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue (4xxx) and costs (5xxx-7xxx) both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , coalesce(cln.node_type <> 'Leaf', false)::boolean                     as is_subtotal
        , ('NODE_TYPE ' || coalesce(cln.node_type, '~BLANK~') || ': subtotal unless Leaf (M1)')::varchar as subtotal_source
        , (coalesce(cln.full_account_key, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(cln.value_type, '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (two renamed, see header)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.node_type
        , cln.department                as src_department
        , cln.account
        , cln.subaccount
        , cln.account_key               as src_account_key
        , cln.business_unit
        , cln.full_account_key
        , cln.value_type
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.forecast_version
        , cln.budget_amount
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_file_export_ts
        , cln.forecast_file_export_ts
        , cln.budget_file_export_ts
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
        , cln.budget_source_file_path
        , cln.budget_source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.full_account_key
    where 1=1
)) n
union all
select 'STG_OUTRIGGER_PACE' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE','CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "PROPERTY_NAME", "SEGMENT", "STAY_MONTH", "STAY_MONTH_LABEL", "CY_PACE_OCCUPANCY", "CY_PACE_ROOMS", "CY_PACE_ADR", "CY_PACE_REVENUE", "LY_PACE_OCCUPANCY", "LY_PACE_ROOMS", "LY_PACE_ADR", "LY_PACE_REVENUE", "FORECAST_OCCUPANCY", "FORECAST_ROOMS", "FORECAST_ADR", "FORECAST_REVENUE", "BUDGET_OCCUPANCY", "BUDGET_ROOMS", "BUDGET_ADR", "BUDGET_REVENUE", "REPORT_FILTERS", "EXPORT_LAYOUT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_GROUP") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'OUTRIGGER'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE'::varchar                            as source_table
        , src.* rename (source_table as export_layout)
    from CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "PROPERTY_NAME", "SEGMENT", "STAY_MONTH", "STAY_MONTH_LABEL", "CY_PACE_OCCUPANCY", "CY_PACE_ROOMS", "CY_PACE_ADR", "CY_PACE_REVENUE", "LY_PACE_OCCUPANCY", "LY_PACE_ROOMS", "LY_PACE_ADR", "LY_PACE_REVENUE", "FORECAST_OCCUPANCY", "FORECAST_ROOMS", "FORECAST_ADR", "FORECAST_REVENUE", "BUDGET_OCCUPANCY", "BUDGET_ROOMS", "BUDGET_ADR", "BUDGET_REVENUE", "REPORT_FILTERS", "EXPORT_LAYOUT", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_GROUP") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'OUTRIGGER'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY'::varchar                            as source_table
        , src.* rename (source_table as export_layout)
    from (select *, portfolio_name as property_group from CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY) src
    where 1=1
)) n
union all
select 'STG_THE_PIG_PACE_NEXT_YEAR' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_NEXT_YEAR','CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "STAY_MONTH_LABEL", "MARKET_SEGMENT", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOMS_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOMS_COMMIT", "ST2Y_DATE_ROOM_REVENUE_COMMIT", "ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'THE_PIG'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_NEXT_YEAR'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_NEXT_YEAR src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "STAY_MONTH_LABEL", "MARKET_SEGMENT", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOMS_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOMS_COMMIT", "ST2Y_DATE_ROOM_REVENUE_COMMIT", "ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'THE_PIG'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY'::varchar                            as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY where pace_year = 'NEXT_YEAR') src
    where 1=1
)) n
union all
select 'STG_THE_PIG_PACE_THIS_YEAR' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_THIS_YEAR','CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "STAY_MONTH_LABEL", "MARKET_SEGMENT", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOMS_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOMS_COMMIT", "ST2Y_DATE_ROOM_REVENUE_COMMIT", "ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'THE_PIG'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_THIS_YEAR'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_THIS_YEAR src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "STAY_MONTH_LABEL", "MARKET_SEGMENT", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOMS_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOMS_COMMIT", "ST2Y_DATE_ROOM_REVENUE_COMMIT", "ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF", "TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'THE_PIG'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY'::varchar                            as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY where pace_year = 'THIS_YEAR') src
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_REF_ACCOUNTS',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_ACCOUNTS'::varchar                            as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_ACCOUNTS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_CODE", "FULL_ACCOUNT_STRING", "ACCOUNT_CODE", "ACCOUNT_DESCRIPTION", "DEPARTMENT_CODE", "DEPARTMENT_DESCRIPTION", "SUBACCOUNT_CODE", "SUBACCOUNT_DESCRIPTION", "PARENT_CODE", "ALIAS", "ACCOUNTS_SOURCE_TABLE", "FIRST_SEEN_DATE", "LAST_SEEN_DATE", "ROW_COUNT", "ENTITY_NAME", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_REF_ACCOUNTS'::varchar                            as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_REF_ACCOUNTS) src
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_NON_OPEX',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "SOURCE_INTEGRATION", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "SAGE_INTACCT_BATCH_DATE", "SAGE_INTACCT_BATCH_NUMBER", "SAGE_INTACCT_BATCH_TITLE", "SAGE_INTACCT_CLASS_NAME", "SAGE_INTACCT_CLASS_NUMBER", "SAGE_INTACCT_CUSTOMER_NAME", "SAGE_INTACCT_CUSTOMER_NUMBER", "SAGE_INTACCT_DEPARTMENT_NAME", "SAGE_INTACCT_DEPARTMENT_NUMBER", "SAGE_INTACCT_DESCRIPTION", "SAGE_INTACCT_DOCUMENT", "SAGE_INTACCT_EMPLOYEE_NAME", "SAGE_INTACCT_EMPLOYEE_NUMBER", "SAGE_INTACCT_GL_ACCOUNT_NAME", "SAGE_INTACCT_GL_ACCOUNT_NUMBER", "SAGE_INTACCT_ITEM_NAME", "SAGE_INTACCT_ITEM_NUMBER", "SAGE_INTACCT_JOURNAL", "SAGE_INTACCT_JOURNAL_ENTRY_CREATED_BY", "SAGE_INTACCT_JOURNAL_ENTRY_TYPE", "SAGE_INTACCT_LOCATION_NAME", "SAGE_INTACCT_LOCATION_NUMBER", "SAGE_INTACCT_MEMO", "SAGE_INTACCT_PROJECT_NAME", "SAGE_INTACCT_PROJECT_NUMBER", "SAGE_INTACCT_VENDOR_NAME", "SAGE_INTACCT_VENDOR_NUMBER", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'AMOUNT'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES: AMOUNT (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.actual_amount::float                                          as source_amount
        , null::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "SOURCE_INTEGRATION", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "SAGE_INTACCT_BATCH_DATE", "SAGE_INTACCT_BATCH_NUMBER", "SAGE_INTACCT_BATCH_TITLE", "SAGE_INTACCT_CLASS_NAME", "SAGE_INTACCT_CLASS_NUMBER", "SAGE_INTACCT_CUSTOMER_NAME", "SAGE_INTACCT_CUSTOMER_NUMBER", "SAGE_INTACCT_DEPARTMENT_NAME", "SAGE_INTACCT_DEPARTMENT_NUMBER", "SAGE_INTACCT_DESCRIPTION", "SAGE_INTACCT_DOCUMENT", "SAGE_INTACCT_EMPLOYEE_NAME", "SAGE_INTACCT_EMPLOYEE_NUMBER", "SAGE_INTACCT_GL_ACCOUNT_NAME", "SAGE_INTACCT_GL_ACCOUNT_NUMBER", "SAGE_INTACCT_ITEM_NAME", "SAGE_INTACCT_ITEM_NUMBER", "SAGE_INTACCT_JOURNAL", "SAGE_INTACCT_JOURNAL_ENTRY_CREATED_BY", "SAGE_INTACCT_JOURNAL_ENTRY_TYPE", "SAGE_INTACCT_LOCATION_NAME", "SAGE_INTACCT_LOCATION_NUMBER", "SAGE_INTACCT_MEMO", "SAGE_INTACCT_PROJECT_NAME", "SAGE_INTACCT_PROJECT_NUMBER", "SAGE_INTACCT_VENDOR_NAME", "SAGE_INTACCT_VENDOR_NUMBER", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_NON_OPEX)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_NON_OPEX'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'AMOUNT'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES: AMOUNT (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.actual_amount::float                                          as source_amount
        , null::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_OPEX',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "FORMULA_LOGIC", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'AMOUNT'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES: AMOUNT (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.actual_amount::float                                          as source_amount
        , null::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "FORMULA_LOGIC", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_OPEX)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_OPEX'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'AMOUNT'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES: AMOUNT (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.actual_amount::float                                          as source_amount
        , null::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_CANCELLATIONS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CANCELLATIONS','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "MARKET_SEGMENT", "GROUP_LEISURE", "TODAY_CANCELED_REVENUE", "TODAY_CANCELED_ROOMS", "STLY_CANCELED_REVENUE", "STLY_CANCELED_ROOMS", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CANCELLATIONS'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CANCELLATIONS src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "MARKET_SEGMENT", "GROUP_LEISURE", "TODAY_CANCELED_REVENUE", "TODAY_CANCELED_ROOMS", "STLY_CANCELED_REVENUE", "STLY_CANCELED_ROOMS", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY'::varchar                            as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY) src
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_CONSOLIDATED_PL' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CONSOLIDATED_PL','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_PL_SUMMARY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_NAME", "LINE_ORDER", "LINE_ITEM", "SOURCE_SECTION_LABEL", "PERIOD_LABEL", "PERIOD_DATE", "PERIOD_TYPE", "SRC_SCENARIO", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CONSOLIDATED_PL
    )
    , cln as (
        select
              src.*
            , (case when src.line_item in ('Days Open', '# of Tents/Rooms', 'Rooms Available', 'Rooms Sold', 'Occupancy %', 'Average Daily Rate', 'Revenue per Available Room', 'Operating CPORs', 'Non-Operating CPORs', 'Adjusted GOP %', 'Adjusted EBITDA Margin %') then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , coalesce(src.line_order in (23, 33, 40, 45, 50, 55, 70, 72, 73, 75, 88, 94, 98, 99, 105, 128, 133, 135), false) as c_subtotal
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CONSOLIDATED_PL'::varchar as source_table
        , nullif(trim(cln.entity_name), '')::varchar                            as source_site_code
        , cln.entity_name::varchar                                              as asset_name
        , nullif(trim(cln.source_section_label), '')::varchar                   as department
        , cln.source_section_label::varchar                                     as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(cln.line_item), '')::varchar                              as source_item_id
        , coalesce(nullif(trim(cln.line_item), ''), '~BLANK~')::varchar         as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , (case when cln.c_rtype = 'STATISTIC' then 'LINE_ITEM named statistic or ratio: STATISTIC (derived, M1)' else 'LINE_ITEM money line: AMOUNT (derived, M1)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_item::varchar                                                as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.actual_amount)::float        as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.actual_amount, null)::float        as stat_value
        , cln.c_subtotal::boolean                                               as is_subtotal
        , (case when cln.c_subtotal then 'total or chain line, ties to its members (M1 tie test)' else 'not a tested total' end)::varchar as subtotal_source
        , (coalesce(to_char(cln.line_order), '~BLANK~') || '|' || coalesce(cln.period_type, '~BLANK~'))::varchar as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_rtype, c_subtotal) rename (scenario as src_scenario)
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "ENTITY_NAME", "LINE_ORDER", "LINE_ITEM", "SOURCE_SECTION_LABEL", "PERIOD_LABEL", "PERIOD_DATE", "PERIOD_TYPE", "SRC_SCENARIO", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_PL_SUMMARY)
    )
    , cln as (
        select
              src.*
            , (case when src.line_item in ('Days Open', '# of Tents/Rooms', 'Rooms Available', 'Rooms Sold', 'Occupancy %', 'Average Daily Rate', 'Revenue per Available Room', 'Operating CPORs', 'Non-Operating CPORs', 'Adjusted GOP %', 'Adjusted EBITDA Margin %') then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , coalesce(src.line_order in (23, 33, 40, 45, 50, 55, 70, 72, 73, 75, 88, 94, 98, 99, 105, 128, 133, 135), false) as c_subtotal
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_PL_SUMMARY'::varchar as source_table
        , nullif(trim(cln.entity_name), '')::varchar                            as source_site_code
        , cln.entity_name::varchar                                              as asset_name
        , nullif(trim(cln.source_section_label), '')::varchar                   as department
        , cln.source_section_label::varchar                                     as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(cln.line_item), '')::varchar                              as source_item_id
        , coalesce(nullif(trim(cln.line_item), ''), '~BLANK~')::varchar         as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , (case when cln.c_rtype = 'STATISTIC' then 'LINE_ITEM named statistic or ratio: STATISTIC (derived, M1)' else 'LINE_ITEM money line: AMOUNT (derived, M1)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_item::varchar                                                as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.actual_amount)::float        as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.actual_amount, null)::float        as stat_value
        , cln.c_subtotal::boolean                                               as is_subtotal
        , (case when cln.c_subtotal then 'total or chain line, ties to its members (M1 tie test)' else 'not a tested total' end)::varchar as subtotal_source
        , (coalesce(to_char(cln.line_order), '~BLANK~') || '|' || coalesce(cln.period_type, '~BLANK~'))::varchar as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_rtype, c_subtotal) rename (scenario as src_scenario)
    from cln
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_DUETTO_DATA' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_DUETTO_DATA','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "MARKET_SEGMENT_CATEGORY", "COLUMN10", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "STLY_DOW_ROOMS_COMMIT", "STLY_DOW_ROOM_REVENUE_COMMIT", "STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "FINAL_LY_DOW_ROOMS_COMMIT", "FINAL_LY_DOW_ROOM_REVENUE_COMMIT", "FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_DUETTO_DATA'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_DUETTO_DATA src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "MARKET_SEGMENT_CATEGORY", "COLUMN10", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "STLY_DOW_ROOMS_COMMIT", "STLY_DOW_ROOM_REVENUE_COMMIT", "STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "FINAL_LY_DOW_ROOMS_COMMIT", "FINAL_LY_DOW_ROOM_REVENUE_COMMIT", "FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY'::varchar                            as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY) src
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_OPS_STATS_MONTHLY',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'STATISTIC'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS: STATISTIC (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , null::float                                          as source_amount
        , cln.actual_amount::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_OPS_STATS_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_OPS_STATS_MONTHLY'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'STATISTIC'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS: STATISTIC (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , null::float                                          as source_amount
        , cln.actual_amount::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_TOTAL_REVENUE' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_TOTAL_REVENUE','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE',source_table), "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "FORMULA_LOGIC", "SOURCE_INTEGRATION", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "SAGE_INTACCT_BATCH_DATE", "SAGE_INTACCT_BATCH_NUMBER", "SAGE_INTACCT_BATCH_TITLE", "SAGE_INTACCT_CLASS_NAME", "SAGE_INTACCT_CLASS_NUMBER", "SAGE_INTACCT_CUSTOMER_NAME", "SAGE_INTACCT_CUSTOMER_NUMBER", "SAGE_INTACCT_DEPARTMENT_NAME", "SAGE_INTACCT_DEPARTMENT_NUMBER", "SAGE_INTACCT_DESCRIPTION", "SAGE_INTACCT_DOCUMENT", "SAGE_INTACCT_EMPLOYEE_NAME", "SAGE_INTACCT_EMPLOYEE_NUMBER", "SAGE_INTACCT_GL_ACCOUNT_NAME", "SAGE_INTACCT_GL_ACCOUNT_NUMBER", "SAGE_INTACCT_ITEM_NAME", "SAGE_INTACCT_ITEM_NUMBER", "SAGE_INTACCT_JOURNAL", "SAGE_INTACCT_JOURNAL_ENTRY_CREATED_BY", "SAGE_INTACCT_JOURNAL_ENTRY_TYPE", "SAGE_INTACCT_LOCATION_NAME", "SAGE_INTACCT_LOCATION_NUMBER", "SAGE_INTACCT_MEMO", "SAGE_INTACCT_PROJECT_NAME", "SAGE_INTACCT_PROJECT_NUMBER", "SAGE_INTACCT_VENDOR_NAME", "SAGE_INTACCT_VENDOR_NUMBER", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_TOTAL_REVENUE
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_TOTAL_REVENUE'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'AMOUNT'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_TOTAL_REVENUE: AMOUNT (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.actual_amount::float                                          as source_amount
        , null::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_SITE_CODE", "ASSET_NAME", "DEPARTMENT", "DEPARTMENT_NAME", "ACCOUNT_NUMBER", "STAT_ACCOUNT", "SOURCE_ITEM_ID", "ACCOUNT_KEY", "RECORD_TYPE", "RECORD_TYPE_SOURCE", "STAT_UNIT_FAMILY", "ACCOUNT_DESC", "PERIOD_END", "SCENARIO", "SOURCE_AMOUNT", "STAT_VALUE", "IS_SUBTOTAL", "SUBTOTAL_SOURCE", "SOURCE_LINE_KEY", "MEASURE_COLUMN", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SRC_SCENARIO", "PERIOD_LABEL", "PERIOD_DATE", "ACCOUNT", "SRC_DEPARTMENT", "LOCATION", "PROJECT", "CLASS_SEGMENT", "ITEM_SEGMENT", "FORMULA_LOGIC", "SOURCE_INTEGRATION", "SOURCE_TYPE", "LAST_MODIFIED_DATE", "SAGE_INTACCT_BATCH_DATE", "SAGE_INTACCT_BATCH_NUMBER", "SAGE_INTACCT_BATCH_TITLE", "SAGE_INTACCT_CLASS_NAME", "SAGE_INTACCT_CLASS_NUMBER", "SAGE_INTACCT_CUSTOMER_NAME", "SAGE_INTACCT_CUSTOMER_NUMBER", "SAGE_INTACCT_DEPARTMENT_NAME", "SAGE_INTACCT_DEPARTMENT_NUMBER", "SAGE_INTACCT_DESCRIPTION", "SAGE_INTACCT_DOCUMENT", "SAGE_INTACCT_EMPLOYEE_NAME", "SAGE_INTACCT_EMPLOYEE_NUMBER", "SAGE_INTACCT_GL_ACCOUNT_NAME", "SAGE_INTACCT_GL_ACCOUNT_NUMBER", "SAGE_INTACCT_ITEM_NAME", "SAGE_INTACCT_ITEM_NUMBER", "SAGE_INTACCT_JOURNAL", "SAGE_INTACCT_JOURNAL_ENTRY_CREATED_BY", "SAGE_INTACCT_JOURNAL_ENTRY_TYPE", "SAGE_INTACCT_LOCATION_NAME", "SAGE_INTACCT_LOCATION_NUMBER", "SAGE_INTACCT_MEMO", "SAGE_INTACCT_PROJECT_NAME", "SAGE_INTACCT_PROJECT_NUMBER", "SAGE_INTACCT_VENDOR_NAME", "SAGE_INTACCT_VENDOR_NUMBER", "ACTUAL_AMOUNT", "FORECAST_AMOUNT", "BUDGET_AMOUNT", "FILE_REPORT_DATE", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          'PROOF'::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'AMOUNT'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_TOTAL_REVENUE: AMOUNT (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.actual_amount::float                                          as source_amount
        , null::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1
)) n
union all
select 'STG_UNDER_CANVAS_WEEKLY_PACE' m, o.n o_rows, n.n n_rows, o.h o_hash, n.h n_hash from (select count(*) n, hash_agg("SOURCE_LANE", decode(source_table,'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_WEEKLY_PACE','CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY',source_table), "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "MARKET_SEGMENT", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOMS_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOMS_COMMIT", "ST2Y_DATE_ROOM_REVENUE_COMMIT", "ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_WEEKLY_PACE'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_WEEKLY_PACE src
    where 1=1
)) o, (select count(*) n, hash_agg("SOURCE_LANE", "SOURCE_TABLE", "SOURCE_FOLDER", "PORTFOLIO_NAME", "SNAPSHOT_DATE", "HOTEL_NAME", "STAY_MONTH", "MARKET_SEGMENT", "TODAY_ROOMS_COMMIT", "TODAY_ROOM_REVENUE_COMMIT", "TODAY_ROOMS_COMMIT_PICKUP_7_DAY", "TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOMS_COMMIT", "STLY_DATE_ROOM_REVENUE_COMMIT", "STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOMS_COMMIT", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT", "FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOMS_COMMIT", "ST2Y_DATE_ROOM_REVENUE_COMMIT", "ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY", "ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY", "FILE_DATE", "SOURCE_FILE_PATH", "SOURCE_ROW_NUMBER", "PROPERTY_NAME") h from (
    select
          'PROOF'::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY'::varchar                            as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY) src
    where 1=1
)) n
) order by m;
