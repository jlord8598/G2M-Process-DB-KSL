-- ============================================================================
-- CLN.UTIL.SPROC_PROMOTE
-- Promotes the pipeline procedures from one environment database to the next.
-- Code only: tables are rebuilt in the target by running its MAINs.
--
-- Allowed paths (anything else is refused):
--   DEV_G2M_AI -> DEV1     DEV_G2M_AI -> DEV2     DEV1 -> TEST     TEST -> PROD
--
-- What it copies, found live in <FROM>.INFORMATION_SCHEMA (no fixed counts):
--   STAGING         SPROC_STG_*
--   XREF_SNAPSHOT   SPROC_XREF_*
--   TRANSFORMATION  SPROC_XFRM_*
--   SEMANTIC        SPROC_SEM_AI_*   (other semantic objects are never touched)
--
-- What it rewrites in each body:
--   - every qualified '<FROM>.' reference becomes '<TO>.'
--   - from DEV_G2M_AI only: each SPROC_XFRM_{LANE} classification CTE is
--     pointed at CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY. Every lane proc must
--     swap exactly once. From any other source the procs must already read
--     the master, so a build-table reference there is an error.
--
-- Usage (FROM and TO are required; the result echoes both):
--   call CLN.UTIL.SPROC_PROMOTE('DEV_G2M_AI', 'DEV1', true);   -- dry run
--   call CLN.UTIL.SPROC_PROMOTE('DEV_G2M_AI', 'DEV1', false);  -- promote
--
-- Runs with the caller's rights: promoted procedures are owned by the role
-- that calls it. Use the role that should own them in the target.
-- ============================================================================
CREATE OR REPLACE PROCEDURE CLN.UTIL.SPROC_PROMOTE(P_FROM_DB VARCHAR, P_TO_DB VARCHAR, P_DRY_RUN BOOLEAN)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
declare
    v_from      varchar default upper(trim(P_FROM_DB));
    v_to        varchar default upper(trim(P_TO_DB));
    v_filter    varchar;
    v_sql       varchar;
    v_sig       varchar;
    v_ddl       varchar;
    v_total     integer default 0;
    v_done      integer default 0;
    v_lane_xfrm integer default 0;
    v_swaps     integer default 0;
    v_after     integer default 0;
    v_log       varchar default '';
    e_path   exception (-20001, 'SPROC_PROMOTE: path not allowed. Allowed: DEV_G2M_AI->DEV1, DEV_G2M_AI->DEV2, DEV1->TEST, TEST->PROD.');
    e_empty  exception (-20002, 'SPROC_PROMOTE: no pipeline procedures found in the source database.');
    e_left   exception (-20003, 'SPROC_PROMOTE: a source-database reference survived the rewrite.');
    e_swap   exception (-20004, 'SPROC_PROMOTE: classification CTE swap count does not match the transformation lane procedures.');
    e_xref   exception (-20005, 'SPROC_PROMOTE: a transformation procedure outside DEV_G2M_AI still reads a build classification table.');
    e_verify exception (-20006, 'SPROC_PROMOTE: target does not hold every promoted procedure after the run.');
begin
    -- ------------------------------------------------------------------------
    -- allowed paths only; this also keeps the names safe for dynamic SQL
    -- ------------------------------------------------------------------------
    if (not ((v_from = 'DEV_G2M_AI' and v_to in ('DEV1', 'DEV2'))
          or (v_from = 'DEV1'       and v_to = 'TEST')
          or (v_from = 'TEST'       and v_to = 'PROD'))) then
        raise e_path;
    end if;

    v_filter := ' where (procedure_schema = ''STAGING''        and startswith(procedure_name, ''SPROC_STG_''))'
             || '    or (procedure_schema = ''XREF_SNAPSHOT''  and startswith(procedure_name, ''SPROC_XREF_''))'
             || '    or (procedure_schema = ''TRANSFORMATION'' and startswith(procedure_name, ''SPROC_XFRM_''))'
             || '    or (procedure_schema = ''SEMANTIC''       and startswith(procedure_name, ''SPROC_SEM_AI_''))';

    -- ------------------------------------------------------------------------
    -- source inventory, live
    -- ------------------------------------------------------------------------
    v_sql := 'select procedure_schema, procedure_name, argument_signature from '
          || v_from || '.INFORMATION_SCHEMA.PROCEDURES' || v_filter
          || ' order by procedure_schema, procedure_name';
    let rs resultset := (execute immediate :v_sql);
    let c_procs cursor for rs;

    -- ------------------------------------------------------------------------
    -- target schemas
    -- ------------------------------------------------------------------------
    if (not P_DRY_RUN) then
        execute immediate 'create schema if not exists ' || v_to || '.STAGING';
        execute immediate 'create schema if not exists ' || v_to || '.XREF_SNAPSHOT';
        execute immediate 'create schema if not exists ' || v_to || '.TRANSFORMATION';
        execute immediate 'create schema if not exists ' || v_to || '.SEMANTIC';
    end if;

    -- ------------------------------------------------------------------------
    -- copy each procedure
    -- ------------------------------------------------------------------------
    for r in c_procs do
        v_total := v_total + 1;

        -- '(P_RUN_ID VARCHAR, P_LANE VARCHAR)' -> '(VARCHAR, VARCHAR)'
        v_sig := v_from || '.' || r.procedure_schema || '.' || r.procedure_name
              || regexp_replace(r.argument_signature, '[A-Za-z0-9_]+ ([A-Za-z0-9_]+)', '\\1');
        v_ddl := (select get_ddl('procedure', :v_sig, true));

        -- classification CTE (transformation lane procedures only)
        if (r.procedure_schema = 'TRANSFORMATION' and not endswith(r.procedure_name, '_MAIN')) then
            v_lane_xfrm := v_lane_xfrm + 1;
            if (regexp_count(v_ddl, '"?' || v_from || '"?\\.XREF_SNAPSHOT\\.XREF_ACCOUNT_CLASSIFICATION', 1, 'i') > 0) then
                if (v_from <> 'DEV_G2M_AI') then
                    raise e_xref;
                end if;
                v_swaps := v_swaps + 1;
                v_ddl := regexp_replace(v_ddl,
                             '"?' || v_from || '"?\\.XREF_SNAPSHOT\\.XREF_ACCOUNT_CLASSIFICATION',
                             'CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY', 1, 0, 'i');
            end if;
        end if;

        -- every other qualified reference to the source database
        v_ddl := regexp_replace(v_ddl, '(^|[^A-Za-z0-9_])"?' || v_from || '"?\\.', '\\1' || v_to || '.', 1, 0, 'i');
        if (regexp_count(v_ddl, '(^|[^A-Za-z0-9_])"?' || v_from || '"?\\.', 1, 'i') > 0) then
            raise e_left;
        end if;

        if (not P_DRY_RUN) then
            execute immediate :v_ddl;
        end if;

        v_done := v_done + 1;
        v_log  := v_log || '\n  ' || r.procedure_schema || '.' || r.procedure_name;
    end for;

    if (v_total = 0) then
        raise e_empty;
    end if;
    if (v_from = 'DEV_G2M_AI' and v_swaps <> v_lane_xfrm) then
        raise e_swap;
    end if;

    -- ------------------------------------------------------------------------
    -- verify the target holds every promoted procedure
    -- ------------------------------------------------------------------------
    if (not P_DRY_RUN) then
        v_sql := 'select count(*) from ' || v_to || '.INFORMATION_SCHEMA.PROCEDURES t'
              || ' join ' || v_from || '.INFORMATION_SCHEMA.PROCEDURES s'
              || '   on s.procedure_schema = t.procedure_schema'
              || '  and s.procedure_name = t.procedure_name'
              || '  and s.argument_signature = t.argument_signature'
              || replace(v_filter, 'procedure_', 's.procedure_');
        let rc resultset := (execute immediate :v_sql);
        let c_cnt cursor for rc;
        open c_cnt;
        fetch c_cnt into v_after;
        close c_cnt;
        if (v_after <> v_total) then
            raise e_verify;
        end if;
    end if;

    return iff(P_DRY_RUN, 'DRY RUN', 'PROMOTED')
        || ' FROM ' || v_from || ' TO ' || v_to
        || ': ' || v_done || ' of ' || v_total || ' procedures'
        || ', classification swaps ' || v_swaps || ' of ' || v_lane_xfrm
        || iff(P_DRY_RUN, '', ', verified in target ' || v_after)
        || v_log;
end;
$$;
