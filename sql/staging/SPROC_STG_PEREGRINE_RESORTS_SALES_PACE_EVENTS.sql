CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS
-- Builds STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS from
-- CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS. Pacing source,
-- empty at M1; staged empty. Kept in its own shape (D-24): every source
-- column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Never feeds
-- the seeder (D-37).
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS as
    select
          :P_RUN_ID::varchar                                                as run_id
        , 'PEREGRINE_RESORTS'::varchar                                      as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS'::varchar  as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS);
    return 'STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS rows=' || v_rows;
end;
$$;
