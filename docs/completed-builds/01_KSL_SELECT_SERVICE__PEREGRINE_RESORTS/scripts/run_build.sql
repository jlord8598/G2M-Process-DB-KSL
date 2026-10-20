execute immediate $$
-- ============================================================================
-- scripts/run_build.sql
-- Test harness, not part of the pipeline. Never deployed; parity never sees it.
-- Calls every MAIN in sequence: STG, then XREF, then XFRM, then SEM.
-- Catches nothing, so the first failure stops the block and its error
-- propagates unchanged.
--
-- Progress is recorded in two session variables, set before and after each
-- MAIN, because nested CALLs are not logged in QUERY_HISTORY. They survive a
-- failure, so after a run:
--     select $RUN_BUILD_STARTED, $RUN_BUILD_COMPLETED;
-- names the MAIN that was running when the block stopped, and every MAIN that
-- completed before it.
-- ============================================================================
declare
    v_r   varchar;
    v_log varchar default '';
begin
    execute immediate 'set RUN_BUILD_COMPLETED = ''''';
    execute immediate 'set RUN_BUILD_STARTED = ''''';

    -- ------------------------------------------------------------------------
    -- STAGING
    -- ------------------------------------------------------------------------
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_KSL_SELECT_SERVICE_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_KSL_SELECT_SERVICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_PEREGRINE_RESORTS_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    -- ------------------------------------------------------------------------
    -- XREF_SNAPSHOT
    -- ------------------------------------------------------------------------
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_KSL_SELECT_SERVICE_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_KSL_SELECT_SERVICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_PEREGRINE_RESORTS_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_PEREGRINE_RESORTS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    -- ------------------------------------------------------------------------
    -- TRANSFORMATION
    -- ------------------------------------------------------------------------
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_KSL_SELECT_SERVICE_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_KSL_SELECT_SERVICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_PEREGRINE_RESORTS_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_PEREGRINE_RESORTS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    -- ------------------------------------------------------------------------
    -- SEMANTIC
    -- ------------------------------------------------------------------------
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_SEM_AI_MAIN''';
    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''DONE''';
    return v_log;
end;
$$
