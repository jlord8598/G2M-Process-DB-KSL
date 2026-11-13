CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_CHART_OF_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_CHART_OF_ACCOUNTS  (build 21)
-- Builds STAGING.STG_DAVIDSON_CHART_OF_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_CHART_OF_ACCOUNTS: ledger account (segment 2) names.
-- Dictionary. Identity form: long, count(source) = count(staged). Every source
-- column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Unique on ACCOUNT_CODE (220 / 220, M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_CHART_OF_ACCOUNTS as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'DAVIDSON'::varchar                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_CHART_OF_ACCOUNTS'::varchar as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_CHART_OF_ACCOUNTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_CHART_OF_ACCOUNTS);
    return 'STG_DAVIDSON_CHART_OF_ACCOUNTS rows=' || v_rows;
end;
$$;
