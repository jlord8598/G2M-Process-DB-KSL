# Reconciliation (build 16): does every record arrive?

Yes, in all 12 lanes.

- **Counts:** partition exact and XFRM = SEM in every lane (M5 check 1 table). Every fact staging row reaches exactly one stream, and every non-pacing stream row reaches exactly one semantic table.
- **Amounts:** `reconcile_<LANE>.sql` compares row count and every numeric measure per source table across CLN, STG, XFRM and SEM, with tolerance 0.005.

| Lane | Metric rows | Failures |
|---|---|---|
| ALTERRA | 12 | 0 |
| ATLANTIC_AVIATION | 7 | 0 |
| BEAUMIER | 23 | 0 |
| DAVIDSON | 12 | 0 |
| HERSHA | 10 | 0 |
| HHG | 16 | 0 |
| INVITED_CLUBS | 15 | 0 |
| JW_VENICE | 11 | 0 |
| NEWBURY | 27 | 0 |
| OUTRIGGER | 18 | 0 |
| THE_PIG | 64 | 0 |
| UNDER_CANVAS | 63 | 0 |

Figures: `reconcile_<LANE>_output.csv`. ATLANTIC_AVIATION compares at the D-49 x1000 scale (AMT_SCALED / STAT_SCALED).
- **Against today's view run:** 207 / 207 objects equal (M6).
- **Rows the source holds and the build does not read:** HERSHA 3,056 budget-only rows (CLN_HERSHA_FIN_PL_MONTHLY) and 1,798 non-preferred stat rows (CLN_HERSHA_OPS_STATS_MONTHLY), under the Q-02 one-build exception (N-36, N-37). They were never in the old tables.
