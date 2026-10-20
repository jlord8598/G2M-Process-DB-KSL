CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SALES_BOOKINGS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_SALES_BOOKINGS
-- Builds STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS from
-- CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS. Pacing-side dictionary
-- (owner Q-07): every source column verbatim, plus RUN_ID, SOURCE_LANE and
-- SOURCE_TABLE. Never feeds the seeder (D-37). Duplicate BOOKING_IDs kept.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS as
    select
          :P_RUN_ID::varchar                                             as run_id
        , 'PEREGRINE_RESORTS'::varchar                                   as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS'::varchar  as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS);
    return 'STG_PEREGRINE_RESORTS_SALES_BOOKINGS rows=' || v_rows;
end;
$$;
