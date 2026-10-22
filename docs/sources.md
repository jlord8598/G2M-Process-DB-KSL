# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

---

## Source schema

`CLN.BOX_INVESTMENT_DATA` (owner, build 03). **Load freeze window (D-43): 48
hours from the owner's stop 1 answer, taken from the database clock:
2026-10-21 11:43:21.114 PDT to 2026-10-23 11:43:21.114 PDT** (query
`01c7e243-020a-3b28-0003-4ff21baac50e`).

Listing at 2026-10-21 11:36:34 PDT (query `01c7e23c-020a-3b2a-0003-4ff21baa4756`):
29 base tables. `last_altered` of every proposed in-scope table:

| Table | Rows | Bytes | `last_altered` (PDT) |
|---|---|---|---|
| `CLN_HERSHA_ACCOUNTS` | 1,196 | 23,552 | 2026-10-19 15:39:49.871 |
| `CLN_HERSHA_GL_ACTUAL` | 50,903 | 1,460,224 | 2026-10-19 15:39:46.615 |
| `CLN_HERSHA_GL_STAT` | 2,272 | 75,776 | 2026-10-19 15:39:48.593 |
| `CLN_INVITED_CLUBS_ACCOUNTS` | 13,314 | 697,856 | 2026-10-19 15:40:44.535 |
| `CLN_INVITED_CLUBS_ESSBASE_EXTRACT` | 17,100,504 | 267,546,624 | 2026-10-19 15:40:41.378 |
| `CLN_INVITED_CLUBS_META_ACCOUNT` | 9,244 | 893,952 | 2026-10-19 15:39:52.237 |
| `CLN_INVITED_CLUBS_META_DEPARTMENT` | 799 | 72,704 | 2026-10-19 15:39:53.835 |
| `CLN_INVITED_CLUBS_META_ENTITY` | 5,472 | 470,528 | 2026-10-19 15:39:57.166 |
| `CLN_INVITED_CLUBS_META_LOCATION` | 1,507 | 119,808 | 2026-10-19 15:39:58.763 |
| `CLN_INVITED_CLUBS_META_SUBACCOUNT` | 1,198 | 99,840 | 2026-10-19 15:39:55.373 |
| `CLN_BEAUMIER_ACCOUNTS` | 2,258 | 36,352 | 2026-10-19 15:39:28.345 |
| `CLN_BEAUMIER_BP` | 35,567 | 785,920 | 2026-10-19 15:39:22.897 |
| `CLN_BEAUMIER_BUDGET` | 17,577 | 420,352 | 2026-10-19 15:39:24.788 |
| `CLN_BEAUMIER_CANCELLATIONS` | 18,930 | 666,112 | 2026-10-19 15:39:26.608 |

Max in-scope `last_altered`: **2026-10-19 15:40:44.535 PDT**. Every milestone's
checks are preceded by a comparison against this table. Row counts are from
`INFORMATION_SCHEMA` metadata and are re-measured with `COUNT(*)` at profiling.

## Lane declaration

**Ask the owner. Do not infer lane names from source system names.**

**Confirmed by the owner at stop 1** (lane names, table assignment, and that none
of the three names is in the master):

| Lane | Source tables | Notes |
|---|---|---|
| `HERSHA` | `CLN_HERSHA_ACCOUNTS`, `_GL_ACTUAL`, `_GL_STAT` | 3 tables |
| `INVITED_CLUBS` | `CLN_INVITED_CLUBS_ACCOUNTS`, `_ESSBASE_EXTRACT`, `_META_ACCOUNT`, `_META_DEPARTMENT`, `_META_ENTITY`, `_META_LOCATION`, `_META_SUBACCOUNT` | 7 tables; `ESSBASE_EXTRACT` is 17.1M rows |
| `BEAUMIER` | `CLN_BEAUMIER_ACCOUNTS`, `_BP`, `_BUDGET`, `_CANCELLATIONS` | 4 tables |

**Out of scope (owner):** the 15 build 02 tables, `CLN_HERITAGE_GOLF_*` (6) and
`CLN_NEWBURY_BOSTON_*` (9). Not profiled beyond identifying them.

3 + 7 + 4 + 15 = 29 = every table listed.

**Name check (D-32):** `HERSHA`, `INVITED_CLUBS` and `BEAUMIER` appear in no file
under `docs/completed-builds/` and are not a `SOURCE_LANE` value in
`XREF_ACCOUNT_CLASSIFICATION` or any of the six SEM_AI tables (present:
`KSL_SELECT_SERVICE`, `PEREGRINE_RESORTS`, `HHG`, `NEWBURY`). The master is the
owner's to check.

A lane is one coherent source set that gets its own staging models and one
transformation procedure. Two tenants of one system are usually two lanes, not
one, if their account vocabularies differ.

**Granted tables.** List everything the role can see, then assign each table to
a declared lane or mark it out of scope. **Being able to see a table does not
put it in scope** ? a previous build's grants may still be in place. The owner
confirms before any model is written.

```sql
select table_schema, table_name, row_count, bytes, last_altered
from CLN.INFORMATION_SCHEMA.TABLES
where table_schema = 'BOX_INVESTMENT_DATA'
order by table_name;
```

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
| `ACCOUNT_KEY` | `coalesce(nullif(trim(ACCOUNT_NUMBER),''), nullif(trim(STAT_ACCOUNT),''), '~BLANK~')`, built here. |
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

Every statement is *measured* against this extract unless marked *unverified*.
Queries were run on 2026-10-21 between 11:43 and 11:52 PDT.

### Lane `HERSHA` (3 tables)

#### `CLN_HERSHA_GL_ACTUAL` - fact

- **Shape** (*measured*): 50,903 rows; one row per company x month x account x
  department x rev/spend category x job x meal period; that 7-column key is
  unique (0 duplicate groups).
  - **Four measure columns:** `ACTUAL_AMOUNT`, `FORECAST_AMOUNT`,
    `ACTUAL_STAT`, `FORECAST_STAT`.
  - 50,723 rows carry both an amount and a stat.
  - Actual months are 2026-01 and 2026-02 only; forecast months are 2026-03 to
    2026-12. No month carries both.
- **Proposed staging:** wide by category, so **2 branches unpivot** (actual,
  forecast), each carrying its amount and its stat on one row (D-29). Identity:
  `count x 2`. This is preferred over a 4-way unpivot, which would split the
  money and its statistic onto separate rows.
- **Site**: `COMPANY_ID` (15 hotels, `COMPANY_NAME` states each).
- **Department**: `DEPARTMENT_CODE` (e.g. `CC225`); `DEPARTMENT_DESCRIPTION`
  supplies the name. 180 rows have a blank department.
- **Account**: `ACCOUNT_CODE`, 25 six-digit codes, with `ACCOUNT_DESCRIPTION`.
  `GL_CODE` states the section in words: `Revenue`, `Expense`, `Stat`.
- **Section** (*measured*):
  - The first digit agrees with `GL_CODE` (4 revenue, 5 cost of sales, 6
    expense), but **does not follow the §5 digit table below 4-5**:
    - 6xxxxx holds payroll (600000-603200) and also `610000 Operating
      Expenses` and `630000 Management Fees`.
    - 7xxxxx holds `700000 Non-Operating Income` and `714000 Non-Operating
      Expenses`.
  - The digit alone would misplace 610000/630000 (as Payroll) and 700000/714000
    (as Operating Expenses).
  - **Proposed: a 25-row account map** (Q-03).
- **`RECORD_TYPE`**:
  - `999999 Available Rooms` is `GL_CODE = 'Stat'`, carries stat columns only
    (180 rows), and so is STATISTIC.
  - Every other account is AMOUNT, with `STAT_VALUE` and `STAT_UNIT_FAMILY` set
    where the stat is non-null (D-29).
  - The same account does not carry both types.
- **Signs** (*measured*): revenue books **negative**, expense positive
  (credit/debit convention). For example `400000 Transient Rooms Revenue`
  actual -24,014,835.46. See Q-04.
- **Category**: by measure column. `ACTUAL_*` -> ACTUAL, `FORECAST_*` ->
  FORECAST. No scenario name is stated.
- **Subtotals**: the source gives no way to tell; every row is account-level.
- **`SOURCE_LINE_KEY`**: `<measure>_SOURCE_FILE_PATH|<measure>_SOURCE_ROW_NUMBER`
  plus the branch. Each file and row pair is unique (50,903 distinct).
- **Blank**: 0 blank accounts; 180 blank departments.

#### `CLN_HERSHA_GL_STAT` - fact, statistics

- **Shape**: 2,272 rows, the same 7-column key, unique. 2026-01 and 2026-02
  only, actual only. The table adds one extra column, `FLAG_COL_2`, which is
  empty on every row profiled.
- **Accounts**: 5 `ST` codes: `ST1000 Rooms Sold`, `ST1010 F&B Covers`,
  `ST1020 Spa Covers`, `ST1030 Labor Hours`, `ST1040 Contract Labor Hours`.
  `GL_CODE` says `Revenue` or `Expense`.
- **The counts sit in `ACTUAL_AMOUNT`**: 686,105.65 in total. `ACTUAL_STAT` is
  0 on every row. The table name and the `ST` codes say these are statistics.
  Proposed: STATISTIC, with the value moved to `STAT_VALUE`, as in the HHG
  dept 999 precedent (Q-02).
- **Unit vocabulary**: the account descriptions (Rooms Sold, Covers, Hours).
  Proposed `H2` = the `ST` code, with the description as `ACCOUNT_DESC`.
  `METRIC_UNIT` null (D-38).

#### `CLN_HERSHA_ACCOUNTS` - dictionary

1,196 rows, **30 distinct `FULL_ACCOUNT_STRING`** (the account code alone),
repeated per department. `ACCOUNT_DESCRIPTION` is present on all rows;
department descriptions on 1,031. `PARENT_CODE` is null. It states nothing the
facts lack, and is staged losslessly.

### Lane `INVITED_CLUBS` (7 tables)

#### `CLN_INVITED_CLUBS_ESSBASE_EXTRACT` - fact, 17,100,504 rows

- **Shape** (*measured*):
  - Taken from the column list first, before any full scan, as instructed:
    **wide by measure**. `ACTUAL_AMOUNT`, `FORECAST_AMOUNT` and `BUDGET_AMOUNT`
    give **3 columns unpivoted**, so the identity is `17,100,504 x 3 =
    51,301,512` staged rows, nulls kept.
  - Dimensions: `REPORT_LEVEL`, `ENTITY`, `ACCOUNT`, `DEPARTMENT`,
    `SUBACCOUNT`, `LOCATION`, `VERSION_NAME`, `DAY_OF_MONTH`, `PERIOD_DATE`.
    These 9 are unique (0 duplicate groups) and never blank.
  - Each measure carries its own file date, path and row.
- **Breakdown** (full scan, query `01c7e243-020a-3b2d-0003-4ff21baa2ace`;
  the 14 groups sum to 17,100,504):

  | `REPORT_LEVEL` | `VERSION_NAME` | `DAY_OF_MONTH` | Rows | Measures populated |
  |---|---|---|---|---|
  | DETAIL | Load | Day00 | 5,519,673 | actual (forecast and budget on 10,488) |
  | DETAIL | Load | Day01-31 | 7,796,169 | actual |
  | DETAIL | Load | TotalDOMEnter | 77,937 | actual |
  | DETAIL | Input | Day00 | 2,094,868 | all three |
  | DETAIL | Input | Day01-31 | 1,422,688 | forecast, budget |
  | DETAIL | Input | TotalDOMEnter | 34,997 | forecast, budget |
  | DETAIL | Central Load | Day00 | 121,325 | forecast, budget |
  | DETAIL | Proforma Adj | Day00 | 3,428 | actual (+1 forecast) |
  | DETAIL | Operations Adj | Day00 | 1,376 | forecast, budget |
  | EBITDA_SUMMARY | Load / Input / Central Load / Operations Adj / Proforma Adj | Day01-31 | 28,043 | all three |

  Non-null cells: actual 13,948,931, forecast 2,871,232, budget 1,421,449.
  The rest of the 51.3M staged rows are null by construction.
- **Period**:
  - `PERIOD_DATE` is a month-end, 2023-01-31 to 2026-12-31 (48 months).
  - `DAY_OF_MONTH` is `Day00` (a monthly value), `Day01`-`Day31` (daily), or
    `TotalDOMEnter`.
  - Daily rows use about 45 accounts (covers, rounds, green fees, wages and
    hours); 6 accounts appear both monthly and daily.
- **Site**: `ENTITY` (780 values, all in `META_ENTITY`).
  - `LOCATION` (1,263) and `SUBACCOUNT` (675) are further dimensions, carried
    but not in the key.
  - Proposed key: entity x department x account. **225,833 distinct
    combinations** = the classification keys (before `RECORD_TYPE`).
- **Account**: `ACCOUNT` is an Essbase member name, 1,544 distinct.
  - 1,083 follow `A` + 5 digits (e.g. `A60813`).
  - 461 are named members (e.g. `Breakfast_Covers`,
    `Regular_Wages_Non_Exempt_Hours`, `PER_Business_CP_Curve_Value`).
- **Section source**: `META_ACCOUNT.ACCOUNT_TYPE`, stated for 1,541 of 1,544
  extract accounts. Its values:

  | `ACCOUNT_TYPE` | Accounts |
  |---|---|
  | revenue | 387 + 28 non-currency |
  | expense | 580 + 5 non-currency |
  | asset | 170 |
  | liability | 227 |
  | equity | 16 |
  | saved assumption | 14 + 114 non-currency |

  - No extract account has two types in `META_ACCOUNT`.
  - The 3 unmatched accounts are `[Total Base Dues].[Fitness|Social|Tennis
    Dues - Base]`, on 24,647 rows.
  - **The A-code digit mostly agrees** with the type (1 asset, 2 liability, 3
    equity, 4 revenue, 6 expense), except **digit 5: 36 revenue, 6 expense**.
  - Named members have no digit.
  - `ACCOUNT_TYPE` does not separate COGS, payroll and opex within `expense`;
    the A-digit does for A-codes.
  - Proposed H1/H2 map: Q-05.
- **`RECORD_TYPE`**: `META_ACCOUNT.DATA_TYPE` states `currency` or
  `non-currency`. Proposed: non-currency -> STATISTIC, currency -> AMOUNT, and
  AMOUNT for the 3 unmatched accounts (Q-05).
- **Balance sheet**: present. Asset, liability and equity accounts total 413,
  on 3.29M rows.
- **Category**: by measure column (ACTUAL / FORECAST / BUDGET).
  - `FORECAST_VERSION` is `Fcst6_6` on every forecast cell.
  - `VERSION_NAME` (`Load`, `Input`, `Central Load`, `Proforma Adj`,
    `Operations Adj`) is an Essbase version. Proposed scenario =
    `VERSION_NAME`, with `FORECAST_VERSION` appended on forecast rows (Q-07).
- **Subtotals**:
  - **`REPORT_LEVEL = 'EBITDA_SUMMARY'`**: 28,043 rows, one account `Adjusted
    Cash EBITDA` (`ACCOUNT_TYPE` revenue), at `Total Operating Departments /
    Total Subaccount / Total Location`. A computed rollup, flagged by
    structure; not verified against its detail (Q-01).
  - **`DAY_OF_MONTH = 'TotalDOMEnter'`**: 112,934 groups. Of the 108,850 that
    also have daily rows, **82,758 (76%) equal the sum of Day01-31** within
    0.005. Borderline (Q-01).
- **`SOURCE_LINE_KEY`**: the measure's `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER` plus
  the measure. Every row has at least one path.
- **Duplicates / overlap** (*unverified*): `Proforma Adj` and `Operations Adj`
  read as adjustments layered on `Load` and `Input`; kept, tagged by scenario.

#### Dictionaries

- **`META_ACCOUNT`**: 9,244 rows, 5,066 accounts. It is not unique on its key:
  the 2 files repeat members, and 1,176 accounts differ only in `PARENT`. Its
  type columns are consistent per account, so it is deduplicated on the join
  with `MIN()`.
- **`META_ENTITY`, `META_DEPARTMENT`, `META_SUBACCOUNT`, `META_LOCATION`**
  (5,472 / 799 / 1,198 / 1,507 rows) cover every extract value.
  `DESCRIPTION` and `ALIAS_DEFAULT` supply `ASSET_NAME` and `DEPARTMENT_NAME`.
- **`ACCOUNTS`**: 13,314 rows, 1,543 distinct account strings, with
  `META_MATCHED` true on every row. It repeats `META_ACCOUNT`'s information;
  staged losslessly.

### Lane `BEAUMIER` (4 tables)

#### `CLN_BEAUMIER_BP` and `CLN_BEAUMIER_BUDGET` - facts

- **Shape** (*measured*): long. `SOURCE_FILE_PATH|SOURCE_ROW_NUMBER|PERIOD_DATE|SCENARIO`
  is unique on both.

  | Table | Rows | Files | Scenarios (rows) | Period |
  |---|---|---|---|---|
  | BP | 35,567 | 2 | `BP` 8,488, `Forecast` 9,171, `Last Fcst` 9,072, `Downgraded Fcst` 8,836 | 2026 |
  | BUDGET | 17,577 | 1 | `Budget` 8,326 (2026), `Prior Year` 9,251 (2025) | 2025-2026 |

- **Site**: `HOTEL_CODE`, 13 codes (`BMR`, `CPH`, `H3V`, ...). No account
  number: **`SOURCE_ITEM_ID = LINE_ITEM`** (126-127 line items), as with HHG
  Anaplan.
- **Section stated in words**:
  - `PL_SECTION`: `Total Operating Revenue`, `COGS`, `* Payroll Expenses`,
    `Other Expenses`.
  - `PL_LINE`: 10 groupings, e.g. `Rooms Revenue`, `Total Undistributed
    Expenses`, `Non-Operating Income & Expenses`.
  - `EBITDA_GROUP`: `EBITDA` or `NOI`. The NOI items are Cluster Services,
    Exceptional, FF&E, and Owners / Holdings.
  - Proposed map: Q-06.
- **`RECORD_TYPE`**: every line item is money; AMOUNT.
- **Signs**: revenue positive, **expenses negative** (Q-04).
- **Category**: by scenario (Q-07). Proposed:
  - BP: `BP` -> BUDGET (business plan); `Forecast`, `Last Fcst`,
    `Downgraded Fcst` -> FORECAST.
  - BUDGET: `Budget` -> BUDGET; `Prior Year` -> ACTUAL.
- **Subtotals**: no line item names a total; the source gives no way to tell.
  The `Holdings` rows (207) lack `PL_LINE` but are detail.
- **Other columns**: `SEASON`, `INCL_FLAG` (`x`), `PERIOD_FLAG` (`x`),
  `YTD_YTG`, and the winter, summer and landing groups are carried as
  attributes. `COL_9` is null throughout.
- **Currency** (*unverified*): not stated on the P&L tables. CANCELLATIONS
  shows CHF and EUR hotels (Q-08).

#### `CLN_BEAUMIER_CANCELLATIONS` - pacing

- 18,930 rows, 11 hotels by name.
  - `REPORT_TYPE`: `Cancellations` or `Production SPIT`.
  - `CURRENCY`: CHF or EUR.
- **As-of exists**: `BUSINESS_DATE`, 52 weekly dates (2025-11-02 to
  2026-10-25), distinct from `STAY_MONTH` (2025-11 to 2027-10, 24 months).
  Business date x hotel x month x type is unique. Pacing is derivable.
- **Wide by prior year**: `OCCUPANCY` and `ROOMS_REVENUE`, plus `_N_1` to
  `_N_5`. Kept in its own shape (D-24); not unpivoted.
- Never feeds the seeder (D-37).

#### `CLN_BEAUMIER_ACCOUNTS` - dictionary

2,258 rows, 127 distinct strings (the line item names), descriptions on 2,255.
Staged losslessly.

### How the lanes map onto the standard hierarchy (proposed; owner approves at stop 2)

| Lane | Source | Proposed `H1` / `H2` |
|---|---|---|
| HERSHA | 4xxxxx, `GL_CODE` Revenue | Revenue / Revenue |
| HERSHA | 500000 Cost of Sales | Expense / Cost of Goods Sold |
| HERSHA | 600000-603200 (wages, contract labour, bonus, payroll taxes, supplemental, benefits) | Expense / Payroll |
| HERSHA | 610000 Operating Expenses, 630000 Management Fees | Expense / Operating Expenses |
| HERSHA | 700000 Non-Operating Income, 714000 Non-Operating Expenses | Below the Line / Other Income / (Expense) |
| HERSHA | 999999, `ST*` | Statistic / the account code |
| INVITED_CLUBS | `ACCOUNT_TYPE` asset / liability / equity | Balance Sheet / Assets, Liabilities, Equity |
| INVITED_CLUBS | revenue | Revenue / Revenue |
| INVITED_CLUBS | expense, A-digit 5 / 6 / 7 / 8 | Expense / COGS, Payroll, Operating Expenses; Below the Line |
| INVITED_CLUBS | expense, named member (no digit) | Unclassified (Q-05) |
| INVITED_CLUBS | non-currency | Statistic / the account member name |
| INVITED_CLUBS | saved assumption, currency | Unclassified (Q-05) |
| BEAUMIER | `Total Operating Revenue` | Revenue / Revenue |
| BEAUMIER | `COGS` | Expense / Cost of Goods Sold |
| BEAUMIER | `* Payroll Expenses` | Expense / Payroll |
| BEAUMIER | `Other Expenses`, `EBITDA_GROUP` EBITDA, except `PL_LINE` `Non-Operating Income & Expenses` | Expense / Operating Expenses |
| BEAUMIER | `PL_LINE` `Non-Operating Income & Expenses`; `EBITDA_GROUP` NOI | Below the Line / Other Income / (Expense) |

`H3` seeds `UNCLASSIFIED` in every lane: no source states a Level 2 that
matches the standard names outright.

---

## Corrections

**When a measurement contradicts something written here, correct it and say
so.** A finding that a documented rule is wrong is worth more than a clean run.

- **The template's `ACCOUNT_KEY` row omits `SOURCE_ITEM_ID`.** D-06 includes it;
  BEAUMIER uses it (`LINE_ITEM`).
- **M3: `SOURCE_LINE_KEY` was wrong for HERSHA and INVITED_CLUBS.** M1 proposed
  the measure's file path and row. At M3 that key had only 50,905 distinct
  values for 101,806 HERSHA rows and 2,775,458 for 51,301,512 ESSBASE rows: a
  branch with an empty measure has no path, and one ESSBASE file row feeds many
  cells. Both now use their measured-unique dimension columns plus the
  measure, giving 101,806, 4,544 and 51,301,512 distinct values (= rows).
- **M3: INVITED_CLUBS names come from `ALIAS_DEFAULT`, not `DESCRIPTION`.**
  `DESCRIPTION` is populated on 2 of 9,244 `META_ACCOUNT` rows and on none in
  `META_ENTITY` or `META_DEPARTMENT`. `ALIAS_DEFAULT` names 1,506 of 1,544
  extract accounts, 772 of 780 entities and 223 of 224 departments, with one
  alias per member.
