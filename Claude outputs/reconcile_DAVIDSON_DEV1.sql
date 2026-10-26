execute immediate $$
-- ============================================================================
-- scripts/reconcile_DAVIDSON.sql
-- M6 deliverable (build 06). Read-only. Never deployed; parity never sees it.
-- For every source table of lane DAVIDSON, compares row count and the sum of
-- every numeric column across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams, grouped by SOURCE_TABLE
--   SEM   the six semantic tables, grouped by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names and the split rules are taken from the deployed staging code:
--   HOTEL_MONTHLY_REPORT  wide, 2 branches: CLN ROWS = count(*) x 2;
--       ACTUAL_/FORECAST_AMOUNT -> STAT_VALUE (STAT) on LINE_CLASS ADR/Rooms or
--       natural account 9xxx (owner Q-06, Q-07), else SOURCE_AMOUNT (AMT)
--   FULL_YEAR_PL          wide, 2 branches; -> STAT_VALUE on the SUMMARY
--       hotel-heading sections (Q-06), else SOURCE_AMOUNT
--   *_SOURCE_ROW_NUMBER   carried verbatim on both branches: STG = 2 x CLN
--       (compared as STG / 2)
-- The lane has no pacing source: XFRM_DAVIDSON_PACING is empty by design (M1).
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
        -- HOTEL_MONTHLY_REPORT
        select 'HOTEL_MONTHLY_REPORT' t, 'CLN' l, object_construct('ROWS', count(*) * 2
             , 'AMT', sum(iff((upper(trim(line_class)) in ('ADR', 'ROOMS') or coalesce(regexp_count(account, '-') = 5 and left(split_part(account, '-', 2), 1) = '9', false)), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0)))
             , 'STAT', sum(iff((upper(trim(line_class)) in ('ADR', 'ROOMS') or coalesce(regexp_count(account, '-') = 5 and left(split_part(account, '-', 2), 1) = '9', false)), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0), 0))
             , 'ACTUAL_SOURCE_ROW_NUMBER', sum(actual_source_row_number), 'FORECAST_SOURCE_ROW_NUMBER', sum(forecast_source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_HOTEL_MONTHLY_REPORT
        union all
        select 'HOTEL_MONTHLY_REPORT', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)
             , 'ACTUAL_SOURCE_ROW_NUMBER', sum(actual_source_row_number) / 2, 'FORECAST_SOURCE_ROW_NUMBER', sum(forecast_source_row_number) / 2)
        from DEV1.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT
        union all
        -- FULL_YEAR_PL
        select 'FULL_YEAR_PL' t, 'CLN' l, object_construct('ROWS', count(*) * 2
             , 'AMT', sum(iff((report_sheet = 'SUMMARY' and regexp_like(section, '^\\[.*\\]$|^[A-Z]{6} ?-.*')), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0)))
             , 'STAT', sum(iff((report_sheet = 'SUMMARY' and regexp_like(section, '^\\[.*\\]$|^[A-Z]{6} ?-.*')), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0), 0))
             , 'ACTUAL_SOURCE_ROW_NUMBER', sum(actual_source_row_number), 'FORECAST_SOURCE_ROW_NUMBER', sum(forecast_source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FULL_YEAR_PL
        union all
        select 'FULL_YEAR_PL', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0)
             , 'ACTUAL_SOURCE_ROW_NUMBER', sum(actual_source_row_number) / 2, 'FORECAST_SOURCE_ROW_NUMBER', sum(forecast_source_row_number) / 2)
        from DEV1.STAGING.STG_DAVIDSON_FULL_YEAR_PL
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, 'CLN_DAVIDSON_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from (select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_DAVIDSON_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_DAVIDSON_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_DAVIDSON_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV1.TRANSFORMATION.XFRM_DAVIDSON_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, 'CLN_DAVIDSON_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from (select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV1.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'DAVIDSON'
        group by source_table
        union all
        -- dictionary ACCOUNTS
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV1.STAGING.STG_DAVIDSON_ACCOUNTS
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
    select 'DAVIDSON' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'DAVIDSON', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
