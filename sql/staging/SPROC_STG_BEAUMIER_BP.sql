CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_BP(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BEAUMIER_BP
-- Builds STAGING.STG_BEAUMIER_BP from
-- CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_FORECAST_VERSIONS.
-- Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim;
-- SCENARIO is carried once, as the standard column (verbatim; owner Q-07).
-- No account number: SOURCE_ITEM_ID = LINE_ITEM (D-06). Site = HOTEL_CODE.
-- ASSET_NAME = STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE exactly, BMR
-- and CPH (CORPORATE) included; ASSET_NAME_SOURCE names the source and the
-- ENTITY_TYPE (build 07 Q-03). The map is unique on HOTEL_CODE (M1).
-- Every line item is money: AMOUNT. Expenses book negative; as booked.
-- The source names no total line: IS_SUBTOTAL false.
-- Build 15 (D-50): SOURCE_SIGN_CONVENTION PROFIT for every row, with its evidence
-- in SOURCE_SIGN_CONVENTION_SOURCE; applied in transformation.
-- Build 15 (Q-06, N-19): CURRENCY_CODE per hotel from STG_BEAUMIER_CANCELLATIONS
-- through LOCATION_MAP.HOTEL_NAME (9 EUR, HGB / HSB CHF); BMR and CPH, which
-- state none, UNCONFIRMED. CANCELLATIONS is staged first (BEAUMIER MAIN).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BEAUMIER_BP as
    select
          :P_RUN_ID::varchar                                                    as run_id
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
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP);
    return 'STG_BEAUMIER_BP rows=' || v_rows;
end;
$$;
