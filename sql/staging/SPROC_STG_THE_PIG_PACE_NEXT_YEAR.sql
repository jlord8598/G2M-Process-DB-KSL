CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_THE_PIG_PACE_NEXT_YEAR(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_THE_PIG_PACE_NEXT_YEAR
-- Builds STAGING.STG_THE_PIG_PACE_NEXT_YEAR from
-- CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_NEXT_YEAR. Pacing source (D-24), pacing-only lane: kept in its own shape; as-of = SNAPSHOT_DATE.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_NEXT_YEAR as
    select
          :P_RUN_ID::varchar                                                  as run_id
        , 'THE_PIG'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_NEXT_YEAR'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_NEXT_YEAR src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_NEXT_YEAR);
    return 'STG_THE_PIG_PACE_NEXT_YEAR rows=' || v_rows;
end;
$$;
