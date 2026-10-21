CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_ROUNDS_DETAIL(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_ROUNDS_DETAIL
-- Builds STAGING.STG_HHG_ROUNDS_DETAIL from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL. Fact table,
-- statistics (owner Q-07).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim; standard columns derived alongside (docs/sources.md).
-- RECORD_TYPE STATISTIC: STAT_VALUE = ROUNDS_COUNT, SOURCE_AMOUNT null.
-- No account, stat account or line item: ACCOUNT_KEY '~BLANK~', one key per
-- club. Site = CLUB_CODE as written; ASSET_NAME from CLUB_LIST on the exact
-- code (all 50 clubs present, M1). The 3,650 zero rows dated after the load
-- are kept (owner Q-07).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL as
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
          :P_RUN_ID::varchar                                                    as run_id
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
        , null::varchar                                                         as scenario
        , null::float                                                           as source_amount
        , cln.rounds_count::float                                               as stat_value
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
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL);
    return 'STG_HHG_ROUNDS_DETAIL rows=' || v_rows;
end;
$$;
