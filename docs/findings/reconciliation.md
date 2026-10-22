# Reconciliation - build 03 (HERSHA, INVITED_CLUBS, BEAUMIER)

**The question: does every record arrive?** Yes. Every row of the 14 in-scope
tables is in staging. Every fact row is in exactly one transformation stream
and one semantic table, and every pacing row is in its lane's pacing stream.
Every numeric column sums the same at every layer that carries it.

Source: `CLN.BOX_INVESTMENT_DATA`, under the D-43 freeze (max in-scope
`last_altered` 2026-10-19 15:40:44.535 PDT, unchanged at every milestone).
State: run 3 (`RUN_20261021_12464x`).

## Counts, per lane and source table

| Lane | Table | Form | CLN | STG | XFRM | SEM |
|---|---|---|---|---|---|---|
| HERSHA | GL_ACTUAL | x2 | 50,903 | 101,806 | IS 101,446, OM 360 | ACTUAL 50,723, FORECAST 50,723, OM 360 |
| HERSHA | GL_STAT | x2 | 2,272 | 4,544 | OM 4,544 | OM 4,544 |
| HERSHA | ACCOUNTS | dict | 1,196 | 1,196 | - | - |
| INVITED_CLUBS | ESSBASE_EXTRACT | x3 | 17,100,504 | 51,301,512 | IS 20,387,874, BS 9,857,187, OM 12,443,505, UN 8,612,946 | ACTUAL, BUDGET, FORECAST 6,795,958 each; BS 9,857,187; OM 12,443,505; UNKNOWN 8,612,946 |
| INVITED_CLUBS | ACCOUNTS, 5 META | dict | 13,314; 9,244; 799; 5,472; 1,507; 1,198 | same | - | - |
| BEAUMIER | BP | long | 35,567 | 35,567 | IS 35,567 | BUDGET 8,488, FORECAST 27,079 |
| BEAUMIER | BUDGET | long | 17,577 | 17,577 | IS 17,577 | ACTUAL 9,251, BUDGET 8,326 |
| BEAUMIER | CANCELLATIONS | pacing | 18,930 | 18,930 | PACING 18,930 | none (D-21) |
| BEAUMIER | ACCOUNTS | dict | 2,258 | 2,258 | - | - |

Fact totals per lane:

| Lane | STG | XFRM | SEM |
|---|---|---|---|
| HERSHA | 106,350 | 106,350 | 106,350 |
| INVITED_CLUBS | 51,301,512 | 51,301,512 | 51,301,512 |
| BEAUMIER | 53,144 | 53,144 | 53,144 |

## Sums, per measure

From `scripts/reconcile_{HERSHA,INVITED_CLUBS,BEAUMIER}.sql`, **0 failures
each** (8, 16 and 23 metric rows). `SOURCE_AMOUNT` and `STAT_VALUE` are never
added together.

| Lane | Table | Measure | CLN = STG = XFRM = SEM |
|---|---|---|---|
| HERSHA | GL_ACTUAL | `SOURCE_AMOUNT` (amounts, `GL_CODE` not Stat) | -103,788,653.07 |
| HERSHA | GL_ACTUAL | `STAT_VALUE` (stats) | 9,477,792.55 |
| HERSHA | GL_STAT | `STAT_VALUE` (amount columns, Q-02) | 686,105.65 |
| INVITED_CLUBS | ESSBASE_EXTRACT | `SOURCE_AMOUNT` (currency / no meta) | 442,516,489,057.67 |
| INVITED_CLUBS | ESSBASE_EXTRACT | `STAT_VALUE` (non-currency) | 531,160,494.09 |
| BEAUMIER | BP | `SOURCE_AMOUNT` | 38,868,453.531294 |
| BEAUMIER | BUDGET | `SOURCE_AMOUNT` | 19,866,830.779535 |
| BEAUMIER | CANCELLATIONS | `ROOMS_REVENUE` / `OCCUPANCY` (+ 10 prior-year columns) | 2,436,169,569.15483 / 4,266,661 (CLN = STG = XFRM) |

No classifier override moved a measure: 0 `RECORD_TYPE`/`H1` disagreements.

## Subtotals the source supplies

| Lane | Rows | Rule | Detail `SOURCE_AMOUNT` | Subtotal `SOURCE_AMOUNT` |
|---|---|---|---|---|
| INVITED_CLUBS | 84,129 staged (28,043 x 3) | `REPORT_LEVEL = 'EBITDA_SUMMARY'`, by structure (owner Q-01) | see the classification table | the `Adjusted Cash EBITDA` account |
| INVITED_CLUBS | 338,802 staged, **not flagged** | `DAY_OF_MONTH = 'TotalDOMEnter'`, borderline: equals Day01-31 in 76% of groups (owner Q-01) | - | - |
| HERSHA, BEAUMIER | 0 | the source gives no way to tell | - | - |

- **`EBITDA_SUMMARY` is flagged by structure and not verified against its
  detail.** It is a computed EBITDA over many accounts, and no detail account
  states it.
- **Exclude `IS_SUBTOTAL` before summing INVITED_CLUBS.**
- **Do not add `TotalDOMEnter` rows to their daily rows**: they double count
  wherever they tie.

## Consumer note: use `SOURCE_AMOUNT` (owner, Q-04)

**For HERSHA and BEAUMIER, consumers use `SOURCE_AMOUNT`, not `VALUE`.** Both
sources book one side with the opposite sign to the build's `VALUE_SIGN`.

| Lane | Category | `SOURCE_AMOUNT` | `VALUE` |
|---|---|---|---|
| HERSHA | ACTUAL | -7,680,004.63 | -73,981,783.23 |
| HERSHA | FORECAST | -96,108,648.44 | -468,370,793.02 |
| BEAUMIER | ACTUAL | 5,086,385.05 | 101,595,949.35 |
| BEAUMIER | BUDGET | 29,081,729.99 | 242,029,014.86 |
| BEAUMIER | FORECAST | 24,567,169.26 | 334,242,743.30 |

- **HERSHA** books revenue negative, so `VALUE` turns revenue negative.
- **BEAUMIER** books expense negative, so `VALUE` turns expense positive.

`VALUE` signing is unchanged for this build (owner decision).

## Rows with nothing to sum

- **INVITED_CLUBS:** 33,059,900 staged rows carry no measure. These are the
  unpivoted empty cells.
- **HERSHA:** 50,903 empty branch rows (each source row is empty in one of its
  two branches).
- **BEAUMIER:** 132 null-amount rows in each fact table.
