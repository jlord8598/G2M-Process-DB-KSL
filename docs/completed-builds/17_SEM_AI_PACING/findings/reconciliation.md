# Reconciliation (build 17): does every pacing record arrive?

Yes. Every row of every non-empty pacing stream reaches SEM_AI_PACING once per declared metric column, except NEWBURY OPS_RATE_SHOPS (38,848 rows), which stays in transformation by owner decision (Q-03).

| Lane | SEM_AI_PACING rows | Failures |
|---|---|---|
| ALTERRA | 148,608 | 0 |
| BEAUMIER | 203,940 | 0 |
| KSL_SELECT_SERVICE | 1,782,079 | 0 |
| NEWBURY | 697,118 | 0 |
| OUTRIGGER | 212,096 | 0 |
| PEREGRINE_RESORTS | 3,798,377 | 0 |
| THE_PIG | 207,360 | 0 |
| UNDER_CANVAS | 1,364,544 | 0 |

Total 8,414,122.
- `scripts/reconcile_PACING.sql`: per lane, source table, metric and snapshot, rows, non-null count and sum, plus the lane-coverage check. TOTAL FAILURES 0. A DEV1 copy is in `scripts/reconcile_PACING_DEV1.sql`.
- The six detail tables and every lane's classification are untouched (M6 check 5).
