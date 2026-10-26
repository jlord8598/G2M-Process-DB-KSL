# Reconciliation - build 07 (BEAUMIER, NEWBURY)

**Does every record arrive?** Yes. Every source row of both lanes reaches
staging and its stream: facts reach semantic, pacing reaches PACING. Every
numeric sum is equal within 0.005.

## Reconcile scripts (run at M6)

| Script | Rows compared | Failures |
|---|---|---|
| `scripts/reconcile_BEAUMIER.sql` (build 03 text + `LOCATION_MAP` rows) | 23 | **0** |
| `scripts/reconcile_NEWBURY.sql` (build 02 text, unchanged) | 33 | **0** |

**BEAUMIER (CLN = STG = XFRM = SEM for facts; CLN = STG = PACING for CANCELLATIONS).**

| Table | Rows | Amount |
|---|---|---|
| BP | 35,567 | 38,868,453.531294 |
| BUDGET | 17,577 | 19,866,830.779535 |
| CANCELLATIONS (pacing) | 18,930 | `ROOMS_REVENUE` 2,436,169,569.15, `OCCUPANCY` 4,266,661 and every `_N_1`-`_N_5` column equal |
| ACCOUNTS | 2,258 | `ROW_COUNT` 53,144 |
| LOCATION_MAP (new) | 13 | no numeric column; 0 rows differ either way (M3) |

**NEWBURY.**

| Table | Rows | Measures |
|---|---|---|
| TRIAL_BALANCE | 16,320 x 3 = 48,960 | AMT 408,072,850.883742; STAT 23,618,399.140313 |
| OPERATING_STATS_BGT | 365 | AMT 46,106,692.2701; STAT 77,289 |
| OPERATING_STATS_PYACT | 2,795 | AMT 203,122,723.54; STAT 330,220 |
| FCST, SHOPS, OTB_1DAY, OTB_3DAY (pacing) | 2,190 / 20,048 / 75,264 / 41,905 | every numeric column equal CLN = STG = PACING |
| EVENTSANDOOO, ACCOUNTS | 426 / 770 | CLN = STG |

## Count identities (`M5.md`, `M6.md`)

| Lane | Fact staged | XFRM (IS + BS + OM + UNKNOWN) | SEM (six tables) | Pacing staged = XFRM PACING |
|---|---|---|---|---|
| BEAUMIER | 53,144 | 53,144 + 0 + 0 + 0 | 9,251 + 16,814 + 27,079 + 0 + 0 + 0 = 53,144 | 18,930 |
| NEWBURY | 52,120 | 38,772 + 0 + 10,188 + 3,160 | 12,924 x 3 + 0 + 10,188 + 3,160 = 52,120 | 139,407 |

## Subtotals

- **BEAUMIER:** no subtotal signal (all `FALSE`), as in build 03.
- **NEWBURY TB:** subtotal unless `NODE_TYPE` is `Leaf`, as in build 02.
- **Neither rule changed** in this build.
