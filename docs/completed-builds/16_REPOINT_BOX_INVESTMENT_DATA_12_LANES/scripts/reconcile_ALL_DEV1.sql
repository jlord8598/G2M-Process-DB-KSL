execute immediate $$
-- ============================================================================
-- scripts/reconcile_ALL_DEV1.sql  (build 16)
-- One run, all 12 build-16 lanes: ALTERRA, ATLANTIC_AVIATION, BEAUMIER,
-- DAVIDSON, HERSHA, HHG, INVITED_CLUBS, JW_VENICE, NEWBURY, OUTRIGGER,
-- THE_PIG, UNDER_CANVAS. Read-only. Never deployed.
-- Each lane's query is the build-16 reconcile_<LANE>.sql query unchanged except
-- that the database is v_db (CLN.BOX_INVESTMENT_DATA is read as is). Each lane
-- runs as its own statement; the results are then unioned.
-- Output: every metric row of every lane (lane TOTAL rows dropped), then one
-- row TOTAL / FAILURES = the count of FAIL rows across all lanes. Zero is required.
-- Assumes the target database has the schemas STAGING, TRANSFORMATION, SEMANTIC.
-- ============================================================================
declare
    v_db   varchar default 'DEV1';
    v_sql  varchar;
    v_ids  array default array_construct();
    v_fin  varchar default '';
    res    resultset;
begin
    -- ------------------------------------------------------------------------
    -- ALTERRA
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    -- ------------------------------------------------------------------------
    -- measures per table per layer, as objects keyed by metric
    -- ------------------------------------------------------------------------
    m as (
        -- MONTHLY_FINANCIALS
        select ''FIN_PL_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 3, ''AMT'', sum(iff(section in (''Skier Visits'', ''KPIs''), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0))), ''STAT'', sum(iff(section in (''Skier Visits'', ''KPIs''), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_FIN_PL_MONTHLY
        union all
        select ''FIN_PL_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0))
        from __DB__.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, ''CLN_ALTERRA_'', 2), ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', sum(source_amount), ''STAT'', sum(stat_value))
        from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ALTERRA_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, ''CLN_ALTERRA_'', 2), ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', sum(source_amount), ''STAT'', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = ''ALTERRA''
        group by source_table
        union all
        -- pacing PACE_BY_STAY_MONTH: CLN, STG and XFRM PACING, every numeric column
        select ''PACE_GROUP_MONTHLY'', ''CLN'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', sum(today_rooms_commit), ''TODAY_ROOM_REVENUE_OTB'', sum(today_room_revenue_otb), ''STLY_DOW_ROOMS_COMMIT'', sum(stly_dow_rooms_commit), ''STLY_DOW_ROOM_REVENUE_OTB'', sum(stly_dow_room_revenue_otb), ''ST2Y_DOW_ROOMS_COMMIT'', sum(st2y_dow_rooms_commit), ''ST2Y_DOW_ROOM_REVENUE_OTB'', sum(st2y_dow_room_revenue_otb)) from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_PACE_GROUP_MONTHLY
        union all
        select ''PACE_GROUP_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', sum(today_rooms_commit), ''TODAY_ROOM_REVENUE_OTB'', sum(today_room_revenue_otb), ''STLY_DOW_ROOMS_COMMIT'', sum(stly_dow_rooms_commit), ''STLY_DOW_ROOM_REVENUE_OTB'', sum(stly_dow_room_revenue_otb), ''ST2Y_DOW_ROOMS_COMMIT'', sum(st2y_dow_rooms_commit), ''ST2Y_DOW_ROOM_REVENUE_OTB'', sum(st2y_dow_room_revenue_otb)) from __DB__.STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH
        union all
        select ''PACE_GROUP_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', sum(today_rooms_commit), ''TODAY_ROOM_REVENUE_OTB'', sum(today_room_revenue_otb), ''STLY_DOW_ROOMS_COMMIT'', sum(stly_dow_rooms_commit), ''STLY_DOW_ROOM_REVENUE_OTB'', sum(stly_dow_room_revenue_otb), ''ST2Y_DOW_ROOMS_COMMIT'', sum(st2y_dow_rooms_commit), ''ST2Y_DOW_ROOM_REVENUE_OTB'', sum(st2y_dow_room_revenue_otb)) from __DB__.TRANSFORMATION.XFRM_ALTERRA_PACING
        union all
        -- dictionary ACCOUNTS
        select ''REF_ACCOUNTS'', ''CLN'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_ALTERRA_REF_ACCOUNTS
        union all
        select ''REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from __DB__.STAGING.STG_ALTERRA_ACCOUNTS
    )
    -- ------------------------------------------------------------------------
    -- one row per table per metric, layers side by side
    -- ------------------------------------------------------------------------
    , r as (
        select
              m.t                                        as source_table
            , f.key::varchar                             as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''ALTERRA'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''ALTERRA'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- ATLANTIC_AVIATION
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    -- ------------------------------------------------------------------------
    -- measures per table per layer, as objects keyed by metric
    -- ------------------------------------------------------------------------
    m as (
        -- OC_DATA
        select ''FIN_PL_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 3, ''AMT'', sum(iff(line_item in (''Landings'', ''Trips'', ''Gallons'', ''MPG''), 0, (coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0)))), ''STAT'', sum(iff(line_item in (''Landings'', ''Trips'', ''Gallons'', ''MPG''), (coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0)), 0)), ''AMT_SCALED'', sum(iff(line_item in (''Landings'', ''Trips'', ''Gallons'', ''MPG''), 0, (coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0)) * iff(line_item in (''Landings'', ''Trips'', ''MPG''), 1, 1000))), ''STAT_SCALED'', sum(iff(line_item in (''Landings'', ''Trips'', ''Gallons'', ''MPG''), (coalesce(actual_amount, 0) + coalesce(forecast_amount, 0) + coalesce(budget_amount, 0)) * iff(line_item in (''Landings'', ''Trips'', ''MPG''), 1, 1000), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_FIN_PL_MONTHLY
        union all
        select ''FIN_PL_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0), ''AMT_SCALED'', coalesce(sum(source_amount * source_unit_scale), 0), ''STAT_SCALED'', coalesce(sum(stat_value * source_unit_scale), 0))
        from __DB__.STAGING.STG_ATLANTIC_AVIATION_OC_DATA
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, ''CLN_ATLANTIC_AVIATION_'', 2), ''XFRM'', object_construct(''ROWS'', count(*), ''AMT_SCALED'', sum(source_amount), ''STAT_SCALED'', sum(stat_value))
        from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, ''CLN_ATLANTIC_AVIATION_'', 2), ''SEM'', object_construct(''ROWS'', count(*), ''AMT_SCALED'', sum(source_amount), ''STAT_SCALED'', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = ''ATLANTIC_AVIATION''
        group by source_table
        union all
        -- dictionary ACCOUNTS
        select ''REF_ACCOUNTS'', ''CLN'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_REF_ACCOUNTS
        union all
        select ''REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from __DB__.STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS
    )
    -- ------------------------------------------------------------------------
    -- one row per table per metric, layers side by side
    -- ------------------------------------------------------------------------
    , r as (
        select
              m.t                                        as source_table
            , f.key::varchar                             as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''ATLANTIC_AVIATION'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''ATLANTIC_AVIATION'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- BEAUMIER
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''CLN_BEAUMIER_FIN_FORECAST_VERSIONS'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''AMT'', coalesce(sum(amount),0), ''STAT'', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_FORECAST_VERSIONS
        union all
        select ''CLN_BEAUMIER_FIN_FORECAST_VERSIONS'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_BEAUMIER_BP
        union all
        select ''CLN_BEAUMIER_FIN_FORECAST_VERSIONS'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_FORECAST_VERSIONS''
        union all
        select ''CLN_BEAUMIER_FIN_FORECAST_VERSIONS'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''BEAUMIER'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_FORECAST_VERSIONS''
        union all
        select ''CLN_BEAUMIER_FIN_BUDGET_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''AMT'', coalesce(sum(amount),0), ''STAT'', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY
        union all
        select ''CLN_BEAUMIER_FIN_BUDGET_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_BEAUMIER_BUDGET
        union all
        select ''CLN_BEAUMIER_FIN_BUDGET_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY''
        union all
        select ''CLN_BEAUMIER_FIN_BUDGET_MONTHLY'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''BEAUMIER'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_FIN_BUDGET_MONTHLY''
        union all
        select ''CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''OCCUPANCY'', coalesce(sum(occupancy), 0), ''ROOMS_REVENUE'', coalesce(sum(rooms_revenue), 0), ''OCCUPANCY_N_1'', coalesce(sum(occupancy_n_1), 0), ''ROOMS_REVENUE_N_1'', coalesce(sum(rooms_revenue_n_1), 0), ''OCCUPANCY_N_2'', coalesce(sum(occupancy_n_2), 0), ''ROOMS_REVENUE_N_2'', coalesce(sum(rooms_revenue_n_2), 0), ''OCCUPANCY_N_3'', coalesce(sum(occupancy_n_3), 0), ''ROOMS_REVENUE_N_3'', coalesce(sum(rooms_revenue_n_3), 0), ''OCCUPANCY_N_4'', coalesce(sum(occupancy_n_4), 0), ''ROOMS_REVENUE_N_4'', coalesce(sum(rooms_revenue_n_4), 0), ''OCCUPANCY_N_5'', coalesce(sum(occupancy_n_5), 0), ''ROOMS_REVENUE_N_5'', coalesce(sum(rooms_revenue_n_5), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY
        union all
        select ''CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''OCCUPANCY'', coalesce(sum(occupancy), 0), ''ROOMS_REVENUE'', coalesce(sum(rooms_revenue), 0), ''OCCUPANCY_N_1'', coalesce(sum(occupancy_n_1), 0), ''ROOMS_REVENUE_N_1'', coalesce(sum(rooms_revenue_n_1), 0), ''OCCUPANCY_N_2'', coalesce(sum(occupancy_n_2), 0), ''ROOMS_REVENUE_N_2'', coalesce(sum(rooms_revenue_n_2), 0), ''OCCUPANCY_N_3'', coalesce(sum(occupancy_n_3), 0), ''ROOMS_REVENUE_N_3'', coalesce(sum(rooms_revenue_n_3), 0), ''OCCUPANCY_N_4'', coalesce(sum(occupancy_n_4), 0), ''ROOMS_REVENUE_N_4'', coalesce(sum(rooms_revenue_n_4), 0), ''OCCUPANCY_N_5'', coalesce(sum(occupancy_n_5), 0), ''ROOMS_REVENUE_N_5'', coalesce(sum(rooms_revenue_n_5), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_BEAUMIER_CANCELLATIONS
        union all
        select ''CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''OCCUPANCY'', coalesce(sum(occupancy), 0), ''ROOMS_REVENUE'', coalesce(sum(rooms_revenue), 0), ''OCCUPANCY_N_1'', coalesce(sum(occupancy_n_1), 0), ''ROOMS_REVENUE_N_1'', coalesce(sum(rooms_revenue_n_1), 0), ''OCCUPANCY_N_2'', coalesce(sum(occupancy_n_2), 0), ''ROOMS_REVENUE_N_2'', coalesce(sum(rooms_revenue_n_2), 0), ''OCCUPANCY_N_3'', coalesce(sum(occupancy_n_3), 0), ''ROOMS_REVENUE_N_3'', coalesce(sum(rooms_revenue_n_3), 0), ''OCCUPANCY_N_4'', coalesce(sum(occupancy_n_4), 0), ''ROOMS_REVENUE_N_4'', coalesce(sum(rooms_revenue_n_4), 0), ''OCCUPANCY_N_5'', coalesce(sum(occupancy_n_5), 0), ''ROOMS_REVENUE_N_5'', coalesce(sum(rooms_revenue_n_5), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_BEAUMIER_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY''
        union all
        select ''CLN_BEAUMIER_REF_ACCOUNTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_ACCOUNTS
        union all
        select ''CLN_BEAUMIER_REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_BEAUMIER_ACCOUNTS
        union all
        select ''CLN_BEAUMIER_REF_HIERARCHY_PL_LINE'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_HIERARCHY_PL_LINE
        union all
        select ''CLN_BEAUMIER_REF_HIERARCHY_PL_LINE'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_BEAUMIER_HIERARCHY
        union all
        select ''CLN_BEAUMIER_REF_PROPERTIES'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_REF_PROPERTIES
        union all
        select ''CLN_BEAUMIER_REF_PROPERTIES'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_BEAUMIER_LOCATION_MAP
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''BEAUMIER'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''BEAUMIER'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- DAVIDSON
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    -- ------------------------------------------------------------------------
    -- measures per table per layer, as objects keyed by metric
    -- ------------------------------------------------------------------------
    m as (
        -- HOTEL_MONTHLY_REPORT
        select ''FIN_PL_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2
             , ''AMT'', sum(iff((upper(trim(line_class)) in (''ADR'', ''ROOMS'') or coalesce(regexp_count(account, ''-'') = 5 and left(split_part(account, ''-'', 2), 1) = ''9'', false)), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0)))
             , ''STAT'', sum(iff((upper(trim(line_class)) in (''ADR'', ''ROOMS'') or coalesce(regexp_count(account, ''-'') = 5 and left(split_part(account, ''-'', 2), 1) = ''9'', false)), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0), 0))
             , ''ACTUAL_SOURCE_ROW_NUMBER'', sum(actual_source_row_number), ''FORECAST_SOURCE_ROW_NUMBER'', sum(forecast_source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY
        union all
        select ''FIN_PL_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)
             , ''ACTUAL_SOURCE_ROW_NUMBER'', sum(actual_source_row_number) / 2, ''FORECAST_SOURCE_ROW_NUMBER'', sum(forecast_source_row_number) / 2)
        from __DB__.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT
        union all
        -- FULL_YEAR_PL
        select ''FIN_PL_SUMMARY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2
             , ''AMT'', sum(iff((report_sheet = ''SUMMARY'' and regexp_like(section, ''^\\\\[.*\\\\]$|^[A-Z]{6} ?-.*'')), 0, coalesce(actual_amount, 0) + coalesce(forecast_amount, 0)))
             , ''STAT'', sum(iff((report_sheet = ''SUMMARY'' and regexp_like(section, ''^\\\\[.*\\\\]$|^[A-Z]{6} ?-.*'')), coalesce(actual_amount, 0) + coalesce(forecast_amount, 0), 0))
             , ''ACTUAL_SOURCE_ROW_NUMBER'', sum(actual_source_row_number), ''FORECAST_SOURCE_ROW_NUMBER'', sum(forecast_source_row_number)) o
        from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY
        union all
        select ''FIN_PL_SUMMARY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)
             , ''ACTUAL_SOURCE_ROW_NUMBER'', sum(actual_source_row_number) / 2, ''FORECAST_SOURCE_ROW_NUMBER'', sum(forecast_source_row_number) / 2)
        from __DB__.STAGING.STG_DAVIDSON_FULL_YEAR_PL
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, ''CLN_DAVIDSON_'', 2), ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0))
        from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_DAVIDSON_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_DAVIDSON_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_DAVIDSON_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_DAVIDSON_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, ''CLN_DAVIDSON_'', 2), ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0))
        from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = ''DAVIDSON''
        group by source_table
        union all
        -- dictionary ACCOUNTS
        select ''REF_ACCOUNTS'', ''CLN'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_ACCOUNTS
        union all
        select ''REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from __DB__.STAGING.STG_DAVIDSON_ACCOUNTS
    )
    -- ------------------------------------------------------------------------
    -- one row per table per metric, layers side by side
    -- ------------------------------------------------------------------------
    , r as (
        select
              m.t                                        as source_table
            , f.key::varchar                             as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''DAVIDSON'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''DAVIDSON'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- HERSHA
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''CLN_HERSHA_FIN_PL_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2, ''AMT'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0), ''STAT'', coalesce(sum(actual_stat),0)+coalesce(sum(forecast_stat),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY where actual_amount is not null or forecast_amount is not null or actual_stat is not null or forecast_stat is not null
        union all
        select ''CLN_HERSHA_FIN_PL_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_HERSHA_GL_ACTUAL
        union all
        select ''CLN_HERSHA_FIN_PL_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY''
        union all
        select ''CLN_HERSHA_FIN_PL_MONTHLY'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''HERSHA'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_PL_MONTHLY''
        union all
        select ''CLN_HERSHA_OPS_STATS_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2, ''AMT'', 0, ''STAT'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_OPS_STATS_MONTHLY where preferred_row
        union all
        select ''CLN_HERSHA_OPS_STATS_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_HERSHA_GL_STAT
        union all
        select ''CLN_HERSHA_OPS_STATS_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_OPS_STATS_MONTHLY''
        union all
        select ''CLN_HERSHA_OPS_STATS_MONTHLY'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''HERSHA'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_OPS_STATS_MONTHLY''
        union all
        select ''CLN_HERSHA_FIN_TRIAL_BALANCE'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2, ''AMT'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0), ''STAT'', coalesce(sum(actual_stat),0)+coalesce(sum(forecast_stat),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_TRIAL_BALANCE
        union all
        select ''CLN_HERSHA_FIN_TRIAL_BALANCE'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_HERSHA_TB_ACTUAL
        union all
        select ''CLN_HERSHA_FIN_TRIAL_BALANCE'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HERSHA_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_TRIAL_BALANCE''
        union all
        select ''CLN_HERSHA_FIN_TRIAL_BALANCE'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''HERSHA'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_FIN_TRIAL_BALANCE''
        union all
        select ''CLN_HERSHA_REF_ACCOUNTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERSHA_REF_ACCOUNTS
        union all
        select ''CLN_HERSHA_REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HERSHA_ACCOUNTS
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''HERSHA'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''HERSHA'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- HHG
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''TOTAL'', coalesce(sum(amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY
        union all
        select ''CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_HHG_TR12_DATA
        union all
        select ''CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY''
        union all
        select ''CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''HHG'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY''
        union all
        select ''CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''TOTAL'', coalesce(sum(amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS
        union all
        select ''CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_HHG_FORECAST_ANAPLAN
        union all
        select ''CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS''
        union all
        select ''CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''HHG'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_FORECAST_VERSIONS''
        union all
        select ''CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''AMT'', 0, ''STAT'', coalesce(sum(rounds_count),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY
        union all
        select ''CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_HHG_ROUNDS_DETAIL
        union all
        select ''CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY''
        union all
        select ''CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''HHG'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_ROUNDS_DAILY''
        union all
        select ''CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''TOTAL'', coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY
        union all
        select ''CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_HHG_BUDGET_BY_CLUB
        union all
        select ''CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_HHG_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY''
        union all
        select ''CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''HHG'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_BUDGET_MONTHLY''
        union all
        select ''CLN_HERITAGE_GOLF_REF_ACCOUNTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS
        union all
        select ''CLN_HERITAGE_GOLF_REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HHG_ACCOUNTS
        union all
        select ''CLN_HERITAGE_GOLF_REF_PROPERTIES'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTIES
        union all
        select ''CLN_HERITAGE_GOLF_REF_PROPERTIES'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HHG_ASSET_CODES
        union all
        select ''CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS
        union all
        select ''CLN_HERITAGE_GOLF_REF_CHART_OF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HHG_CHART_OF_ACCOUNTS
        union all
        select ''CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS
        union all
        select ''CLN_HERITAGE_GOLF_REF_PROPERTY_STATUS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HHG_CLUB_LIST
        union all
        select ''CLN_HERITAGE_GOLF_REF_DEPARTMENTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_DEPARTMENTS
        union all
        select ''CLN_HERITAGE_GOLF_REF_DEPARTMENTS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HHG_DEPARTMENT_KEY
        union all
        select ''CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS
        union all
        select ''CLN_HERITAGE_GOLF_REF_PROPERTY_WORKSHEETS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HHG_REFERENCES
        union all
        select ''CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING
        union all
        select ''CLN_HERITAGE_GOLF_REF_ACCOUNT_MAPPING'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_HHG_TR12_ACCOUNTS
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''HHG'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''HHG'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- INVITED_CLUBS
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    -- ------------------------------------------------------------------------
    -- measures per table per layer, as objects keyed by metric
    -- ------------------------------------------------------------------------
    m as (
        -- ESSBASE_EXTRACT
        select ''FIN_GL_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 3, ''AMT'', sum(iff(lower(trim(m.dt)) = ''non-currency'', 0, coalesce(e.actual_amount, 0) + coalesce(e.forecast_amount, 0) + coalesce(e.budget_amount, 0))), ''STAT'', sum(iff(lower(trim(m.dt)) = ''non-currency'', coalesce(e.actual_amount, 0) + coalesce(e.forecast_amount, 0) + coalesce(e.budget_amount, 0), 0))) o
        from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_FIN_GL_MONTHLY e
        left join (select account, min(data_type) dt from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ACCOUNT group by account) m on m.account = e.account
        union all
        select ''FIN_GL_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0))
        from __DB__.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
        union all
        -- facts in XFRM, four H1-routed streams, by source table
        select split_part(source_table, ''CLN_INVITED_CLUBS_'', 2), ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', sum(source_amount), ''STAT'', sum(stat_value))
        from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN)
        group by source_table
        union all
        -- facts in SEM, six tables, this lane, by source table
        select split_part(source_table, ''CLN_INVITED_CLUBS_'', 2), ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', sum(source_amount), ''STAT'', sum(stat_value))
        from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN)
        where source_lane = ''INVITED_CLUBS''
        group by source_table
        union all
        -- dictionary ACCOUNTS
        select ''REF_ACCOUNTS'', ''CLN'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_ACCOUNTS
        union all
        select ''REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from __DB__.STAGING.STG_INVITED_CLUBS_ACCOUNTS
        union all
        -- dictionary META_ACCOUNT
        select ''REF_HIERARCHY_ACCOUNT'', ''CLN'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ACCOUNT
        union all
        select ''REF_HIERARCHY_ACCOUNT'', ''STG'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from __DB__.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
        union all
        -- dictionary META_DEPARTMENT
        select ''REF_HIERARCHY_DEPARTMENT'', ''CLN'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_DEPARTMENT
        union all
        select ''REF_HIERARCHY_DEPARTMENT'', ''STG'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from __DB__.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
        union all
        -- dictionary META_ENTITY
        select ''REF_HIERARCHY_ENTITY'', ''CLN'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_ENTITY
        union all
        select ''REF_HIERARCHY_ENTITY'', ''STG'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from __DB__.STAGING.STG_INVITED_CLUBS_META_ENTITY
        union all
        -- dictionary META_LOCATION
        select ''REF_HIERARCHY_LOCATION'', ''CLN'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_LOCATION
        union all
        select ''REF_HIERARCHY_LOCATION'', ''STG'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from __DB__.STAGING.STG_INVITED_CLUBS_META_LOCATION
        union all
        -- dictionary META_SUBACCOUNT
        select ''REF_HIERARCHY_SUBACCOUNT'', ''CLN'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_REF_HIERARCHY_SUBACCOUNT
        union all
        select ''REF_HIERARCHY_SUBACCOUNT'', ''STG'', object_construct(''ROWS'', count(*), ''SOURCE_ROW_NUMBER'', sum(source_row_number)) from __DB__.STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT
    )
    -- ------------------------------------------------------------------------
    -- one row per table per metric, layers side by side
    -- ------------------------------------------------------------------------
    , r as (
        select
              m.t                                        as source_table
            , f.key::varchar                             as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''INVITED_CLUBS'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''INVITED_CLUBS'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- JW_VENICE
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''CLN_JW_VENICE_FCAST_ACT_FORECAST'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2, ''TOTAL'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY where source_object = ''REPORT_CELLS: JW_VENICE_FCAST_ACT_FORECAST''
        union all
        select ''CLN_JW_VENICE_FCAST_ACT_FORECAST'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
        union all
        select ''CLN_JW_VENICE_FCAST_ACT_FORECAST'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY'' and (source_line_key) in (select source_line_key from __DB__.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST)
        union all
        select ''CLN_JW_VENICE_FCAST_ACT_FORECAST'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''JW_VENICE'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY'' and (source_line_key) in (select source_line_key from __DB__.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST)
        union all
        select ''CLN_JW_VENICE_FCAST_BY_PERIOD'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2, ''TOTAL'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY where source_object = ''REPORT_CELLS: JW_VENICE_FCAST_BY_PERIOD''
        union all
        select ''CLN_JW_VENICE_FCAST_BY_PERIOD'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
        union all
        select ''CLN_JW_VENICE_FCAST_BY_PERIOD'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_line_key, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY'' and (source_line_key) in (select source_line_key from __DB__.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD)
        union all
        select ''CLN_JW_VENICE_FCAST_BY_PERIOD'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_line_key, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''JW_VENICE'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_SUMMARY'' and (source_line_key) in (select source_line_key from __DB__.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD)
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_FTE'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 4, ''TOTAL'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)+coalesce(sum(previous_forecast_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_FTE
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_FTE'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_JW_VENICE_FTE
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_FTE'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_FTE''
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_FTE'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''JW_VENICE'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_FTE''
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_HEADCOUNT'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 4, ''TOTAL'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)+coalesce(sum(previous_forecast_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_HEADCOUNT
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_HEADCOUNT'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_JW_VENICE_HEADCOUNT
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_HEADCOUNT'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_HEADCOUNT''
        union all
        select ''CLN_JW_VENICE_OPS_LABOR_HEADCOUNT'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''JW_VENICE'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_OPS_LABOR_HEADCOUNT''
        union all
        select ''CLN_JW_VENICE_FIN_PL_DEPARTMENT'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 2, ''TOTAL'', coalesce(sum(actual_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_DEPARTMENT
        union all
        select ''CLN_JW_VENICE_FIN_PL_DEPARTMENT'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT
        union all
        select ''CLN_JW_VENICE_FIN_PL_DEPARTMENT'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_DEPARTMENT''
        union all
        select ''CLN_JW_VENICE_FIN_PL_DEPARTMENT'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''JW_VENICE'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FIN_PL_DEPARTMENT''
        union all
        select ''CLN_JW_VENICE_REF_ACCOUNTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_REF_ACCOUNTS
        union all
        select ''CLN_JW_VENICE_REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_JW_VENICE_ACCOUNTS
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''JW_VENICE'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''JW_VENICE'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- NEWBURY
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 3, ''TOTAL'', coalesce(sum(actual_amount),0)+coalesce(sum(forecast_amount),0)+coalesce(sum(budget_amount),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY
        union all
        select ''CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_NEWBURY_TRIAL_BALANCE
        union all
        select ''CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY''
        union all
        select ''CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY'', ''SEM'', object_construct(''ROWS'', count(*), ''TOTAL'', coalesce(sum(source_amount),0)+coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''NEWBURY'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_FIN_PL_MONTHLY''
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''AMT'', coalesce(sum(revenue),0), ''STAT'', coalesce(sum(rooms),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET''
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''NEWBURY'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_BUDGET''
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL'' t, ''CLN'' l, object_construct(''ROWS'', count(*) * 1, ''AMT'', coalesce(sum(revenue),0), ''STAT'', coalesce(sum(rooms),0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from __DB__.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL'', ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN) where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL''
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL'', ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount),0), ''STAT'', coalesce(sum(stat_value),0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''NEWBURY'' and source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_ACTUAL''
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST'', ''STG'', object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_NEWBURY_OPERATING_STATS_FCST
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST'', ''XFRM'', object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_STATS_DAILY_FORECAST''
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''RATE_VALUE'', coalesce(sum(rate_value), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS'', ''STG'', object_construct(''ROWS'', count(*), ''RATE_VALUE'', coalesce(sum(rate_value), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS'', ''XFRM'', object_construct(''ROWS'', count(*), ''RATE_VALUE'', coalesce(sum(rate_value), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS''
        union all
        select ''CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''AVAILABLE_ROOMS'', coalesce(sum(available_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY
        union all
        select ''CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY'', ''STG'', object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''AVAILABLE_ROOMS'', coalesce(sum(available_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_NEWBURY_OTB_1DAY_PICKUP
        union all
        select ''CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY'', ''XFRM'', object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''AVAILABLE_ROOMS'', coalesce(sum(available_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_1DAY''
        union all
        select ''CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''AVAILABLE_ROOMS'', coalesce(sum(available_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY
        union all
        select ''CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY'', ''STG'', object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''AVAILABLE_ROOMS'', coalesce(sum(available_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP
        union all
        select ''CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY'', ''XFRM'', object_construct(''ROWS'', count(*), ''ROOMS'', coalesce(sum(rooms), 0), ''REVENUE'', coalesce(sum(revenue), 0), ''AVAILABLE_ROOMS'', coalesce(sum(available_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_NEWBURY_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_PACE_OTB_DAILY_PICKUP_3DAY''
        union all
        select ''CLN_NEWBURY_BOSTON_REF_ACCOUNTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_REF_ACCOUNTS
        union all
        select ''CLN_NEWBURY_BOSTON_REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_NEWBURY_ACCOUNTS
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO'' t, ''CLN'' l, object_construct(''ROWS'', count(*)) o from CLN.BOX_INVESTMENT_DATA.CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO
        union all
        select ''CLN_NEWBURY_BOSTON_OPS_EVENTS_OOO'', ''STG'', object_construct(''ROWS'', count(*)) from __DB__.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''NEWBURY'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''NEWBURY'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- OUTRIGGER
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''OUTRIGGER_PACE'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''CY_PACE_OCCUPANCY'', coalesce(sum(cy_pace_occupancy), 0), ''CY_PACE_ROOMS'', coalesce(sum(cy_pace_rooms), 0), ''CY_PACE_ADR'', coalesce(sum(cy_pace_adr), 0), ''CY_PACE_REVENUE'', coalesce(sum(cy_pace_revenue), 0), ''LY_PACE_OCCUPANCY'', coalesce(sum(ly_pace_occupancy), 0), ''LY_PACE_ROOMS'', coalesce(sum(ly_pace_rooms), 0), ''LY_PACE_ADR'', coalesce(sum(ly_pace_adr), 0), ''LY_PACE_REVENUE'', coalesce(sum(ly_pace_revenue), 0), ''FORECAST_OCCUPANCY'', coalesce(sum(forecast_occupancy), 0), ''FORECAST_ROOMS'', coalesce(sum(forecast_rooms), 0), ''FORECAST_ADR'', coalesce(sum(forecast_adr), 0), ''FORECAST_REVENUE'', coalesce(sum(forecast_revenue), 0), ''BUDGET_OCCUPANCY'', coalesce(sum(budget_occupancy), 0), ''BUDGET_ROOMS'', coalesce(sum(budget_rooms), 0), ''BUDGET_ADR'', coalesce(sum(budget_adr), 0), ''BUDGET_REVENUE'', coalesce(sum(budget_revenue), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY
        union all
        select ''OUTRIGGER_PACE'', ''STG'', object_construct(''ROWS'', count(*), ''CY_PACE_OCCUPANCY'', coalesce(sum(cy_pace_occupancy), 0), ''CY_PACE_ROOMS'', coalesce(sum(cy_pace_rooms), 0), ''CY_PACE_ADR'', coalesce(sum(cy_pace_adr), 0), ''CY_PACE_REVENUE'', coalesce(sum(cy_pace_revenue), 0), ''LY_PACE_OCCUPANCY'', coalesce(sum(ly_pace_occupancy), 0), ''LY_PACE_ROOMS'', coalesce(sum(ly_pace_rooms), 0), ''LY_PACE_ADR'', coalesce(sum(ly_pace_adr), 0), ''LY_PACE_REVENUE'', coalesce(sum(ly_pace_revenue), 0), ''FORECAST_OCCUPANCY'', coalesce(sum(forecast_occupancy), 0), ''FORECAST_ROOMS'', coalesce(sum(forecast_rooms), 0), ''FORECAST_ADR'', coalesce(sum(forecast_adr), 0), ''FORECAST_REVENUE'', coalesce(sum(forecast_revenue), 0), ''BUDGET_OCCUPANCY'', coalesce(sum(budget_occupancy), 0), ''BUDGET_ROOMS'', coalesce(sum(budget_rooms), 0), ''BUDGET_ADR'', coalesce(sum(budget_adr), 0), ''BUDGET_REVENUE'', coalesce(sum(budget_revenue), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_OUTRIGGER_PACE
        union all
        select ''OUTRIGGER_PACE'', ''XFRM'', object_construct(''ROWS'', count(*), ''CY_PACE_OCCUPANCY'', coalesce(sum(cy_pace_occupancy), 0), ''CY_PACE_ROOMS'', coalesce(sum(cy_pace_rooms), 0), ''CY_PACE_ADR'', coalesce(sum(cy_pace_adr), 0), ''CY_PACE_REVENUE'', coalesce(sum(cy_pace_revenue), 0), ''LY_PACE_OCCUPANCY'', coalesce(sum(ly_pace_occupancy), 0), ''LY_PACE_ROOMS'', coalesce(sum(ly_pace_rooms), 0), ''LY_PACE_ADR'', coalesce(sum(ly_pace_adr), 0), ''LY_PACE_REVENUE'', coalesce(sum(ly_pace_revenue), 0), ''FORECAST_OCCUPANCY'', coalesce(sum(forecast_occupancy), 0), ''FORECAST_ROOMS'', coalesce(sum(forecast_rooms), 0), ''FORECAST_ADR'', coalesce(sum(forecast_adr), 0), ''FORECAST_REVENUE'', coalesce(sum(forecast_revenue), 0), ''BUDGET_OCCUPANCY'', coalesce(sum(budget_occupancy), 0), ''BUDGET_ROOMS'', coalesce(sum(budget_rooms), 0), ''BUDGET_ADR'', coalesce(sum(budget_adr), 0), ''BUDGET_REVENUE'', coalesce(sum(budget_revenue), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_OUTRIGGER_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE_OTB_MONTHLY''
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''OUTRIGGER'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''OUTRIGGER'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- THE_PIG
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''PIG_HOTELS_PACE_THIS_YEAR'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_rooms_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_pickup_7_day_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_pickup_7_day_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_pickup_7_day_change), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY where pace_year = ''THIS_YEAR''
        union all
        select ''PIG_HOTELS_PACE_THIS_YEAR'', ''STG'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_rooms_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_pickup_7_day_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_pickup_7_day_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_pickup_7_day_change), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_THE_PIG_PACE_THIS_YEAR
        union all
        select ''PIG_HOTELS_PACE_THIS_YEAR'', ''XFRM'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_rooms_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_pickup_7_day_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_pickup_7_day_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_pickup_7_day_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_pickup_7_day_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_pickup_7_day_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_pickup_7_day_change), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_THE_PIG_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY'' and (source_file_path, source_row_number) in (select source_file_path, source_row_number from __DB__.STAGING.STG_THE_PIG_PACE_THIS_YEAR)
        union all
        select ''PIG_HOTELS_PACE_NEXT_YEAR'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_change), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY where pace_year = ''NEXT_YEAR''
        union all
        select ''PIG_HOTELS_PACE_NEXT_YEAR'', ''STG'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_change), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_THE_PIG_PACE_NEXT_YEAR
        union all
        select ''PIG_HOTELS_PACE_NEXT_YEAR'', ''XFRM'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_rooms_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_rooms_commit_change), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_stly_date_room_revenue_commit_diff), 0), ''TODAY_VS_STLY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_stly_date_room_revenue_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_rooms_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_rooms_commit_change), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_diff), 0), ''TODAY_VS_FINAL_LY_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_final_ly_date_room_revenue_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_rooms_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOMS_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_rooms_commit_change), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_DIFF'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_diff), 0), ''TODAY_VS_ST2Y_DATE_ROOM_REVENUE_COMMIT_CHANGE'', coalesce(sum(today_vs_st2y_date_room_revenue_commit_change), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_THE_PIG_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_OTB_MONTHLY'' and (source_file_path, source_row_number) in (select source_file_path, source_row_number from __DB__.STAGING.STG_THE_PIG_PACE_NEXT_YEAR)
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''THE_PIG'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''THE_PIG'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- UNDER_CANVAS
    -- ------------------------------------------------------------------------
    v_sql := replace('with
    m as (
        select ''FIN_GL_DETAIL_REVENUE'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(actual_amount), 0), ''STAT'', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_REVENUE
        union all
        select ''FIN_GL_DETAIL_REVENUE'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE
        union all
        select ''FIN_GL_DETAIL_OPEX'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(actual_amount), 0), ''STAT'', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_OPEX
        union all
        select ''FIN_GL_DETAIL_OPEX'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES
        union all
        select ''FIN_GL_DETAIL_NON_OPEX'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(actual_amount), 0), ''STAT'', 0) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_GL_DETAIL_NON_OPEX
        union all
        select ''FIN_GL_DETAIL_NON_OPEX'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES
        union all
        select ''OPS_STATS_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''AMT'', 0, ''STAT'', coalesce(sum(actual_amount), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_OPS_STATS_MONTHLY
        union all
        select ''OPS_STATS_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS
        union all
        select ''FIN_PL_SUMMARY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(iff(line_item in (''Days Open'', ''# of Tents/Rooms'', ''Rooms Available'', ''Rooms Sold'', ''Occupancy %'', ''Average Daily Rate'', ''Revenue per Available Room'', ''Operating CPORs'', ''Non-Operating CPORs'', ''Adjusted GOP %'', ''Adjusted EBITDA Margin %''), 0, actual_amount)), 0), ''STAT'', coalesce(sum(iff(line_item in (''Days Open'', ''# of Tents/Rooms'', ''Rooms Available'', ''Rooms Sold'', ''Occupancy %'', ''Average Daily Rate'', ''Revenue per Available Room'', ''Operating CPORs'', ''Non-Operating CPORs'', ''Adjusted GOP %'', ''Adjusted EBITDA Margin %''), actual_amount, 0)), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_FIN_PL_SUMMARY
        union all
        select ''FIN_PL_SUMMARY'', ''STG'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL
        union all
        select split_part(source_table, ''CLN_UNDER_CANVAS_'', 2), ''XFRM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS union all select source_table, source_amount, stat_value from __DB__.TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN) group by source_table
        union all
        select split_part(source_table, ''CLN_UNDER_CANVAS_'', 2), ''SEM'', object_construct(''ROWS'', count(*), ''AMT'', coalesce(sum(source_amount), 0), ''STAT'', coalesce(sum(stat_value), 0)) from (select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_BALANCE_SHEET union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_OPERATING_METRICS union all select source_lane, source_table, source_amount, stat_value from __DB__.SEMANTIC.SEM_AI_UNKNOWN) where source_lane = ''UNDER_CANVAS'' group by source_table
        union all
        select ''PACE_OTB_WEEKLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_rooms_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY
        union all
        select ''PACE_OTB_WEEKLY'', ''STG'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_rooms_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_WEEKLY_PACE
        union all
        select ''PACE_OTB_WEEKLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_rooms_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_rooms_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_rooms_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOMS_COMMIT'', coalesce(sum(st2y_date_rooms_commit), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(st2y_date_room_revenue_commit), 0), ''ST2Y_DATE_ROOMS_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_rooms_commit_pickup_7_day), 0), ''ST2Y_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(st2y_date_room_revenue_commit_pickup_7_day), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_WEEKLY''
        union all
        select ''PACE_OTB_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(today_room_revenue_commit_pickup_28_day), 0), ''STLY_DOW_ROOMS_COMMIT'', coalesce(sum(stly_dow_rooms_commit), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_dow_room_revenue_commit), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_dow_room_revenue_commit_pickup_7_day), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(stly_dow_room_revenue_commit_pickup_28_day), 0), ''FINAL_LY_DOW_ROOMS_COMMIT'', coalesce(sum(final_ly_dow_rooms_commit), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_dow_room_revenue_commit), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_28_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_28_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_28_day), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY
        union all
        select ''PACE_OTB_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(today_room_revenue_commit_pickup_28_day), 0), ''STLY_DOW_ROOMS_COMMIT'', coalesce(sum(stly_dow_rooms_commit), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_dow_room_revenue_commit), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_dow_room_revenue_commit_pickup_7_day), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(stly_dow_room_revenue_commit_pickup_28_day), 0), ''FINAL_LY_DOW_ROOMS_COMMIT'', coalesce(sum(final_ly_dow_rooms_commit), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_dow_room_revenue_commit), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_28_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_28_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_28_day), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_DUETTO_DATA
        union all
        select ''PACE_OTB_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''TODAY_ROOMS_COMMIT'', coalesce(sum(today_rooms_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT'', coalesce(sum(today_room_revenue_commit), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(today_room_revenue_commit_pickup_7_day), 0), ''TODAY_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(today_room_revenue_commit_pickup_28_day), 0), ''STLY_DOW_ROOMS_COMMIT'', coalesce(sum(stly_dow_rooms_commit), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_dow_room_revenue_commit), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_dow_room_revenue_commit_pickup_7_day), 0), ''STLY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(stly_dow_room_revenue_commit_pickup_28_day), 0), ''FINAL_LY_DOW_ROOMS_COMMIT'', coalesce(sum(final_ly_dow_rooms_commit), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_dow_room_revenue_commit), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DOW_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(final_ly_dow_room_revenue_commit_pickup_28_day), 0), ''STLY_DATE_ROOMS_COMMIT'', coalesce(sum(stly_date_rooms_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(stly_date_room_revenue_commit), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_7_day), 0), ''STLY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(stly_date_room_revenue_commit_pickup_28_day), 0), ''FINAL_LY_DATE_ROOMS_COMMIT'', coalesce(sum(final_ly_date_rooms_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT'', coalesce(sum(final_ly_date_room_revenue_commit), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_7_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_7_day), 0), ''FINAL_LY_DATE_ROOM_REVENUE_COMMIT_PICKUP_28_DAY'', coalesce(sum(final_ly_date_room_revenue_commit_pickup_28_day), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_OTB_MONTHLY''
        union all
        select ''PACE_CANCELLATIONS_MONTHLY'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''TODAY_CANCELED_REVENUE'', coalesce(sum(today_canceled_revenue), 0), ''TODAY_CANCELED_ROOMS'', coalesce(sum(today_canceled_rooms), 0), ''STLY_CANCELED_REVENUE'', coalesce(sum(stly_canceled_revenue), 0), ''STLY_CANCELED_ROOMS'', coalesce(sum(stly_canceled_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY
        union all
        select ''PACE_CANCELLATIONS_MONTHLY'', ''STG'', object_construct(''ROWS'', count(*), ''TODAY_CANCELED_REVENUE'', coalesce(sum(today_canceled_revenue), 0), ''TODAY_CANCELED_ROOMS'', coalesce(sum(today_canceled_rooms), 0), ''STLY_CANCELED_REVENUE'', coalesce(sum(stly_canceled_revenue), 0), ''STLY_CANCELED_ROOMS'', coalesce(sum(stly_canceled_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.STAGING.STG_UNDER_CANVAS_CANCELLATIONS
        union all
        select ''PACE_CANCELLATIONS_MONTHLY'', ''XFRM'', object_construct(''ROWS'', count(*), ''TODAY_CANCELED_REVENUE'', coalesce(sum(today_canceled_revenue), 0), ''TODAY_CANCELED_ROOMS'', coalesce(sum(today_canceled_rooms), 0), ''STLY_CANCELED_REVENUE'', coalesce(sum(stly_canceled_revenue), 0), ''STLY_CANCELED_ROOMS'', coalesce(sum(stly_canceled_rooms), 0), ''SOURCE_ROW_NUMBER'', coalesce(sum(source_row_number), 0)) from __DB__.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING where source_table = ''CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_PACE_CANCELLATIONS_MONTHLY''
        union all
        select ''REF_ACCOUNTS'' t, ''CLN'' l, object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) o from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_REF_ACCOUNTS
        union all
        select ''REF_ACCOUNTS'', ''STG'', object_construct(''ROWS'', count(*), ''ROW_COUNT'', sum(row_count)) from __DB__.STAGING.STG_UNDER_CANVAS_ACCOUNTS
    )
    , r as (
        select
              m.t                                          as source_table
            , f.key::varchar                               as metric
            , max(iff(m.l = ''CLN'',  f.value::float, null)) as cln
            , max(iff(m.l = ''STG'',  f.value::float, null)) as stg
            , max(iff(m.l = ''XFRM'', f.value::float, null)) as xfrm
            , max(iff(m.l = ''SEM'',  f.value::float, null)) as sem
        from m, lateral flatten(input => m.o) f
        group by 1, 2
    )
    , chk as (
        select
              r.*
            , case
                  when cln is null                                    then ''FAIL''
                  when stg  is null or abs(stg  - cln) > 0.005        then ''FAIL''
                  when xfrm is not null and abs(xfrm - cln) > 0.005   then ''FAIL''
                  when sem  is not null and abs(sem  - cln) > 0.005   then ''FAIL''
                  else ''PASS''
              end as status
        from r
    )
    select ''UNDER_CANVAS'' as lane, source_table, metric, cln, stg, xfrm, sem, status
    from chk
    union all
    select ''UNDER_CANVAS'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null
         , iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'')
    from chk
    order by source_table = ''TOTAL'', source_table, metric', '__DB__', :v_db);
    res := (execute immediate :v_sql);
    v_ids := array_append(v_ids, sqlid);
    -- ------------------------------------------------------------------------
    -- union of the lane results, then the single total
    -- ------------------------------------------------------------------------
    for i in 0 to array_size(:v_ids) - 1 do
        v_fin := v_fin || iff(i = 0, '', ' union all ') || 'select lane, source_table, metric, cln, stg, xfrm, sem, status from table(result_scan(''' || v_ids[i]::varchar || '''))';
    end for;
    v_sql := 'with a as (' || v_fin || ') '
          || 'select lane, source_table, metric, cln, stg, xfrm, sem, status from a where source_table <> ''TOTAL'' '
          || 'union all '
          || 'select ''ALL'', ''TOTAL'', ''FAILURES'', count_if(status = ''FAIL''), null, null, null, iff(count_if(status = ''FAIL'') = 0, ''PASS'', ''FAIL'') from a where source_table <> ''TOTAL'' '
          || 'order by source_table = ''TOTAL'', lane, source_table, metric';
    res := (execute immediate :v_sql);
    return table(res);
end;
$$
