-- scripts/build15_q09_jw_hashes.sql (build 15, Q-09 re-run): every JW_VENICE object, 18 objects.
select 'STAGING.STG_JW_VENICE_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_ACCOUNTS
union all
select 'STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_ACT_FORECAST
union all
select 'STAGING.STG_JW_VENICE_FCAST_BY_PERIOD' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_FCAST_BY_PERIOD
union all
select 'STAGING.STG_JW_VENICE_FTE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_FTE
union all
select 'STAGING.STG_JW_VENICE_HEADCOUNT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_HEADCOUNT
union all
select 'STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_JW_VENICE_MONTHLY_PL_DEPT
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING
union all
select 'TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN JW_VENICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'JW_VENICE';
