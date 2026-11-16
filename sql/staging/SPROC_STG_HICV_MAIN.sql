CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HICV_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HICV_MAIN
-- Staging orchestrator for lane HICV. Builds nothing itself.
-- Stamps its own RUN_ID and passes it to every model it calls.
-- Calls no other MAIN. Catches no exception.
-- Build 23 (new lane). M3: dictionaries, facts, pacing. The models read only
-- CLN, so their order carries no dependency.
-- CLN_HICV_OPS_PRIORITIES_WEEKLY is reference only and not staged (owner Q-10).
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar default '';
    v_log    varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls: lane dictionaries
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_HICV_ACCOUNTS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_HICV_ROOM_KEYS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    -- ------------------------------------------------------------------------
    -- model calls: facts
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_HICV_PL(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_HICV_GL(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    -- ------------------------------------------------------------------------
    -- model calls: pacing (owner Q-08)
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_HICV_KPI_WEEKLY(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_HICV_TREND_WEEKLY(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_HICV_RESERVATIONS_WEEKLY(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    return 'SPROC_STG_HICV_MAIN ' || v_run_id || ' models=' || v_models || v_log;
end;
$$;
