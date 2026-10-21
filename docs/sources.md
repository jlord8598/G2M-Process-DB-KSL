# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

Build 02. Every figure below is from a query run on 2026-10-20 against
`CLN.BOX_INVESTMENT_DATA`. *Measured* means confirmed against this extract;
*proposed* means a rule M1 suggests and the owner decides at stop 2;
*unverified* means noted but not tested.

---

## Source schema

`CLN.<SOURCE>`: **`CLN.BOX_INVESTMENT_DATA`**. Owner `G2M_SYSADMIN`; schema
created 2026-10-14 10:51:47 PDT.

**Load freeze window** (`CLAUDE.md` D-43): starts **2026-10-20 14:34 PDT**
(owner, stop 1). End **2026-10-22 14:34 PDT** until the owner confirms an
extension, which has been requested.

**`last_altered` of every in-scope table**, recorded at M1 (query
`01c7dd4f-020a-3548-0003-4ff21b99b382`, 2026-10-20 14:34 PDT) and re-checked
unchanged at 14:40 (`01c7dd54-020a-3589-0003-4ff21b9984ce`) and at the end of
M1 profiling (`01c7dd5e-020a-3587-0003-4ff21b99a922`, max
2026-10-19 15:41:03.950). Before each milestone's checks these are compared
again; any change is a stop.

| Lane | Table | Rows | Created | `last_altered` |
|---|---|---|---|---|
| HHG | `CLN_HERITAGE_GOLF_ACCOUNTS` | 13,759 | 2026-10-19 15:39:42.562 | 2026-10-19 15:39:44.169 |
| HHG | `CLN_HERITAGE_GOLF_CLUB_LIST` | 50 | 2026-10-19 15:39:33.092 | 2026-10-19 15:39:34.465 |
| HHG | `CLN_HERITAGE_GOLF_FORECAST_ANAPLAN` | 19,080 | 2026-10-19 15:39:38.310 | 2026-10-19 15:39:40.072 |
| HHG | `CLN_HERITAGE_GOLF_REFERENCES` | 45 | 2026-10-19 15:39:34.495 | 2026-10-19 15:39:35.764 |
| HHG | `CLN_HERITAGE_GOLF_ROUNDS_DETAIL` | 91,300 | 2026-10-19 15:39:41.184 | 2026-10-19 15:39:42.542 |
| HHG | `CLN_HERITAGE_GOLF_TR12_DATA` | 164,760 | 2026-10-19 15:39:35.787 | 2026-10-19 15:39:38.096 |
| NEWBURY | `CLN_NEWBURY_BOSTON_ACCOUNTS` | 770 | 2026-10-19 15:41:01.806 | 2026-10-19 15:41:03.950 |
| NEWBURY | `CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT` | 365 | 2026-10-19 15:40:44.977 | 2026-10-19 15:40:46.853 |
| NEWBURY | `CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO` | 426 | 2026-10-19 15:40:51.824 | 2026-10-19 15:40:53.495 |
| NEWBURY | `CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST` | 2,190 | 2026-10-19 15:40:46.883 | 2026-10-19 15:40:48.530 |
| NEWBURY | `CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT` | 2,795 | 2026-10-19 15:40:48.568 | 2026-10-19 15:40:49.844 |
| NEWBURY | `CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS` | 20,048 | 2026-10-19 15:40:49.874 | 2026-10-19 15:40:51.796 |
| NEWBURY | `CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP` | 75,264 | 2026-10-19 15:40:57.710 | 2026-10-19 15:40:59.873 |
| NEWBURY | `CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP` | 41,905 | 2026-10-19 15:40:59.895 | 2026-10-19 15:41:01.771 |
| NEWBURY | `CLN_NEWBURY_BOSTON_TRIAL_BALANCE` | 16,320 | 2026-10-19 15:40:53.519 | 2026-10-19 15:40:57.687 |

All times PDT. Rows: HHG 288,994, NEWBURY 160,083, total 449,077 (measured
`COUNT(*)` agrees with the metadata on every table profiled).

## Lane declaration

**Confirmed by the owner at stop 1** (2026-10-20). `HHG` is Heritage Golf. The
owner has confirmed neither name is in the master.

| Lane | Source tables | Notes |
|---|---|---|
| `HHG` | `CLN_HERITAGE_GOLF_ACCOUNTS`, `_CLUB_LIST`, `_FORECAST_ANAPLAN`, `_REFERENCES`, `_ROUNDS_DETAIL`, `_TR12_DATA` (6) | **confirmed**. Heritage Golf: 50 golf clubs, one `PROPERTY_NAME` ("Heritage Golf"). |
| `NEWBURY` | `CLN_NEWBURY_BOSTON_ACCOUNTS`, `_OPERATING_STATS_BGT`, `_OPERATING_STATS_EVENTSANDOOO`, `_OPERATING_STATS_FCST`, `_OPERATING_STATS_PYACT`, `_OPERATING_STATS_SHOPS`, `_OTB_1DAY_PICKUP`, `_OTB_3DAY_PICKUP`, `_TRIAL_BALANCE` (9) | **confirmed**. The Newbury Boston, one hotel (`HOTEL_ID` 3338). |
| out of scope | none | **confirmed** |

**Lane names** (D-32): neither appears under `docs/completed-builds/` or `sql/`,
as a `SOURCE_LANE` in `DEV_G2M_AI`, or in any `DEV_G2M_AI` object name.

```sql
select table_schema, table_name, row_count, bytes, last_altered
from CLN.INFORMATION_SCHEMA.TABLES
where table_schema = 'BOX_INVESTMENT_DATA'
order by table_name;
```

**Common to every table** (*measured*): `SOURCE_FOLDER` and `PROPERTY_NAME`
are constant within a lane. Most tables carry their own lineage columns
(`SOURCE_FILE_PATH`, `SOURCE_ROW_NUMBER`, `FILE_DATE`); the two `ACCOUNTS`
dictionaries carry `SOURCE_TABLE`, naming the fact table each entry came from.

---

## What every lane must supply to staging

**Every fact staging table** supplies all of these; the classification join
needs them. A lane missing one is a finding to raise, not a gap to work around
— except `SOURCE_LINE_KEY`, which may be null if the source has no natural line
identifier. **Pacing and dictionary staging tables keep their own shape**, plus
`RUN_ID`, `SOURCE_LANE` and `SOURCE_TABLE`; they never feed the seeder.

| | Used for |
|---|---|
| `SOURCE_LANE` | Key part. The declared lane name. |
| `SOURCE_SITE_CODE` | Key part. The lane's own site, property or entity identifier. |
| `DEPARTMENT` | Key part, as the source holds it. |
| `ACCOUNT_NUMBER` | Raw, malformed and blank included. |
| `STAT_ACCOUNT` | Raw, where the lane has one. |
| `ACCOUNT_KEY` | `coalesce(nullif(trim(ACCOUNT_NUMBER),''), nullif(trim(STAT_ACCOUNT),''), nullif(trim(SOURCE_ITEM_ID),''), '~BLANK~')`, built here (D-06). |
| `RECORD_TYPE` | Key part. `AMOUNT` or `STATISTIC`, normalised here. |
| `RECORD_TYPE_SOURCE` | The stating column, or the derivation rule. Never null. |
| `STAT_UNIT_FAMILY` | Where a row carries both a money amount and a statistic value (D-29). |
| `ACCOUNT_DESC` | Carried, and shown in the review report. |
| `ASSET_NAME` | The site or property name, where a dimension supplies one. |
| `DEPARTMENT_NAME` | Where the lane supplies one; null otherwise. |
| `PERIOD_END` | A date, derived per lane. |
| `SCENARIO` | The named scenario, verbatim. |
| `SOURCE_AMOUNT` | As booked, **sign included**. Never strip a negative - that is a silent repair (invariant 3). |
| `STAT_VALUE` | Where the lane holds a statistic measure. |
| `IS_SUBTOTAL` | The source's own total or rollup row. Default `FALSE`. |
| `SUBTOTAL_SOURCE` | How a subtotal was identified, or that the source gives no way to tell. |
| `SOURCE_TABLE` | Which source table the row came from. Never null. |
| `SOURCE_LINE_KEY` | The natural key making a source row addressable, or null. |

---

## Per-lane findings

### Table roles

| Lane | Table | Role (proposed) | Basis |
|---|---|---|---|
| HHG | `TR12_DATA` | **fact** | GL by entity-department-account, monthly, actuals |
| HHG | `FORECAST_ANAPLAN` | **fact** | forecast by club and line item, monthly |
| HHG | `ROUNDS_DETAIL` | **fact, statistics** | rounds played per club per day (Q-07) |
| HHG | `ACCOUNTS` | dictionary | account strings seen in the two money tables |
| HHG | `CLUB_LIST` | dictionary | club code, name, acquisition date, status by year |
| HHG | `REFERENCES` | dictionary | club code to GL entity number (`CLUB_NUMBER`) |
| NEWBURY | `TRIAL_BALANCE` | **fact** | GL, monthly, actual + forecast + budget columns |
| NEWBURY | `OPERATING_STATS_BGT` | **fact** (Q-12) | daily budget rooms and room revenue, 2026 |
| NEWBURY | `OPERATING_STATS_PYACT` | **fact** (Q-12) | daily actual rooms and room revenue, 2019 - 2026-09-24 |
| NEWBURY | `OPERATING_STATS_FCST` | **pacing** (Q-12) | six report-date snapshots of the same 2026 stay dates |
| NEWBURY | `OTB_1DAY_PICKUP` | **pacing** | on-the-books by report date and stay date |
| NEWBURY | `OTB_3DAY_PICKUP` | **pacing** | as above, a different report-date set |
| NEWBURY | `OPERATING_STATS_SHOPS` | **pacing-shaped, competitor data** (Q-13) | rate shops of eight comp-set names by report date and stay date |
| NEWBURY | `OPERATING_STATS_EVENTSANDOOO` | dictionary (Q-12) | daily event notes plus out-of-order / overbook counts |
| NEWBURY | `ACCOUNTS` | dictionary | one entry per trial-balance key, all described |

---

### Lane `HHG`

#### `CLN_HERITAGE_GOLF_TR12_DATA` — fact

- **Shape** (*measured*): long. 164,760 rows = 13,730 source lines × 12
  month-ends; `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER` is 13,730 distinct, and with
  `PERIOD_DATE` added it is unique on every row. One file (`FILE_DATE`
  2026-10-09 22:24:41 UTC). Columns: `ACCOUNT_CODE`, `PERIOD_DATE`,
  `SCENARIO`, `AMOUNT`. No department, site, description or type column of its
  own. Identity: `count(source) = count(staged)`, 0 columns unpivoted.
- **Account number** (*measured*): `ACCOUNT_CODE` matches `9999-999-99999` on
  100% of rows (13,729 distinct). Structure: **entity (4) - department (3) -
  natural account (5)**. 54 entities, 11 departments, 270 natural accounts. No
  blank account.
- **Site** (*measured*): the entity segment is the club's GL number.
  `REFERENCES.CLUB_NUMBER` names 45 entities; **9 entities are in TR12 and not
  in `REFERENCES`**: 9050-9056, 9099, 9102, on 17,124 rows (Q-03).
- **Department** (*measured*): segment 2, 11 codes (901-909, 950, 999). **No
  dictionary names them**: `ACCOUNTS.DEPARTMENT_DESCRIPTION` is null on all
  13,759 rows. `DEPARTMENT_NAME` would be null.
- **Section source** (*measured*): first digit of the natural account
  (segment 3, character 1 of 5). Present: 4 (2,959 strings), 5 (917), 6
  (4,332), 7 (4,537), 8 (366), 9 (618). **No 1, 2 or 3: there is no balance
  sheet in this lane.**
- **Digit 9 is department 999, and looks like statistics** (*measured*): every
  digit-9 row is in department 999 and every department-999 row is digit 9
  (7,416 rows, 16 natural accounts 90000-96000, 618 strings). **None of the
  7,416 values has a fraction**; outside it 71,122 of 157,344 do. Nothing in
  the source names them (Q-01).
- **`RECORD_TYPE`** (*measured*): no stating column. Proposed: `AMOUNT` on
  every row, unless the owner rules department 999 statistics (Q-01).
- **Category** (*measured*): `SCENARIO` holds `ACT` (109,840 rows, Jan-Aug 2026)
  and `PY ACT` (54,920 rows, Sep-Dec 2025). Both proposed `ACTUAL`, scenario
  verbatim (Q-06).
- **Coverage** (*measured*): 2025-09-30 to 2026-08-31, every account in every
  month, all month-end dates.
- **Signs** (*measured*): revenue and expense both book positive. Digit 4
  positive 306.0M (ACT), digits 5-7 positive. Negative-amount rows exist in
  every section.
- **Blank and malformed**: none. **Duplicates** (*measured*): 12 rows on one
  key: `9102-950-49992` appears on two source lines (rows 579 and 9042) with
  different amounts in 4 of 12 months. Two real lines; kept (Q-08).
- **Descriptions** (*measured*): **`ACCOUNTS.ACCOUNT_DESCRIPTION` is null for
  all 13,729 TR12 strings.** `ACCOUNT_DESC` will be null for this table (Q-02).
- **Subtotals**: the source gives no way to tell. No level, total or rollup
  column; every row is an entity-level account. `IS_SUBTOTAL = FALSE`.
- **`SOURCE_LINE_KEY`** (proposed): `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER|PERIOD_DATE`
  (unique, *measured*).
- **Period**: `PERIOD_DATE` (already month-end).

#### `CLN_HERITAGE_GOLF_FORECAST_ANAPLAN` — fact

- **Shape** (*measured*): long. 19,080 rows = 53 locations × 30 line items ×
  12 months; `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER|PERIOD_DATE` unique. One file.
- **No account number.** The identifier is `LINE_ITEM`, 30 values, all named in
  words (for example `Green Fees`, `Food & Beverage Labor`, `Merchandise Cost of
  Sales`). Proposed `SOURCE_ITEM_ID = LINE_ITEM`, so `ACCOUNT_KEY` is the line
  item name (D-06).
- **Site**: `LOCATION` is a club *name*, not a code. 14 of the 53 do not match a
  `CLUB_LIST.CLUB_NAME` exactly (spellings differ, for example `Savannah
  Quarters Country Club` against `The Club at Savannah Quarters`; two,
  `Independence Country Club` and `Old Natchez Country Club`, appear nowhere
  else) (Q-03).
- **Section source**: no digit. The line item name states the section in words
  (Q-04 has the proposed map).
- **Category** (*measured*): one scenario, `KFCST FINAL`, all rows. Proposed
  `FORECAST`.
- **Coverage** (*measured*): 2026-01-31 to 2026-12-31, every month.
- **Signs** (*measured*): **expense books negative** (every Expense, Labor and
  Cost of Sales line sums negative), revenue positive. The opposite convention
  to TR12 within one lane.
- **Subtotal** (*measured, verified*): `LOCATION = '+All Regions'` equals the
  sum of the other 52 locations on **all 360** line-item × month cells (largest
  difference 0.000007). Proposed `IS_SUBTOTAL = TRUE` on those 360 rows (Q-05).
- **`SOURCE_LINE_KEY`** (proposed): `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER|PERIOD_DATE`.

#### `CLN_HERITAGE_GOLF_ROUNDS_DETAIL` — fact, statistics

- **Shape** (*measured*): long. 91,300 rows = 50 clubs × 1,826 days
  (2022-01-01 to 2026-12-31), one row per club per day, no duplicates, every
  `CLUB_CODE` in `CLUB_LIST`. `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER` is 1,826
  distinct, one per day, so the file held one column per club.
- **Measure**: `ROUNDS_COUNT`, total 6,959,463.04. 43,437 zero rows, **175
  negative**, 16 fractional (2022-2024 only).
- **Future dates** (*measured*): 3,650 rows dated after the 2026-10-19 load,
  all zero (Q-07).
- **Role**: rounds played is a statistic. Proposed `RECORD_TYPE = STATISTIC`,
  `STAT_VALUE = ROUNDS_COUNT`, `SOURCE_AMOUNT` null.
- **No account**: no account, stat account or line item. `ACCOUNT_KEY` would be
  `~BLANK~` on every row, one key per club (Q-07).
- **Unit**: the source states none beyond the column name. `H2` would be the
  source's own name, `ROUNDS_COUNT` (D-38); `METRIC_UNIT` null.
- **Category**: no scenario column. Proposed `ACTUAL` by `SOURCE_TABLE` (Q-07).
- **`SOURCE_LINE_KEY`** (proposed): `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER|CLUB_CODE`.

#### Dictionaries

- **`ACCOUNTS`** (*measured*): 13,759 rows, unique on `FULL_ACCOUNT_STRING`.
  13,729 from TR12 (the account code; `ACCOUNT_CODE` and `DEPARTMENT_CODE`
  parsed out, every description null) and 30 from Anaplan (the line-item name
  in `FULL_ACCOUNT_STRING`, codes null). `SUBACCOUNT_*`, `PARENT_CODE`, `ALIAS`
  null on every row. `FIRST_SEEN_DATE` = `LAST_SEEN_DATE` = 2026-10-09.
  **Supplies nothing the seed can use beyond the codes the facts already hold.**
- **`CLUB_LIST`** (*measured*): 50 clubs, unique `CLUB_CODE`, acquisition date
  2020-01-30 to 2026-06-15, `STATUS_2022..2026` (`DEV` or `SS`). All 50 appear
  in `ROUNDS_DETAIL`.
- **`REFERENCES`** (*measured*): 45 rows, unique on `CLUB_CODE` and on
  `CLUB_NUMBER`. `CLUB_NUMBER` is the TR12 entity. **The five clubs acquired
  most recently are missing** (`PLS`, `OCA`, `PLN`, `PLA`, `SOU`).
  **`WORKSHEET_CODE` differs from `CLUB_CODE` on 27 of 45 rows** in a pattern
  that looks shifted rather than wrong per row (for example `BAS` pointing to
  `2025 BOC YE Fcast.xlsm`) (Q-09).

#### How HHG accounts map onto the standard hierarchy (proposed)

| Source | Rule | `H1` / `H2` |
|---|---|---|
| TR12 natural account digit 4 | §5 digit table | Revenue / `Revenue` |
| digit 5 | §5 | Expense / `Cost of Goods Sold` |
| digit 6 | §5 | Expense / `Payroll` |
| digit 7 | §5 | Expense / `Operating Expenses` |
| digit 8 | §5 | Below the Line / `Other Income / (Expense)` |
| digit 9 (= dept 999) | §5, or Statistic (Q-01) | Allocations & Reserves / `UNCLASSIFIED`, or Statistic / `STAT_9` |
| Anaplan line items | words (Q-04) | see Q-04 |
| `ROUNDS_COUNT` | `RECORD_TYPE` | Statistic / `ROUNDS_COUNT` |

Nothing states a Level 2: `H3` seeds `UNCLASSIFIED`. Without descriptions, D&A
and Income Taxes cannot be found in TR12; they arrive as digit-7 or digit-8
accounts.

---

### Lane `NEWBURY`

#### `CLN_NEWBURY_BOSTON_TRIAL_BALANCE` — fact

- **Shape** (*measured*): **wide by measure.** 16,320 rows, each with
  `ACTUAL_AMOUNT`, `FORECAST_AMOUNT` and `BUDGET_AMOUNT`. Unique on
  `FULL_ACCOUNT_KEY|PERIOD_DATE|VALUE_TYPE`. **3 columns unpivoted**, so the
  identity is `16,320 × 3 = 48,960` staged rows, `INCLUDE NULLS` (§8). Non-null
  cells: actual 14,156, forecast 2,873, budget 6,504 = 23,533; the other
  25,427 staged rows carry a null amount by construction (Q-10).
- **Account number** (*measured*): `FULL_ACCOUNT_KEY` matches
  `9999-999999-9999-999999-9999` on every row: **department (4) - account (6)
  - sub-account (4) - 000000 - 0000**; segments 4 and 5 are zero on every row.
  `ACCOUNT_KEY` (source column) equals segments 1-3 on all 16,320 rows.
  `DEPARTMENT`, `ACCOUNT`, `SUBACCOUNT` carry `code-label` text, for example
  `1000-Rooms`, `410005-Transient BAR`, `0410-Room Nights Stat`. 770 distinct
  keys, 286 accounts, 24 departments.
- **Site**: `BUSINESS_UNIT` is `KANRZZ` on every row (Q-11).
- **Department**: segment 1, named by the `DEPARTMENT` text and the dictionary.
- **Section source** (*measured*): first digit of the 6-digit account. Present
  4, 5, 6, 7, 8, 9. **No 1-3: no balance sheet in this lane either.**
- **`RECORD_TYPE`** (*measured*): stated by `VALUE_TYPE`: `Amount` 12,924 rows,
  `STAT` 3,396. **11 full keys carry both an Amount and a STAT row** (the
  `920000-Allocation to Department` keys and `1000-610115-0620`). `RECORD_TYPE`
  in the key is what keeps them apart.
- **Statistic unit vocabulary** (*measured*): the sub-account labels on STAT
  rows: `Hours Hourly` (0621), `Overtime Hours Hourly` (0631), `Hours Mgmt`
  (0620), `Covers STAT Paid` (0420), `Room Nights Stat` (0410), `Overtime Hours
  Mgmt` (0630), `Misc Units` (0829), `Kgal Units` (0822), `CCF Units` (0823),
  `MLbs Units` (0826), `Revenue STAT Generic` (0432), `Cubit Meters Units`
  (0825), `Therms Units` (0821), `KwH Units` (0820), plus four department codes
  on allocation STAT rows (2001, 2043, 2044, 1000) and `0000-Default` on
  `991954-Out of Order Rooms`. Proposed `H2` for STATISTIC keys: the
  sub-account label as stated. These are units the source names, so
  `METRIC_UNIT` could carry them; proposed to keep it null (D-38) and use them
  as `H2` only.
- **Category** (*measured*): from the measure column. `ACTUAL_AMOUNT` →
  `ACTUAL`, `FORECAST_AMOUNT` → `FORECAST`, `BUDGET_AMOUNT` → `BUDGET`.
  Scenario: `FORECAST_VERSION` (`Forecast9`, `Forecast10`) on forecast cells;
  none stated for actual or budget.
- **Coverage** (*measured*): actual 2025-01 to 2026-09 (Sep: 716 of 720 keys);
  forecast 2026-09 (`Forecast9`, 713 rows) and 2026-10 to 12 (`Forecast10`, 716
  rows a month, plus 4 `Forecast9` rows a month, all zero); budget 2026-01 to
  12, 542 of 720 keys a month. **Sep 2026 carries both actual and forecast**
  on 709 keys (Q-15).
- **Signs** (*measured*): revenue and expense both positive. Section 8 actual
  is **-154,987,494.35**, driven by `870215-Depr Expense-FF&E Reserve` at
  **-206,407,739.14** over 12 rows (Q-14).
- **Subtotals** (*measured*): `NODE_TYPE` is `Leaf` on every row. Proposed
  rule: `IS_SUBTOTAL = (NODE_TYPE <> 'Leaf')`, true on no row in this extract.
- **Status/state**: none beyond `NODE_TYPE`.
- **Blank and malformed**: none.
- **`SOURCE_LINE_KEY`** (proposed): `FULL_ACCOUNT_KEY|PERIOD_DATE|VALUE_TYPE`
  plus the unpivoted measure name.
- **Period**: `PERIOD_DATE` (month-end).

#### `CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT`, `_PYACT`, `_FCST` (Q-12)

Same columns: `HOTEL_ID` (3338), `STAY_DATE`, `SCENARIO`, `ROOMS`, `REVENUE`,
`YEAR_MONTH`, `FILE_REPORT_DATE`. Each row carries both a statistic (rooms) and
money (room revenue).

| Table | Rows | `SCENARIO` | Stay dates | Report dates | Notes (*measured*) |
|---|---|---|---|---|---|
| BGT | 365 | `Budget` | 2026-01-01 .. 2026-12-31 | 1 (2026-09-28) | one row per day |
| PYACT | 2,795 | `Actual` | 2019-01-01 .. 2026-09-24 | 1 (2026-09-28) | one row per day; **29 days missing, 2021-05-01 .. 2021-05-29** |
| FCST | 2,190 | `Actual` 1,458, `AFF 9.5` 732 | 2026-01-01 .. 2026-12-31 | 6 (2026-09-21 .. 09-28) | each report date repeats all 365 days; 117 stay dates change between reports |

- **Proposed** for BGT and PYACT: facts, `RECORD_TYPE = AMOUNT`, `SOURCE_AMOUNT =
  REVENUE`, `STAT_VALUE = ROOMS`, `STAT_UNIT_FAMILY` stated as rooms (D-29).
  Category from `SCENARIO` (`Budget` → BUDGET, `Actual` → ACTUAL). No account:
  `ACCOUNT_KEY` `~BLANK~`.
- **Proposed** for FCST: pacing, as-of `FILE_REPORT_DATE`, six snapshots. It
  carries actual stay dates and `AFF 9.5` forecast stay dates in every
  snapshot.
- **Overlap, unverified**: these restate room revenue that the trial balance
  also books (account 41xxxx). Not compared yet; a monthly comparison is
  possible for complete months only.

#### `CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP`, `_OTB_3DAY_PICKUP` — pacing

- **As-of exists** (*measured*): `REPORT_DATE` is distinct from `STAY_DATE`.
  1DAY: 18 report dates (2025-09-15..25 and 2026-09-14..24); 3DAY: 10 report
  dates (2025-09-14..28 and 2026-09-13..27). Stay dates 2025-01-01 to
  2028-03-30. **Pacing is derivable.**
- **Shape**: `MARKET_SEGMENT`, `ROOMS`, `REVENUE`, `AVAILABLE_ROOMS`, `POSTPD`,
  `DATA_SOURCE` (`OPERA` / `PBCS`), `DATA_TYPE` (`ACTUALS`, `OTB-7`, `OTB-2`,
  `OTB-1`, `OTB0`, `OTB1`, `OTB7`). Unique on report date, stay date, segment,
  data type and source. `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER` unique on both.
- **Code columns tested against the GL format**: `MARKET_SEGMENT` values are
  like `T-BAR`, `G-Corporate`, `O-NoShow`; not accounts. Never mapped to
  `ACCOUNT_NUMBER` (D-37).
- **Duplicates across the two** (*measured*): 6 report dates are shared and
  **16,908 rows are identical in every column**; no shared key differs in
  value. Both kept, tagged by `SOURCE_TABLE` (D-25, Q-16).
- **`REPORT_DATE` never equals `FILE_REPORT_DATE`** (all 75,264 1DAY rows): the
  report date is the business as-of, the file date is the export.

#### `CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS` — competitor rate shops (Q-13)

20,048 rows: 8 `COMP_HOTEL_NAME` values × 2,506 rows each, `OTA`
(`branddotcom` 14,416, `expedia` 5,632), `IS_BAR` half true, `RATE_VALUE`
(913 zero), `RATE_COMMENT` (`rates.soldout` 782, restriction and no-BAR notes
131). Reported dates 2026-09-19..26 (4), stay dates 2026-09-22..2027-09-26.
One comp name is the literal `~` (2,506 rows). `SHOP_HOTEL_ID` is 3338 on every
row (the shopper, not the shopped). As-of exists (`REPORTED_DATE`). Not the
property's own money or statistics.

#### `CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO` — dictionary (Q-12)

426 rows, one per `OCC_DATE` (2026-08-01..2027-09-30), 2 file report dates.
`DAILY_EVENT` text on 166 rows (conventions, games, holidays);
`OUT_OF_ORDER_ROOMS` total 54, `OVERBOOK_ROOMS` none. Forward-looking
calendar, not a ledger.

#### `CLN_NEWBURY_BOSTON_ACCOUNTS` — dictionary

770 rows, unique on `FULL_ACCOUNT_STRING`, and **exactly the trial balance's
770 keys** (none missing either way). Account, department and sub-account
descriptions present on every row; `PARENT_CODE` and `ALIAS` null on every row.
Supplies `DEPARTMENT_NAME` and `ACCOUNT_DESC`.

#### How NEWBURY accounts map onto the standard hierarchy (proposed)

| Account digit | `H1` / `H2` |
|---|---|
| 4 | Revenue / `Revenue` |
| 5 | Expense / `Cost of Goods Sold` |
| 6 | Expense / `Payroll` |
| 7 | Expense / `Operating Expenses` |
| 8 | Below the Line / `Other Income / (Expense)`; except D&A and income tax named outright (Q-14) |
| 9 | Allocations & Reserves / `UNCLASSIFIED` (`920000` allocations, `999900` FF&E reserve) |
| any, `VALUE_TYPE = STAT` | Statistic / the sub-account label |

Section 8 holds management fees (80xxxx), lease income (805xxx), taxes and
insurance (83-84xxxx), interest (860xxx), **depreciation (870xxx, 7 accounts)**,
**amortization (880420/430/440)** and **`890010-Federal Income Tax`**.

---

## Corrections

**When a measurement contradicts something written here, correct it and say
so.** A finding that a documented rule is wrong is worth more than a clean run.

- **The template's table-listing query named `CLEAN`.** For this build it is
  `BOX_INVESTMENT_DATA`; corrected above.
- **The template's `ACCOUNT_KEY` row omitted `SOURCE_ITEM_ID`.** D-06 includes
  it; corrected above.
- **`AGENTS.md`, "Approvals"**, still says "profiling queries ... against
  `CLN.CLEAN`" after commit 65a99ee. `CLAUDE.md` §2 says `CLN.CLEAN` means this
  build's `CLN.<SOURCE>`; followed here.
