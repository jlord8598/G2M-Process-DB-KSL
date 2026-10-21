-- ============================================================================
-- scripts/build02_hashes.sql  (build 02, check 5)
-- Row count and content hash of every build 02 object: the 15 staging tables,
-- the HHG and NEWBURY rows of the classification table (LAST_SEEN_RUN_ID
-- excluded), the 10 transformation tables, and the HHG and NEWBURY rows of
-- the six SEM_AI tables (RUN_ID excluded). Run after each run_build.sql; two
-- consecutive runs must agree.
-- ============================================================================
select 'STAGING.STG_HHG_TR12_DATA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA
union all
select 'STAGING.STG_HHG_FORECAST_ANAPLAN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN
union all
select 'STAGING.STG_HHG_ROUNDS_DETAIL' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL
union all
select 'STAGING.STG_HHG_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_ACCOUNTS
union all
select 'STAGING.STG_HHG_CLUB_LIST' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_CLUB_LIST
union all
select 'STAGING.STG_HHG_REFERENCES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_REFERENCES
union all
select 'STAGING.STG_NEWBURY_TRIAL_BALANCE' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_BGT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_PYACT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_FCST' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_FCST
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_SHOPS
union all
select 'STAGING.STG_NEWBURY_OTB_1DAY_PICKUP' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_1DAY_PICKUP
union all
select 'STAGING.STG_NEWBURY_OTB_3DAY_PICKUP' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OTB_3DAY_PICKUP
union all
select 'STAGING.STG_NEWBURY_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_ACCOUNTS
union all
select 'STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'HHG'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'NEWBURY'
union all
select 'TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HHG_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HHG_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HHG_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_PACING
union all
select 'TRANSFORMATION.XFRM_HHG_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_NEWBURY_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING
union all
select 'TRANSFORMATION.XFRM_NEWBURY_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'NEWBURY'
order by obj;
