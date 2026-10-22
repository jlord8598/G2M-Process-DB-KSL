-- ============================================================================
-- scripts/build03_hashes.sql  (build 03, check 5)
-- Row count and content hash of every build 03 object: the 14 staging tables,
-- the three lanes' rows of the classification table (LAST_SEEN_RUN_ID
-- excluded), the 15 transformation tables, and the three lanes' rows of the
-- six SEM_AI tables (RUN_ID excluded). Run after each run_build.sql; two
-- consecutive runs must agree.
-- ============================================================================
select 'STAGING.STG_HERSHA_GL_ACTUAL' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HERSHA_GL_ACTUAL
union all
select 'STAGING.STG_HERSHA_GL_STAT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HERSHA_GL_STAT
union all
select 'STAGING.STG_HERSHA_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HERSHA_ACCOUNTS
union all
select 'STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
union all
select 'STAGING.STG_INVITED_CLUBS_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ACCOUNTS
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
select 'STAGING.STG_BEAUMIER_BP' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
union all
select 'STAGING.STG_BEAUMIER_BUDGET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
union all
select 'STAGING.STG_BEAUMIER_CANCELLATIONS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
union all
select 'STAGING.STG_BEAUMIER_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'HERSHA'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'INVITED_CLUBS'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'BEAUMIER'
union all
select 'TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HERSHA_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_PACING
union all
select 'TRANSFORMATION.XFRM_HERSHA_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_PACING
union all
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_PACING
union all
select 'TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_UNKNOWN
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'BEAUMIER'
order by obj;
