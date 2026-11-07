execute immediate $$
-- ============================================================================
-- scripts/reconcile_BEAUMIER.sql
-- M6 deliverable (build 15, D-44 rebuild). Read-only. Never deployed.
-- For every in-scope source table of lane BEAUMIER: row count (CLN x the stated
-- unpivot multiplier) and every numeric measure across
--   CLN   CLN.BOX_INVESTMENT_DATA source table
--   STG   its staging table
--   XFRM  the four H1-routed streams (facts) or PACING (pace tables), by SOURCE_TABLE
--   SEM   the six semantic tables (facts), by SOURCE_TABLE
-- Fact tables: AMT and STAT where the CLN columns state the split; otherwise
-- TOTAL (SOURCE_AMOUNT + STAT_VALUE against the sum of the CLN measure columns,
-- where staging splits each row by RECORD_TYPE). Pace tables: every numeric
-- column. Dictionaries: rows.
-- SOURCE_AMOUNT is reconciled, never VALUE (D-50 changes VALUE, not the amount).
-- PASS when every carried layer is within 0.005 of CLN; FAIL otherwise.
-- The last row is the total failure count. Zero is required.
-- ============================================================================
declare
    res resultset;
begin
    res := (
    with
    m as (
        select 'CLN_BEAUMIER_BP' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'AMT', coalesce(sum(amount),0), 'STAT', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BP
        union all
        select 'CLN_BEAUMIER_BP', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
        union all
        select 'CLN_BEAUMIER_BP', 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BP'
        union all
        select 'CLN_BEAUMIER_BP', 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'BEAUMIER' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BP'
        union all
        select 'CLN_BEAUMIER_BUDGET' t, 'CLN' l, object_construct('ROWS', count(*) * 1, 'AMT', coalesce(sum(amount),0), 'STAT', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BUDGET
        union all
        select 'CLN_BEAUMIER_BUDGET', 'STG', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
        union all
        select 'CLN_BEAUMIER_BUDGET', 'XFRM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN) where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BUDGET'
        union all
        select 'CLN_BEAUMIER_BUDGET', 'SEM', object_construct('ROWS', count(*), 'AMT', coalesce(sum(source_amount),0), 'STAT', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = 'BEAUMIER' and source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BUDGET'
        union all
        select 'CLN_BEAUMIER_CANCELLATIONS' t, 'CLN' l, object_construct('ROWS', count(*), 'OCCUPANCY', coalesce(sum(occupancy), 0), 'ROOMS_REVENUE', coalesce(sum(rooms_revenue), 0), 'OCCUPANCY_N_1', coalesce(sum(occupancy_n_1), 0), 'ROOMS_REVENUE_N_1', coalesce(sum(rooms_revenue_n_1), 0), 'OCCUPANCY_N_2', coalesce(sum(occupancy_n_2), 0), 'ROOMS_REVENUE_N_2', coalesce(sum(rooms_revenue_n_2), 0), 'OCCUPANCY_N_3', coalesce(sum(occupancy_n_3), 0), 'ROOMS_REVENUE_N_3', coalesce(sum(rooms_revenue_n_3), 0), 'OCCUPANCY_N_4', coalesce(sum(occupancy_n_4), 0), 'ROOMS_REVENUE_N_4', coalesce(sum(rooms_revenue_n_4), 0), 'OCCUPANCY_N_5', coalesce(sum(occupancy_n_5), 0), 'ROOMS_REVENUE_N_5', coalesce(sum(rooms_revenue_n_5), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_CANCELLATIONS
        union all
        select 'CLN_BEAUMIER_CANCELLATIONS', 'STG', object_construct('ROWS', count(*), 'OCCUPANCY', coalesce(sum(occupancy), 0), 'ROOMS_REVENUE', coalesce(sum(rooms_revenue), 0), 'OCCUPANCY_N_1', coalesce(sum(occupancy_n_1), 0), 'ROOMS_REVENUE_N_1', coalesce(sum(rooms_revenue_n_1), 0), 'OCCUPANCY_N_2', coalesce(sum(occupancy_n_2), 0), 'ROOMS_REVENUE_N_2', coalesce(sum(rooms_revenue_n_2), 0), 'OCCUPANCY_N_3', coalesce(sum(occupancy_n_3), 0), 'ROOMS_REVENUE_N_3', coalesce(sum(rooms_revenue_n_3), 0), 'OCCUPANCY_N_4', coalesce(sum(occupancy_n_4), 0), 'ROOMS_REVENUE_N_4', coalesce(sum(rooms_revenue_n_4), 0), 'OCCUPANCY_N_5', coalesce(sum(occupancy_n_5), 0), 'ROOMS_REVENUE_N_5', coalesce(sum(rooms_revenue_n_5), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
        union all
        select 'CLN_BEAUMIER_CANCELLATIONS', 'XFRM', object_construct('ROWS', count(*), 'OCCUPANCY', coalesce(sum(occupancy), 0), 'ROOMS_REVENUE', coalesce(sum(rooms_revenue), 0), 'OCCUPANCY_N_1', coalesce(sum(occupancy_n_1), 0), 'ROOMS_REVENUE_N_1', coalesce(sum(rooms_revenue_n_1), 0), 'OCCUPANCY_N_2', coalesce(sum(occupancy_n_2), 0), 'ROOMS_REVENUE_N_2', coalesce(sum(rooms_revenue_n_2), 0), 'OCCUPANCY_N_3', coalesce(sum(occupancy_n_3), 0), 'ROOMS_REVENUE_N_3', coalesce(sum(rooms_revenue_n_3), 0), 'OCCUPANCY_N_4', coalesce(sum(occupancy_n_4), 0), 'ROOMS_REVENUE_N_4', coalesce(sum(rooms_revenue_n_4), 0), 'OCCUPANCY_N_5', coalesce(sum(occupancy_n_5), 0), 'ROOMS_REVENUE_N_5', coalesce(sum(rooms_revenue_n_5), 0), 'SOURCE_ROW_NUMBER', coalesce(sum(source_row_number), 0)) from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_CANCELLATIONS'
        union all
        select 'CLN_BEAUMIER_ACCOUNTS' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS
        union all
        select 'CLN_BEAUMIER_ACCOUNTS', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS
        union all
        select 'CLN_BEAUMIER_HIERARCHY' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_HIERARCHY
        union all
        select 'CLN_BEAUMIER_HIERARCHY', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_HIERARCHY
        union all
        select 'CLN_BEAUMIER_LOCATION_MAP' t, 'CLN' l, object_construct('ROWS', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP
        union all
        select 'CLN_BEAUMIER_LOCATION_MAP', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP
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
    select 'BEAUMIER' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select 'BEAUMIER', 'TOTAL', 'FAILURES', count_if(status = 'FAIL'), null, null, null
         , iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL')
    from chk
    order by source_table = 'TOTAL', source_table, metric
    );
    return table(res);
end;
$$
