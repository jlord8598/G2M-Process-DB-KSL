CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_ALTERRA_PACE_BY_STAY_MONTH(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_ALTERRA_PACE_BY_STAY_MONTH
-- Builds STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH from
-- CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_BY_STAY_MONTH.
-- Pacing source: rooms and room revenue on the books by stay month, as-of
-- SNAPSHOT_DATE (5 snapshots, M1).
-- Kept in its own shape (D-24): every source column verbatim, plus RUN_ID,
-- SOURCE_LANE and SOURCE_TABLE. Never feeds the seeder (D-37).
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH as
    select
          :P_RUN_ID::varchar  as run_id
        , 'ALTERRA'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_BY_STAY_MONTH'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_BY_STAY_MONTH src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH);
    return 'STG_ALTERRA_PACE_BY_STAY_MONTH rows=' || v_rows;
end;
$$;
