CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_META_ENTITY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_INVITED_CLUBS_META_ENTITY
-- Builds STAGING.STG_INVITED_CLUBS_META_ENTITY from
-- CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ENTITY.
-- Dictionary: Essbase entity.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY as
    select
          :P_RUN_ID::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ENTITY'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ENTITY) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY);
    return 'STG_INVITED_CLUBS_META_ENTITY rows=' || v_rows;
end;
$$;
