CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BECKONS_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BECKONS_MAIN
-- Staging orchestrator for lane BECKONS. Builds nothing itself.
-- Stamps its own RUN_ID and passes it to every model it calls.
-- Calls no other MAIN. Catches no exception.
-- Build 26 (new lane; source CLN.DATA_SHARE).
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar default '';
    v_log    varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls: facts (the lane has no dictionary or pacing source)
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_BECKONS_ACTUALS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_BECKONS_BUDGET(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    return 'SPROC_STG_BECKONS_MAIN ' || v_run_id || ' models=' || v_models || v_log;
end;
$$;
