CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_NEWBURY_OPERATING_STATS_BGT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_NEWBURY_OPERATING_STATS_BGT
-- Builds STAGING.STG_NEWBURY_OPERATING_STATS_BGT from
-- CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT. Fact table (owner Q-12).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim; standard columns derived alongside (docs/sources.md).
-- SCENARIO is carried once: the standard column is the raw value verbatim.
-- Each row carries money (REVENUE) and a statistic (ROOMS): RECORD_TYPE
-- AMOUNT, SOURCE_AMOUNT = REVENUE, STAT_VALUE = ROOMS, STAT_UNIT_FAMILY set
-- to the source's column name (D-29).
-- No account, stat account or line item: ACCOUNT_KEY '~BLANK~'.
-- Site = HOTEL_ID as written (owner Q-11).
-- SCENARIO verbatim.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT as
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
          :P_RUN_ID::varchar                                                    as run_id
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
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT);
    return 'STG_NEWBURY_OPERATING_STATS_BGT rows=' || v_rows;
end;
$$;
