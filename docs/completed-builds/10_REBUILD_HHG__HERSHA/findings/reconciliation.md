# Reconciliation - build 10 (HHG, HERSHA)

**Does every record arrive?** Yes. Every source row reaches staging, its
stream and semantic. Every numeric sum is equal within 0.005.

## Reconcile scripts (run at M6)

| Script | Rows compared | Failures |
|---|---|---|
| `scripts/reconcile_HHG.sql` (build 08 text + 4 new dictionaries) | 24 | **0** |
| `scripts/reconcile_HERSHA.sql` (build 06 text + TB_ACTUAL) | 10 | **0** |

| Lane | Table | Rows | Measures (CLN = STG = XFRM = SEM) |
|---|---|---|---|
| HHG | TR12_DATA | 164,760 | AMT 826,163,401.59; STAT 2,766,666.00 |
| HHG | FORECAST_ANAPLAN | 19,080 | AMT 325,117,641.875673 |
| HHG | ROUNDS_DETAIL | 91,300 | STAT 7,114,966.04 |
| HHG | ACCOUNTS / CLUB_LIST / REFERENCES / ASSET_CODES / CHART_OF_ACCOUNTS / DEPARTMENT_KEY / TR12_ACCOUNTS | 13,759 / 50 / 45 / 50 / 623 / 11 / 50,940 | CLN = STG |
| HERSHA | GL_ACTUAL | 50,903 x 2 = 101,806 | AMT -103,788,653.07; STAT 9,477,792.55 |
| HERSHA | TB_ACTUAL (new) | 52,827 x 2 = 105,654 | AMT -77,467,135.26; STAT 4,659,289.08 |
| HERSHA | GL_STAT | 9,424 x 2 = 18,848 | STAT 2,623,115.53 |
| HERSHA | ACCOUNTS | 2,187 | CLN = STG |

## Count identities

| Lane | Staged | XFRM | SEM |
|---|---|---|---|
| HHG | 275,140 | IS 176,424 + OM 98,716 | ACTUAL 157,344 + FORECAST 19,080 + OM 98,716 |
| HERSHA | 226,308 | IS 115,398 + OM 19,208 + UNKNOWN 91,702 | ACTUAL 64,675 + FORECAST 50,723 + OM 19,208 + UNKNOWN 91,702 |

## Duplicate sources (D-48)

HERSHA UNKNOWN carries 91,702 `DUPLICATE_DETAIL` rows (-23,268,972.52):
- GL_ACTUAL ACTUAL rows at TB's 12 hotels;
- every TB_ACTUAL FORECAST row.

They are kept and counted in the identities, but not in the income
statement. **Check 2(m): 0 cells counted from both TB and GL.**

## Subtotals

Unchanged. HHG and HERSHA: the source gives no way to tell.
