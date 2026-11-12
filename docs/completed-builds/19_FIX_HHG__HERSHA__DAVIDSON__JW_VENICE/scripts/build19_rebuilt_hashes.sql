-- scripts/build19_rebuilt_hashes.sql (build 19 A/B determinism): every object of the 4 rebuilt lanes, RUN_ID excluded. One statement per lane. Read-only.
select 'STAGING.STG_HHG_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_ACCOUNTS
union all
select 'STAGING.STG_HHG_ASSET_CODES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_ASSET_CODES
union all
select 'STAGING.STG_HHG_BUDGET_BY_CLUB' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_BUDGET_BY_CLUB
union all
select 'STAGING.STG_HHG_CHART_OF_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_CHART_OF_ACCOUNTS
union all
select 'STAGING.STG_HHG_CLUB_LIST' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_CLUB_LIST
union all
select 'STAGING.STG_HHG_DEPARTMENT_KEY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_DEPARTMENT_KEY
union all
select 'STAGING.STG_HHG_FORECAST_ANAPLAN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN
union all
select 'STAGING.STG_HHG_MEMBERSHIP_MONTHLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_MEMBERSHIP_MONTHLY
union all
select 'STAGING.STG_HHG_REFERENCES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_REFERENCES
union all
select 'STAGING.STG_HHG_ROUNDS_DETAIL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL
union all
select 'STAGING.STG_HHG_TR12_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_TR12_ACCOUNTS
union all
select 'STAGING.STG_HHG_TR12_DATA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA
union all
select 'TRANSFORMATION.XFRM_HHG_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HHG_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HHG_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_PACING
union all
select 'TRANSFORMATION.XFRM_HHG_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_PACING HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='HHG'
union all
select 'XREF HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HHG'
;
select 'STAGING.STG_HERSHA_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HERSHA_ACCOUNTS
union all
select 'STAGING.STG_HERSHA_GL_ACTUAL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HERSHA_GL_ACTUAL
union all
select 'STAGING.STG_HERSHA_GL_STAT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HERSHA_GL_STAT
union all
select 'STAGING.STG_HERSHA_TB_ACTUAL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HERSHA_TB_ACTUAL
union all
select 'TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HERSHA_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_PACING
union all
select 'TRANSFORMATION.XFRM_HERSHA_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_PACING HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='HERSHA'
union all
select 'XREF HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HERSHA'
;
select 'STAGING.STG_DAVIDSON_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNTS
union all
select 'STAGING.STG_DAVIDSON_FULL_YEAR_PL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_FULL_YEAR_PL
union all
select 'STAGING.STG_DAVIDSON_HOTEL_BUDGET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_BUDGET
union all
select 'STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_PACING
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_PACING DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='DAVIDSON'
union all
select 'XREF DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='DAVIDSON'
;
select 'STAGING.STG_JW_VENICE_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_ACCOUNTS
union all
select 'STAGING.STG_JW_VENICE_CAPEX' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_CAPEX
union all
select 'STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
union all
select 'STAGING.STG_JW_VENICE_FCAST_BY_PERIOD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
union all
select 'STAGING.STG_JW_VENICE_FTE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_FTE
union all
select 'STAGING.STG_JW_VENICE_HEADCOUNT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT
union all
select 'STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT
union all
select 'STAGING.STG_JW_VENICE_PACE_OTB_DAILY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_PACE_OTB_DAILY
union all
select 'STAGING.STG_JW_VENICE_PACE_SEGMENT_MONTHLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_JW_VENICE_PACE_SEGMENT_MONTHLY
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_PACING JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='JW_VENICE'
union all
select 'XREF JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='JW_VENICE'
;
