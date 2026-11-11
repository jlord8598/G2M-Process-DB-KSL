CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_HIERARCHY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BEAUMIER_HIERARCHY
-- Builds STAGING.STG_BEAUMIER_HIERARCHY from
-- CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_HIERARCHY_PL_LINE.
-- Dictionary: the P&L line hierarchy (LINE_ITEM with LEVEL_0-4, PL_GROUP,
-- LINE_TYPE, INDEX_*). New in build 15 (owner, stop 1): evidence for the D-50
-- sign rule (GOP = Total Departmental Profit - Undistributed). Read by nothing
-- downstream yet.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BEAUMIER_HIERARCHY as
    select
          :P_RUN_ID::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_HIERARCHY_PL_LINE'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_HIERARCHY_PL_LINE) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BEAUMIER_HIERARCHY);
    return 'STG_BEAUMIER_HIERARCHY rows=' || v_rows;
end;
$$;
