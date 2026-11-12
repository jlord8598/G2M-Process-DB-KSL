# Reconciliation (build 19)

`scripts/reconcile_<LANE>.sql` for HHG, HERSHA, DAVIDSON and JW_VENICE. Each compares every in-scope source table, CLN -> STG -> XFRM -> SEM: rows, and every numeric measure with tolerance 0.005. JW's pace tables are compared column by column, and SEM_AI_PACING as rows / k plus VALUE summed per METRIC_NAME.

| Lane | Rows checked | Failures |
|---|---|---|
| HHG | 19 | 0 |
| HERSHA | 10 | 0 |
| DAVIDSON | 16 | 0 |
| JW_VENICE | 23 | 0 |

- Outputs: `reconcile_<LANE>_output.csv`. DEV1 copies: `scripts/reconcile_<LANE>_DEV1.sql` (not run; my role cannot see DEV1).
- The new tables' figures are in M6.
