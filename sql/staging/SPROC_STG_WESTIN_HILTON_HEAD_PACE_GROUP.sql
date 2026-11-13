CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_WESTIN_HILTON_HEAD_PACE_GROUP(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_WESTIN_HILTON_HEAD_PACE_GROUP  (build 22, new lane)
-- Builds STAGING.STG_WESTIN_HILTON_HEAD_PACE_GROUP from CLN.BOX_INVESTMENT_DATA.CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY.
-- Pacing source (D-24): group pace, long (one METRIC per line), as-of
-- SNAPSHOT_DATE. The lane is pace-only this build (owner Q-02).
-- Identity form: long, count(source) = count(staged). Every source column
-- verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE (the source's own
-- SOURCE_TABLE column carried as RAW_SOURCE_TABLE where present).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_WESTIN_HILTON_HEAD_PACE_GROUP as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'WESTIN_HILTON_HEAD'::varchar                                         as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY'::varchar as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_WESTIN_HILTON_HEAD_PACE_GROUP);
    return 'STG_WESTIN_HILTON_HEAD_PACE_GROUP rows=' || v_rows;
end;
$$;
