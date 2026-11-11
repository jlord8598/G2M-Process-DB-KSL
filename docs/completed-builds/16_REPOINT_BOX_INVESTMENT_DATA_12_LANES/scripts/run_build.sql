execute immediate $$
-- ============================================================================
-- scripts/run_build.sql  (build 16: 12 CLN.BOX_INVESTMENT_DATA lanes repointed to the new table names)
-- Test harness, not part of the pipeline. Never deployed; parity never sees it.
-- Calls this build's MAINs in sequence: STG, then XREF, then XFRM, then the
-- shared SPROC_SEM_AI_MAIN. Calls no MAIN of a lane not in this build (D-42).
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
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_ALTERRA_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_ALTERRA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_ATLANTIC_AVIATION_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_ATLANTIC_AVIATION_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_BEAUMIER_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_DAVIDSON_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_HERSHA_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_HERSHA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_HHG_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_HHG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_INVITED_CLUBS_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_JW_VENICE_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_JW_VENICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_NEWBURY_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_NEWBURY_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_OUTRIGGER_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_OUTRIGGER_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_THE_PIG_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_THE_PIG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_STG_UNDER_CANVAS_MAIN''';
    call DEV_G2M_AI.STAGING.SPROC_STG_UNDER_CANVAS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';


    -- ------------------------------------------------------------------------
    -- XREF_SNAPSHOT
    -- ------------------------------------------------------------------------
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_ALTERRA_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_ALTERRA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_ATLANTIC_AVIATION_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_ATLANTIC_AVIATION_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_BEAUMIER_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_BEAUMIER_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_DAVIDSON_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_HERSHA_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_HERSHA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_HHG_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_HHG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_INVITED_CLUBS_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_INVITED_CLUBS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_JW_VENICE_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_JW_VENICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_NEWBURY_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_NEWBURY_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_OUTRIGGER_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_OUTRIGGER_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_THE_PIG_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_THE_PIG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XREF_UNDER_CANVAS_MAIN''';
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_UNDER_CANVAS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';


    -- ------------------------------------------------------------------------
    -- TRANSFORMATION
    -- ------------------------------------------------------------------------
    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_ALTERRA_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_ALTERRA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_ATLANTIC_AVIATION_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_ATLANTIC_AVIATION_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_BEAUMIER_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_BEAUMIER_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_DAVIDSON_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_DAVIDSON_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_HERSHA_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_HERSHA_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_HHG_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_HHG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_INVITED_CLUBS_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_INVITED_CLUBS_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_JW_VENICE_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_JW_VENICE_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_NEWBURY_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_NEWBURY_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_OUTRIGGER_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_OUTRIGGER_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_THE_PIG_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_THE_PIG_MAIN() into :v_r;
    v_log := v_log || v_r || '\n';
    execute immediate 'set RUN_BUILD_COMPLETED = ''' || replace(v_log, '\n', ' | ') || '''';

    execute immediate 'set RUN_BUILD_STARTED = ''SPROC_XFRM_UNDER_CANVAS_MAIN''';
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_UNDER_CANVAS_MAIN() into :v_r;
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
