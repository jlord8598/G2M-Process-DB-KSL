CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_KSL_SELECT_SERVICE_COA(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_KSL_SELECT_SERVICE_COA
-- Builds STAGING.STG_KSL_SELECT_SERVICE_COA from
-- CLN.CLEAN.CUR_PROFITSWORD_KSL_COA. Dictionary: the lane's chart of
-- accounts as taken from the API (owner Q-01, build 04). Replaces the retired
-- STG_SHARED_CHART_OF_ACCOUNTS for this lane (owner Q-06).
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_COA as
    select
          :P_RUN_ID::varchar                                as run_id
        , 'KSL_SELECT_SERVICE'::varchar                                    as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_KSL_COA'::varchar      as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_KSL_COA src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_COA);
    return 'STG_KSL_SELECT_SERVICE_COA rows=' || v_rows;
end;
$$;
