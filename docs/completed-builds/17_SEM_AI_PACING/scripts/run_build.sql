execute immediate $$
-- ============================================================================
-- scripts/run_build.sql  (build 17: SEM_AI_PACING)
-- Test harness, not part of the pipeline. Never deployed; parity never sees it.
-- Build 17 restages no lane and reads only DEV_G2M_AI.TRANSFORMATION, so the
-- only MAIN it calls is the shared SPROC_SEM_AI_MAIN (D-35). Catches nothing:
-- the first failure stops the block and its error propagates unchanged.
--     select $RUN_BUILD_STARTED, $RUN_BUILD_COMPLETED;
-- names the MAIN that was running when the block stopped.
-- ============================================================================
declare
    v_r   varchar;
    v_log varchar default '';
begin
    execute immediate 'set RUN_BUILD_COMPLETED = ''''';
    execute immediate 'set RUN_BUILD_STARTED = ''''';

    -- ------------------------------------------------------------------------
    -- SEMANTIC
    -- ------------------------------------------------------------------------
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_SEM_AI_MAIN''';
    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';
    execute immediate 'set RUN_BUILD_STARTED = ''DONE''';

    return v_log;
end;
$$
