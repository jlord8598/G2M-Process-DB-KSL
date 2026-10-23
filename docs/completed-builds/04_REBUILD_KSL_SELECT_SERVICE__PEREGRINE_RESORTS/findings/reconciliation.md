# Reconciliation - build 04 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: does every record arrive?** Yes, on both rebuilt lanes, at
every boundary, by count and by every numeric sum. Figures are from the final
run (`RUN_20261022_1604*`, after the check 6 restore).

## Read this first: overlapping extracts (build 01 Q-09, re-measured)

**`DAILY_EXTENDED`, `MONTHLY_EXTENDED` and `LEDGER_BATCHES` overlap, so do not
sum across them; filter on `SOURCE_TABLE`.**
- **Daily against Monthly Actuals.** Daily equals Monthly Actuals per site x
  month x account on 99.77% of KSL keys (178,888 of 179,298, 2024-01 to
  2026-09) and on 100% of PEREGRINE keys (6,805, 2026-09) (M1).
- **The ledger** is the daily income journal again (`TYPE_ID = INJ` on every
  row).
- **Labor** is an independent source.

Nothing is deduplicated (D-25).

**Subtotals:** filter `IS_SUBTOTAL = FALSE` before summing detail. Flagged
rows are the `TOT*` rollups and the COA's account-less total lines (Q-05,
Q-08), all in daily. All of them are in `SEM_AI_UNKNOWN`, because their
item-tag keys carry no classification.

**Signs:** `SOURCE_AMOUNT` is as booked. The ledger books revenue negative
(the prevailing direction for ledger Revenue keys is `-`, against `+` in daily
and monthly; `classification-coverage.md`). Use `VALUE` only where
`VALUE_SIGN` is set.

**Forecast scenarios:** `FORECAST` holds several named scenarios, now
including `Smart Forecast` (a historical projection, 2024-01 to 2025-02;
Q-03) and the blended `5 Year Plan 2026 Final` (build 01). Filter on
`SCENARIO`.

## Check 1: counts, every boundary, per lane

| Lane | CLN fact rows | STG | XFRM four streams | SEM six tables | CLN pacing | STG | XFRM PACING |
|---|---|---|---|---|---|---|---|
| KSL_SELECT_SERVICE | 10,275,670 | 10,275,670 | 10,275,670 | 10,275,670 | 557,049 | 557,049 | 557,049 |
| PEREGRINE_RESORTS | 1,238,168 | 1,238,168 | 1,238,168 | 1,238,168 | 623,819 | 623,819 | 623,819 |

**SEM by table:**

| Lane | ACTUAL | BUDGET | FORECAST | BS | OM | UNKNOWN | Sum |
|---|---|---|---|---|---|---|---|
| KSL | 1,380,576 | 264,021 | 525,410 | 676,983 | 221,742 | 7,206,938 | 10,275,670 |
| PEREGRINE | 289,298 | 82,374 | 294,651 | 38,060 | 10,438 | 523,347 | 1,238,168 |

The three IS tables equal the XFRM IS stream (KSL 2,170,007, PEREGRINE
666,323). BS, OM and UNKNOWN map one to one. Dictionaries reconcile one to
one, CLN to STG, in the scripts below.

## Check 3: sums, every boundary, every numeric column

`scripts/reconcile_KSL_SELECT_SERVICE.sql` and
`scripts/reconcile_PEREGRINE_RESORTS.sql` compare, per source table, the row
count and the sum of every numeric column across CLN, STG, XFRM and SEM:
- fact measures as `AMT`/`STAT`;
- pacing columns verbatim;
- dictionaries by count and their numeric columns, the COA included.

**Results: 57 metric rows per lane, 0 FAIL, total failures 0, on both
lanes.**

**Per-table fact bridges, STG = XFRM = SEM (`SOURCE_AMOUNT` / `STAT_VALUE`):**

| Lane | Table | `SOURCE_AMOUNT` | `STAT_VALUE` |
|---|---|---|---|
| KSL | DAILY_EXTENDED | 41,958,905,233.64 | 970,248,807.31 |
| KSL | MONTHLY_EXTENDED | 18,337,709,718.83 | 39,851,382.15 |
| KSL | LEDGER_BATCHES | 646,689,882.50 | 4,339,810.11 |
| KSL | DAILY_LABOR | 63,128,472.54 | 2,740,722.52 |
| PEREGRINE | DAILY_EXTENDED | 3,307,061,990.18 | 58,195,082.43 |
| PEREGRINE | MONTHLY_EXTENDED | 12,195,687,532.74 | 1,078,143,453.06 |
| PEREGRINE | LEDGER_BATCHES | 174,018,380.29 | 619,905.00 |
| PEREGRINE | DAILY_LABOR | 39,776,329.70 | 1,513,668.17 |

**Detail and subtotal totals in SEMANTIC (query `01c7e8f1-020a-3b2c-0003-4ff21bba3dc2`):**

| Lane | Table | Rows | Subtotal rows | Detail `SOURCE_AMOUNT` | Subtotal `SOURCE_AMOUNT` |
|---|---|---|---|---|---|
| KSL | IS ACTUAL | 1,380,576 | 0 | 2,095,950,382.26 | 0 |
| KSL | IS BUDGET | 264,021 | 0 | 1,607,161,106.36 | 0 |
| KSL | IS FORECAST | 525,410 | 0 | 3,717,966,326.69 | 0 |
| KSL | BS | 676,983 | 0 | 3,059,122,597.56 | 0 |
| KSL | OM | 221,742 | 0 | 3,432,396,858.85 | 0 |
| KSL | UNKNOWN | 7,206,938 | 3,559,388 | 28,714,090,786.35 | 18,379,745,249.44 |
| PEREGRINE | IS ACTUAL | 289,298 | 0 | 2,148,472,189.17 | 0 |
| PEREGRINE | IS BUDGET | 82,374 | 0 | 1,144,603,321.29 | 0 |
| PEREGRINE | IS FORECAST | 294,651 | 0 | 3,368,963,785.64 | 0 |
| PEREGRINE | BS | 38,060 | 0 | 3,408,488,794.14 | 0 |
| PEREGRINE | OM | 10,438 | 0 | 634,949,922.00 | 0 |
| PEREGRINE | UNKNOWN | 523,347 | 157,704 | 3,333,753,377.97 | 1,677,312,842.70 |

## Against build 01

These are new figures for a new extract, not a correction: the history was
loaded to 2024 and the COA replaced. The build 01 M6 totals are in its
archived `reconciliation.md`; the change in row counts is the new history
(M1, M4).
