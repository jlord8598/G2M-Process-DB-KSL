# Build 25 reconciliation (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)
- reconcile_KSL_SELECT_SERVICE.sql and reconcile_PEREGRINE_RESORTS.sql (build 18 versions, unchanged): row count and every numeric sum per source table across CLN, STG, XFRM and SEM. 0 failures each; output in `reconcile_build25_output.txt`.
- Partition: KSL 16,466,152 = 1,076,022 IS + 121,724 BS + 817,055 OM + 14,451,351 UNKNOWN; PEREGRINE 3,488,989 = 598,413 + 18,170 + 382,713 + 2,489,693. Pacing (557,049 / 623,819) is unchanged.
- **Overlap guidance replaced.** Build 01's "filter on SOURCE_TABLE" guidance (Q-09) no longer applies to the actual income statement: under D-48, each site-month carries one source (monthly Actuals, else daily). The ledger is in UNKNOWN in full. Summing SEM_AI_INCOME_STATEMENT_ACTUAL is now valid for these lanes.
- Revenue and EBITDA tie-outs against ProfitSword: M6.md.
