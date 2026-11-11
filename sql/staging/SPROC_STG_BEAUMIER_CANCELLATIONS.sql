CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_CANCELLATIONS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BEAUMIER_CANCELLATIONS
-- Builds STAGING.STG_BEAUMIER_CANCELLATIONS from
-- CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY.
-- Pacing source: cancellations and production by stay month, as-of BUSINESS_DATE; wide by prior year (N_1..N_5), not unpivoted.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Kept in its own shape (D-24). Never feeds the seeder (D-37).
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS as
    select
          :P_RUN_ID::varchar  as run_id
        , 'BEAUMIER'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS);
    return 'STG_BEAUMIER_CANCELLATIONS rows=' || v_rows;
end;
$$;
