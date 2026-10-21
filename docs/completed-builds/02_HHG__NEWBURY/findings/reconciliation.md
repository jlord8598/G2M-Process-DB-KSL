# Reconciliation - build 02 (HHG, NEWBURY)

**The question: does every record arrive?** Yes. Every source row of the 15
in-scope tables is in staging; every fact row is in exactly one transformation
stream and one semantic table; every pacing row is in its lane's pacing stream.
Every numeric column sums the same at every layer that carries it.

Source: `CLN.BOX_INVESTMENT_DATA`, held under the D-43 load freeze (max
`last_altered` 2026-10-19 15:41:03.950 -07:00, unchanged at every milestone).
State: run 3, query `01c7dd9b-020a-3608-0003-4ff21b9b64da`.

## Counts, per lane, per source table

| Lane | Source table | Form | CLN | STG | XFRM stream(s) | XFRM | SEM table(s) | SEM |
|---|---|---|---|---|---|---|---|---|
| HHG | TR12_DATA | long | 164,760 | 164,760 | IS 157,344, OM 7,416 | 164,760 | IS_ACTUAL 157,344, OM 7,416 | 164,760 |
| HHG | FORECAST_ANAPLAN | long | 19,080 | 19,080 | IS 19,080 | 19,080 | IS_FORECAST 19,080 | 19,080 |
| HHG | ROUNDS_DETAIL | long | 91,300 | 91,300 | OM 91,300 | 91,300 | OM 91,300 | 91,300 |
| HHG | ACCOUNTS, CLUB_LIST, REFERENCES | dictionary | 13,759 / 50 / 45 | same | - | - | - | - |
| NEWBURY | TRIAL_BALANCE | wide, x3 | 16,320 (x3 = 48,960) | 48,960 | IS 38,772, OM 10,188 | 48,960 | IS_ACTUAL, _BUDGET, _FORECAST 12,924 each; OM 10,188 | 48,960 |
| NEWBURY | OPERATING_STATS_BGT | long | 365 | 365 | UNKNOWN 365 | 365 | UNKNOWN 365 | 365 |
| NEWBURY | OPERATING_STATS_PYACT | long | 2,795 | 2,795 | UNKNOWN 2,795 | 2,795 | UNKNOWN 2,795 | 2,795 |
| NEWBURY | OPERATING_STATS_FCST | pacing | 2,190 | 2,190 | PACING | 2,190 | none (D-21) | - |
| NEWBURY | OPERATING_STATS_SHOPS | pacing | 20,048 | 20,048 | PACING | 20,048 | none | - |
| NEWBURY | OTB_1DAY_PICKUP | pacing | 75,264 | 75,264 | PACING | 75,264 | none | - |
| NEWBURY | OTB_3DAY_PICKUP | pacing | 41,905 | 41,905 | PACING | 41,905 | none | - |
| NEWBURY | ACCOUNTS, OPERATING_STATS_EVENTSANDOOO | dictionary | 770 / 426 | same | - | - | - | - |

**Lane totals.**
- **HHG:** CLN 288,994 = STG 288,994; facts 275,140 = XFRM 275,140 = SEM
  275,140.
- **NEWBURY:** STG 192,723 = CLN 160,083 + 32,640 (the two unpivoted
  trial-balance columns); facts 52,120 = XFRM 52,120 = SEM 52,120; pacing
  139,407 = XFRM_NEWBURY_PACING 139,407.

## Sums, per lane, per source table, per measure

From `scripts/reconcile_HHG.sql` and `scripts/reconcile_NEWBURY.sql` (0
failures each). `SOURCE_AMOUNT` and `STAT_VALUE` are never added together.

| Lane | Table | Measure | CLN | STG | XFRM | SEM |
|---|---|---|---|---|---|---|
| HHG | TR12_DATA | `SOURCE_AMOUNT` (AMOUNT, dept <> 999) | 826,163,401.59 | same | same | same |
| HHG | TR12_DATA | `STAT_VALUE` (AMOUNT, dept 999; owner Q-01) | 2,766,666 | same | same | same |
| HHG | FORECAST_ANAPLAN | `SOURCE_AMOUNT` | 325,117,641.875673 | same | same | same |
| HHG | ROUNDS_DETAIL | `STAT_VALUE` (ROUNDS_COUNT) | 6,959,463.04 | same | same | same |
| NEWBURY | TRIAL_BALANCE | `SOURCE_AMOUNT` (Amount rows, 3 measures) | 408,072,850.883742 | same | same | same |
| NEWBURY | TRIAL_BALANCE | `STAT_VALUE` (STAT rows, 3 measures) | 23,618,399.140313 | same | same | same |
| NEWBURY | OPERATING_STATS_BGT | `SOURCE_AMOUNT` (REVENUE) / `STAT_VALUE` (ROOMS) | 46,106,692.2701 / 77,289 | same | same | same |
| NEWBURY | OPERATING_STATS_PYACT | `SOURCE_AMOUNT` (REVENUE) / `STAT_VALUE` (ROOMS) | 203,122,723.54 / 330,220 | same | same | same |
| NEWBURY | OPERATING_STATS_FCST | ROOMS / REVENUE | 444,759 / 291,599,340.6705 | same | same | - |
| NEWBURY | OPERATING_STATS_SHOPS | RATE_VALUE | 17,106,633.3 | same | same | - |
| NEWBURY | OTB_1DAY_PICKUP | ROOMS / REVENUE / AVAILABLE_ROOMS | 1,364,830 / 823,772,430.0835 / 21,525,504 | same | same | - |
| NEWBURY | OTB_3DAY_PICKUP | ROOMS / REVENUE / AVAILABLE_ROOMS | 759,087 / 458,444,630.2943 / 11,984,830 | same | same | - |

`SOURCE_ROW_NUMBER` and every dictionary's numeric columns also reconcile
CLN = STG (and = XFRM for pacing); see the scripts' output.

Trial balance by measure (M3, query `01c7dd7d-020a-354c-0003-4ff21b995f8a`):

| Measure | Amount rows `SOURCE_AMOUNT` | STAT rows `STAT_VALUE` |
|---|---|---|
| actual | 134,959,077.79 | 12,530,786.89 |
| forecast | 73,064,741.907628 | 2,678,567.049976 |
| budget | 200,049,031.186114 | 8,409,045.200337 |

These sum to 408,072,850.883742 and 23,618,399.140313.

**No classifier override moved a measure.** Every STATISTIC row is in
operating metrics with its number in `STAT_VALUE`, and every AMOUNT row is in
the income statement or unknown with its number in `SOURCE_AMOUNT`. There are
0 `RECORD_TYPE`/`H1` disagreements.

## Subtotals the source supplies

| Lane | Rows | Rule (`SUBTOTAL_SOURCE`) | Detail `SOURCE_AMOUNT` | Subtotal `SOURCE_AMOUNT` |
|---|---|---|---|---|
| HHG Anaplan | 360 of 19,080 | `LOCATION = '+All Regions'` | 162,558,820.94 | 162,558,820.94 |
| HHG TR12, rounds | 0 | source gives no way to tell | - | - |
| NEWBURY trial balance | 0 | `NODE_TYPE <> 'Leaf'`; every row is `Leaf` | - | - |
| NEWBURY BGT, PYACT | 0 | source gives no way to tell | - | - |

**Verified, not asserted**: the 360 subtotal rows equal the sum of the other 52
locations on all 360 line-item x month cells (M1), and in total (query
`01c7dd96-020a-3606-0003-4ff21b9b5362`). **Summing HHG forecast without
excluding `IS_SUBTOTAL` doubles it.**

## Rows with nothing to sum

- NEWBURY trial balance: 25,427 rows carry a null measure by construction
  (unpivoted empty cells: actual 2,164, forecast 13,447, budget 9,816). They
  are counted and sum to nothing.
- HHG rounds: 3,650 rows dated after the 2026-10-19 load are all zero (owner
  Q-07).

## Consumer note: HHG Anaplan forecast (owner, Q-22)

**Use `SOURCE_AMOUNT`, not `VALUE`, for the HHG Anaplan forecast.**
- **Why:** Anaplan books expenses negative, and the build's `VALUE_SIGN`
  (Debit -1) turns them positive. `VALUE` on those rows is therefore a gross
  figure (1,428,944,200.12), not the net (325,117,641.88).
- **Owner decision:** `VALUE` signing is unchanged for this build.
- **Also exclude `IS_SUBTOTAL`** on these rows to avoid double counting
  (see "Subtotals the source supplies" above).
