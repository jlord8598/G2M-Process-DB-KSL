-- scripts/build26_lane_hashes.sql (build 26): BECKONS and HAI_HOSPITALITY (new), every object in full, RUN_ID / LAST_SEEN_RUN_ID excluded. Check 5 run-to-run. Read-only.
select 'STAGING.STG_BECKONS_ACTUALS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BECKONS_ACTUALS
union all
select 'STAGING.STG_BECKONS_BUDGET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_BECKONS_BUDGET
union all
select 'TRANSFORMATION.XFRM_BECKONS_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_BECKONS_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_BECKONS_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_BECKONS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_PACING
union all
select 'TRANSFORMATION.XFRM_BECKONS_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BECKONS_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='BECKONS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='BECKONS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='BECKONS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='BECKONS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='BECKONS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='BECKONS'
union all
select 'SEMANTIC.SEM_AI_PACING BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='BECKONS'
union all
select 'XREF BECKONS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='BECKONS';

select 'STAGING.STG_HAI_HOSPITALITY_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_HAI_HOSPITALITY_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HAI_HOSPITALITY_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HAI_HOSPITALITY_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HAI_HOSPITALITY_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HAI_HOSPITALITY_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_PACING
union all
select 'TRANSFORMATION.XFRM_HAI_HOSPITALITY_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HAI_HOSPITALITY_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HAI_HOSPITALITY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HAI_HOSPITALITY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HAI_HOSPITALITY'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HAI_HOSPITALITY'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HAI_HOSPITALITY'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HAI_HOSPITALITY'
union all
select 'SEMANTIC.SEM_AI_PACING HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='HAI_HOSPITALITY'
union all
select 'XREF HAI_HOSPITALITY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HAI_HOSPITALITY';
