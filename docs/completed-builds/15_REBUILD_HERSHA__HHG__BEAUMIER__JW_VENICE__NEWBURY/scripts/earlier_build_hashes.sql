-- ============================================================================
-- scripts/earlier_build_hashes.sql  (build 15, check 5)
-- Every object of the 9 lanes this build does not rebuild (KSL_SELECT_SERVICE, PEREGRINE_RESORTS, INVITED_CLUBS, DAVIDSON, ALTERRA, ATLANTIC_AVIATION, UNDER_CANVAS, THE_PIG, OUTRIGGER):
-- 163 objects. content_hash: full content (RUN_ID / LAST_SEEN_RUN_ID
-- excluded); rest_hash identical. Both must be identical before this build's
-- first run and after its last.
-- ============================================================================
select 'STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_COA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_COA
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DATASETS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DATASETS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_COA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_COA
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DATASETS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DATASETS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'PEREGRINE_RESORTS'
union all
select 'STAGING.STG_INVITED_CLUBS_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ACCOUNTS
union all
select 'STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
union all
select 'STAGING.STG_INVITED_CLUBS_META_ACCOUNT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
union all
select 'STAGING.STG_INVITED_CLUBS_META_DEPARTMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
union all
select 'STAGING.STG_INVITED_CLUBS_META_ENTITY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY
union all
select 'STAGING.STG_INVITED_CLUBS_META_LOCATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_LOCATION
union all
select 'STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_PACING
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'INVITED_CLUBS'
union all
select 'STAGING.STG_DAVIDSON_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_DAVIDSON_ACCOUNTS
union all
select 'STAGING.STG_DAVIDSON_FULL_YEAR_PL' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_DAVIDSON_FULL_YEAR_PL
union all
select 'STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_PACING
union all
select 'TRANSFORMATION.XFRM_DAVIDSON_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION DAVIDSON' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL DAVIDSON' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET DAVIDSON' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST DAVIDSON' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET DAVIDSON' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS DAVIDSON' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN DAVIDSON' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'DAVIDSON'
union all
select 'STAGING.STG_ALTERRA_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_ALTERRA_ACCOUNTS
union all
select 'STAGING.STG_ALTERRA_MONTHLY_FINANCIALS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_ALTERRA_MONTHLY_FINANCIALS
union all
select 'STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_ALTERRA_PACE_BY_STAY_MONTH
union all
select 'TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_ALTERRA_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_PACING
union all
select 'TRANSFORMATION.XFRM_ALTERRA_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'ALTERRA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ALTERRA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'ALTERRA'
union all
select 'STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_ACCOUNTS
union all
select 'STAGING.STG_ATLANTIC_AVIATION_OC_DATA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_ATLANTIC_AVIATION_OC_DATA
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING
union all
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ATLANTIC_AVIATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'ATLANTIC_AVIATION'
union all
select 'STAGING.STG_UNDER_CANVAS_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_ACCOUNTS
union all
select 'STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES
union all
select 'STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CAMP_OPERATING_EXPENSES
union all
select 'STAGING.STG_UNDER_CANVAS_CANCELLATIONS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CANCELLATIONS
union all
select 'STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL
union all
select 'STAGING.STG_UNDER_CANVAS_DUETTO_DATA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_DUETTO_DATA
union all
select 'STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_STATISTICAL_ACCOUNTS
union all
select 'STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_TOTAL_REVENUE
union all
select 'STAGING.STG_UNDER_CANVAS_WEEKLY_PACE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_WEEKLY_PACE
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING
union all
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'UNDER_CANVAS'
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
select 'SEMANTIC.SEM_AI_UNKNOWN UNDER_CANVAS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'UNDER_CANVAS'
union all
select 'STAGING.STG_THE_PIG_PACE_NEXT_YEAR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_NEXT_YEAR
union all
select 'STAGING.STG_THE_PIG_PACE_THIS_YEAR' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_THE_PIG_PACE_THIS_YEAR
union all
select 'TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_THE_PIG_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_PACING
union all
select 'TRANSFORMATION.XFRM_THE_PIG_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION THE_PIG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'THE_PIG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL THE_PIG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'THE_PIG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET THE_PIG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'THE_PIG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST THE_PIG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'THE_PIG'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET THE_PIG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'THE_PIG'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS THE_PIG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'THE_PIG'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN THE_PIG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'THE_PIG'
union all
select 'STAGING.STG_OUTRIGGER_PACE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.STAGING.STG_OUTRIGGER_PACE
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING
union all
select 'TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_UNKNOWN
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION OUTRIGGER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as rest_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL OUTRIGGER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET OUTRIGGER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST OUTRIGGER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET OUTRIGGER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS OUTRIGGER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN OUTRIGGER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as rest_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'OUTRIGGER';
