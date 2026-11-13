CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_LABOR_TYPES(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_LABOR_TYPES  (build 21)
-- Builds STAGING.STG_DAVIDSON_LABOR_TYPES from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_LABOR_TYPES: labor type (segment 6) names.
-- Dictionary. Identity form: long, count(source) = count(staged). Every source
-- column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Unique on LABOR_TYPE_CODE (293 / 293, M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_LABOR_TYPES as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'DAVIDSON'::varchar                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_LABOR_TYPES'::varchar as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_LABOR_TYPES src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_LABOR_TYPES);
    return 'STG_DAVIDSON_LABOR_TYPES rows=' || v_rows;
end;
$$;
