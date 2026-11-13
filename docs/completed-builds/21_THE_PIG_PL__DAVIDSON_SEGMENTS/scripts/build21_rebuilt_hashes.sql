-- scripts/build21_rebuilt_hashes.sql (build 21 A/B): every object of THE_PIG and DAVIDSON, RUN_ID excluded. One statement per lane. Read-only.
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
