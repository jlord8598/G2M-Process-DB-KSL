execute immediate $$
-- ============================================================================
-- scripts/reconcile_HHG.sql
-- M6 deliverable. Read-only. Never deployed; parity never sees it.
-- For every source table of lane HHG, compares row count and the sum of
-- every numeric column across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pacing tables),
--         grouped by SOURCE_TABLE
--   SEM   the six semantic tables (facts), grouped by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names are taken from the deployed staging code:
--   TR12_DATA         AMOUNT where department <> 999 -> SOURCE_AMOUNT (AMT),
--                     AMOUNT where department = 999 -> STAT_VALUE (STAT) (Q-01)
--   FORECAST_ANAPLAN  AMOUNT -> SOURCE_AMOUNT (AMT)
--   ROUNDS_DETAIL     ROUNDS_COUNT -> STAT_VALUE (STAT)
-- The lane has no pacing source: XFRM_HHG_PACING is empty by design (M1).
-- every other numeric column is carried verbatim under its own name.
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
        -- TR12_DATA ---------------------------------------------------------
        select 'TR12_DATA' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', sum(iff(split_part(trim(account_code), '-', 2) = '999', null, amount)), 'STAT', sum(iff(split_part(trim(account_code), '-', 2) = '999', amount, null)), 'SOURCE_ROW_NUMBER', sum(source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA
        union all
        select 'TR12_DATA', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value), 'SOURCE_ROW_NUMBER', sum(source_row_number))
        from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA
        union all
        -- FORECAST_ANAPLAN --------------------------------------------------
        select 'FORECAST_ANAPLAN' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', sum(amount), 'SOURCE_ROW_NUMBER', sum(source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN
        union all
        select 'FORECAST_ANAPLAN', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'SOURCE_ROW_NUMBER', sum(source_row_number))
        from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN
        union all
        -- ROUNDS_DETAIL -----------------------------------------------------
        select 'ROUNDS_DETAIL' t, 'CLN' l, object_construct('ROWS', count(*), 'STAT', sum(rounds_count), 'SOURCE_ROW_NUMBER', sum(source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL
        union all
        select 'ROUNDS_DETAIL', 'STG', object_construct('ROWS', count(*), 'STAT', sum(stat_value), 'SOURCE_ROW_NUMBER', sum(source_row_number))
        from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL
        union all
        -- facts in XFRM, four H1-routed streams, by source table --------------
        select split_part(source_table, 'CLN_HERITAGE_GOLF_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table ----------------
        select split_part(source_table, 'CLN_HERITAGE_GOLF_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'HHG'
        group by source_table
        union all
        -- dictionary ACCOUNTS -----------------------------------------------
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_HHG_ACCOUNTS
        union all
        -- dictionary CLUB_LIST ----------------------------------------------
        select 'CLUB_LIST', 'CLN', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_CLUB_LIST
        union all
        select 'CLUB_LIST', 'STG', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_HHG_CLUB_LIST
        union all
        -- dictionary REFERENCES ---------------------------------------------
        select 'REFERENCES', 'CLN', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REFERENCES
        union all
        select 'REFERENCES', 'STG', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_HHG_REFERENCES
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
    select 'HHG' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'HHG', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
