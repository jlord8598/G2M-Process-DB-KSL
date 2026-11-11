# Build 17 promotion (owner, 2026-11-11)

Build 17: SEM_AI_PACING, the seventh semantic table (D-51). It unions every lane's transformation pacing stream, long, one row per pacing row x metric column: 8 lanes, 8,414,122 rows. No source table was read and no freeze applied; no lane was restaged; classification and the six detail tables are unchanged. Stop 4 approved, then Q-10 (EVENTS QTY METRIC_UNIT 'COUNT', additive) and the coverage-scope change were applied.

## Results reported by the owner

- **D-47 master merge:** none needed (build 17 adds no classification key).
- **CLN.UTIL.SPROC_PROMOTE:** 156 procedures moved (155 + SPROC_SEM_AI_PACING); 12 of 12 classification-source swaps; 2 lanes with no classification.
- **Re-promotion of SPROC_SEM_AI_PACING:** after the late Q-10 redeploy (EVENTS QTY METRIC_UNIT 'count', then 'COUNT' to match the other units), so DEV1 carries the final version.
- **CLN.UTIL.SPROC_RUN_PIPELINE('DEV1'):** 14 lanes, 43 MAINs, 0 new keys; SPROC_SEM_AI_MAIN models=7.
- **DEV1 pacing reconcile (`reconcile_PACING_DEV1.sql`):** TOTAL FAILURES 0. The 8 process lanes pass coverage; the 4 foreign STR tables (XFRM_CSTR_MONTHLY_PACING, XFRM_STR_MONTHLY_PACING, XFRM_STR_WEEKLY_PACING, XFRM_WEEKLY_PACING) are listed as "not a process lane, not checked".
  - The first DEV1 run reported 4 failures from those tables. The coverage check was then scoped to process lanes (a SPROC_XFRM_<LANE>_MAIN in the same database), and both directions were proved in DEV_G2M_AI (findings/M6.md).
  - The STR tables are not this process's objects. They look like market benchmark data, not pacing, but their contents were not visible to the build role.

## Build figures (stop-4 memos)

- SEM_AI_PACING rows per lane:

| Lane | Rows |
|---|---|
| ALTERRA | 148,608 |
| BEAUMIER | 203,940 |
| KSL_SELECT_SERVICE | 1,782,079 |
| NEWBURY | 697,118 |
| OUTRIGGER | 212,096 |
| PEREGRINE_RESORTS | 3,798,377 |
| THE_PIG | 207,360 |
| UNDER_CANVAS | 1,364,544 |

- Checks 1-6 pass. Reconcile: 942 metric-snapshot rows + coverage, 0 failures. Runs A and B identical; 112 earlier objects unchanged throughout.
- Owner decisions:
  - NEWBURY OPS_RATE_SHOPS stays in transformation (competitor rates);
  - BEAUMIER snapshot = FILE_DATE;
  - EVENTS stay = EVENT_DATE (STAY_GRAIN 'EVENT');
  - KSL / PEREGRINE SOURCE_LINE_KEY null (no unique line id).

## Scripts archived with this build

`run_build.sql` (SPROC_SEM_AI_MAIN only), `build17_hashes.sql`, `reconcile_PACING.sql`, `reconcile_PACING_DEV1.sql`.

## CLAUDE.md changes applied

Invariant 7 (seven tables); section 3 pacing ("reaches semantic only through SEM_AI_PACING"); section 4 (seventh-table paragraph; "Seven tables" invariant); check 1 pacing identity and coverage; D-21; D-24; new D-51, including the coverage-scope sentence.

## Open items raised

N-39 (KSL forward pace only from 2026-10-19; 09-29 and 10-07 missing), N-40 (PEREGRINE 4 snapshots), N-41 (NEWBURY rate-shop repeated cells), N-42 (KSL / PEREGRINE no unique line key), N-43 (what EVENTS QTY counts).
