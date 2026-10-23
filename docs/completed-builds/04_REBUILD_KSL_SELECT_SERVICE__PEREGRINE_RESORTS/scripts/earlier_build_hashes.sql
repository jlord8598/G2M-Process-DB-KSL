-- ============================================================================
-- scripts/earlier_build_hashes.sql  (build 04, check 5)
-- Row count and content hash of every object of the lanes NOT rebuilt in this
-- build: HHG, NEWBURY (build 02), HERSHA, INVITED_CLUBS, BEAUMIER (build 03).
-- 54 staging and transformation tables (RUN_ID excluded), their rows in the
-- shared XREF table (LAST_SEEN_RUN_ID excluded) and their slices of the six
-- SEM_AI tables (RUN_ID excluded). KSL_SELECT_SERVICE and PEREGRINE_RESORTS are
-- rebuilt (D-44) and excluded. Run before this build's first run_build.sql and
-- after each; must not change. 89 objects.
-- ============================================================================
select 'STAGING.STG_BEAUMIER_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_ACCOUNTS
union all
select 'STAGING.STG_BEAUMIER_BP' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
union all
select 'STAGING.STG_BEAUMIER_BUDGET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
union all
select 'STAGING.STG_BEAUMIER_CANCELLATIONS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_BEAUMIER_CANCELLATIONS
union all
select 'STAGING.STG_HERSHA_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HERSHA_ACCOUNTS
union all
select 'STAGING.STG_HERSHA_GL_ACTUAL' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HERSHA_GL_ACTUAL
union all
select 'STAGING.STG_HERSHA_GL_STAT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HERSHA_GL_STAT
union all
select 'STAGING.STG_HHG_ACCOUNTS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_ACCOUNTS
union all
select 'STAGING.STG_HHG_CLUB_LIST' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_CLUB_LIST
union all
select 'STAGING.STG_HHG_FORECAST_ANAPLAN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN
union all
select 'STAGING.STG_HHG_REFERENCES' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_REFERENCES
union all
select 'STAGING.STG_HHG_ROUNDS_DETAIL' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL
union all
select 'STAGING.STG_HHG_TR12_DATA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA
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
select 'TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HERSHA_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_PACING
union all
select 'TRANSFORMATION.XFRM_HERSHA_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_UNKNOWN
union all
select 'TRANSFORMATION.XFRM_HHG_BALANCE_SHEET' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET
union all
select 'TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT
union all
select 'TRANSFORMATION.XFRM_HHG_OPERATING_METRICS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_OPERATING_METRICS
union all
select 'TRANSFORMATION.XFRM_HHG_PACING' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_PACING
union all
select 'TRANSFORMATION.XFRM_HHG_UNKNOWN' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_UNKNOWN
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
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'HHG'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'NEWBURY'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'HERSHA'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'INVITED_CLUBS'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'LAST_SEEN_RUN_ID')) as content_hash from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane = 'NEWBURY'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN BEAUMIER' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HERSHA' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'HERSHA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HHG' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'HHG'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN INVITED_CLUBS' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN NEWBURY' as obj, count(*) as row_count, hash_agg(object_delete(object_construct_keep_null(*), 'RUN_ID')) as content_hash from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane = 'NEWBURY'
order by obj;
