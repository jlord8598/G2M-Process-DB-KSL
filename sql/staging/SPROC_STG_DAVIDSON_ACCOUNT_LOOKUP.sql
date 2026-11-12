CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_ACCOUNT_LOOKUP(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_ACCOUNT_LOOKUP  (build 20, N-49)
-- Builds STAGING.STG_DAVIDSON_ACCOUNT_LOOKUP from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNT_LOOKUP: the Davidson
-- ProfitSword account-string dictionary (cost center, ledger account, revenue
-- category, sales item, spend category, labor type names by code).
-- Dictionary. Identity form: long, count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair; every source column verbatim,
-- plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Not unique on
-- CONCATENATED_PROFITSWORD_STRING (513 strings on more than one line, the old
-- M3 codes, build 20 M1); the fact models choose one line per string.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_LOOKUP as
    select
          :P_RUN_ID::varchar                                                  as run_id
        , 'DAVIDSON'::varchar                                                 as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNT_LOOKUP'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNT_LOOKUP src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_LOOKUP);
    return 'STG_DAVIDSON_ACCOUNT_LOOKUP rows=' || v_rows;
end;
$$;
