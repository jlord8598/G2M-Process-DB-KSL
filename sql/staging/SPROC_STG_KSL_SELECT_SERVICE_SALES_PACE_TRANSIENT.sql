CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT
-- Builds STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT from
-- CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT. Pacing source.
-- Kept in its own shape (D-24): every source column verbatim, plus RUN_ID,
-- SOURCE_LANE and SOURCE_TABLE. Never feeds the seeder; ACCOUNT_CODE is a
-- CRM code, never mapped to ACCOUNT_NUMBER (D-37).
-- Identity form: long. count(source) = count(staged).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT as
    select
          :P_RUN_ID::varchar                                             as run_id
        , 'KSL_SELECT_SERVICE'::varchar                                  as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT'::varchar  as source_table
        , src.*
    from CLN.CLEAN.CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT);
    return 'STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT rows=' || v_rows;
end;
$$;
