CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SITES(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_SITES
-- Builds STAGING.STG_PEREGRINE_RESORTS_SITES from
-- CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITES. Dictionary: site name and
-- address. Every source column verbatim, plus RUN_ID, SOURCE_LANE and
-- SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'PEREGRINE_RESORTS'::varchar                          as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITES'::varchar  as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITES src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES);
    return 'STG_PEREGRINE_RESORTS_SITES rows=' || v_rows;
end;
$$;
