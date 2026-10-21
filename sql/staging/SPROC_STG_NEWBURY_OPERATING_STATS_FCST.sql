CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_NEWBURY_OPERATING_STATS_FCST(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_NEWBURY_OPERATING_STATS_FCST
-- Builds STAGING.STG_NEWBURY_OPERATING_STATS_FCST from
-- CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST.
-- Pacing source: forecast snapshots, as-of FILE_REPORT_DATE (owner Q-12).
-- Kept in its own shape (D-24): every source column verbatim, plus RUN_ID,
-- SOURCE_LANE and SOURCE_TABLE. Never feeds the seeder (D-37).
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST as
    select
          :P_RUN_ID::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST);
    return 'STG_NEWBURY_OPERATING_STATS_FCST rows=' || v_rows;
end;
$$;
