CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_META_LOCATION(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_INVITED_CLUBS_META_LOCATION
-- Builds STAGING.STG_INVITED_CLUBS_META_LOCATION from
-- CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_LOCATION.
-- Dictionary: Essbase location.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_LOCATION as
    select
          :P_RUN_ID::varchar  as run_id
        , 'INVITED_CLUBS'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_LOCATION'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_LOCATION src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_LOCATION);
    return 'STG_INVITED_CLUBS_META_LOCATION rows=' || v_rows;
end;
$$;
