CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_LOCATION_MAP(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BEAUMIER_LOCATION_MAP
-- Builds STAGING.STG_BEAUMIER_LOCATION_MAP from
-- CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP.
-- Dictionary: hotel code to hotel name and ENTITY_TYPE (HOTEL / CORPORATE),
-- unique on HOTEL_CODE (build 07 M1). New in build 07 (owner Q-03).
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP as
    select
          :P_RUN_ID::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP);
    return 'STG_BEAUMIER_LOCATION_MAP rows=' || v_rows;
end;
$$;
