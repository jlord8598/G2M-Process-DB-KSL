execute immediate $$
-- ============================================================================
-- scripts/run_build.sql  (build 18: labor as operating metrics, KSL_SELECT_SERVICE
-- and PEREGRINE_RESORTS; D-44 rebuild, labor only)
-- Test harness, not part of the pipeline. Never deployed; parity never sees it.
-- Owner Q-02 (build 18): only the two DAILY_LABOR staging models are restaged;
-- every other staging table of the two lanes stays as staged on 2026-11-04. So
-- this harness calls those two models directly with its own RUN_ID instead of
-- the lanes' STG MAINs (which would restage every table from the 11-11 reload).
-- Then the two lanes' XREF and XFRM MAINs, then SPROC_SEM_AI_MAIN. A promoted
-- environment runs the full MAINs. Calls no other lane's MAIN (D-42).
-- Catches nothing: the first failure stops the block.
--     select $RUN_BUILD_STARTED, $RUN_BUILD_COMPLETED;
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_r      varchar;
    v_log    varchar default '';
begin
    execute immediate 'set RUN_BUILD_COMPLETED = ''''';
    execute immediate 'set RUN_BUILD_STARTED = ''''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_KSL_SELECT_SERVICE_DAILY_LABOR''';
    call DEV_G2M_AI.STAGING.SPROC_STG_KSL_SELECT_SERVICE_DAILY_LABOR(:v_run_id) into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_PEREGRINE_RESORTS_DAILY_LABOR''';
    call DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_DAILY_LABOR(:v_run_id) into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_KSL_SELECT_SERVICE_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_KSL_SELECT_SERVICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_PEREGRINE_RESORTS_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_PEREGRINE_RESORTS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_KSL_SELECT_SERVICE_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_KSL_SELECT_SERVICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_PEREGRINE_RESORTS_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_PEREGRINE_RESORTS_MAIN() into :v_r;
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
