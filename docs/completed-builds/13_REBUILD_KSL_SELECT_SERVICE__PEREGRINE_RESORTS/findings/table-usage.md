# Table usage (build 13)

All 27 `CLN.CLEAN` tables of the two lanes are read, by the same staging procedures as build 05 (build 05 table-usage.md, archived). Changed reads: `CUR_PROFITSWORD_{KSL,PEREGRINE}_COA` columns IS_CALCULATED_LINE, BUD_FORMULA, ACCOUNT_NUMBER, STAT_ACCT_NUMBER, TAG, now in SPROC_STG_*_DAILY_EXTENDED and _MONTHLY_EXTENDED for IS_SUBTOTAL (IS_TOTAL_LINE no longer read). No table retired; no procedure added (129).
