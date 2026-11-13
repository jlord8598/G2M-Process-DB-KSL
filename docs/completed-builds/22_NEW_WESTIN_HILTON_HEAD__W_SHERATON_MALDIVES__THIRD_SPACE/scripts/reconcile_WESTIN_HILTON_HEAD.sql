execute immediate $$
-- ============================================================================
-- scripts/reconcile_WESTIN_HILTON_HEAD.sql
-- M6 deliverable (build 22, new lane): pace-only this build (owner Q-02): PACE_GROUP_MONTHLY verbatim through STG / XFRM, and SEM_AI_PACING VALUE = AMOUNT
-- (k = 1). FIN_PL_MONTHLY and REF_ACCOUNTS are not staged (N-55).
-- Read-only. Never deployed; parity never sees it.
-- For every source table of lane WESTIN_HILTON_HEAD, compares row count and the sum of
-- every numeric column across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pace tables), by SOURCE_TABLE
--   SEM   the six semantic tables (facts), by SOURCE_TABLE
-- A layer that does not carry a metric shows null and is not compared.
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- CLN column names are taken from the deployed staging code: facts ACTUAL_AMOUNT
-- -> SOURCE_AMOUNT (AMT) or STAT_VALUE (STAT, statistic rows); pace tables carry
-- every source column verbatim.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    m as (
        select 'WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY' t, 'CLN' l, object_construct('ROWS', count(*), 'AMOUNT', coalesce(sum(amount), 0), 'SOURCE_ROWS_COMBINED', coalesce(sum(source_rows_combined), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY
        union all
        select 'WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY', 'STG', object_construct('ROWS', count(*), 'AMOUNT', coalesce(sum(amount), 0), 'SOURCE_ROWS_COMBINED', coalesce(sum(source_rows_combined), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_WESTIN_HILTON_HEAD_PACE_GROUP
        union all
        select 'WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY', 'XFRM', object_construct('ROWS', count(*), 'AMOUNT', coalesce(sum(amount), 0), 'SOURCE_ROWS_COMBINED', coalesce(sum(source_rows_combined), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY'
        union all
        select 'WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY', 'SEM', object_construct('ROWS', count(*), 'AMOUNT', coalesce(sum(value), 0)) from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane = 'WESTIN_HILTON_HEAD' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY'
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
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
    select 'WESTIN_HILTON_HEAD' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'WESTIN_HILTON_HEAD', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
