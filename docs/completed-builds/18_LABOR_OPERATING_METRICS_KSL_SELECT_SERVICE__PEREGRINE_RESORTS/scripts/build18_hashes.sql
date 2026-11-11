-- scripts/build18_hashes.sql (build 18 proof): per lane, one statement each. Every semantic table (7) by lane, excluding the two rebuilt lanes' DAILY_LABOR rows; classification rows excluding labor keys; for KSL_SELECT_SERVICE / PEREGRINE_RESORTS every non-labor staging table and every transformation stream excluding labor rows. Read-only.
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='ALTERRA' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='ALTERRA' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='ALTERRA' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='ALTERRA' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='ALTERRA' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='ALTERRA' 
union all
select 'SEMANTIC.SEM_AI_PACING ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='ALTERRA' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ALTERRA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='ALTERRA' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='ATLANTIC_AVIATION' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='ATLANTIC_AVIATION' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='ATLANTIC_AVIATION' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='ATLANTIC_AVIATION' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='ATLANTIC_AVIATION' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='ATLANTIC_AVIATION' 
union all
select 'SEMANTIC.SEM_AI_PACING ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='ATLANTIC_AVIATION' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ATLANTIC_AVIATION' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='ATLANTIC_AVIATION' 
;
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
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION BEAUMIER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='BEAUMIER' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='DAVIDSON' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='DAVIDSON' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='DAVIDSON' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='DAVIDSON' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='DAVIDSON' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='DAVIDSON' 
union all
select 'SEMANTIC.SEM_AI_PACING DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='DAVIDSON' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION DAVIDSON' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='DAVIDSON' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HERSHA' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HERSHA' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HERSHA' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HERSHA' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HERSHA' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HERSHA' 
union all
select 'SEMANTIC.SEM_AI_PACING HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='HERSHA' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HERSHA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HERSHA' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HHG' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HHG' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HHG' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HHG' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HHG' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HHG' 
union all
select 'SEMANTIC.SEM_AI_PACING HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='HHG' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HHG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HHG' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='INVITED_CLUBS' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='INVITED_CLUBS' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='INVITED_CLUBS' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='INVITED_CLUBS' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='INVITED_CLUBS' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='INVITED_CLUBS' 
union all
select 'SEMANTIC.SEM_AI_PACING INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='INVITED_CLUBS' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION INVITED_CLUBS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='INVITED_CLUBS' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='JW_VENICE' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='JW_VENICE' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='JW_VENICE' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='JW_VENICE' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='JW_VENICE' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='JW_VENICE' 
union all
select 'SEMANTIC.SEM_AI_PACING JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='JW_VENICE' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION JW_VENICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='JW_VENICE' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='KSL_SELECT_SERVICE' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='KSL_SELECT_SERVICE' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='KSL_SELECT_SERVICE' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='KSL_SELECT_SERVICE' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='KSL_SELECT_SERVICE' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='KSL_SELECT_SERVICE' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_PACING KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='KSL_SELECT_SERVICE' and source_table not ilike '%DAILY_LABOR'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION KSL_SELECT_SERVICE' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='KSL_SELECT_SERVICE' and (source_site_code, department, account_key, record_type) not in (select distinct coalesce(nullif(trim(source_site_code),''),'~BLANK~'), coalesce(nullif(trim(department),''),'~BLANK~'), coalesce(nullif(trim(account_key),''),'~BLANK~'), coalesce(nullif(trim(record_type),''),'~BLANK~') from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR)
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_COA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_COA
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DATASETS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DATASETS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DEPARTMENTS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_LEDGER_BATCHES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_BOOKINGS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITES
union all
select 'STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_SITE_GROUPS
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_OPERATING_METRICS where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_UNKNOWN where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING where 1=1 and source_table not ilike '%DAILY_LABOR'
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='NEWBURY' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='NEWBURY' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='NEWBURY' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='NEWBURY' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='NEWBURY' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='NEWBURY' 
union all
select 'SEMANTIC.SEM_AI_PACING NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='NEWBURY' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION NEWBURY' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='NEWBURY' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='OUTRIGGER' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='OUTRIGGER' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='OUTRIGGER' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='OUTRIGGER' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='OUTRIGGER' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='OUTRIGGER' 
union all
select 'SEMANTIC.SEM_AI_PACING OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='OUTRIGGER' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION OUTRIGGER' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='OUTRIGGER' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='PEREGRINE_RESORTS' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='PEREGRINE_RESORTS' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='PEREGRINE_RESORTS' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='PEREGRINE_RESORTS' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='PEREGRINE_RESORTS' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='PEREGRINE_RESORTS' and source_table not ilike '%DAILY_LABOR'
union all
select 'SEMANTIC.SEM_AI_PACING PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='PEREGRINE_RESORTS' and source_table not ilike '%DAILY_LABOR'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION PEREGRINE_RESORTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='PEREGRINE_RESORTS' and (source_site_code, department, account_key, record_type) not in (select distinct coalesce(nullif(trim(source_site_code),''),'~BLANK~'), coalesce(nullif(trim(department),''),'~BLANK~'), coalesce(nullif(trim(account_key),''),'~BLANK~'), coalesce(nullif(trim(record_type),''),'~BLANK~') from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR)
union all
select 'STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_ACCOUNT_CLASS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_COA' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_COA
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DATASETS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DATASETS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_BOOKINGS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITES' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES
union all
select 'STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITE_GROUPS
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_OPERATING_METRICS where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_UNKNOWN where 1=1 and source_table not ilike '%DAILY_LABOR'
union all
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING where 1=1 and source_table not ilike '%DAILY_LABOR'
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='THE_PIG' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='THE_PIG' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='THE_PIG' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='THE_PIG' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='THE_PIG' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='THE_PIG' 
union all
select 'SEMANTIC.SEM_AI_PACING THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='THE_PIG' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION THE_PIG' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='THE_PIG' 
;
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='UNDER_CANVAS' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='UNDER_CANVAS' 
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='UNDER_CANVAS' 
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='UNDER_CANVAS' 
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='UNDER_CANVAS' 
union all
select 'SEMANTIC.SEM_AI_UNKNOWN UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='UNDER_CANVAS' 
union all
select 'SEMANTIC.SEM_AI_PACING UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.SEMANTIC.SEM_AI_PACING where source_lane='UNDER_CANVAS' 
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION UNDER_CANVAS' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) h from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='UNDER_CANVAS' 
;
