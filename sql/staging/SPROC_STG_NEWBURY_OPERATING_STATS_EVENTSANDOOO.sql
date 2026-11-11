CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO
-- Builds STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO from
-- CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO.
-- Dictionary: event and out-of-order calendar by OCC_DATE (owner Q-12).
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO as
    select
          :P_RUN_ID::varchar  as run_id
        , 'NEWBURY'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO);
    return 'STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO rows=' || v_rows;
end;
$$;
