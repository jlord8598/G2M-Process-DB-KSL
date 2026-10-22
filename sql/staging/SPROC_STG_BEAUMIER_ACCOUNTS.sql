CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BEAUMIER_ACCOUNTS
-- Builds STAGING.STG_BEAUMIER_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS.
-- Dictionary: line item names.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- The source's own SOURCE_TABLE column is carried, renamed, as
-- ACCOUNTS_SOURCE_TABLE: the name is taken by the lineage column.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS as
    select
          :P_RUN_ID::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS);
    return 'STG_BEAUMIER_ACCOUNTS rows=' || v_rows;
end;
$$;
