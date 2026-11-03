CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_DEPARTMENT_KEY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_DEPARTMENT_KEY
-- Builds STAGING.STG_HHG_DEPARTMENT_KEY from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_DEPARTMENT_KEY.
-- Dictionary: department code, name, account count. Lineage only.
-- Every source column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE.
-- Identity form: long. count(source) = count(staged). Added in build 10 (Q-01).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_DEPARTMENT_KEY as
    select
          :P_RUN_ID::varchar  as run_id
        , 'HHG'::varchar  as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_DEPARTMENT_KEY'::varchar  as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_DEPARTMENT_KEY src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_DEPARTMENT_KEY);
    return 'STG_HHG_DEPARTMENT_KEY rows=' || v_rows;
end;
$$;
