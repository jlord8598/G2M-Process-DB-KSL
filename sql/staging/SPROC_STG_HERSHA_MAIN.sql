CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HERSHA_MAIN
-- Staging orchestrator for lane HERSHA. Builds nothing itself.
-- Stamps its own RUN_ID and passes it to every model it calls.
-- Calls no other MAIN. Catches no exception.
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar;
    v_log    varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls: facts
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_GL_ACTUAL(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_GL_STAT(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    -- ------------------------------------------------------------------------
    -- model calls: lane dictionaries
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_ACCOUNTS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    return 'SPROC_STG_HERSHA_MAIN ' || v_run_id || ' models=' || v_models || v_log;
end;
$$;
