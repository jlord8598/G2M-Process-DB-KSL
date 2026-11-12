CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_JW_VENICE_PACE_OTB_DAILY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_JW_VENICE_PACE_OTB_DAILY  (build 19)
-- Builds STAGING.STG_JW_VENICE_PACE_OTB_DAILY from
-- CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_PACE_OTB_DAILY. Pacing source (D-24): kept in its own shape; as-of = SNAPSHOT_DATE.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- Build 19 (owner, item 11): Owner Weekly on-the-books by stay date (OCCUPANCY and room counts).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_JW_VENICE_PACE_OTB_DAILY as
    select
          :P_RUN_ID::varchar                                                  as run_id
        , 'JW_VENICE'::varchar                                                         as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_PACE_OTB_DAILY'::varchar                            as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_PACE_OTB_DAILY) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_JW_VENICE_PACE_OTB_DAILY);
    return 'STG_JW_VENICE_PACE_OTB_DAILY rows=' || v_rows;
end;
$$;
