# Reconciliation - does every record arrive?

Generated on 2026-10-19 from live queries against the deployed objects,
after the Q-04 re-run (`M6-q04-rerun.md`). The extract is the `CLN.CLEAN`
load of 07:39:27 - 07:39:56 (Q-17), the same as M6; no source table was
altered while the re-run ran.

The final build run used these `RUN_ID`s:
- STG: `RUN_20261019_103628_871` (KSL) and `RUN_20261019_103655_304`
  (PEREGRINE);
- SEM: `RUN_20261019_103753_922`.

## Read this before summing anything

**`DAILY_EXTENDED`, `MONTHLY_EXTENDED` and `LEDGER_BATCHES` overlap.**
- **They are the same business activity extracted three ways.** Daily is
  actuals by business date. Monthly Actuals is the same actuals by month,
  and equals daily on about 99.8% of site x month x account keys (M1).
  Ledger is the Daily Income Journal: revenue and balance sheet, with
  section-4 signs inverted against daily, and stat-only rows whose amounts
  equal daily's to the cent (M5).
- **All three are kept**, by design (D-25, Q-09). No row is deduplicated.
- **Consequence.** Summing `SEM_INCOME_STATEMENT_ACTUAL` or
  `SEM_BALANCE_SHEET` across `SOURCE_TABLE` double- or triple-counts.
- **Consumers must filter on `SOURCE_TABLE`** and choose one source per
  question. Never sum across them.
- **`SEM_BALANCE_SHEET` and `SEM_OPERATING_METRICS` also hold every
  category** (D-16). Their monthly rows include budget and forecast
  scenarios, so filter on `CATEGORY` (and `SCENARIO`) as well.
- **`SEM_INCOME_STATEMENT_FORECAST` holds several scenarios** (below). They
  are alternative forecasts of the same periods; filter on `SCENARIO`, never
  sum across them.

The overlap is visible in the semantic tables themselves:

| Lane | Table | `SOURCE_TABLE` | `CATEGORY` | Rows | `SOURCE_AMOUNT` |
|---|---|---|---|---|---|
| KSL | SEM_INCOME_STATEMENT_ACTUAL | DAILY_EXTENDED | ACTUAL | 235,372 | 202,988,847.17 |
| KSL | SEM_INCOME_STATEMENT_ACTUAL | MONTHLY_EXTENDED | ACTUAL | 40,387 | 203,243,084.98 |
| KSL | SEM_INCOME_STATEMENT_ACTUAL | LEDGER_BATCHES | ACTUAL | 83,666 | -122,554,559.77 |
| KSL | SEM_BALANCE_SHEET | DAILY_EXTENDED | ACTUAL | 113,195 | 126,895,981.82 |
| KSL | SEM_BALANCE_SHEET | MONTHLY_EXTENDED | ACTUAL | 9,077 | 125,517,954.01 |
| KSL | SEM_BALANCE_SHEET | MONTHLY_EXTENDED | BUDGET | 1,616 | 101,147,684.93 |
| KSL | SEM_BALANCE_SHEET | MONTHLY_EXTENDED | FORECAST | 9,406 | 240,963,671.49 |
| KSL | SEM_BALANCE_SHEET | LEDGER_BATCHES | ACTUAL | 56,989 | 122,462,873.64 |
| PEREGRINE | SEM_INCOME_STATEMENT_ACTUAL | DAILY_EXTENDED | ACTUAL | 78,937 | 127,659,431.97 |
| PEREGRINE | SEM_INCOME_STATEMENT_ACTUAL | MONTHLY_EXTENDED | ACTUAL | 10,010 | 78,414,021.85 |
| PEREGRINE | SEM_INCOME_STATEMENT_ACTUAL | LEDGER_BATCHES | ACTUAL | 21,276 | -60,537,761.41 |
| PEREGRINE | SEM_BALANCE_SHEET | DAILY_EXTENDED | ACTUAL | 11,464 | 23,539,558.01 |
| PEREGRINE | SEM_BALANCE_SHEET | MONTHLY_EXTENDED | ACTUAL | 754 | 6,300,583.37 |
| PEREGRINE | SEM_BALANCE_SHEET | MONTHLY_EXTENDED | FORECAST | 556 | -7,823,271.26 |
| PEREGRINE | SEM_BALANCE_SHEET | LEDGER_BATCHES | ACTUAL | 8,697 | 62,142,774.76 |

**Changed from M6.** M6 showed KSL `SEM_BALANCE_SHEET` monthly as one line,
18,441 rows and 341,336,764.63, without splitting by category. It is now
20,099 rows and 467,629,310.43 (9,077 + 1,616 + 9,406; 125,517,954.01 +
101,147,684.93 + 240,963,671.49). The difference, 1,658 rows and
126,292,545.80, is KSL `Flex` balance sheet rows that were in `SEM_UNKNOWN`
until Q-04 was answered. PEREGRINE monthly balance sheet (754 + 556 = 1,310
rows, -1,522,687.89) is unchanged. Every `SEM_INCOME_STATEMENT_ACTUAL` line
is unchanged.

**Forecast scenarios** in `SEM_INCOME_STATEMENT_FORECAST`, all from
`MONTHLY_EXTENDED`, sorted by amount:

| Lane | `SCENARIO` | Since | Rows | `SOURCE_AMOUNT` | `VALUE` |
|---|---|---|---|---|---|
| KSL | 5 Year Plan 2026 Final | Q-04 | 7,097 | 444,898,744.35 | 85,171,585.75 |
| KSL | Flex | Q-04 | 79,998 | 338,616,742.17 | 18,754,720.39 |
| KSL | Primary Forecast | M5 | 60,825 | 298,584,257.67 | 55,636,421.76 |
| KSL | Forecast 2 | M5 | 2,183 | 12,099,196.00 | 1,820,238.75 |
| KSL | RMS - OneYield | Q-04 | 177 | 11,670,513.00 | 11,670,513.00 |
| KSL | Forecast 3 | M5 | 2,266 | 10,952,386.17 | 1,418,437.74 |
| KSL | RMS - HiltonGRO/IDeaS | Q-04 | 31 | 1,782,229.54 | 1,782,229.54 |
| PEREGRINE | Flex | Q-04 | 36,735 | 345,235,368.37 | -78,940,816.14 |
| PEREGRINE | Primary Forecast | M5 | 21,492 | 228,989,183.82 | 22,902,116.37 |
| PEREGRINE | Forecast 2 | M5 | 8,579 | 82,028,088.86 | -98,017.61 |

KSL 152,577 rows, PEREGRINE 66,806. The M5-era lines total KSL 65,274 rows
and 321,635,839.83, PEREGRINE 30,071 and 311,017,272.68, exactly M6's
FORECAST table. **The KSL 5 Year Plan carries actuals-like values for
elapsed months** (Q-04 evidence, `open-questions.md`), so it is not a pure
forward forecast.

**Subtotals.** `IS_SUBTOTAL = TRUE` rows are the source's own `TOT*` rollups
(Q-05). They carry no account, so every one lands in `SEM_UNKNOWN` and none
is in a classified table. Exclude them before summing `SEM_UNKNOWN`.

## Counts, per lane, every boundary

### Source to staging

The long identity holds on every model, `count(source) = count(staged)`, with
0 columns unpivoted. The per-table figures are in the reconcile script output
below: 12 tables per lane plus the shared chart, all `PASS`. (M6's version of
this sentence said 21 tables per lane; the scripts cover 12 per lane plus the
chart, 25 in all, as `table-usage.md` lists. No figure changed.)

### Staging to transformation: the partition

| Lane | Fact staging | `IS` | `BS` | `OM` | `UNKNOWN` | Sum | Diff |
|---|---|---|---|---|---|---|---|
| KSL_SELECT_SERVICE | 2,696,029 | 620,849 | 190,283 | 53,888 | 1,831,009 | 2,696,029 | 0 |
| PEREGRINE_RESORTS | 748,855 | 219,586 | 21,471 | 3,132 | 504,666 | 748,855 | 0 |

| Lane | Pace staging (rooms + transient + events) | `PACING` | Diff |
|---|---|---|---|
| KSL_SELECT_SERVICE | 17,637 + 215,710 + 11,091 = 244,438 | 244,438 | 0 |
| PEREGRINE_RESORTS | 1,122 + 2,405 + 5,371 = 8,898 | 8,898 | 0 |

**The fact staging figure is the sum of the four fact tables:**
- KSL: 2,050,067 + 328,292 + 174,751 + 142,919 = 2,696,029.
- PEREGRINE: 335,161 + 122,070 + 30,889 + 260,735 = 748,855.

**Changed from M6.** The stream split moved; the totals did not. KSL `IS`
+87,303, `BS` +1,658, `OM` +631, `UNKNOWN` -89,592. PEREGRINE `IS` +36,735,
`OM` +217, `UNKNOWN` -36,952. These are the Q-04 rows (`M6-q04-rerun.md`).

### Transformation to semantic

| Lane | `ACTUAL` | `BUDGET` | `FORECAST` | `BALANCE_SHEET` | `OPERATING_METRICS` | `UNKNOWN` | Six-table total | Fact staging | Diff |
|---|---|---|---|---|---|---|---|---|---|
| KSL_SELECT_SERVICE | 359,425 | 108,847 | 152,577 | 190,283 | 53,888 | 1,831,009 | 2,696,029 | 2,696,029 | 0 |
| PEREGRINE_RESORTS | 110,223 | 42,557 | 66,806 | 21,471 | 3,132 | 504,666 | 748,855 | 748,855 | 0 |

- **The `IS` stream fans out to three tables.** KSL 359,425 + 108,847 +
  152,577 = 620,849, and PEREGRINE 110,223 + 42,557 + 66,806 = 219,586, both
  equal to `XFRM_IS`.
- **The other three map one to one,** with difference 0.
- **Pacing has no semantic table (D-21).**
- **Changed from M6:** `FORECAST`, `BALANCE_SHEET`, `OPERATING_METRICS` and
  `UNKNOWN`, by the amounts in the partition note above. `ACTUAL` and
  `BUDGET` are unchanged and hash identically to M6.

## Measures, per source table, CLN to SEM

`scripts/reconcile_{LANE}.sql` sums every numeric column at every layer that
carries it:
- **Fact tables:** `SOURCE_AMOUNT` and `STAT_VALUE` at all four layers.
  Their other numeric columns at CLN and STG.
- **Pace tables:** every numeric column at CLN, STG and XFRM.
- **Dictionaries:** CLN and STG.

Tolerance is `abs(a-b) > 0.005`.

| Lane | Query | Rows checked | `FAIL` | Total failure count |
|---|---|---|---|---|
| KSL_SELECT_SERVICE | `01c7d6ba-020a-2bbb-0003-4ff21b86a2f6` | 57 | 0 | **0** |
| PEREGRINE_RESORTS | `01c7d6bb-020a-2b54-0003-4ff21b85ea6a` | 57 | 0 | **0** |

**Facts, identical at CLN = STG = XFRM = SEM** (unchanged from M6; the
mapping moves rows between tables, not out of a source table):

| Lane | Table | Rows | `SOURCE_AMOUNT` | `STAT_VALUE` |
|---|---|---|---|---|
| KSL | DAILY_EXTENDED | 2,050,067 | 9,544,296,449.38166 | 257,337,898.026695 |
| KSL | MONTHLY_EXTENDED | 328,292 | 3,637,802,734.94822 | 16,776,086.8105081 |
| KSL | LEDGER_BATCHES | 174,751 | 135,499,285.82 | 1,175,986 |
| KSL | DAILY_LABOR | 142,919 | 21,851,259.85 | 911,574.91 |
| PEREGRINE | DAILY_EXTENDED | 335,161 | 3,169,992,878.79882 | 56,948,235.005766 |
| PEREGRINE | MONTHLY_EXTENDED | 122,070 | 1,707,953,383.2355 | 60,215,823.2314 |
| PEREGRINE | LEDGER_BATCHES | 30,889 | 168,040,643.10 | 602,362 |
| PEREGRINE | DAILY_LABOR | 260,735 | 38,850,809.69 | 1,484,367.98 |

**Pacing, identical at CLN = STG = XFRM (values in the script output):**
- KSL: rooms 17,637 rows, transient 215,710, events 11,091.
- PEREGRINE: rooms 1,122, transient 2,405, events 5,371.

## Detail and subtotal totals, per semantic table

`SOURCE_AMOUNT` as booked. Every subtotal row is in `SEM_UNKNOWN`.

| Lane | Table | Rows | Subtotal rows | Detail `SOURCE_AMOUNT` | Subtotal `SOURCE_AMOUNT` | Detail `STAT_VALUE` | Subtotal `STAT_VALUE` |
|---|---|---|---|---|---|---|---|
| KSL | SEM_INCOME_STATEMENT_ACTUAL | 359,425 | 0 | 283,677,372.38 | 0 | 4,035,217.42 | 0 |
| KSL | SEM_INCOME_STATEMENT_BUDGET | 108,847 | 0 | 598,846,272.64 | 0 | 7,096,023.9516 | 0 |
| KSL | SEM_INCOME_STATEMENT_FORECAST | 152,577 | 0 | 1,118,604,068.89 | 0 | 17,053,321.5424 | 0 |
| KSL | SEM_BALANCE_SHEET | 190,283 | 0 | 716,988,165.89 | 0 | 0 | 0 |
| KSL | SEM_OPERATING_METRICS | 53,888 | 0 | 523,594,223.42 | 0 | -13,989,855.84 | 0 |
| KSL | SEM_UNKNOWN | 1,831,009 | 912,736 | 6,215,087,828.16 | 3,882,651,798.63 | 234,989,205.1132 | 27,017,633.56 |
| PEREGRINE | SEM_INCOME_STATEMENT_ACTUAL | 110,223 | 0 | 145,535,692.41 | 0 | 7,837,989.0099 | 0 |
| PEREGRINE | SEM_INCOME_STATEMENT_BUDGET | 42,557 | 0 | 617,118,954.62 | 0 | 7,340,685.8235 | 0 |
| PEREGRINE | SEM_INCOME_STATEMENT_FORECAST | 66,806 | 0 | 656,252,641.05 | 0 | 11,072,948.2094 | 0 |
| PEREGRINE | SEM_BALANCE_SHEET | 21,471 | 0 | 84,159,644.88 | 0 | 0 | 0 |
| PEREGRINE | SEM_OPERATING_METRICS | 3,132 | 0 | 616,134,821.78 | 0 | 56,895,521.5439 | 0 |
| PEREGRINE | SEM_UNKNOWN | 504,666 | 150,057 | 1,522,505,462.46 | 1,443,130,497.63 | 20,561,230.2222 | 15,542,413.4083 |

**Changed from M6**, every difference being the Q-04 rows:
- KSL FORECAST +87,303 rows, +796,968,229.05 / +13,153,588.5059; BALANCE_SHEET
  +1,658 rows, +126,292,545.80; OPERATING_METRICS +631 rows, amount
  unchanged, `STAT_VALUE` -3,253,035.99; UNKNOWN detail -89,592 rows,
  -923,260,774.85 / -9,900,552.5159.
- PEREGRINE FORECAST +36,735 rows, +345,235,368.37 / +3,495,694.5284;
  OPERATING_METRICS +217 rows, +311,089.86 / +5,860,037.1021; UNKNOWN detail
  -36,952 rows, -345,546,458.22 / -9,355,731.6305.
- **Subtotals are unchanged** (KSL 912,736 rows, PEREGRINE 150,057): no
  subtotal row has an account, so none was a Q-04 move.

**Three things these totals do not mean:**
- **`SOURCE_AMOUNT` is not a profit figure.** The source books revenue and
  expense both positive on daily and monthly (`classification-coverage.md`).
- **`SEM_OPERATING_METRICS` carries real `SOURCE_AMOUNT`.** These are
  stat-only source rows with a non-zero `AMT` (M5). Its measure is
  `STAT_VALUE`.
- **Signed `VALUE` exists only on the income statement tables**, and is null
  wherever `VALUE_SIGN` is null.
