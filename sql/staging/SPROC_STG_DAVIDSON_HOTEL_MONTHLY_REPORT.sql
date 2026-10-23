CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_HOTEL_MONTHLY_REPORT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_HOTEL_MONTHLY_REPORT
-- Builds STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT. Fact table.
-- Identity form: wide by category, 2 branches (ACTUAL_*, FORECAST_*), nulls kept:
-- count(staged) = count(source) x 2.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = HOTEL_CODE; ASSET_NAME = HOTEL_NAME (fact). ACCOUNT is
-- DEPT-NATURAL-4 subsegments; department = segment 1 and NATURAL_ACCOUNT =
-- segment 2 only on a 6-segment ACCOUNT (structural; the 156 one-segment
-- x... strings and the ADR/Rooms lines get null). No department names.
-- ACCOUNT_KEY = ACCOUNT, else LINE_CLASS (SOURCE_ITEM_ID) on ADR/Rooms (Q-05).
-- RECORD_TYPE from LINE_CLASS: ADR, Rooms STATISTIC; Item AMOUNT (Q-06). The
-- branch amount is SOURCE_AMOUNT on AMOUNT rows and STAT_VALUE on STATISTIC.
-- SCENARIO = the branch's measure column name (D-45). No subtotal signal.
-- ACCOUNT_DESC from STG_DAVIDSON_ACCOUNTS, MIN per entity + string + source
-- table (one value per string at M1).
-- SOURCE_LINE_KEY: hotel, class, account, period (unique at M1) plus branch.
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
    , cln as (
        select
              unp.*
            , nullif(trim(unp.hotel_code), '')                                   as c_site
            , nullif(trim(unp.account), '')                                      as c_acct
            , null::varchar                                                      as c_stat
            , nullif(trim(unp.line_class), '')                                   as c_item
            , iff(regexp_count(unp.account, '-') = 5, nullif(split_part(unp.account, '-', 1), ''), null) as c_dept
            , iff(regexp_count(unp.account, '-') = 5, nullif(split_part(unp.account, '-', 2), ''), null) as c_natural
            , upper(trim(unp.line_class)) in ('ADR', 'ROOMS')                    as c_is_stat
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
          and a.raw_source_table = 'CLN_DAVIDSON_HOTEL_MONTHLY_REPORT'
        group by a.entity_code, a.full_account_string
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
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
              when cln.c_is_stat
                  then 'LINE_CLASS ' || cln.line_class || ': STATISTIC (stated by the source class; Q-06)'
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
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT);
    return 'STG_DAVIDSON_HOTEL_MONTHLY_REPORT rows=' || v_rows;
end;
$$;
