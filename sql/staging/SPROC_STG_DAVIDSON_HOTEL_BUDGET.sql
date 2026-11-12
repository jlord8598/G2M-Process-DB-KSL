CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_HOTEL_BUDGET(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_HOTEL_BUDGET  (build 19, owner Q-11)
-- Builds STAGING.STG_DAVIDSON_HOTEL_BUDGET from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_BUDGET_MONTHLY (RAW_DAVIDSON_HOTEL_BUDGET:
-- the '<Hotel> BUD_<code>.csv' 2026 budgets of 11-06 / 11-07 and 2027 budgets of 11-11).
-- Fact table. Identity form: long, count(source) = count(staged); one measure,
-- BUDGET_AMOUNT (MEASURE_COLUMN 'BUDGET').
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Same account layout as CLN_DAVIDSON_FIN_PL_MONTHLY, so site, department,
-- natural account, ACCOUNT_KEY, RECORD_TYPE and the statistic rule are exactly
-- those of SPROC_STG_DAVIDSON_HOTEL_MONTHLY_REPORT (build 06 Q-05 to Q-07).
-- SCENARIO = 'BUDGET_AMOUNT', the measure column name (D-45); BUDGET_YEAR carried.
-- ACCOUNT_DESC from STG_DAVIDSON_ACCOUNTS rows of this source table.
-- SOURCE_LINE_KEY: file | row | period (owner Q-11; unique, 245,676 / 245,676 at M1;
-- hotel + account + month is not unique on the 720 uncoded Rooms / ADR lines).
-- Sign: as the monthly report (revenue and costs positive; PRESENTED, D-50).
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_BUDGET as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_BUDGET_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- one measure (long): BUDGET_AMOUNT
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'BUDGET'::varchar as measure_column, 'BUDGET_AMOUNT'::varchar as m_scenario, src.budget_amount as m_amount from src
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
          and a.raw_source_table = 'CLN_DAVIDSON_FIN_BUDGET_MONTHLY'
        group by a.entity_code, a.full_account_string
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'DAVIDSON'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_BUDGET_MONTHLY'::varchar as source_table
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
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
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
        , cln.file_code
        , cln.budget_amount
        , cln.budget_year
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join acct
        on  acct.entity_code         = cln.hotel_code
        and acct.full_account_string = coalesce(cln.account, cln.line_class)
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_BUDGET);
    return 'STG_DAVIDSON_HOTEL_BUDGET rows=' || v_rows;
end;
$$;
