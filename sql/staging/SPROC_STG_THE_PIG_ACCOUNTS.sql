CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_THE_PIG_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_THE_PIG_ACCOUNTS  (build 21)
-- Builds STAGING.STG_THE_PIG_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_REF_ACCOUNTS. Dictionary.
-- Identity form: long, count(source) = count(staged). Every source column
-- verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Unique on ENTITY_CODE +
-- FULL_ACCOUNT_STRING (1,044 / 1,044, build 21 M1). The source's own SOURCE_TABLE
-- column is carried verbatim as RAW_SOURCE_TABLE (as STG_DAVIDSON_ACCOUNTS).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_THE_PIG_ACCOUNTS as
    select
          :P_RUN_ID::varchar                                            as run_id
        , 'THE_PIG'::varchar                                            as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_REF_ACCOUNTS'::varchar as source_table
        , src.* rename (source_table as raw_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_REF_ACCOUNTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_THE_PIG_ACCOUNTS);
    return 'STG_THE_PIG_ACCOUNTS rows=' || v_rows;
end;
$$;
