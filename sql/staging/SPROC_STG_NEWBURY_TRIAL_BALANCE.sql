CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_NEWBURY_TRIAL_BALANCE(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_NEWBURY_TRIAL_BALANCE
-- Builds STAGING.STG_NEWBURY_TRIAL_BALANCE from
-- CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE. Fact table.
-- Identity form: wide, 3 columns unpivoted (ACTUAL_AMOUNT, FORECAST_AMOUNT,
-- BUDGET_AMOUNT), nulls kept: count(staged) = count(source) x 3 (Q-10).
-- The unpivot is a UNION ALL of one branch per measure column; no branch
-- filters, so every null cell is staged.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim on every branch; standard columns derived alongside.
-- Two raw names collide with standard columns and are carried renamed:
-- DEPARTMENT as SRC_DEPARTMENT, ACCOUNT_KEY as SRC_ACCOUNT_KEY.
-- RECORD_TYPE stated by VALUE_TYPE (Amount / STAT). On STATISTIC rows the
-- measure goes to STAT_VALUE and SOURCE_AMOUNT is null; STAT_UNIT_FAMILY is
-- the SUBACCOUNT text as stated.
-- Site = BUSINESS_UNIT as written (owner Q-11). Descriptions from the lane's
-- ACCOUNTS dictionary, unique on FULL_ACCOUNT_STRING and 1:1 with the keys.
-- SCENARIO (D-45, build 07 Q-04): FORECAST_VERSION verbatim on the forecast
-- branch where the source gives one, else the measure column name
-- (FORECAST_AMOUNT); ACTUAL_AMOUNT / BUDGET_AMOUNT on the other branches, which
-- name no scenario. MEASURE_COLUMN names the branch; category is set at M5.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE
    )
    -- ------------------------------------------------------------------------
    -- unpivot: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL_AMOUNT'::varchar   as measure_column, src.actual_amount   as measure_value, 'ACTUAL_AMOUNT'::varchar   as measure_scenario from src
        union all
        select src.*, 'FORECAST_AMOUNT'::varchar as measure_column, src.forecast_amount as measure_value, coalesce(nullif(src.forecast_version, ''), 'FORECAST_AMOUNT')::varchar as measure_scenario from src
        union all
        select src.*, 'BUDGET_AMOUNT'::varchar   as measure_column, src.budget_amount   as measure_value, 'BUDGET_AMOUNT'::varchar   as measure_scenario from src
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              unp.*
            , nullif(trim(unp.business_unit), '')                        as c_site
            , nullif(trim(unp.full_account_key), '')                     as c_acct
            , null::varchar                                              as c_stat
            , null::varchar                                              as c_item
            , nullif(split_part(trim(unp.full_account_key), '-', 1), '') as c_dept
            , upper(trim(unp.value_type))                                as c_vtype
        from unp
    )
    -- ------------------------------------------------------------------------
    -- account dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.account_description
            , a.department_description
        from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_ACCOUNTS a
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'NEWBURY'::varchar                                                    as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_TRIAL_BALANCE'::varchar   as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.property_name::varchar                                            as asset_name
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                  as department_name
        , cln.full_account_key::varchar                                         as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case cln.c_vtype
              when 'AMOUNT' then 'AMOUNT'
              when 'STAT'   then 'STATISTIC'
              else cln.c_vtype
          end::varchar                                                          as record_type
        , ('VALUE_TYPE ' || coalesce(cln.value_type, '~BLANK~') || ' (stated by the source, M1)')::varchar as record_type_source
        , iff(cln.c_vtype = 'STAT', cln.subaccount, null)::varchar              as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.measure_scenario::varchar                                         as scenario
        , iff(cln.c_vtype = 'STAT', null, cln.measure_value)::float             as source_amount
        , iff(cln.c_vtype = 'STAT', cln.measure_value, null)::float             as stat_value
        , coalesce(cln.node_type <> 'Leaf', false)::boolean                     as is_subtotal
        , ('NODE_TYPE ' || coalesce(cln.node_type, '~BLANK~') || ': subtotal unless Leaf (M1)')::varchar as subtotal_source
        , (coalesce(cln.full_account_key, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(cln.value_type, '~BLANK~')
            || '|' || cln.measure_column)::varchar                              as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (two renamed, see header)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.node_type
        , cln.department                as src_department
        , cln.account
        , cln.subaccount
        , cln.account_key               as src_account_key
        , cln.business_unit
        , cln.full_account_key
        , cln.value_type
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.forecast_version
        , cln.budget_amount
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_file_export_ts
        , cln.forecast_file_export_ts
        , cln.budget_file_export_ts
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
        , cln.budget_source_file_path
        , cln.budget_source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.full_account_key
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE);
    return 'STG_NEWBURY_TRIAL_BALANCE rows=' || v_rows;
end;
$$;
