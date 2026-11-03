-- ============================================================================
-- scripts/build11_hashes.sql  (build 11, check 5)
-- Row count and full content hash (RUN_ID, or LAST_SEEN_RUN_ID, excluded) of
-- every object of this build's lanes ALTERRA, ATLANTIC_AVIATION, JW_VENICE:
-- 10 staging tables, 3 classification slices, 15 transformation tables and 18
-- semantic slices. 46 objects.
-- ============================================================================
select 'STAGING.STG_ALTERRA_MONTHLY_FINANCIALS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS
union all
select 'STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH
union all
select 'STAGING.STG_ALTERRA_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_ALTERRA_ACCOUNTS
union all
select 'STAGING.STG_ATLANTIC_AVIATION_OC_DATA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_OC_DATA
union all
select 'STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS
union all
select 'STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
union all
select 'STAGING.STG_JW_VENICE_FCAST_BY_PERIOD' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
union all
select 'STAGING.STG_JW_VENICE_FTE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_FTE
union all
select 'STAGING.STG_JW_VENICE_HEADCOUNT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT
union all
select 'STAGING.STG_JW_VENICE_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_ACCOUNTS
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'ALTERRA'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'ATLANTIC_AVIATION'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'JW_VENICE'
union all
select 'TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_ALTERRA_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_PACING
union all
select 'TRANSFORMATION.XFRM_ALTERRA_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'JW_VENICE';
