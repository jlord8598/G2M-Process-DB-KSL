# Build 18 promotion (owner, 2026-11-11)

Build 18: D-44 rebuild of KSL_SELECT_SERVICE and PEREGRINE_RESORTS, labor only. DAILY_LABOR rows were moved from SEM_AI_UNKNOWN (UNCLASSIFIED_ACCOUNT) to SEM_AI_OPERATING_METRICS as statistics, following the B09-D4 pattern:
- H1 Statistic, H2 DAILY_LABOR, METRIC_UNIT CURRENCY, AGGREGATION_TYPE FLOW;
- wages kept as SOURCE_AMOUNT (RECORD_TYPE AMOUNT), hours as STAT_VALUE with STAT_UNIT_FAMILY 'HOURS' (D-29);
- labor never enters the P&L.

Only the two DAILY_LABOR staging models were restaged, on the 2026-11-11 extract; every other staging table stayed as staged on 11-04 (owner Q-02). The freeze (Gary) on KSL / PEREGRINE ran to 22:00 MT, with 3 / 3 tables unchanged at every check.

Person data: PERSON_ID, EMPLOYEE_ID and EMPLOYEE_NAME stay in staging only. Labor SOURCE_LINE_KEY is null (owner Q-03; checked in the reconcile scripts; N-44). EFFECTIVE_RATE stays in staging. Stop 4 approved.

## Results reported by the owner

- **D-47 master merge:** 0 inserted, 10,107 updated.
  - That is the 10,046 re-seeded existing labor keys plus the 61 new labor keys (KSL 14, PEREGRINE 47).
  - The 61 were already in the master from the morning DEV1 run, so they updated instead of inserting.
  - This equals the stop-4 expectation of 61 inserts + 10,046 updates.
- **CLN.UTIL.SPROC_PROMOTE:** 156 procedures moved; 12 of 12 classification-source swaps; 2 lanes with no classification.
- **CLN.UTIL.SPROC_RUN_PIPELINE('DEV1'):** 14 lanes, 43 MAINs, 0 new keys, SEM models=7.
  - SEM_AI_OPERATING_METRICS up KSL 793,934 and PEREGRINE 366,164; SEM_AI_UNKNOWN down by the same.
  - DEV1's full STG MAINs restaged every table from the 11-11 reload, so all of today's labor moved there (build 18 Q-06).
- **DEV1 reconciles (`reconcile_KSL_SELECT_SERVICE_DEV1.sql`, `reconcile_PEREGRINE_RESORTS_DEV1.sql`):** TOTAL FAILURES 0 each. Labor is equal from CLN to SEM, with 0 person columns in TRANSFORMATION / SEMANTIC and 0 labor line keys.

## Build figures (stop-4 memos)

- **DEV_G2M_AI:**
  - SEM_AI_OPERATING_METRICS 23,140,413 -> 24,300,511 (+1,160,098);
  - SEM_AI_UNKNOWN 23,699,628 -> 22,558,157 (-1,141,471, the 787,419 + 354,052 labor rows on the 11-04 staging);
  - the other five semantic tables unchanged.
- **Proof:** 148 objects hashed (7 semantic tables x 14 lanes minus the two lanes' labor rows; classification minus labor keys; the two lanes' non-labor staging and streams). All identical before and after run A, run B and the final run. The classification proof used the corrected labor key set (before plus after).
- **Keys:** every existing labor key reproduced and none moved; 61 new from new labels; 3 dead labor keys kept, still Unclassified.
- **Informational tie:** labor wages vs monthly GL payroll by complete site-month: KSL 18 / 944 within 1%, PEREGRINE 0 / 28. No D-48 rule.

## Scripts archived with this build

`run_build.sql` (labor staging models, then both lanes' XREF / XFRM MAINs, then SPROC_SEM_AI_MAIN), `build18_hashes.sql`, `d43_check.sql`, `reconcile_KSL_SELECT_SERVICE.sql`, `reconcile_PEREGRINE_RESORTS.sql` and their `_DEV1` copies.

## CLAUDE.md changes applied

None.

## Open items raised

N-44 (person-level labor: does any consumer need it, and under what access policy; for the PM).
