CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_ACCOUNTS
-- Builds STAGING.STG_DAVIDSON_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNTS.
-- Dictionary: account strings per entity, derived by the source from both
-- DAVIDSON facts. Not unique on entity + string + source table (M1, Q-10):
-- staged as it is.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. The
-- source's own SOURCE_TABLE column (which fact a string came from) is carried
-- verbatim as RAW_SOURCE_TABLE, because SOURCE_TABLE is the standard column.
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNTS as
    select
          :P_RUN_ID::varchar  as run_id
        , 'DAVIDSON'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as raw_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNTS) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNTS);
    return 'STG_DAVIDSON_ACCOUNTS rows=' || v_rows;
end;
$$;
