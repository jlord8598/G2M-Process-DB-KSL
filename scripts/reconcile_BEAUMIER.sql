execute immediate $$
-- ============================================================================
-- scripts/reconcile_BEAUMIER.sql
-- M6 deliverable (build 07: LOCATION_MAP added; otherwise build 03 text). Read-only. Never deployed; parity never sees it.
-- For every source table of lane BEAUMIER, compares row count and the sum of
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
--   BP, BUDGET     AMOUNT -> SOURCE_AMOUNT (AMT)
--   CANCELLATIONS  pacing; every numeric column carried under its own name
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
        -- BP
        select 'BP' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', sum(amount), 'SOURCE_ROW_NUMBER', sum(source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BP
        union all
        select 'BP', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'SOURCE_ROW_NUMBER', sum(source_row_number))
        from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
        union all
        -- BUDGET
        select 'BUDGET' t, 'CLN' l, object_construct('ROWS', count(*), 'AMT', sum(amount), 'SOURCE_ROW_NUMBER', sum(source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_BUDGET
        union all
        select 'BUDGET', 'STG', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'SOURCE_ROW_NUMBER', sum(source_row_number))
        from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, 'CLN_BEAUMIER_', 2), 'XFRM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS union all select source_table, source_amount, stat_value from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, 'CLN_BEAUMIER_', 2), 'SEM', object_construct('ROWS', count(*), 'AMT', sum(source_amount), 'STAT', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = 'BEAUMIER'
        group by source_table
        union all
        -- pacing CANCELLATIONS
        select 'CANCELLATIONS', 'CLN', object_construct('ROWS', count(*), 'OCCUPANCY', sum(occupancy), 'ROOMS_REVENUE', sum(rooms_revenue), 'OCCUPANCY_N_1', sum(occupancy_n_1), 'ROOMS_REVENUE_N_1', sum(rooms_revenue_n_1), 'OCCUPANCY_N_2', sum(occupancy_n_2), 'ROOMS_REVENUE_N_2', sum(rooms_revenue_n_2), 'OCCUPANCY_N_3', sum(occupancy_n_3), 'ROOMS_REVENUE_N_3', sum(rooms_revenue_n_3), 'OCCUPANCY_N_4', sum(occupancy_n_4), 'ROOMS_REVENUE_N_4', sum(rooms_revenue_n_4), 'OCCUPANCY_N_5', sum(occupancy_n_5), 'ROOMS_REVENUE_N_5', sum(rooms_revenue_n_5), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_CANCELLATIONS
        union all
        select 'CANCELLATIONS', 'STG', object_construct('ROWS', count(*), 'OCCUPANCY', sum(occupancy), 'ROOMS_REVENUE', sum(rooms_revenue), 'OCCUPANCY_N_1', sum(occupancy_n_1), 'ROOMS_REVENUE_N_1', sum(rooms_revenue_n_1), 'OCCUPANCY_N_2', sum(occupancy_n_2), 'ROOMS_REVENUE_N_2', sum(rooms_revenue_n_2), 'OCCUPANCY_N_3', sum(occupancy_n_3), 'ROOMS_REVENUE_N_3', sum(rooms_revenue_n_3), 'OCCUPANCY_N_4', sum(occupancy_n_4), 'ROOMS_REVENUE_N_4', sum(rooms_revenue_n_4), 'OCCUPANCY_N_5', sum(occupancy_n_5), 'ROOMS_REVENUE_N_5', sum(rooms_revenue_n_5), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
        union all
        select 'CANCELLATIONS', 'XFRM', object_construct('ROWS', count(*), 'OCCUPANCY', sum(occupancy), 'ROOMS_REVENUE', sum(rooms_revenue), 'OCCUPANCY_N_1', sum(occupancy_n_1), 'ROOMS_REVENUE_N_1', sum(rooms_revenue_n_1), 'OCCUPANCY_N_2', sum(occupancy_n_2), 'ROOMS_REVENUE_N_2', sum(rooms_revenue_n_2), 'OCCUPANCY_N_3', sum(occupancy_n_3), 'ROOMS_REVENUE_N_3', sum(rooms_revenue_n_3), 'OCCUPANCY_N_4', sum(occupancy_n_4), 'ROOMS_REVENUE_N_4', sum(rooms_revenue_n_4), 'OCCUPANCY_N_5', sum(occupancy_n_5), 'ROOMS_REVENUE_N_5', sum(rooms_revenue_n_5), 'SOURCE_ROW_NUMBER', sum(source_row_number)) from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_PACING where source_table = 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_CANCELLATIONS'
        union all
        -- dictionary ACCOUNTS
        select 'ACCOUNTS', 'CLN', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_ACCOUNTS
        union all
        select 'ACCOUNTS', 'STG', object_construct('ROWS', count(*), 'ROW_COUNT', sum(row_count)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS
        union all
        -- dictionary LOCATION_MAP (build 07): no numeric column, rows compared
        select 'LOCATION_MAP', 'CLN', object_construct('ROWS', count(*)) from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_LOCATION_MAP
        union all
        select 'LOCATION_MAP', 'STG', object_construct('ROWS', count(*)) from DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP
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
