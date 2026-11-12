CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_JW_VENICE_CAPEX(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_JW_VENICE_CAPEX  (build 19, owner Q-10)
-- Builds STAGING.STG_JW_VENICE_CAPEX from
-- CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_CAPEX (capital purchases by vendor
-- and month, 'AUG - PL.xlsm'). Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = PROPERTY_NAME, as every JW fact. No department.
-- ACCOUNT_KEY = VENDOR_NAME (owner Q-10), as SOURCE_ITEM_ID; ACCOUNT_DESC =
-- VENDOR_NAME. PURCHASE_DESCRIPTION, PURCHASE_DATE carried raw.
-- RECORD_TYPE AMOUNT (money); classified Statistic / FIN_CAPEX / CURRENCY /
-- FLOW in the seeder: capital spend never enters the P&L (owner Q-10).
-- SCENARIO = 'ACTUAL_AMOUNT', the measure column name (D-45); MEASURE_COLUMN ACTUAL.
-- SOURCE_LINE_KEY: file | row (unique, 200 / 200 at M3).
-- SOURCE_SIGN_CONVENTION PRESENTED: spend as stated (D-50).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_JW_VENICE_CAPEX as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_CAPEX)
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'JW_VENICE'::varchar                                                  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_CAPEX'::varchar            as source_table
        , nullif(trim(src.property_name), '')::varchar                          as source_site_code
        , src.property_name::varchar                                            as asset_name
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(src.vendor_name), '')::varchar                            as source_item_id
        , coalesce(nullif(trim(src.vendor_name), ''), '~BLANK~')::varchar       as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'capital purchase amount: AMOUNT (owner Q-10)'::varchar               as record_type_source
        , null::varchar                                                         as stat_unit_family
        , src.vendor_name::varchar                                              as account_desc
        , src.period_date::date                                                 as period_end
        , 'ACTUAL_AMOUNT'::varchar                                              as scenario
        , src.actual_amount::float                                              as source_amount
        , null::float                                                           as stat_value
        , 'PRESENTED'::varchar                                                  as source_sign_convention
        , 'capital spend as stated (build 19 M3, D-50)'::varchar                as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(src.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(src.source_row_number), '~BLANK~'))::varchar as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.property_name
        , src.vendor_name
        , src.period_date
        , src.purchase_date
        , src.purchase_description
        , src.col_3
        , src.actual_amount
        , src.file_report_month
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_JW_VENICE_CAPEX);
    return 'STG_JW_VENICE_CAPEX rows=' || v_rows;
end;
$$;
