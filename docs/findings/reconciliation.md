# Reconciliation - build 06 (DAVIDSON, HHG, HERSHA)

**Does every record arrive?** Yes. Every source row of the three lanes
reaches staging, a transformation stream and a semantic table, with every
numeric sum equal within 0.005.

## Reconcile scripts (run at M6, after the check-6 restore)

| Script | Rows compared | Failures |
|---|---|---|
| `scripts/reconcile_DAVIDSON.sql` | 12 | **0** |
| `scripts/reconcile_HHG.sql` | 16 | **0** |
| `scripts/reconcile_HERSHA.sql` | 7 | **0** |

**DAVIDSON (CLN = STG = XFRM = SEM).**

| Table | Rows | `SOURCE_AMOUNT` | `STAT_VALUE` |
|---|---|---|---|
| HOTEL_MONTHLY_REPORT | 156,948 x 2 = 313,896 | 1,103,640,040.71 | 13,803,975.21 |
| FULL_YEAR_PL | 237,156 x 2 = 474,312 | 10,497,893,064 | 4,058,489 |
| ACCOUNTS (CLN = STG) | 32,842 | `ROW_COUNT` 394,104 | |

- **Row numbers.** `ACTUAL_` / `FORECAST_SOURCE_ROW_NUMBER` equal CLN on both
  facts: 61,544,955 / 32,611,053 and 124,681,335 / 42,380,894.
- **The bridge per measure.**
  - **CLN split.** The script splits each CLN amount between `SOURCE_AMOUNT`
    and `STAT_VALUE` by the deployed staging rules: MR STATISTIC on `ADR`,
    `Rooms` and natural 9xxx; PL STATISTIC on the SUMMARY hotel headings.
  - **Totals.** MR 1,103,640,040.71 + 13,803,975.21 = 1,117,444,015.92 =
    CLN actual 750,402,952.70 + forecast 367,041,063.22.
  - **No overrides.** No row is shifted by a classifier override.

**HHG and HERSHA:** every row PASS (scripts unchanged from builds 02 and 03).
- **HHG.**
  - TR12: 164,760 rows; AMT 826,163,401.59 + STAT 2,766,666 = CLN 828,930,067.59.
  - ANAPLAN: 19,080 rows; 325,117,641.88.
  - ROUNDS: 91,300 rows; STAT 6,959,463.04.
  - Dictionaries: CLN = STG.
- **HERSHA.**
  - GL_ACTUAL: 101,806 rows; AMT -103,788,653.07, STAT 9,477,792.55.
  - GL_STAT: 4,544 rows; STAT 686,105.65.
  - ACCOUNTS: 1,196 rows.

## Count identities per lane (`M5.md`, `M6.md`)

| Lane | Staged | XFRM partition (IS + BS + OM + PACING + UNKNOWN) | SEM (six tables) |
|---|---|---|---|
| DAVIDSON | 788,208 | 262,632 + 0 + 76,536 + 0 + 449,040 = 788,208 | 131,316 + 0 + 131,316 + 0 + 76,536 + 449,040 = 788,208 |
| HHG | 275,140 | 176,424 + 0 + 98,716 + 0 + 0 = 275,140 | 157,344 + 0 + 19,080 + 0 + 98,716 + 0 = 275,140 |
| HERSHA | 106,350 | 101,446 + 0 + 4,904 + 0 + 0 = 106,350 | 50,723 + 0 + 50,723 + 0 + 4,904 + 0 = 106,350 |

## Subtotals (DAVIDSON PL; `M3.md`, `M3-stop3-rerun.md`)

| | Source rows | Staged `SOURCE_AMOUNT` |
|---|---|---|
| Subtotal (`IS_SUBTOTAL`: roll-ups, SUMMARY, `Total` and GOP/EBITDA lines) | 92,940 | 8,845,224,909 |
| Detail | 144,216 | 1,652,668,155 |
| **Total** | **237,156** | **10,497,893,064** |

- **Excluding subtotals.** A consumer summing the PL should filter out
  `IS_SUBTOTAL`.
- **Avoiding double counting.** A consumer should not add the PL to the
  monthly report: separate them by `SOURCE_TABLE` (Q-10).
- **Other tables.** MR, HHG and HERSHA carry no subtotal signal (all
  `FALSE`).
