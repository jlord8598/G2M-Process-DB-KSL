-- scripts/build17_hashes.sql (build 17, check 5): per lane, the pacing stream, the six semantic tables' lane rows and the classification rows. Run one lane per statement. Read-only.
select 'TRANSFORMATION.XFRM_ALTERRA_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ALTERRA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ALTERRA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ALTERRA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ALTERRA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ALTERRA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='ALTERRA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ALTERRA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='ALTERRA'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ALTERRA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='ALTERRA'
;
select 'TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL ATLANTIC_AVIATION', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET ATLANTIC_AVIATION', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST ATLANTIC_AVIATION', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET ATLANTIC_AVIATION', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS ATLANTIC_AVIATION', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='ATLANTIC_AVIATION'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN ATLANTIC_AVIATION', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='ATLANTIC_AVIATION'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION ATLANTIC_AVIATION', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='ATLANTIC_AVIATION'
;
select 'TRANSFORMATION.XFRM_BEAUMIER_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL BEAUMIER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET BEAUMIER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST BEAUMIER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET BEAUMIER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS BEAUMIER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='BEAUMIER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN BEAUMIER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='BEAUMIER'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION BEAUMIER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='BEAUMIER'
;
select 'TRANSFORMATION.XFRM_DAVIDSON_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL DAVIDSON', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET DAVIDSON', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST DAVIDSON', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET DAVIDSON', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS DAVIDSON', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='DAVIDSON'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN DAVIDSON', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='DAVIDSON'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION DAVIDSON', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='DAVIDSON'
;
select 'TRANSFORMATION.XFRM_HERSHA_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HERSHA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HERSHA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HERSHA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HERSHA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HERSHA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HERSHA'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HERSHA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HERSHA'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HERSHA', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HERSHA'
;
select 'TRANSFORMATION.XFRM_HHG_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL HHG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET HHG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST HHG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET HHG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS HHG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='HHG'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN HHG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='HHG'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION HHG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='HHG'
;
select 'TRANSFORMATION.XFRM_INVITED_CLUBS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL INVITED_CLUBS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET INVITED_CLUBS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST INVITED_CLUBS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET INVITED_CLUBS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS INVITED_CLUBS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='INVITED_CLUBS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN INVITED_CLUBS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='INVITED_CLUBS'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION INVITED_CLUBS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='INVITED_CLUBS'
;
select 'TRANSFORMATION.XFRM_JW_VENICE_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL JW_VENICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET JW_VENICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST JW_VENICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET JW_VENICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS JW_VENICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='JW_VENICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN JW_VENICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='JW_VENICE'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION JW_VENICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='JW_VENICE'
;
select 'TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL KSL_SELECT_SERVICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET KSL_SELECT_SERVICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST KSL_SELECT_SERVICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET KSL_SELECT_SERVICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS KSL_SELECT_SERVICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='KSL_SELECT_SERVICE'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN KSL_SELECT_SERVICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='KSL_SELECT_SERVICE'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION KSL_SELECT_SERVICE', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='KSL_SELECT_SERVICE'
;
select 'TRANSFORMATION.XFRM_NEWBURY_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL NEWBURY', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET NEWBURY', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST NEWBURY', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET NEWBURY', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS NEWBURY', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='NEWBURY'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN NEWBURY', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='NEWBURY'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION NEWBURY', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='NEWBURY'
;
select 'TRANSFORMATION.XFRM_OUTRIGGER_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_OUTRIGGER_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL OUTRIGGER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET OUTRIGGER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST OUTRIGGER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET OUTRIGGER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS OUTRIGGER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='OUTRIGGER'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN OUTRIGGER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='OUTRIGGER'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION OUTRIGGER', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='OUTRIGGER'
;
select 'TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL PEREGRINE_RESORTS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET PEREGRINE_RESORTS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST PEREGRINE_RESORTS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET PEREGRINE_RESORTS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS PEREGRINE_RESORTS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='PEREGRINE_RESORTS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN PEREGRINE_RESORTS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='PEREGRINE_RESORTS'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION PEREGRINE_RESORTS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='PEREGRINE_RESORTS'
;
select 'TRANSFORMATION.XFRM_THE_PIG_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL THE_PIG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET THE_PIG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST THE_PIG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET THE_PIG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS THE_PIG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='THE_PIG'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN THE_PIG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='THE_PIG'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION THE_PIG', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='THE_PIG'
;
select 'TRANSFORMATION.XFRM_UNDER_CANVAS_PACING' obj, count(*) n, hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) h from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_PACING
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL UNDER_CANVAS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET UNDER_CANVAS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_BUDGET where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST UNDER_CANVAS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_FORECAST where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_BALANCE_SHEET UNDER_CANVAS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_OPERATING_METRICS UNDER_CANVAS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_OPERATING_METRICS where source_lane='UNDER_CANVAS'
union all
select 'SEMANTIC.SEM_AI_UNKNOWN UNDER_CANVAS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'RUN_ID')) from DEV_G2M_AI.SEMANTIC.SEM_AI_UNKNOWN where source_lane='UNDER_CANVAS'
union all
select 'XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION UNDER_CANVAS', count(*), hash_agg(object_delete(object_construct_keep_null(*),'LAST_SEEN_RUN_ID')) from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION where source_lane='UNDER_CANVAS'
;
