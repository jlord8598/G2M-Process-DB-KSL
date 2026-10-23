CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_KSL_SELECT_SERVICE_DEPARTMENTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_KSL_SELECT_SERVICE_DEPARTMENTS
-- Builds STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS from
-- CLN.CLEAN.CUR_PROFITSWORD_DEPARTMENTS. Dictionary: department names per
-- (TENANT, SITE_TAG, DEPT_CODE), unique there (measured, M1).
-- The source holds both tenants; staged per lane (D-26), losslessly: every
-- row and every column verbatim, TENANT included, plus RUN_ID, SOURCE_LANE
-- and SOURCE_TABLE. The fact models select this lane's tenant at the join.
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'KSL_SELECT_SERVICE'::varchar                                        as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_DEPARTMENTS'::varchar      as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_DEPARTMENTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS);
    return 'STG_KSL_SELECT_SERVICE_DEPARTMENTS rows=' || v_rows;
end;
$$;
