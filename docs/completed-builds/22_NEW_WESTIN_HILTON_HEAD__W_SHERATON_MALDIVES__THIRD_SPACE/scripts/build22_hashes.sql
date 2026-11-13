-- scripts/build22_hashes.sql (build 22 proof): every object of the 14 existing lanes (build 22 only adds lanes). One statement per lane. Read-only.
select 'STAGING.STG_ALTERRA_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_ALTERRA_ACCOUNTS
union all
select 'STAGING.STG_ALTERRA_MONTHLY_FINANCIALS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS
union all
select 'STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH
union all
select 'TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_ALTERRA_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_PACING
union all
select 'TRANSFORMATION.XFRM_ALTERRA_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_PACING ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='ALTERRA'
union all
select 'XREF ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='ALTERRA'
;
select 'STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS
union all
select 'STAGING.STG_ATLANTIC_AVIATION_OC_DATA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_OC_DATA
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_PACING ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='ATLANTIC_AVIATION'
union all
select 'XREF ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='ATLANTIC_AVIATION'
;
select 'STAGING.STG_BEAUMIER_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS
union all
select 'STAGING.STG_BEAUMIER_BP' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
union all
select 'STAGING.STG_BEAUMIER_BUDGET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
union all
select 'STAGING.STG_BEAUMIER_CANCELLATIONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
union all
select 'STAGING.STG_BEAUMIER_HIERARCHY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_HIERARCHY
union all
select 'STAGING.STG_BEAUMIER_LOCATION_MAP' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_PACING
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_PACING BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='BEAUMIER'
union all
select 'XREF BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='BEAUMIER'
;
select 'STAGING.STG_DAVIDSON_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNTS
union all
select 'STAGING.STG_DAVIDSON_ACCOUNT_MAPPING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNT_MAPPING
union all
select 'STAGING.STG_DAVIDSON_CHART_OF_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_CHART_OF_ACCOUNTS
union all
select 'STAGING.STG_DAVIDSON_DEPARTMENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_DEPARTMENTS
union all
select 'STAGING.STG_DAVIDSON_FULL_YEAR_PL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_FULL_YEAR_PL
union all
select 'STAGING.STG_DAVIDSON_HOTEL_BUDGET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_BUDGET
union all
select 'STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT
union all
select 'STAGING.STG_DAVIDSON_LABOR_TYPES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_LABOR_TYPES
union all
select 'STAGING.STG_DAVIDSON_REVENUE_CATEGORIES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_REVENUE_CATEGORIES
union all
select 'STAGING.STG_DAVIDSON_SALES_ITEMS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_SALES_ITEMS
union all
select 'STAGING.STG_DAVIDSON_SPEND_CATEGORIES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_DAVIDSON_SPEND_CATEGORIES
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
select 'STAGING.STG_INVITED_CLUBS_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ACCOUNTS
union all
select 'STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
union all
select 'STAGING.STG_INVITED_CLUBS_META_ACCOUNT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
union all
select 'STAGING.STG_INVITED_CLUBS_META_DEPARTMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
union all
select 'STAGING.STG_INVITED_CLUBS_META_ENTITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY
union all
select 'STAGING.STG_INVITED_CLUBS_META_LOCATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_LOCATION
union all
select 'STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_PACING
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_PACING INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='INVITED_CLUBS'
union all
select 'XREF INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='INVITED_CLUBS'
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
select 'STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_COA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_COA
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DATASETS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DATASETS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_PACING KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='KSL_SELECT_SERVICE'
union all
select 'XREF KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='KSL_SELECT_SERVICE'
;
select 'STAGING.STG_NEWBURY_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_ACCOUNTS
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_BGT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_FCST' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_PYACT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS
union all
select 'STAGING.STG_NEWBURY_OTB_1DAY_PICKUP' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_1DAY_PICKUP
union all
select 'STAGING.STG_NEWBURY_OTB_3DAY_PICKUP' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP
union all
select 'STAGING.STG_NEWBURY_TRIAL_BALANCE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
union all
select 'TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_NEWBURY_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING
union all
select 'TRANSFORMATION.XFRM_NEWBURY_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_PACING NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='NEWBURY'
union all
select 'XREF NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='NEWBURY'
;
select 'STAGING.STG_OUTRIGGER_PACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_OUTRIGGER_PACE
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_PACING OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='OUTRIGGER'
union all
select 'XREF OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='OUTRIGGER'
;
select 'STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_COA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_COA
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DATASETS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DATASETS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_PACING PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='PEREGRINE_RESORTS'
union all
select 'XREF PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='PEREGRINE_RESORTS'
;
select 'STAGING.STG_THE_PIG_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_THE_PIG_ACCOUNTS
union all
select 'STAGING.STG_THE_PIG_PACE_NEXT_YEAR' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_NEXT_YEAR
union all
select 'STAGING.STG_THE_PIG_PACE_THIS_YEAR' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_THIS_YEAR
union all
select 'STAGING.STG_THE_PIG_PL_MONTHLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_THE_PIG_PL_MONTHLY
union all
select 'TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_THE_PIG_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_PACING
union all
select 'TRANSFORMATION.XFRM_THE_PIG_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_PACING THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='THE_PIG'
union all
select 'XREF THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='THE_PIG'
;
select 'STAGING.STG_UNDER_CANVAS_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_ACCOUNTS
union all
select 'STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES
union all
select 'STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES
union all
select 'STAGING.STG_UNDER_CANVAS_CANCELLATIONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CANCELLATIONS
union all
select 'STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL
union all
select 'STAGING.STG_UNDER_CANVAS_DUETTO_DATA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_DUETTO_DATA
union all
select 'STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS
union all
select 'STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE
union all
select 'STAGING.STG_UNDER_CANVAS_WEEKLY_PACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_WEEKLY_PACE
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_PACING UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='UNDER_CANVAS'
union all
select 'XREF UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='UNDER_CANVAS'
;
