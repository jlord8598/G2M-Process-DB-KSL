CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_ACCOUNT_MAPPING(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_ACCOUNT_MAPPING  (build 21)
-- Builds STAGING.STG_DAVIDSON_ACCOUNT_MAPPING from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNT_MAPPING: the ProfitSword account-string mapping. Replaces CLN_DAVIDSON_REF_ACCOUNT_LOOKUP
-- (identical content under renamed columns, DATA_ITEM dropped; build 21 M1,
-- owner Q-09), and with it SPROC_STG_DAVIDSON_ACCOUNT_LOOKUP, retired.
-- Dictionary. Identity form: long, count(source) = count(staged). Every source
-- column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Not unique on ACCOUNT_STRING (513 strings on more
-- than one line); the fact models choose one line per string.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'DAVIDSON'::varchar                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNT_MAPPING'::varchar as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNT_MAPPING src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING);
    return 'STG_DAVIDSON_ACCOUNT_MAPPING rows=' || v_rows;
end;
$$;
