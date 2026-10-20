-- ============================================================================
-- CLN.UTIL.SPROC_RUN_PIPELINE
-- Runs this process's lanes in one promoted environment, in layer order:
--   1 STAGING        SPROC_STG_{LANE}_MAIN    for every lane
--   2 XREF_SNAPSHOT  SPROC_XREF_{LANE}_MAIN   for every lane
--   3 new keys -> master: snapshot keys not yet in
--     CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY are inserted; existing master
--     rows are never touched
--   4 TRANSFORMATION SPROC_XFRM_{LANE}_MAIN   for every lane
--   5 SEMANTIC.SPROC_SEM_AI_MAIN
--
-- Lanes come from the master (distinct SOURCE_LANE), the register of every
-- lane this process has promoted. MAIN names are built from those lanes, so
-- no other procedure in the environment is ever called. A lane with none of
-- its three MAINs in this environment is skipped (not promoted here yet) and
-- listed; a lane with only some of them is an error.
--
-- Nothing is caught: the first error stops the run, and the step that was
-- running is left in session variable RUN_PIPELINE_STEP:
--   select $RUN_PIPELINE_STEP;
--
-- Allowed: DEV1, DEV2, TEST, PROD. DEV_G2M_AI is the agent's build database:
-- it runs through scripts/run_build.sql and never writes the master (D-03).
--
-- Usage:
--   call CLN.UTIL.SPROC_RUN_PIPELINE('DEV1');
-- Runs with the caller's rights; the caller needs USAGE on the env's procs,
-- read on CLN.CLEAN, and SELECT/INSERT on the master.
-- ============================================================================
CREATE OR REPLACE PROCEDURE CLN.UTIL.SPROC_RUN_PIPELINE(P_DB VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
declare
    v_db          varchar default upper(trim(P_DB));
    v_plan_sql    varchar;
    v_sql         varchar;
    v_ret         varchar;
    v_lanes_run   integer default 0;
    v_mains       integer default 0;
    v_partial     integer default 0;
    v_sem         integer default 0;
    v_new_keys    integer default 0;
    v_skipped     varchar default '';
    v_log         varchar default '';
    v_master_done boolean default false;
    v_started     timestamp_ltz default current_timestamp();
    e_db      exception (-20101, 'SPROC_RUN_PIPELINE: database not allowed. Allowed: DEV1, DEV2, TEST, PROD.');
    e_partial exception (-20102, 'SPROC_RUN_PIPELINE: a lane has only some of its STG/XREF/XFRM MAINs in this environment. Run the plan query to see which.');
    e_none    exception (-20103, 'SPROC_RUN_PIPELINE: no lane registered in the master is promoted to this environment.');
    e_sem     exception (-20104, 'SPROC_RUN_PIPELINE: SEMANTIC.SPROC_SEM_AI_MAIN not found.');
begin
    if (v_db not in ('DEV1', 'DEV2', 'TEST', 'PROD')) then
        raise e_db;
    end if;

    -- ------------------------------------------------------------------------
    -- plan: the three MAINs of every registered lane, and whether each exists
    -- ------------------------------------------------------------------------
    v_plan_sql :=
           'with lanes as ( '
        || '  select distinct SOURCE_LANE as lane from CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY ) '
        || ', layers as ( '
        || '  select column1 as layer, column2 as schema_name, column3 as pfx '
        || '  from values (1, ''STAGING'', ''STG''), (2, ''XREF_SNAPSHOT'', ''XREF''), (4, ''TRANSFORMATION'', ''XFRM'') ) '
        || ', mains as ( '
        || '  select l.lane, y.layer, y.schema_name, ''SPROC_'' || y.pfx || ''_'' || l.lane || ''_MAIN'' as proc_name '
        || '  from lanes l cross join layers y ) '
        || ', found as ( '
        || '  select m.*, iff(p.procedure_name is null, 0, 1) as present '
        || '  from mains m '
        || '  left join ' || v_db || '.INFORMATION_SCHEMA.PROCEDURES p '
        || '    on p.procedure_schema = m.schema_name '
        || '   and p.procedure_name = m.proc_name '
        || '   and p.argument_signature = ''()'' ) '
        || 'select lane, layer, schema_name, proc_name, present '
        || '     , sum(present) over (partition by lane) as lane_present '
        || 'from found '
        || 'order by layer, lane';

    -- ------------------------------------------------------------------------
    -- validate the plan before running anything
    -- ------------------------------------------------------------------------
    let rs_chk resultset := (execute immediate :v_plan_sql);
    let c_chk cursor for rs_chk;
    for r in c_chk do
        if (r.lane_present between 1 and 2) then
            v_partial := v_partial + 1;
        end if;
        if (r.lane_present = 3 and r.layer = 1) then
            v_lanes_run := v_lanes_run + 1;
        end if;
        if (r.lane_present = 0 and r.layer = 1) then
            v_skipped := v_skipped || ' ' || r.lane;
        end if;
    end for;

    if (v_partial > 0) then
        raise e_partial;
    end if;
    if (v_lanes_run = 0) then
        raise e_none;
    end if;

    v_sql := 'select count(*) from ' || v_db || '.INFORMATION_SCHEMA.PROCEDURES '
          || 'where procedure_schema = ''SEMANTIC'' and procedure_name = ''SPROC_SEM_AI_MAIN'' '
          || 'and argument_signature = ''()''';
    execute immediate :v_sql;
    v_sem := (select $1 from table(result_scan(last_query_id())));
    if (v_sem <> 1) then
        raise e_sem;
    end if;

    -- ------------------------------------------------------------------------
    -- run: lanes present in full, layer by layer; new keys to the master
    -- between XREF and XFRM; semantic last
    -- ------------------------------------------------------------------------
    let rs_run resultset := (execute immediate :v_plan_sql);
    let c_run cursor for rs_run;
    for r in c_run do
        if (r.lane_present = 3) then
            if (r.layer = 4 and not v_master_done) then
                execute immediate 'set RUN_PIPELINE_STEP = ''NEW KEYS TO MASTER''';
                v_sql := 'insert into CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY ( '
                      || '  SOURCE_LANE, SOURCE_SITE_CODE, DEPARTMENT, ACCOUNT_KEY, RECORD_TYPE '
                      || ', ASSET_NAME, DEPARTMENT_NAME, ACCOUNT_NUMBER, STAT_ACCOUNT, ACCOUNT_DESC '
                      || ', H1, H2, H3, H4, H5, P_L_SECTION, NORMAL_BALANCE, VALUE_SIGN '
                      || ', METRIC_UNIT, AGGREGATION_TYPE, REVIEW_STATUS, SEED_SOURCE '
                      || ', FIRST_SEEN_RUN_ID, LAST_SEEN_RUN_ID, PROMOTED_FROM_RUN_ID, PROMOTED_AT, LAST_UPDATED_AT ) '
                      || 'select s.SOURCE_LANE, s.SOURCE_SITE_CODE, s.DEPARTMENT, s.ACCOUNT_KEY, s.RECORD_TYPE '
                      || ', s.ASSET_NAME, s.DEPARTMENT_NAME, s.ACCOUNT_NUMBER, s.STAT_ACCOUNT, s.ACCOUNT_DESC '
                      || ', s.H1, s.H2, s.H3, s.H4, s.H5, s.P_L_SECTION, s.NORMAL_BALANCE, s.VALUE_SIGN '
                      || ', s.METRIC_UNIT, s.AGGREGATION_TYPE, s.REVIEW_STATUS, s.SEED_SOURCE '
                      || ', s.FIRST_SEEN_RUN_ID, s.LAST_SEEN_RUN_ID, s.LAST_SEEN_RUN_ID, current_timestamp(), current_timestamp() '
                      || 'from ' || v_db || '.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION s '
                      || 'where not exists ( select 1 from CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY m '
                      || '  where m.SOURCE_LANE = s.SOURCE_LANE and m.SOURCE_SITE_CODE = s.SOURCE_SITE_CODE '
                      || '    and m.DEPARTMENT = s.DEPARTMENT and m.ACCOUNT_KEY = s.ACCOUNT_KEY '
                      || '    and m.RECORD_TYPE = s.RECORD_TYPE )';
                execute immediate :v_sql;
                v_new_keys := SQLROWCOUNT;
                v_log := v_log || '\n  NEW KEYS TO MASTER: ' || v_new_keys;
                v_master_done := true;
            end if;

            execute immediate 'set RUN_PIPELINE_STEP = ''' || r.schema_name || '.' || r.proc_name || '''';
            v_sql := 'call ' || v_db || '.' || r.schema_name || '.' || r.proc_name || '()';
            execute immediate :v_sql;
            v_ret := (select $1::varchar from table(result_scan(last_query_id())));
            v_mains := v_mains + 1;
            v_log := v_log || '\n  ' || r.schema_name || '.' || r.proc_name || ': ' || left(v_ret, 200);
        end if;
    end for;

    execute immediate 'set RUN_PIPELINE_STEP = ''SEMANTIC.SPROC_SEM_AI_MAIN''';
    v_sql := 'call ' || v_db || '.SEMANTIC.SPROC_SEM_AI_MAIN()';
    execute immediate :v_sql;
    v_ret := (select $1::varchar from table(result_scan(last_query_id())));
    v_mains := v_mains + 1;
    v_log := v_log || '\n  SEMANTIC.SPROC_SEM_AI_MAIN: ' || left(v_ret, 200);

    execute immediate 'set RUN_PIPELINE_STEP = ''COMPLETE''';
    return 'RUN_PIPELINE ' || v_db || ' COMPLETE: ' || v_lanes_run || ' lanes, '
        || v_mains || ' MAINs, ' || v_new_keys || ' new keys to master, '
        || datediff('second', v_started, current_timestamp()) || 's'
        || iff(v_skipped = '', '', '\n  skipped (not promoted here):' || v_skipped)
        || v_log;
end;
$$;
