CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_UNDER_CANVAS_CANCELLATIONS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_UNDER_CANVAS_CANCELLATIONS
-- Builds STAGING.STG_UNDER_CANVAS_CANCELLATIONS from
-- CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CANCELLATIONS. Pacing source (D-24): kept in its own shape; as-of = SNAPSHOT_DATE.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CANCELLATIONS as
    select
          :P_RUN_ID::varchar                                                  as run_id
        , 'UNDER_CANVAS'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CANCELLATIONS'::varchar                            as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CANCELLATIONS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CANCELLATIONS);
    return 'STG_UNDER_CANVAS_CANCELLATIONS rows=' || v_rows;
end;
$$;
