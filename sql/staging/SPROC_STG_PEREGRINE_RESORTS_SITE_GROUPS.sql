CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SITE_GROUPS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_SITE_GROUPS
-- Builds STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS from
-- CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS. Dictionary: region
-- membership. Empty at M1; staged empty. Every source column verbatim, plus
-- RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS as
    select
          :P_RUN_ID::varchar                                          as run_id
        , 'PEREGRINE_RESORTS'::varchar                                as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS'::varchar  as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS);
    return 'STG_PEREGRINE_RESORTS_SITE_GROUPS rows=' || v_rows;
end;
$$;
