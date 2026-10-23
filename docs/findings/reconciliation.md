# Reconciliation - build 05 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: does every record arrive?** Yes, on both lanes, at every
boundary, by count and by every numeric sum (run C).

**Build 04's reading notes still apply** (archived `reconciliation.md`):
- daily, monthly and ledger overlap, so filter on `SOURCE_TABLE`;
- filter `IS_SUBTOTAL = FALSE` for detail;
- the ledger books revenue negative;
- filter on `SCENARIO` within `FORECAST`.

**New in this build:**
- **`BUDGET` now includes `Budget 3`** (PEREGRINE, 4,369 rows, 2027-01 to
  2027-04). Filter on `SCENARIO`.
- **`SCENARIO` is never null (D-45).** On daily, ledger and labor it is the
  source table's name (for example `CUR_PROFITSWORD_KSL_DAILY_EXTENDED`), so
  `SCENARIO` alone now tells a consumer which extract a row came from.

## Check 1: counts per lane

| Lane | CLN fact rows | STG | XFRM four streams | SEM six tables | Pacing CLN = STG = XFRM |
|---|---|---|---|---|---|
| KSL_SELECT_SERVICE | 10,291,750 | 10,291,750 | 10,291,750 | 10,291,750 | 557,049 |
| PEREGRINE_RESORTS | 1,251,561 | 1,251,561 | 1,251,561 | 1,251,561 | 623,819 |

| Lane | ACTUAL | BUDGET | FORECAST | BS | OM | UNKNOWN | Sum |
|---|---|---|---|---|---|---|---|
| KSL | 1,382,506 | 264,021 | 525,407 | 678,150 | 222,051 | 7,219,615 | 10,291,750 |
| PEREGRINE | 291,147 | 86,734 | 294,665 | 38,407 | 10,484 | 530,124 | 1,251,561 |

## Check 3: sums

`scripts/reconcile_{LANE}.sql`: row count and every numeric column per source
table across CLN, STG, XFRM and SEM, including pacing, the dictionaries, the
COA and `DEPARTMENTS`. **58 metric rows per lane, 0 failures, on both lanes.**

**Fact bridges (CLN = STG = XFRM = SEM):**

| Lane | Table | `SOURCE_AMOUNT` | `STAT_VALUE` |
|---|---|---|---|
| KSL | daily | 42,015,541,204.62 | 971,716,535.33 |
| KSL | monthly | 18,343,084,951.28 | 39,874,123.23 |
| KSL | ledger | 647,816,253.53 | 4,345,713.11 |
| KSL | labor | 63,284,142.79 | 2,747,136.37 |
| PEREGRINE | daily | 3,374,765,269.96 | 58,649,237.21 |
| PEREGRINE | monthly | 12,255,530,295.30 | 1,079,440,524.02 |
| PEREGRINE | ledger | 176,955,960.59 | 629,871.00 |
| PEREGRINE | labor | 40,067,552.19 | 1,524,197.95 |

## Against build 04

The extract is about one day newer (09:14 reload, `sources.md`), and the
counts and sums differ by that day. Classification is unchanged; only the
`DEPARTMENT_NAME` and `SCENARIO` columns and the `Budget 3` category differ
by rule.
