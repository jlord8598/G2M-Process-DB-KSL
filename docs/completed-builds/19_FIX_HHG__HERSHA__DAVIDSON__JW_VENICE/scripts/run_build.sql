execute immediate $$
-- ============================================================================
-- scripts/run_build.sql  (build 19: fix / extension HHG, HERSHA, DAVIDSON,
-- JW_VENICE; D-44 rebuild of the four lanes on the 2026-11-12 03:03 extract)
-- Test harness, not part of the pipeline. Never deployed; parity never sees it.
-- The four lanes' STG, XREF and XFRM MAINs, then SPROC_SEM_AI_MAIN. Calls no
-- other lane's MAIN (D-42). Catches nothing: the first failure stops the block.
--     select $RUN_BUILD_STARTED, $RUN_BUILD_COMPLETED;
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_r      varchar;
    v_log    varchar default '';
begin
    execute immediate 'set RUN_BUILD_COMPLETED = ''''';
    execute immediate 'set RUN_BUILD_STARTED = ''''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_HHG_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_HHG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_HERSHA_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_DAVIDSON_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_JW_VENICE_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_JW_VENICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_HHG_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_HHG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_HERSHA_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_HERSHA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_DAVIDSON_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_JW_VENICE_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_JW_VENICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_HHG_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_HHG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_HERSHA_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_HERSHA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_DAVIDSON_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(replace(v_log, '\n', ' | '), '''', '') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_JW_VENICE_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_JW_VENICE_MAIN() into :v_r;
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
