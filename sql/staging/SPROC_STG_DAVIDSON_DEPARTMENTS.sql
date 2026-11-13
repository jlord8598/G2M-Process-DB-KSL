CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_DEPARTMENTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_DEPARTMENTS  (build 21)
-- Builds STAGING.STG_DAVIDSON_DEPARTMENTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_DEPARTMENTS: department (segment 1) names.
-- Dictionary. Identity form: long, count(source) = count(staged). Every source
-- column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Unique on DEPARTMENT_CODE (66 / 66, M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_DEPARTMENTS as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'DAVIDSON'::varchar                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_DEPARTMENTS'::varchar as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_DEPARTMENTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_DEPARTMENTS);
    return 'STG_DAVIDSON_DEPARTMENTS rows=' || v_rows;
end;
$$;
