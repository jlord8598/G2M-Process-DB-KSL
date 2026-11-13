CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_W_SHERATON_MALDIVES_BALANCE_SHEET(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_W_SHERATON_MALDIVES_BALANCE_SHEET  (build 22, new lane)
-- Builds STAGING.STG_W_SHERATON_MALDIVES_BALANCE_SHEET from
-- CLN.BOX_INVESTMENT_DATA.CLN_W_SHERATON_MALDIVES_FIN_BALANCE_SHEET (1BST5).
-- Fact table. Identity form: long, count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = HOTEL_CODE; DEPARTMENT = SECTION; ACCOUNT_NUMBER / ACCOUNT_KEY =
-- ACCOUNT_CODE; ACCOUNT_DESC = ACCOUNT_DESCRIPTION. RECORD_TYPE AMOUNT.
-- PERIOD_END = BALANCE_DATE; BALANCE_TYPE (CURRENT_PERIOD, PRIOR_PERIOD,
-- PRIOR_FULL_YEAR) carried raw. SCENARIO = 'ACTUAL_BALANCE', the measure column
-- name (D-45); MEASURE_COLUMN ACTUAL. Goes to SEM_AI_BALANCE_SHEET (owner Q-04).
-- SOURCE_SIGN_CONVENTION DEBIT (assets positive, liabilities negative, M1).
-- SOURCE_LINE_KEY: hotel | account | balance date | balance type (unique, M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_BALANCE_SHEET as
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'W_SHERATON_MALDIVES'::varchar                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_W_SHERATON_MALDIVES_FIN_BALANCE_SHEET'::varchar as source_table
        , nullif(trim(src.hotel_code), '')::varchar                             as source_site_code
        , src.hotel_name::varchar                                               as asset_name
        , nullif(trim(src.section), '')::varchar                                as department
        , null::varchar                                                         as department_name
        , src.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(src.account_code), ''), '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'balance sheet balance: AMOUNT (build 22 M1)'::varchar                as record_type_source
        , null::varchar                                                         as stat_unit_family
        , src.account_description::varchar                                      as account_desc
        , src.balance_date::date                                                as period_end
        , 'ACTUAL_BALANCE'::varchar                                             as scenario
        , src.actual_balance::float                                             as source_amount
        , null::float                                                           as stat_value
        , 'DEBIT'::varchar                                                      as source_sign_convention
        , 'debit-positive: assets positive, liabilities negative (build 22 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(src.hotel_code, '~BLANK~')
            || '|' || coalesce(src.account_code, '~BLANK~')
            || '|' || coalesce(to_char(src.balance_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(src.balance_type, '~BLANK~'))::varchar           as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.portfolio_name
        , src.hotel_code
        , src.hotel_name
        , src.section
        , src.account_code
        , src.account_description
        , src.balance_date
        , src.actual_balance
        , src.balance_type
        , src.report_period
        , src.line_order
        , src.file_date
        , src.source_file_path
    from CLN.BOX_INVESTMENT_DATA.CLN_W_SHERATON_MALDIVES_FIN_BALANCE_SHEET src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_BALANCE_SHEET);
    return 'STG_W_SHERATON_MALDIVES_BALANCE_SHEET rows=' || v_rows;
end;
$$;
