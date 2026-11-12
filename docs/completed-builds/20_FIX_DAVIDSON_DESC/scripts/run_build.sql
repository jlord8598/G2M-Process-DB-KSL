execute immediate $$
-- ============================================================================
-- scripts/run_build.sql  (build 20: FIX_DAVIDSON_DESC; D-44 rebuild of DAVIDSON,
-- descriptions only)
-- Test harness, not part of the pipeline. Never deployed; parity never sees it.
-- DAVIDSON's STG, XREF and XFRM MAINs, then SPROC_SEM_AI_MAIN. Calls no other
-- lane's MAIN (D-42). Catches nothing: the first failure stops the block.
--     select $RUN_BUILD_STARTED, $RUN_BUILD_COMPLETED;
-- ============================================================================
declare
    v_r      varchar;
    v_log    varchar default '';
begin
    execute immediate 'set RUN_BUILD_COMPLETED = ''''';
    execute immediate 'set RUN_BUILD_STARTED = ''''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_DAVIDSON_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_DAVIDSON_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_DAVIDSON_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_SEM_AI_MAIN''';
    call DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''DONE''';
    return v_log;
end;
$$
