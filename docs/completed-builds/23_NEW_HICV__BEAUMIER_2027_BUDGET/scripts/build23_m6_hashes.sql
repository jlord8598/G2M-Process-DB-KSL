-- scripts/build23_m6_hashes.sql (build 23): check 5, every HICV and BEAUMIER object (staging, streams, their semantic rows, their classification rows), RUN_ID (LAST_SEEN_RUN_ID on the classification table) excluded. Read-only.
select 'STAGING.STG_HICV_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HICV_ACCOUNTS
union all
select 'STAGING.STG_HICV_ROOM_KEYS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HICV_ROOM_KEYS
union all
select 'STAGING.STG_HICV_PL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HICV_PL
union all
select 'STAGING.STG_HICV_GL' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HICV_GL
union all
select 'STAGING.STG_HICV_KPI_WEEKLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HICV_KPI_WEEKLY
union all
select 'STAGING.STG_HICV_TREND_WEEKLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HICV_TREND_WEEKLY
union all
select 'STAGING.STG_HICV_RESERVATIONS_WEEKLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HICV_RESERVATIONS_WEEKLY
union all
select 'STAGING.STG_BEAUMIER_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS
union all
select 'STAGING.STG_BEAUMIER_LOCATION_MAP' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP
union all
select 'STAGING.STG_BEAUMIER_HIERARCHY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_HIERARCHY
union all
select 'STAGING.STG_BEAUMIER_CANCELLATIONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
union all
select 'STAGING.STG_BEAUMIER_BP' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
union all
select 'STAGING.STG_BEAUMIER_BUDGET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
union all
select 'STAGING.STG_BEAUMIER_BUDGET_USALI' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET_USALI
union all
select 'STAGING.STG_BEAUMIER_OPS_STATS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BEAUMIER_OPS_STATS
union all
select 'TRANSFORMATION.XFRM_HICV_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HICV_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HICV_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HICV_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_PACING
union all
select 'TRANSFORMATION.XFRM_HICV_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HICV_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HICV'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HICV'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HICV'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HICV'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HICV'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HICV'
union all
select 'SEMANTIC.SEM_AI_PACING HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='HICV'
union all
select 'XREF HICV' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HICV'
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET
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
