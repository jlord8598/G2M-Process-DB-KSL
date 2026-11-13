CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_WESTIN_HILTON_HEAD_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_WESTIN_HILTON_HEAD_MAIN
-- Staging orchestrator for lane WESTIN_HILTON_HEAD. Builds nothing itself.
-- Stamps its own RUN_ID and passes it to every model it calls.
-- Calls no other MAIN. Catches no exception.
-- Build 22 (new lane).
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar default '';
    v_log    varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls: dictionaries, facts, pacing
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_WESTIN_HILTON_HEAD_PACE_GROUP(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    return 'SPROC_STG_WESTIN_HILTON_HEAD_MAIN ' || v_run_id || ' models=' || v_models || v_log;
end;
$$;
