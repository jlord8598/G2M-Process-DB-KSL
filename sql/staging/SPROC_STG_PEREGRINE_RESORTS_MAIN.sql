CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_MAIN
-- Staging orchestrator for lane PEREGRINE_RESORTS. Builds nothing itself.
-- Stamps its own RUN_ID and passes it to every model it calls.
-- Calls no other MAIN. Catches no exception.
-- Build 04 rebuild (D-44): the shared chart call is retired (owner Q-06) and
-- the lane's own COA dictionary is staged (owner Q-01).
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar;
    v_log    varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls: lane dictionaries (first: the fact models read STG_PEREGRINE_RESORTS_SITES, owner Q-13)
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SALES_BOOKINGS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_DATASETS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SITES(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SITE_GROUPS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_ACCOUNT_CLASS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_COA(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    -- ------------------------------------------------------------------------
    -- model calls: facts
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_DAILY_EXTENDED(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_LEDGER_BATCHES(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_DAILY_LABOR(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    -- ------------------------------------------------------------------------
    -- model calls: pacing
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    return 'SPROC_STG_PEREGRINE_RESORTS_MAIN ' || v_run_id || ' models=' || v_models || v_log;
end;
$$;
