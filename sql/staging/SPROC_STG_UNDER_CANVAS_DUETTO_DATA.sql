CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_UNDER_CANVAS_DUETTO_DATA(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_UNDER_CANVAS_DUETTO_DATA
-- Builds STAGING.STG_UNDER_CANVAS_DUETTO_DATA from
-- CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_DUETTO_DATA. Pacing source (D-24): kept in its own shape; as-of = SNAPSHOT_DATE.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_DUETTO_DATA as
    select
          :P_RUN_ID::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_DUETTO_DATA'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_DUETTO_DATA src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_DUETTO_DATA);
    return 'STG_UNDER_CANVAS_DUETTO_DATA rows=' || v_rows;
end;
$$;
