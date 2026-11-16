CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_BUDGET_USALI(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BEAUMIER_BUDGET_USALI
-- Builds STAGING.STG_BEAUMIER_BUDGET_USALI from
-- CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI.
-- Fact table. Build 23 (BEAUMIER rebuilt, D-44: 2027 budget add-on).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Shaped as STG_BEAUMIER_BUDGET so the key comes out the same way (D-44):
-- no account number, SOURCE_ITEM_ID = LINE_ITEM (D-06), site = HOTEL_CODE, no
-- department, RECORD_TYPE AMOUNT. All 113 line items match the existing
-- budget's line names (M1).
-- BUDGET_AMOUNT is already in units (= SOURCE_VALUE_THOUSANDS x 1000 on every
-- line, M1): no D-49 scale. SCENARIO: the budget year (BUDGET_YEAR) verbatim,
-- as owner Q-14 for the sister table; category BUDGET in transformation.
-- Sign (D-50): PROFIT, as the lane's existing budget. Currency (owner Q-11):
-- the lane's per-hotel currency from STG_BEAUMIER_CANCELLATIONS, as
-- STG_BEAUMIER_BUDGET; the table comment's "EUR for all" is a conflict (N-58).
-- The source names no total line: IS_SUBTOTAL false.
-- No overlap with the 2025-26 budget: no D-48 rule (M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET_USALI as
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'BEAUMIER'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI'::varchar as source_table
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
        , 'BUDGET_AMOUNT'::varchar                                              as source_measure
        , to_char(src.budget_year)::varchar                                     as scenario
        , 'BUDGET_YEAR (as owner Q-14)'::varchar                                as scenario_source
        , src.budget_amount::float                                              as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                     as source_sign_convention
        , 'profit-signed as the lane budget (D-50, build 15); signs match STG_BEAUMIER_BUDGET line names (build 23 M1)'::varchar as source_sign_convention_source
        , coalesce(cur.currency, 'UNCONFIRMED')::varchar                       as currency_code
        , case
              when cur.currency is not null
                  then 'STG_BEAUMIER_CANCELLATIONS.CURRENCY on LOCATION_MAP.HOTEL_NAME; one currency per hotel (N-19, build 23 Q-11, conflict N-58)'
              else 'no currency stated for this entity (build 15 Q-06)'
          end::varchar                                                          as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(src.source_file_path, '~BLANK~') || '|' || coalesce(to_char(src.source_row_number), '~BLANK~') || '|' || coalesce(to_char(src.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.portfolio_name
        , src.hotel_code
        , src.period_date
        , src.line_item
        , src.budget_amount
        , src.source_value_thousands
        , src.budget_year
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI src
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

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET_USALI);
    return 'STG_BEAUMIER_BUDGET_USALI rows=' || v_rows;
end;
$$;
