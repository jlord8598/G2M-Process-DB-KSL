CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_NEWBURY_OTB_3DAY_PICKUP(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_NEWBURY_OTB_3DAY_PICKUP
-- Builds STAGING.STG_NEWBURY_OTB_3DAY_PICKUP from
-- CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP.
-- Pacing source: on-the-books pickup, as-of REPORT_DATE; shares 16,908 identical rows with OTB_1DAY_PICKUP, both kept (Q-16).
-- Kept in its own shape (D-24): every source column verbatim, plus RUN_ID,
-- SOURCE_LANE and SOURCE_TABLE. Never feeds the seeder (D-37).
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP as
    select
          :P_RUN_ID::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP);
    return 'STG_NEWBURY_OTB_3DAY_PICKUP rows=' || v_rows;
end;
$$;
