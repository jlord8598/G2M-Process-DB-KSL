CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_ATLANTIC_AVIATION_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_ATLANTIC_AVIATION_ACCOUNTS
-- Builds STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_REF_ACCOUNTS.
-- Dictionary: one row per entity x section x line item of the lane facts.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- The source's own SOURCE_TABLE column is carried, renamed, as
-- ACCOUNTS_SOURCE_TABLE: the name is taken by the lineage column.
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS as
    select
          :P_RUN_ID::varchar  as run_id
        , 'ATLANTIC_AVIATION'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_REF_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_REF_ACCOUNTS) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS);
    return 'STG_ATLANTIC_AVIATION_ACCOUNTS rows=' || v_rows;
end;
$$;
