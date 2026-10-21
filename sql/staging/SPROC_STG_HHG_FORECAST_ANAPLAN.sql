CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_FORECAST_ANAPLAN(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_FORECAST_ANAPLAN
-- Builds STAGING.STG_HHG_FORECAST_ANAPLAN from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN. Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim; standard columns derived alongside (docs/sources.md).
-- SCENARIO is carried once: the standard column is the raw value verbatim.
-- No account number: SOURCE_ITEM_ID = LINE_ITEM, so ACCOUNT_KEY is the line
-- item name (D-06). Site = LOCATION as written; no name matching (owner Q-03).
-- Every line item is money: RECORD_TYPE AMOUNT. Expenses book negative in
-- this source; carried as booked.
-- LOCATION '+All Regions' is the sum of the other 52 locations on all 360
-- cells (M1): IS_SUBTOTAL true there (Q-05).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN as
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
          :P_RUN_ID::varchar                                                    as run_id
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
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN);
    return 'STG_HHG_FORECAST_ANAPLAN rows=' || v_rows;
end;
$$;
