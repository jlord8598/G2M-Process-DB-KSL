-- ============================================================================
-- scripts/build14_hashes.sql  (build 14, check 5)
-- Every object of the new lanes UNDER_CANVAS, THE_PIG, OUTRIGGER. Staging
-- (12 tables) from M3; classification, transformation and semantic objects are
-- appended at M4-M6. content_hash = rest_hash (no earlier state to diff).
-- ============================================================================
select 'STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE
union all
select 'STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES
union all
select 'STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES
union all
select 'STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS
union all
select 'STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL
union all
select 'STAGING.STG_UNDER_CANVAS_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_ACCOUNTS
union all
select 'STAGING.STG_UNDER_CANVAS_WEEKLY_PACE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_WEEKLY_PACE
union all
select 'STAGING.STG_UNDER_CANVAS_DUETTO_DATA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_DUETTO_DATA
union all
select 'STAGING.STG_UNDER_CANVAS_CANCELLATIONS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CANCELLATIONS
union all
select 'STAGING.STG_THE_PIG_PACE_THIS_YEAR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_THIS_YEAR
union all
select 'STAGING.STG_THE_PIG_PACE_NEXT_YEAR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_NEXT_YEAR
union all
select 'STAGING.STG_OUTRIGGER_PACE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_OUTRIGGER_PACE
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'UNDER_CANVAS'
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_THE_PIG_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_PACING
union all
select 'TRANSFORMATION.XFRM_THE_PIG_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'UNDER_CANVAS';
