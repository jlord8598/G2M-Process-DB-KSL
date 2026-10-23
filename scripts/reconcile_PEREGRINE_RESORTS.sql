execute immediate $$
-- ============================================================================
-- scripts/reconcile_PEREGRINE_RESORTS.sql
-- M6 deliverable. Read-only. Never deployed; parity never sees it.
-- For every source table of lane PEREGRINE_RESORTS (build 05 rebuild, D-44; DEPARTMENTS added; the lane's
-- COA dictionary replaces the retired shared chart, owner Q-06),
-- compares row count and the sum of every numeric column across
--   CLN   CLN.CLEAN source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pace tables),
--         grouped by SOURCE_TABLE
--   SEM   the six semantic tables (facts), grouped by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names are taken from the deployed staging code: AMT -> SOURCE_AMOUNT,
-- STAT/QTY/HOURS -> STAT_VALUE, AMOUNTS -> SOURCE_AMOUNT; every other numeric
-- column is carried verbatim under its own name.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    -- ------------------------------------------------------------------------
    -- measures per table per layer, as objects keyed by metric
    -- ------------------------------------------------------------------------
    m as (
        -- DAILY_EXTENDED ------------------------------------------------------
        select 'DAILY_EXTENDED' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', sum(amt), 'STAT', sum(stat), 'YEAR', sum(year), 'MONTH', sum(month)) o
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED
        union all
        select 'DAILY_EXTENDED', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value), 'YEAR', sum(year), 'MONTH', sum(month))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED
        -- MONTHLY_EXTENDED ----------------------------------------------------
        union all
        select 'MONTHLY_EXTENDED', 'CLN', object_construct('ROWS', count(*), 'AMT', sum(amt), 'STAT', sum(stat), 'FCID', sum(fcid), 'YEAR', sum(year), 'MONTH', sum(month))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED
        union all
        select 'MONTHLY_EXTENDED', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value), 'FCID', sum(fcid), 'YEAR', sum(year), 'MONTH', sum(month))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
        -- LEDGER_BATCHES ------------------------------------------------------
        union all
        select 'LEDGER_BATCHES', 'CLN', object_construct('ROWS', count(*), 'AMT', sum(amt), 'STAT', sum(qty), 'BATCH_ID', sum(batch_id), 'FISCAL_YEAR', sum(fiscal_year), 'FISCAL_PERIOD', sum(fiscal_period), 'LINE_SEQ', sum(line_seq))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES
        union all
        select 'LEDGER_BATCHES', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value), 'BATCH_ID', sum(batch_id), 'FISCAL_YEAR', sum(fiscal_year), 'FISCAL_PERIOD', sum(fiscal_period), 'LINE_SEQ', sum(line_seq))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES
        -- DAILY_LABOR ---------------------------------------------------------
        union all
        select 'DAILY_LABOR', 'CLN', object_construct('ROWS', count(*), 'AMT', sum(amounts), 'STAT', sum(hours), 'PERSON_ID', sum(person_id), 'EFFECTIVE_RATE', sum(effective_rate), 'LINE_SEQ', sum(line_seq))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR
        union all
        select 'DAILY_LABOR', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value), 'PERSON_ID', sum(person_id), 'EFFECTIVE_RATE', sum(effective_rate), 'LINE_SEQ', sum(line_seq))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR
        -- facts in XFRM, four H1-routed streams, by source table --------------
        union all
        select split_part(source_table, 'CUR_PROFITSWORD_PEREGRINE_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (
            select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT
            union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET
            union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS
            union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN
        )
        group by source_table
        -- facts in SEM, six tables, this lane, by source table ----------------
        union all
        select split_part(source_table, 'CUR_PROFITSWORD_PEREGRINE_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (
            select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL
            union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET
            union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST
            union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET
            union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS
            union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN
        )
        where source_lane = 'PEREGRINE_RESORTS'
        group by source_table
        -- pacing --------------------------------------------------------------
        union all
        select 'SALES_PACE_ROOMS', 'CLN', object_construct('ROWS', count(*), 'QTY', sum(qty), 'AMT', sum(amt), 'AVG_RATE', sum(avg_rate), 'DAYS_OUT', sum(days_out), 'LINE_SEQ', sum(line_seq))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS
        union all
        select 'SALES_PACE_ROOMS', 'STG', object_construct('ROWS', count(*), 'QTY', sum(qty), 'AMT', sum(amt), 'AVG_RATE', sum(avg_rate), 'DAYS_OUT', sum(days_out), 'LINE_SEQ', sum(line_seq))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS
        union all
        select 'SALES_PACE_TRANSIENT', 'CLN', object_construct('ROWS', count(*), 'QTY', sum(qty), 'AMT', sum(amt), 'AVG_RATE', sum(avg_rate), 'DAYS_OUT', sum(days_out), 'LINE_SEQ', sum(line_seq))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT
        union all
        select 'SALES_PACE_TRANSIENT', 'STG', object_construct('ROWS', count(*), 'QTY', sum(qty), 'AMT', sum(amt), 'AVG_RATE', sum(avg_rate), 'DAYS_OUT', sum(days_out), 'LINE_SEQ', sum(line_seq))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT
        union all
        select 'SALES_PACE_EVENTS', 'CLN', object_construct('ROWS', count(*), 'QTY', sum(qty), 'AMT_FOOD', sum(amt_food), 'AMT_BEV', sum(amt_bev), 'AMT_RENT', sum(amt_rent), 'AMT_RSRC', sum(amt_rsrc), 'AMT_MISC', sum(amt_misc), 'AMT_TOTAL', sum(amt_total), 'DAYS_OUT', sum(days_out), 'LINE_SEQ', sum(line_seq))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS
        union all
        select 'SALES_PACE_EVENTS', 'STG', object_construct('ROWS', count(*), 'QTY', sum(qty), 'AMT_FOOD', sum(amt_food), 'AMT_BEV', sum(amt_bev), 'AMT_RENT', sum(amt_rent), 'AMT_RSRC', sum(amt_rsrc), 'AMT_MISC', sum(amt_misc), 'AMT_TOTAL', sum(amt_total), 'DAYS_OUT', sum(days_out), 'LINE_SEQ', sum(line_seq))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS
        union all
        select split_part(source_table, 'CUR_PROFITSWORD_PEREGRINE_', 2), 'XFRM', object_construct('ROWS', count(*), 'QTY', sum(qty), 'AMT', sum(amt), 'AVG_RATE', sum(avg_rate), 'AMT_FOOD', sum(amt_food), 'AMT_BEV', sum(amt_bev), 'AMT_RENT', sum(amt_rent), 'AMT_RSRC', sum(amt_rsrc), 'AMT_MISC', sum(amt_misc), 'AMT_TOTAL', sum(amt_total), 'DAYS_OUT', sum(days_out), 'LINE_SEQ', sum(line_seq))
        from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING
        group by source_table
        -- dictionaries --------------------------------------------------------
        union all
        select 'SALES_BOOKINGS', 'CLN', object_construct('ROWS', count(*), 'BOOKING_ID', sum(booking_id), 'SPAN_NIGHTS', sum(span_nights))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS
        union all
        select 'SALES_BOOKINGS', 'STG', object_construct('ROWS', count(*), 'BOOKING_ID', sum(booking_id), 'SPAN_NIGHTS', sum(span_nights))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS
        union all
        select 'DATASETS', 'CLN', object_construct('ROWS', count(*), 'FCID', sum(fcid))
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DATASETS
        union all
        select 'DATASETS', 'STG', object_construct('ROWS', count(*), 'FCID', sum(fcid))
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DATASETS
        union all
        select 'SITES', 'CLN', object_construct('ROWS', count(*)) from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITES
        union all
        select 'SITES', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES
        union all
        select 'SITE_GROUPS', 'CLN', object_construct('ROWS', count(*)) from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS
        union all
        select 'SITE_GROUPS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS
        union all
        select 'ACCOUNT_CLASS', 'CLN', object_construct('ROWS', count(*)) from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_ACCOUNT_CLASS
        union all
        select 'ACCOUNT_CLASS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS
        union all
        select 'COA', 'CLN', object_construct('ROWS', count(*)) from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_COA
        union all
        select 'COA', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_COA
        union all
        select 'DEPARTMENTS', 'CLN', object_construct('ROWS', count(*)) from CLN.CLEAN.CUR_PROFITSWORD_DEPARTMENTS
        union all
        select 'DEPARTMENTS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS
    )
    -- ------------------------------------------------------------------------
    -- one row per table per metric, layers side by side
    -- ------------------------------------------------------------------------
    , r as (
        select
              m.t                                        as source_table
            , f.key::varchar                             as metric
            , max(iff(m.l = 'CLN',  f.value::float, null)) as cln
            , max(iff(m.l = 'STG',  f.value::float, null)) as stg
            , max(iff(m.l = 'XFRM', f.value::float, null)) as xfrm
            , max(iff(m.l = 'SEM',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then 'FAIL'
                  when stg  is null or abs(stg  - cln) > 0.005        then 'FAIL'
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then 'FAIL'
                  when sem  is not null and abs(sem  - cln) > 0.005   then 'FAIL'
                  else 'PASS'
              end as status
        from r
    )
    select 'PEREGRINE_RESORTS' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'PEREGRINE_RESORTS', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
