CREATE OR REPLACE PROCEDURE DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_SEM_AI_MAIN
-- Semantic orchestrator, shared by every lane. Builds nothing itself.
-- Stamps its own RUN_ID and passes it to the six semantic models.
-- Calls no other MAIN. Catches no exception.
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar;
    v_log    varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_INCOME_STATEMENT_ACTUAL(:v_run_id) into :v_r;
    v_models := v_models + 1;
    v_log := v_log || '; ' || v_r;

    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_INCOME_STATEMENT_BUDGET(:v_run_id) into :v_r;
    v_models := v_models + 1;
    v_log := v_log || '; ' || v_r;

    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_INCOME_STATEMENT_FORECAST(:v_run_id) into :v_r;
    v_models := v_models + 1;
    v_log := v_log || '; ' || v_r;

    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_BALANCE_SHEET(:v_run_id) into :v_r;
    v_models := v_models + 1;
    v_log := v_log || '; ' || v_r;

    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_OPERATING_METRICS(:v_run_id) into :v_r;
    v_models := v_models + 1;
    v_log := v_log || '; ' || v_r;

    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_UNKNOWN(:v_run_id) into :v_r;
    v_models := v_models + 1;
    v_log := v_log || '; ' || v_r;

    return 'SPROC_SEM_AI_MAIN ' || v_run_id || ' models=' || v_models || v_log;
end;
$$;
