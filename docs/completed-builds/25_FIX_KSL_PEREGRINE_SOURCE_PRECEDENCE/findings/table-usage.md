# Build 25 table usage
All 27 CLN.CLEAN tables of the two lanes (CUR_PROFITSWORD_KSL_* 13, CUR_PROFITSWORD_PEREGRINE_* 13, CUR_PROFITSWORD_DEPARTMENTS) are read by the same staging procedures as build 18 (archived table-usage.md); no read changed. Changed use, in transformation only:
- STG_{LANE}_MONTHLY_EXTENDED (SOURCE_SITE_CODE, PERIOD_END, CATEGORY ACTUAL via STG_{LANE}_DATASETS.IS_ACTUALS): defines the winning site-months, SPROC_XFRM_{LANE} CTE `sm_monthly`.
- STG_{LANE}_DAILY_EXTENDED (SOURCE_SITE_CODE, PERIOD_END): defines the site-months where daily beats the ledger, CTE `sm_daily`.
- STG_{LANE}_LEDGER_BATCHES: every line to UNKNOWN (CTE `prec`, column `d48_loses_to`).
Read-only: CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY (merge expectation, D-03).
