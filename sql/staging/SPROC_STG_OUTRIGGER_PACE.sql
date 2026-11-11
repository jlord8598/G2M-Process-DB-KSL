CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_OUTRIGGER_PACE(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_OUTRIGGER_PACE
-- Builds STAGING.STG_OUTRIGGER_PACE from
-- CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY. Pacing source (D-24), pacing-only lane: kept in its own shape; as-of = SNAPSHOT_DATE. V1 and V2 export layouts carried as is (owner Q-06).
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- The source column SOURCE_TABLE is carried as EXPORT_LAYOUT: the name is taken by the lineage column.
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME / PROPERTY_GROUP) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_OUTRIGGER_PACE as
    select
          :P_RUN_ID::varchar                                                  as run_id
        , 'OUTRIGGER'::varchar                                                      as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY'::varchar                            as source_table
        , src.* rename (source_table as export_layout)
    from (select *, portfolio_name as property_group from CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_OUTRIGGER_PACE);
    return 'STG_OUTRIGGER_PACE rows=' || v_rows;
end;
$$;
