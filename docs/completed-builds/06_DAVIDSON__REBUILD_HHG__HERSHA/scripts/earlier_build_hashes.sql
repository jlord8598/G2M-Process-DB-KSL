-- ============================================================================
-- scripts/earlier_build_hashes.sql  (build 06, check 5)
-- Row count and content hash of every object of the lanes NOT in this build:
-- BEAUMIER, INVITED_CLUBS, NEWBURY (builds 02-03), KSL_SELECT_SERVICE and
-- PEREGRINE_RESORTS (build 05). 48 staging and 25 transformation tables
-- (RUN_ID excluded), their rows in the shared XREF table (LAST_SEEN_RUN_ID
-- excluded) and their slices of the six SEM_AI tables (RUN_ID excluded).
-- DAVIDSON, HHG and HERSHA are this build's lanes and excluded. Run before
-- this build's first run_build.sql and after each; must not change.
-- 108 objects.
-- ============================================================================
select 'STAGING.STG_BEAUMIER_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS
union all
select 'STAGING.STG_BEAUMIER_BP' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
union all
select 'STAGING.STG_BEAUMIER_BUDGET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
union all
select 'STAGING.STG_BEAUMIER_CANCELLATIONS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
union all
select 'STAGING.STG_INVITED_CLUBS_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ACCOUNTS
union all
select 'STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
union all
select 'STAGING.STG_INVITED_CLUBS_META_ACCOUNT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
union all
select 'STAGING.STG_INVITED_CLUBS_META_DEPARTMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
union all
select 'STAGING.STG_INVITED_CLUBS_META_ENTITY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY
union all
select 'STAGING.STG_INVITED_CLUBS_META_LOCATION' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_LOCATION
union all
select 'STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_SUBACCOUNT
union all
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
select 'STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS
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
select 'STAGING.STG_NEWBURY_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_ACCOUNTS
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_BGT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_FCST' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_PYACT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS
union all
select 'STAGING.STG_NEWBURY_OTB_1DAY_PICKUP' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_1DAY_PICKUP
union all
select 'STAGING.STG_NEWBURY_OTB_3DAY_PICKUP' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP
union all
select 'STAGING.STG_NEWBURY_TRIAL_BALANCE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
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
select 'STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS
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
select 'TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_PACING
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_PACING
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN
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
select 'TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_NEWBURY_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING
union all
select 'TRANSFORMATION.XFRM_NEWBURY_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN
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
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'BEAUMIER'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'INVITED_CLUBS'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'NEWBURY'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN KSL_SELECT_SERVICE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN PEREGRINE_RESORTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'PEREGRINE_RESORTS'
order by obj;
