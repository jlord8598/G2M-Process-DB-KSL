CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_UNDER_CANVAS_TOTAL_REVENUE(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_UNDER_CANVAS_TOTAL_REVENUE
-- Builds STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE from
-- CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE.
-- Fact table: revenue (Sage Intacct export, Under Canvas actuals file).
-- Identity form: long, one branch (ACTUAL_AMOUNT). FORECAST_AMOUNT and
-- BUDGET_AMOUNT are null on every row (M1): no branch; carried raw.
-- Key (owner, stop 1/2): SITE = leading code of LOCATION; DEPARTMENT = leading
-- code of DEPARTMENT, or the text where it has none; ACCOUNT_NUMBER = leading
-- code of ACCOUNT ('NNNN' or 'NNNN-NNN'; a structural split, the text is kept
-- in ACCOUNT_DESC); SOURCE_ITEM_ID = ACCOUNT; RECORD_TYPE AMOUNT (stated by
-- the table). IS_SUBTOTAL false: GL detail (M1).
-- SCENARIO: the source's SCENARIO, verbatim. Signs as booked.
-- SOURCE_LINE_KEY: SOURCE_ROW_NUMBER (unique in the table, M1).
-- Source columns DEPARTMENT and SCENARIO are carried as SRC_DEPARTMENT and
-- SRC_SCENARIO: the names are taken by standard columns.
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (structural code splits)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(regexp_substr(trim(src.location), '^[0-9]+'), nullif(trim(src.location), ''))     as c_site
            , nullif(trim(regexp_replace(trim(src.location), '^[0-9]+ - ', '')), '')                       as c_site_name
            , coalesce(regexp_substr(trim(src.department), '^[0-9]+'), nullif(trim(src.department), '')) as c_dept
            , nullif(trim(regexp_replace(trim(src.department), '^[0-9]+ - ', '')), '')                     as c_dept_name
            , regexp_substr(trim(src.account), '^[0-9]+(-[0-9]+)?')                                       as c_acct
            , nullif(trim(src.account), '')                                                                as c_item
        from src
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.c_site_name::varchar                                              as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.c_dept_name::varchar                                              as department_name
        , cln.c_acct::varchar                                                   as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_item, '~BLANK~')::varchar                  as account_key
        , 'AMOUNT'::varchar                                                  as record_type
        , 'table CLN_UNDER_CANVAS_TOTAL_REVENUE: AMOUNT (stated by the source table)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account::varchar                                                  as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario::varchar                                                 as scenario
        , cln.actual_amount::float                                          as source_amount
        , null::float                                          as stat_value
        , false::boolean                                                        as is_subtotal
        , 'GL detail: no subtotal rows (M1)'::varchar                           as subtotal_source
        , coalesce(to_char(cln.source_row_number), '~BLANK~')::varchar          as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_site, c_site_name, c_dept, c_dept_name, c_acct, c_item) rename (department as src_department, scenario as src_scenario)
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE);
    return 'STG_UNDER_CANVAS_TOTAL_REVENUE rows=' || v_rows;
end;
$$;
