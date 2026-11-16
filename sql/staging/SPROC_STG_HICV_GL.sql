CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HICV_GL(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HICV_GL
-- Builds STAGING.STG_HICV_GL from
-- CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_GL_MONTHLY.
-- Fact table. Build 23 (new lane HICV).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Key (owner Q-09): site = LOCATION_CODE, department = COST_CENTER_CODE,
-- account = ACCOUNT_CODE; ledger and LOB carried, not keyed. Every line is
-- money: RECORD_TYPE AMOUNT. ACTUAL only (ACTUAL_SOURCE CURRENT_YEAR, M1).
-- SCENARIO (D-45): the source names none; the table name, verbatim.
-- Precedence (owner Q-03, D-48): CLN_HICV_FIN_PL_MONTHLY wins every month; it
-- is applied in transformation, not here. Every GL line is staged.
-- PL_MAJOR_CATEGORY / PL_SUB_CATEGORY_1-3 are the source's own hierarchy,
-- carried verbatim for the seeder (owner Q-04).
-- SOURCE_LINES_COMBINED > 1 on some lines: the landing layer combined source
-- lines before this table; carried as booked.
-- Sign (D-50): PROFIT, as booked. Currency (owner Q-05): USD, assumed.
-- The source names no total line: IS_SUBTOTAL false.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HICV_GL as
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HICV'::varchar                                                       as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_GL_MONTHLY'::varchar            as source_table
        , nullif(trim(src.location_code), '')::varchar                          as source_site_code
        , nullif(trim(src.location_description), '')::varchar                   as asset_name
        , 'LOCATION_DESCRIPTION'::varchar                                       as asset_name_source
        , nullif(trim(src.cost_center_code), '')::varchar                       as department
        , nullif(trim(src.cost_center_description), '')::varchar                as department_name
        , nullif(trim(src.account_code), '')::varchar                           as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(src.account_code), ''), '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every line is money (M1)'::varchar                                   as record_type_source
        , null::varchar                                                         as stat_unit_family
        , src.account_description::varchar                                      as account_desc
        , src.period_date::date                                                 as period_end
        , 'ACTUAL_AMOUNT'::varchar                                              as source_measure
        , 'CLN_HICV_FIN_GL_MONTHLY'::varchar                                    as scenario
        , 'source table name (D-45)'::varchar                                   as scenario_source
        , src.actual_amount::float                                              as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                     as source_sign_convention
        , 'profit-signed: revenue sub-categories positive, expense negative (build 23 M1, Q-06)'::varchar as source_sign_convention_source
        , 'USD'::varchar                                                        as currency_code
        , 'owner assumption (build 23 Q-05); not in landed data'::varchar       as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no total line (build 23 M1)'::varchar                   as subtotal_source
        , (coalesce(src.ledger_code, '~BLANK~') || '|' || coalesce(src.lob_code, '~BLANK~') || '|' || coalesce(src.cost_center_code, '~BLANK~') || '|' || coalesce(src.location_code, '~BLANK~') || '|' || coalesce(src.account_code, '~BLANK~') || '|' || coalesce(src.line_id, '~BLANK~') || '|' || coalesce(to_char(src.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.portfolio_name
        , src.ledger_code
        , src.ledger_name
        , src.lob_code
        , src.lob_description
        , src.cost_center_code
        , src.cost_center_description
        , src.site_name
        , src.location_code
        , src.location_description
        , src.account_code
        , src.account_description
        , src.line_id
        , src.pl_major_category
        , src.pl_sub_category_1
        , src.pl_sub_category_2
        , src.pl_sub_category_3
        , src.period_date
        , src.actual_amount
        , src.actual_source
        , src.source_lines_combined
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_GL_MONTHLY src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HICV_GL);
    return 'STG_HICV_GL rows=' || v_rows;
end;
$$;
