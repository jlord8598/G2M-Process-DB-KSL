-- scripts/build22_new_hashes.sql (build 22 A/B): every object of the 3 new lanes, RUN_ID excluded. One statement per lane. Read-only.
select 'STAGING.STG_WESTIN_HILTON_HEAD_PACE_GROUP' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_WESTIN_HILTON_HEAD_PACE_GROUP
union all
select 'TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_PACING
union all
select 'TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_WESTIN_HILTON_HEAD_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='WESTIN_HILTON_HEAD'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='WESTIN_HILTON_HEAD'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='WESTIN_HILTON_HEAD'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='WESTIN_HILTON_HEAD'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='WESTIN_HILTON_HEAD'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='WESTIN_HILTON_HEAD'
union all
select 'SEMANTIC.SEM_AI_PACING WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='WESTIN_HILTON_HEAD'
union all
select 'XREF WESTIN_HILTON_HEAD' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='WESTIN_HILTON_HEAD'
;
select 'STAGING.STG_W_SHERATON_MALDIVES_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_ACCOUNTS
union all
select 'STAGING.STG_W_SHERATON_MALDIVES_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_BALANCE_SHEET
union all
select 'STAGING.STG_W_SHERATON_MALDIVES_PL_MONTHLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_MONTHLY
union all
select 'STAGING.STG_W_SHERATON_MALDIVES_PL_OWNER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_OWNER
union all
select 'STAGING.STG_W_SHERATON_MALDIVES_PL_SUMMARY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_W_SHERATON_MALDIVES_PL_SUMMARY
union all
select 'TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_PACING
union all
select 'TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_W_SHERATON_MALDIVES_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='W_SHERATON_MALDIVES'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='W_SHERATON_MALDIVES'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='W_SHERATON_MALDIVES'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='W_SHERATON_MALDIVES'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='W_SHERATON_MALDIVES'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='W_SHERATON_MALDIVES'
union all
select 'SEMANTIC.SEM_AI_PACING W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='W_SHERATON_MALDIVES'
union all
select 'XREF W_SHERATON_MALDIVES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='W_SHERATON_MALDIVES'
;
select 'STAGING.STG_THIRD_SPACE_ACCOUNTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_THIRD_SPACE_ACCOUNTS
union all
select 'STAGING.STG_THIRD_SPACE_PL_MONTHLY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_THIRD_SPACE_PL_MONTHLY
union all
select 'TRANSFORMATION.XFRM_THIRD_SPACE_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_THIRD_SPACE_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_THIRD_SPACE_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_THIRD_SPACE_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_PACING
union all
select 'TRANSFORMATION.XFRM_THIRD_SPACE_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THIRD_SPACE_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='THIRD_SPACE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='THIRD_SPACE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='THIRD_SPACE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='THIRD_SPACE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='THIRD_SPACE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='THIRD_SPACE'
union all
select 'SEMANTIC.SEM_AI_PACING THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='THIRD_SPACE'
union all
select 'XREF THIRD_SPACE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='THIRD_SPACE'
;
