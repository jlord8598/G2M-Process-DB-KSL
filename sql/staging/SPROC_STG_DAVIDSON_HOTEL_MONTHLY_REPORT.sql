CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_HOTEL_MONTHLY_REPORT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_HOTEL_MONTHLY_REPORT
-- Builds STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY. Fact table.
-- Identity form: wide by category, 2 branches (ACTUAL_*, FORECAST_*), nulls kept:
-- count(staged) = count(source) x 2.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = HOTEL_CODE; ASSET_NAME = HOTEL_NAME (fact). ACCOUNT is
-- DEPT-NATURAL-4 subsegments; department = segment 1 and NATURAL_ACCOUNT =
-- segment 2 only on a 6-segment ACCOUNT (structural; the 156 one-segment
-- x... strings and the ADR/Rooms lines get null). No department names.
-- ACCOUNT_KEY = ACCOUNT, else LINE_CLASS (SOURCE_ITEM_ID) on ADR/Rooms (Q-05).
-- RECORD_TYPE: LINE_CLASS ADR, Rooms STATISTIC (Q-06); natural account 9000-9990
-- STATISTIC, 9990 being stat-ledger offsets (owner Q-07); else AMOUNT. The
-- branch amount is SOURCE_AMOUNT on AMOUNT rows and STAT_VALUE on STATISTIC.
-- SCENARIO = the branch's measure column name (D-45). No subtotal signal.
-- ACCOUNT_DESC from STG_DAVIDSON_ACCOUNTS, MIN per entity + string + source
-- table (one value per string at M1).
-- SOURCE_LINE_KEY: hotel, class, account, period (unique at M1) plus branch.
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- Build 20 (N-49; owner Q-02 to Q-05): ACCOUNT_DESC precedence, existing first:
--   REF_ACCOUNTS description where non-blank; else the ProfitSword lookup line for
--   the exact ACCOUNT string (LOOKUP_EXACT); else, for a 6-segment ACCOUNT whose
--   every non-XXXXX segment has a name, the segment names (SEGMENT_BUILT); else
--   null. ACCOUNT_DESC_SOURCE says which. No key, amount or row changes.
-- Build 21 (N-49; owner Q-08, Q-09): the account mapping is
--   CLN_DAVIDSON_REF_ACCOUNT_MAPPING (STG_DAVIDSON_ACCOUNT_MAPPING; identical to
--   the retired REF_ACCOUNT_LOOKUP). SEGMENT_BUILT now covers every 6-segment
--   ACCOUNT the mapping lacks: each non-XXXXX segment named from its segment
--   table, else the mapping's name, else its raw code (e.g. PRET2). Only
--   non-six-segment strings stay null.
-- Build 21 (owner Q-11): precedence reordered: LOOKUP_EXACT (the mapping's text
--   for the exact ACCOUNT), then SEGMENT_BUILT, then REF_ACCOUNTS only where
--   neither applies (Rooms / ADR line classes and non-six-segment strings).
--   Reason: since the 2026-11-13 reload REF_ACCOUNTS carries only the ledger name
--   ("Other Expenses"), and the mapping is the fuller text of the same chart
--   ("5200:Other Expenses | Lounge | Dishwashing Supplies"). This supersedes the
--   build-20 "existing description first" order for these two tables.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT as
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
    -- ------------------------------------------------------------------------
    -- builds 20-21 (N-49): ProfitSword account mapping, one line per account
    -- string. Rule (owner Q-04): a retired line last - its account name saying
    -- RETIRED or DO NOT USE, or any name starting zDNU - then the first
    -- description alphabetically. Description (Q-05): ledger | cost center |
    -- revenue category | sales item | spend category | labor type, empty parts
    -- skipped. Exact matches keep the mapping's own names (build 21 Q-08).
    -- ------------------------------------------------------------------------
    , lkp as (
        select
              l.account_string as cps
            , array_to_string(array_construct_compact(l.ledger_account, l.department_name, l.revenue_category, l.sales_item, l.spend_category, l.labor_type), ' | ') as lkp_desc
        from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING l
        where 1=1
          and l.account_string is not null
        qualify row_number() over (
            partition by l.account_string
            order by iff(l.historic_account_name ilike '%RETIRED%' or l.historic_account_name ilike '%DO NOT USE%' or l.historic_account_name ilike 'zDNU%' or l.department_name ilike 'zDNU%' or l.ledger_account ilike 'zDNU%' or l.revenue_category ilike 'zDNU%' or l.sales_item ilike 'zDNU%' or l.spend_category ilike 'zDNU%' or l.labor_type ilike 'zDNU%', 1, 0), array_to_string(array_construct_compact(l.ledger_account, l.department_name, l.revenue_category, l.sales_item, l.spend_category, l.labor_type), ' | ')) = 1
    )
    -- ------------------------------------------------------------------------
    -- build 21 (owner Q-08): segment names, one per segment code. The segment
    -- table's name first (REF_DEPARTMENTS, REF_CHART_OF_ACCOUNTS,
    -- REF_REVENUE_CATEGORIES, REF_SALES_ITEMS, REF_SPEND_CATEGORIES,
    -- REF_LABOR_TYPES); else the mapping's name for the code, retired last, then
    -- alphabetical. A code with no name anywhere shows as its raw code.
    -- ------------------------------------------------------------------------
    , seg_dict as (
        select seg, code, seg_name
        from (
            select 1 as seg, r.department_code as code, r.department_name::varchar as seg_name, 0 as pri, 0 as retired from DEV_G2M_AI.STAGING.STG_DAVIDSON_DEPARTMENTS r where r.department_code is not null and r.department_name is not null
            union all
            select 2 as seg, r.account_code::varchar as code, r.ledger_account::varchar as seg_name, 0 as pri, 0 as retired from DEV_G2M_AI.STAGING.STG_DAVIDSON_CHART_OF_ACCOUNTS r where r.account_code::varchar is not null and r.ledger_account is not null
            union all
            select 3 as seg, r.revenue_category_code as code, r.revenue_category::varchar as seg_name, 0 as pri, 0 as retired from DEV_G2M_AI.STAGING.STG_DAVIDSON_REVENUE_CATEGORIES r where r.revenue_category_code is not null and r.revenue_category is not null
            union all
            select 4 as seg, r.sales_item_code as code, r.sales_item::varchar as seg_name, 0 as pri, 0 as retired from DEV_G2M_AI.STAGING.STG_DAVIDSON_SALES_ITEMS r where r.sales_item_code is not null and r.sales_item is not null
            union all
            select 5 as seg, r.spend_category_code as code, r.spend_category::varchar as seg_name, 0 as pri, 0 as retired from DEV_G2M_AI.STAGING.STG_DAVIDSON_SPEND_CATEGORIES r where r.spend_category_code is not null and r.spend_category is not null
            union all
            select 6 as seg, r.labor_type_code as code, r.labor_type::varchar as seg_name, 0 as pri, 0 as retired from DEV_G2M_AI.STAGING.STG_DAVIDSON_LABOR_TYPES r where r.labor_type_code is not null and r.labor_type is not null
            union all
            select 1, l.department_code, l.department_name::varchar, 1, iff(l.historic_account_name ilike '%RETIRED%' or l.historic_account_name ilike '%DO NOT USE%' or l.historic_account_name ilike 'zDNU%' or l.department_name ilike '%RETIRED%' or l.department_name ilike '%DO NOT USE%' or l.department_name ilike 'zDNU%', 1, 0) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING l where l.department_code is not null and l.department_name is not null
            union all
            select 2, l.account_code::varchar, l.ledger_account::varchar, 1, iff(l.historic_account_name ilike '%RETIRED%' or l.historic_account_name ilike '%DO NOT USE%' or l.historic_account_name ilike 'zDNU%' or l.ledger_account ilike '%RETIRED%' or l.ledger_account ilike '%DO NOT USE%' or l.ledger_account ilike 'zDNU%', 1, 0) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING l where l.account_code::varchar is not null and l.ledger_account is not null
            union all
            select 3, l.revenue_category_code, l.revenue_category::varchar, 1, iff(l.historic_account_name ilike '%RETIRED%' or l.historic_account_name ilike '%DO NOT USE%' or l.historic_account_name ilike 'zDNU%' or l.revenue_category ilike '%RETIRED%' or l.revenue_category ilike '%DO NOT USE%' or l.revenue_category ilike 'zDNU%', 1, 0) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING l where l.revenue_category_code is not null and l.revenue_category is not null
            union all
            select 4, l.sales_item_code, l.sales_item::varchar, 1, iff(l.historic_account_name ilike '%RETIRED%' or l.historic_account_name ilike '%DO NOT USE%' or l.historic_account_name ilike 'zDNU%' or l.sales_item ilike '%RETIRED%' or l.sales_item ilike '%DO NOT USE%' or l.sales_item ilike 'zDNU%', 1, 0) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING l where l.sales_item_code is not null and l.sales_item is not null
            union all
            select 5, l.spend_category_code, l.spend_category::varchar, 1, iff(l.historic_account_name ilike '%RETIRED%' or l.historic_account_name ilike '%DO NOT USE%' or l.historic_account_name ilike 'zDNU%' or l.spend_category ilike '%RETIRED%' or l.spend_category ilike '%DO NOT USE%' or l.spend_category ilike 'zDNU%', 1, 0) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING l where l.spend_category_code is not null and l.spend_category is not null
            union all
            select 6, l.labor_type_code, l.labor_type::varchar, 1, iff(l.historic_account_name ilike '%RETIRED%' or l.historic_account_name ilike '%DO NOT USE%' or l.historic_account_name ilike 'zDNU%' or l.labor_type ilike '%RETIRED%' or l.labor_type ilike '%DO NOT USE%' or l.labor_type ilike 'zDNU%', 1, 0) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING l where l.labor_type_code is not null and l.labor_type is not null
        ) d
        where 1=1
        qualify row_number() over (partition by seg, code order by pri, retired, seg_name) = 1
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
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
        , coalesce(lkp.lkp_desc, iff(regexp_count(cln.account, '-') = 5, nullif(array_to_string(array_construct_compact(coalesce(s2.seg_name, nullif(split_part(cln.account, '-', 2), 'XXXXX')), coalesce(s1.seg_name, nullif(split_part(cln.account, '-', 1), 'XXXXX')), coalesce(s3.seg_name, nullif(split_part(cln.account, '-', 3), 'XXXXX')), coalesce(s4.seg_name, nullif(split_part(cln.account, '-', 4), 'XXXXX')), coalesce(s5.seg_name, nullif(split_part(cln.account, '-', 5), 'XXXXX')), coalesce(s6.seg_name, nullif(split_part(cln.account, '-', 6), 'XXXXX'))), ' | '), ''), null), nullif(trim(acct.account_description), ''))::varchar as account_desc
        , case
              when lkp.lkp_desc is not null                              then 'LOOKUP_EXACT'
              when iff(regexp_count(cln.account, '-') = 5, nullif(array_to_string(array_construct_compact(coalesce(s2.seg_name, nullif(split_part(cln.account, '-', 2), 'XXXXX')), coalesce(s1.seg_name, nullif(split_part(cln.account, '-', 1), 'XXXXX')), coalesce(s3.seg_name, nullif(split_part(cln.account, '-', 3), 'XXXXX')), coalesce(s4.seg_name, nullif(split_part(cln.account, '-', 4), 'XXXXX')), coalesce(s5.seg_name, nullif(split_part(cln.account, '-', 5), 'XXXXX')), coalesce(s6.seg_name, nullif(split_part(cln.account, '-', 6), 'XXXXX'))), ' | '), ''), null) is not null then 'SEGMENT_BUILT'
              when nullif(trim(acct.account_description), '') is not null then 'REF_ACCOUNTS'
          end::varchar                                                          as account_desc_source
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
    left join lkp
        on  lkp.cps = cln.account
    left join seg_dict s1
        on  s1.seg = 1
        and s1.code = iff(regexp_count(cln.account, '-') = 5, nullif(split_part(cln.account, '-', 1), 'XXXXX'), null)
    left join seg_dict s2
        on  s2.seg = 2
        and s2.code = iff(regexp_count(cln.account, '-') = 5, nullif(split_part(cln.account, '-', 2), 'XXXXX'), null)
    left join seg_dict s3
        on  s3.seg = 3
        and s3.code = iff(regexp_count(cln.account, '-') = 5, nullif(split_part(cln.account, '-', 3), 'XXXXX'), null)
    left join seg_dict s4
        on  s4.seg = 4
        and s4.code = iff(regexp_count(cln.account, '-') = 5, nullif(split_part(cln.account, '-', 4), 'XXXXX'), null)
    left join seg_dict s5
        on  s5.seg = 5
        and s5.code = iff(regexp_count(cln.account, '-') = 5, nullif(split_part(cln.account, '-', 5), 'XXXXX'), null)
    left join seg_dict s6
        on  s6.seg = 6
        and s6.code = iff(regexp_count(cln.account, '-') = 5, nullif(split_part(cln.account, '-', 6), 'XXXXX'), null)
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT);
    return 'STG_DAVIDSON_HOTEL_MONTHLY_REPORT rows=' || v_rows;
end;
$$;
