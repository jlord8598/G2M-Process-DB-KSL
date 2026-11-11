CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_TR12_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_TR12_ACCOUNTS
-- Builds STAGING.STG_HHG_TR12_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING.
-- Dictionary: TR12 report layout (REPORT_SECTION, LINE_GROUP). Lineage only.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged). Added in build 10 (Q-01).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_TR12_ACCOUNTS as
    select
          :P_RUN_ID::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_TR12_ACCOUNTS);
    return 'STG_HHG_TR12_ACCOUNTS rows=' || v_rows;
end;
$$;
