CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_REFERENCES(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_REFERENCES
-- Builds STAGING.STG_HHG_REFERENCES from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS.
-- Dictionary: club code to GL entity (CLUB_NUMBER) and worksheet (Q-09).
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged).
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_REFERENCES as
    select
          :P_RUN_ID::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS'::varchar  as source_table
        , src.*
    from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS) src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_REFERENCES);
    return 'STG_HHG_REFERENCES rows=' || v_rows;
end;
$$;
