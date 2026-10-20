CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_KSL_SELECT_SERVICE_DATASETS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_KSL_SELECT_SERVICE_DATASETS
-- Builds STAGING.STG_KSL_SELECT_SERVICE_DATASETS from
-- CLN.CLEAN.CUR_PROFITSWORD_KSL_DATASETS. Dictionary: scenario name and
-- IS_ACTUALS per FCID, read by transformation for category derivation.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DATASETS as
    select
          :P_RUN_ID::varchar                                 as run_id
        , 'KSL_SELECT_SERVICE'::varchar                      as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_KSL_DATASETS'::varchar  as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_KSL_DATASETS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DATASETS);
    return 'STG_KSL_SELECT_SERVICE_DATASETS rows=' || v_rows;
end;
$$;
