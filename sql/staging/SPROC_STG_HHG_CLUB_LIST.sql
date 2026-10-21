CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_CLUB_LIST(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_CLUB_LIST
-- Builds STAGING.STG_HHG_CLUB_LIST from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST.
-- Dictionary: club code, name, acquisition date, status by year.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_CLUB_LIST as
    select
          :P_RUN_ID::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_CLUB_LIST);
    return 'STG_HHG_CLUB_LIST rows=' || v_rows;
end;
$$;
