execute immediate $$
-- ============================================================================
-- scripts/reconcile_INVITED_CLUBS.sql
-- M6 deliverable (rerun unchanged in build 08; source amount columns unchanged). Read-only. Never deployed; parity never sees it.
-- For every source table of lane INVITED_CLUBS, compares row count and the sum of
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
--   ESSBASE_EXTRACT  wide, 3 columns unpivoted: CLN ROWS = count(*) x 3;
--                    ACTUAL_, FORECAST_, BUDGET_AMOUNT -> SOURCE_AMOUNT (AMT), or
--                    STAT_VALUE (STAT) where META_ACCOUNT.DATA_TYPE is non-currency
--                    (owner Q-05)
-- The lane has no pacing source: XFRM_INVITED_CLUBS_PACING is empty by design.
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
        -- ESSBASE_EXTRACT
        select 'ESSBASE_EXTRACT' t, 'CLN' l, object_construct('ROWS', count(*) * 3, 'AMT', sum(iff(lower(trim(m.dt)) = 'non-currency', 0, coalesce(e.actual_amount, 0) + coalesce(e.forecast_amount, 0) + coalesce(e.budget_amount, 0))), 'STAT', sum(iff(lower(trim(m.dt)) = 'non-currency', coalesce(e.actual_amount, 0) + coalesce(e.forecast_amount, 0) + coalesce(e.budget_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ESSBASE_EXTRACT e
        left join (select account, min(data_type) dt from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ACCOUNT group by account) m on m.account = e.account
        union all
        select 'ESSBASE_EXTRACT', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount), 0), 'STAT', coalesce(sum(stat_value), 0))
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, 'CLN_INVITED_CLUBS_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, 'CLN_INVITED_CLUBS_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'INVITED_CLUBS'
        group by source_table
        union all
        -- dictionary ACCOUNTS
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ACCOUNTS
        union all
        -- dictionary META_ACCOUNT
        select 'META_ACCOUNT', 'CLN', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ACCOUNT
        union all
        select 'META_ACCOUNT', 'STG', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
        union all
        -- dictionary META_DEPARTMENT
        select 'META_DEPARTMENT', 'CLN', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_DEPARTMENT
        union all
        select 'META_DEPARTMENT', 'STG', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
        union all
        -- dictionary META_ENTITY
        select 'META_ENTITY', 'CLN', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_ENTITY
        union all
        select 'META_ENTITY', 'STG', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY
        union all
        -- dictionary META_LOCATION
        select 'META_LOCATION', 'CLN', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_LOCATION
        union all
        select 'META_LOCATION', 'STG', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_LOCATION
        union all
        -- dictionary META_SUBACCOUNT
        select 'META_SUBACCOUNT', 'CLN', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_META_SUBACCOUNT
        union all
        select 'META_SUBACCOUNT', 'STG', object_construct('ROWS', count(*), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT
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
    select 'INVITED_CLUBS' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'INVITED_CLUBS', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
