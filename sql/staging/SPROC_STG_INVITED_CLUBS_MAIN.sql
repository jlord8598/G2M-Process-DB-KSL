CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_INVITED_CLUBS_MAIN
-- Staging orchestrator for lane INVITED_CLUBS. Builds nothing itself.
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
    -- model calls: lane dictionaries (before the fact, which joins META_*)
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_META_ACCOUNT(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_META_DEPARTMENT(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_META_ENTITY(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_META_LOCATION(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_META_SUBACCOUNT(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_ACCOUNTS(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    -- ------------------------------------------------------------------------
    -- model calls: facts
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT(:v_run_id) into :v_r;
    v_log := v_log || '; ' || v_r;
    v_models := v_models + 1;

    return 'SPROC_STG_INVITED_CLUBS_MAIN ' || v_run_id || ' models=' || v_models || v_log;
end;
$$;
