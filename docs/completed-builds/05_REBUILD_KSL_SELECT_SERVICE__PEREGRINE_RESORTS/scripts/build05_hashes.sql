-- ============================================================================
-- scripts/build05_hashes.sql  (build 05, check 5)
-- Row count and content hash of the rebuilt lanes' objects: 13 staging tables
-- per lane (RUN_ID excluded) and each lane's rows in the classification table
-- (LAST_SEEN_RUN_ID excluded). Plus the 5 transformation streams per lane (M5). Plus each lane's slice of the six semantic tables (M6). Two consecutive runs must hash identically. 52 objects (build 05 adds STG_{LANE}_DEPARTMENTS).
-- ============================================================================
select 'STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_COA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_COA
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DATASETS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DATASETS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_COA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_COA
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DATASETS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DATASETS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'PEREGRINE_RESORTS'
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'PEREGRINE_RESORTS'
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS
order by obj;
