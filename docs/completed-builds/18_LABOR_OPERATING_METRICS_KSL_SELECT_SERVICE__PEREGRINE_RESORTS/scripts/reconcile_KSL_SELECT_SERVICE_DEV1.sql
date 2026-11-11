execute immediate $$
-- ============================================================================
-- scripts/reconcile_KSL_SELECT_SERVICE_DEV1.sql  (build 18: labor as operating metrics; read-only;
-- never deployed). Database = v_db.
-- DAILY_LABOR: rows, wages (AMOUNTS = SOURCE_AMOUNT), hours (HOURS = STAT_VALUE)
-- across CLN, STG, XFRM and SEM. The other fact tables (DAILY_EXTENDED,
-- MONTHLY_EXTENDED, LEDGER_BATCHES) were staged 2026-11-04 and their CLN tables
-- reloaded 2026-11-11, so they are compared STG -> XFRM -> SEM only (owner Q-02).
-- Also: labor rows outside operating metrics = 0; no PERSON_ID / EMPLOYEE_ID /
-- EMPLOYEE_NAME column in TRANSFORMATION or SEMANTIC; labor SOURCE_LINE_KEY null
-- (owner Q-03). Tolerance 0.005. Last row: TOTAL FAILURES; zero is required.
-- ============================================================================
declare
    v_db  varchar default 'DEV1';
    v_sql varchar;
    res   resultset;
begin
    v_sql := replace('with a as (with
    m as (
        select ''DAILY_LABOR'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(amounts), 0), ''STAT'', coalesce(sum(hours), 0)) o from CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR
        union all
        select ''DAILY_LABOR'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR
        union all
        select ''DAILY_LABOR'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN) where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR''
        union all
        select ''DAILY_LABOR'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN where source_lane = ''KSL_SELECT_SERVICE'') where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR''
        union all
        select ''DAILY_EXTENDED'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED
        union all
        select ''DAILY_EXTENDED'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN) where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_EXTENDED''
        union all
        select ''DAILY_EXTENDED'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN where source_lane = ''KSL_SELECT_SERVICE'') where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_EXTENDED''
        union all
        select ''MONTHLY_EXTENDED'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED
        union all
        select ''MONTHLY_EXTENDED'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN) where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED''
        union all
        select ''MONTHLY_EXTENDED'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN where source_lane = ''KSL_SELECT_SERVICE'') where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED''
        union all
        select ''LEDGER_BATCHES'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES
        union all
        select ''LEDGER_BATCHES'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN) where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_LEDGER_BATCHES''
        union all
        select ''LEDGER_BATCHES'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = ''KSL_SELECT_SERVICE'' union all select source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN where source_lane = ''KSL_SELECT_SERVICE'') where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_LEDGER_BATCHES''
    )
    , r as (
        select m.t source_table, f.key::varchar metric
             , max(iff(m.l = ''CLN'',  f.value::float, null)) cln
             , max(iff(m.l = ''STG'',  f.value::float, null)) stg
             , max(iff(m.l = ''XFRM'', f.value::float, null)) xfrm
             , max(iff(m.l = ''SEM'',  f.value::float, null)) sem
        from m, lateral flatten(input => m.o) f group by 1, 2
    )
    , chk as (
        select r.*
             , case
                   when stg is null or xfrm is null or sem is null           then ''FAIL''
                   when cln is not null and abs(stg - cln) > 0.005           then ''FAIL''
                   when abs(xfrm - stg) > 0.005 or abs(sem - stg) > 0.005    then ''FAIL''
                   else ''PASS''
               end status
        from r
        union all
        -- labor reaches only operating metrics: 0 labor rows in any other stream / table
        select ''DAILY_LABOR'', ''ROWS_OUTSIDE_OPERATING_METRICS'', null, null
             , (select count(*) from (select source_table from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT union all select source_table from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET union all select source_table from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN union all select source_table from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING) where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR'')
             , (select count(*) from (select source_lane, source_table from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''KSL_SELECT_SERVICE'' and source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR'')
             , null
        union all
        -- personal data (owner Q-03): no person column in TRANSFORMATION or SEMANTIC,
        -- and SOURCE_LINE_KEY null on every labor row
        select ''PERSONAL_DATA'', ''PERSON_COLUMNS_IN_XFRM_OR_SEM'', null, null
             , (select count(*) from __DB__.INFORMATION_SCHEMA.COLUMNS where table_schema in (''TRANSFORMATION'', ''SEMANTIC'') and column_name in (''PERSON_ID'', ''EMPLOYEE_ID'', ''EMPLOYEE_NAME''))
             , null, null
        union all
        select ''PERSONAL_DATA'', ''LABOR_ROWS_WITH_LINE_KEY'', null, null
             , (select count_if(source_line_key is not null) from __DB__.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS where source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR'')
             , (select count_if(source_line_key is not null) from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = ''KSL_SELECT_SERVICE'' and source_table = ''CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR'')
             , null
    )
    select ''KSL_SELECT_SERVICE'' lane, source_table, metric, cln, stg, xfrm, sem
         , case when metric in (''ROWS_OUTSIDE_OPERATING_METRICS'', ''PERSON_COLUMNS_IN_XFRM_OR_SEM'', ''LABOR_ROWS_WITH_LINE_KEY'')
                then iff(coalesce(xfrm, 0) = 0 and coalesce(sem, 0) = 0, ''PASS'', ''FAIL'') else status end status
    from chk) select lane, source_table, metric, cln, stg, xfrm, sem, status from a union all select ''KSL_SELECT_SERVICE'', ''TOTAL'', ''FAILURES'', null, count_if(status = ''FAIL''), null, null, iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'') from a order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    return table(res);
end;
$$
