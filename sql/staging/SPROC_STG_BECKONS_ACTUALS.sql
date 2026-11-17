CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BECKONS_ACTUALS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BECKONS_ACTUALS  (build 26, new lane)
-- Builds STAGING.STG_BECKONS_ACTUALS from CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS. Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = LODGE_CODE; where the source gives none, LOCATION_NAME as stated
--   (location UNKNOWN, a Tierra central entity on the 7-digit chart; owner
--   Q-10), named in SOURCE_SITE_CODE_SOURCE. ASSET_NAME = REPORTING_LOCATION_NAME.
-- DEPARTMENT = DEPARTMENT_TITLE. ACCOUNT_KEY = ACCOUNT_NO (no stat account, no
--   item id).
-- RECORD_TYPE: the three non-numeric accounts AROOM, NIGHT, OROOM (available
--   rooms, bed nights, occupied rooms) STATISTIC; else AMOUNT.
-- Measure (owner Q-02): the local base amount; SOURCE_AMOUNT for AMOUNT lines,
--   STAT_VALUE for STATISTIC lines (owner Q-04). CURRENCY_CODE = BASE_CURRENCY.
--   The AUD-converted figure is carried as a raw column only and is never a
--   measure.
-- SOURCE_SIGN_CONVENTION per table and entity (owner Q-03; D-50):
--   ACTUALS: PROFIT at every lodge; DEBIT at location UNKNOWN (reversed).
-- IS_SUBTOTAL false: no total, profit or EBITDA line in the source (build 26 M1;
--   the "- Total" iLevel buckets hold detail accounts).
-- SCENARIO = the table name without schema (D-45).
-- PERIOD_END = FINANCIAL_PERIOD (month end).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BECKONS_ACTUALS as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs and per-line rules
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , coalesce(nullif(trim(src.lodge_code), ''), nullif(trim(src.location_name), '')) as c_site
            , (nullif(trim(src.lodge_code), '') is null and nullif(trim(src.location_name), '') is not null) as c_site_from_name
            , nullif(trim(src.department_title), '')                     as c_dept
            , nullif(trim(src.account_no), '')                           as c_acct
            , coalesce(trim(src.account_no) in ('AROOM', 'NIGHT', 'OROOM'), false) as c_is_stat
        from src
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'BECKONS'::varchar                                                    as source_lane
        , 'CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , iff(cln.c_site_from_name, 'LOCATION_NAME (no LODGE_CODE; owner Q-10)', 'LODGE_CODE')::varchar as source_site_code_source
        , cln.reporting_location_name::varchar                                  as asset_name
        , cln.c_dept::varchar                                                   as department
        , cln.department_title::varchar                                         as department_name
        , cln.account_no::varchar                                               as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(cln.c_acct, '~BLANK~')::varchar                              as account_key
        , iff(cln.c_is_stat, 'STATISTIC', 'AMOUNT')::varchar                    as record_type
        , iff(cln.c_is_stat, 'ACCOUNT_NO AROOM / NIGHT / OROOM (rooms and bed-night counts): STATISTIC (build 26 M1)', 'numeric ACCOUNT_NO: AMOUNT (build 26 M1)')::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account_title::varchar                                            as account_desc
        , cln.financial_period::date                                            as period_end
        , 'CLN_BECKONS_INCOME_STATEMENT_ACTUALS'::varchar as scenario
        , iff(cln.c_is_stat, null, cln.transaction_amount_base)::float                      as source_amount
        , iff(cln.c_is_stat, cln.transaction_amount_base, null)::float                      as stat_value
        , cln.base_currency::varchar                                            as currency_code
        , (case
              when cln.c_site_from_name then 'DEBIT'
              else 'PROFIT'
          end)::varchar as source_sign_convention
        , (case
              when cln.c_site_from_name then 'location UNKNOWN (no LODGE_CODE) books revenue negative and costs positive, the reverse of every lodge (sign by section, build 26 M1; owner Q-03)'
              else 'revenue positive, costs negative at every lodge (sign by section, build 26 M1; D-50)'
          end)::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'no total, profit or EBITDA line in the source (build 26 M1)'::varchar as subtotal_source
        , (coalesce(cln.lodge_code, '~BLANK~')
            || '|' || coalesce(cln.location_name, '~BLANK~')
            || '|' || coalesce(to_char(cln.financial_period, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(cln.department_title, '~BLANK~')
            || '|' || coalesce(cln.account_no, '~BLANK~'))::varchar             as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.location_name
        , cln.reporting_location_name
        , cln.lodge_code
        , cln.financial_period
        , cln.department_title
        , cln.account_no
        , cln.account_title
        , cln.base_currency
        , cln.ilevelmapping1
        , cln.ilevelmapping2
        , cln.ilevelmapping3
        , cln.transaction_amount_aud
        , cln.transaction_amount_base
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BECKONS_ACTUALS);
    return 'STG_BECKONS_ACTUALS rows=' || v_rows;
end;
$$;
