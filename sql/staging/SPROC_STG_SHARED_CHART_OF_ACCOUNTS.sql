CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_SHARED_CHART_OF_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_SHARED_CHART_OF_ACCOUNTS
-- Builds STAGING.STG_SHARED_CHART_OF_ACCOUNTS from
-- CLN.CLEAN.CUR_PROFITSWORD_CHART_OF_ACCOUNTS.
-- Shared dictionary: serves KSL_SELECT_SERVICE and PEREGRINE_RESORTS, staged
-- once. Called by both lanes' staging MAINs; deterministic, so either call
-- rebuilds the same content.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation. Every source column is carried
-- verbatim. Cleaned columns are added alongside, never in place.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_SHARED_CHART_OF_ACCOUNTS as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.CLEAN.CUR_PROFITSWORD_CHART_OF_ACCOUNTS
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs (empty strings become null; raw kept alongside)
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.account_number), '') as c_account_number
            , nullif(trim(src.stat_account), '')   as c_stat_account
        from src
    )
    select
          :P_RUN_ID::varchar                                          as run_id
        , case cln.tenant
              when 'KSL'       then 'KSL_SELECT_SERVICE'
              when 'PEREGRINE' then 'PEREGRINE_RESORTS'
          end::varchar                                                as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_CHART_OF_ACCOUNTS'::varchar      as source_table
        , cln.c_account_number::varchar                               as account_number_clean
        , cln.c_stat_account::varchar                                 as stat_account_clean
        , split_part(cln.c_account_number, '-', 1)::varchar           as department_code
        , cln.tenant
        , cln.account_number
        , cln.stat_account
        , cln.account_kind
        , cln.description
        , cln.item_tag
        , cln.seg1
        , cln.seg2
        , cln.seg3
        , cln.statement
        , cln.pl_section
        , cln.department
        , cln.dept_group
        , cln.account_type
        , cln.first_period
        , cln.last_period
        , cln.cur_load_date
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_SHARED_CHART_OF_ACCOUNTS);
    return 'STG_SHARED_CHART_OF_ACCOUNTS rows=' || v_rows;
end;
$$;
