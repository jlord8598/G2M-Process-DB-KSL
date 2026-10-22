CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HERSHA_ACCOUNTS
-- Builds STAGING.STG_HERSHA_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_ACCOUNTS.
-- Dictionary: account descriptions per department.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- The source's own SOURCE_TABLE column is carried, renamed, as
-- ACCOUNTS_SOURCE_TABLE: the name is taken by the lineage column.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HERSHA_ACCOUNTS as
    select
          :P_RUN_ID::varchar  as run_id
        , 'HERSHA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_ACCOUNTS'::varchar  as source_table
        , src.* rename (source_table as accounts_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_ACCOUNTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HERSHA_ACCOUNTS);
    return 'STG_HERSHA_ACCOUNTS rows=' || v_rows;
end;
$$;
