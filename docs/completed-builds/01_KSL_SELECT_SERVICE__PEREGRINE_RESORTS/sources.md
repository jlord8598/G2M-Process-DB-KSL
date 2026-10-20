# Sources - this build

Written at M1 from queries run in this session against `CLN.CLEAN`, and
updated after stop 2 with the owner's answers (Q-01, Q-02, Q-03, Q-05, Q-06,
Q-07) and at M3 with the mid-build reload (Q-17, see Corrections). Every
statement is marked *measured* (confirmed against this extract), *unverified*
(noted, not tested) or *decided* (the owner's answer). Currency figures live
in `docs/findings/M1.md` and `M3.md`; this document carries counts only.

**Figures below are as measured at M1 unless marked otherwise.** The source
was reloaded during M2 (Q-17); current figures are in `docs/findings/M3.md`.

Records of previous builds: none. `docs/completed-builds/` does not exist;
this is the first build.

---

## Lane declaration

Declared by the owner at stop 1. The owner confirmed both names are unused in
`CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`; there are no earlier builds to check
against.

| Lane | Source tables | Notes |
|---|---|---|
| `KSL_SELECT_SERVICE` | the 12 `CUR_PROFITSWORD_KSL_*` tables, plus the `TENANT = 'KSL'` rows of the shared chart | ProfitSword tenant `KSL` |
| `PEREGRINE_RESORTS` | the 12 `CUR_PROFITSWORD_PEREGRINE_*` tables, plus the `TENANT = 'PEREGRINE'` rows of the shared chart | ProfitSword tenant `PEREGRINE` |
| shared | `CUR_PROFITSWORD_CHART_OF_ACCOUNTS` | staged once as `STG_SHARED_CHART_OF_ACCOUNTS`, carrying `TENANT` |

**Tenant to lane (decided).** `KSL` = `KSL_SELECT_SERVICE`;
`PEREGRINE` = `PEREGRINE_RESORTS`.

**Granted tables.** 25 are visible in `CLN.CLEAN`, and all 25 are in scope
(owner, stop 1).

| Table | Rows (M1) | Lane | Role (decided) | Staging table |
|---|---|---|---|---|
| CUR_PROFITSWORD_CHART_OF_ACCOUNTS | 5,837 | shared | dictionary | `STG_SHARED_CHART_OF_ACCOUNTS` |
| CUR_PROFITSWORD_KSL_ACCOUNT_CLASS | 54 | KSL_SELECT_SERVICE | dictionary | `STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS` |
| CUR_PROFITSWORD_KSL_DAILY_EXTENDED | 2,014,289 | KSL_SELECT_SERVICE | fact | `STG_KSL_SELECT_SERVICE_DAILY_EXTENDED` |
| CUR_PROFITSWORD_KSL_DAILY_LABOR | 141,139 | KSL_SELECT_SERVICE | fact | `STG_KSL_SELECT_SERVICE_DAILY_LABOR` |
| CUR_PROFITSWORD_KSL_DATASETS | 24 | KSL_SELECT_SERVICE | dictionary | `STG_KSL_SELECT_SERVICE_DATASETS` |
| CUR_PROFITSWORD_KSL_LEDGER_BATCHES | 171,083 | KSL_SELECT_SERVICE | fact | `STG_KSL_SELECT_SERVICE_LEDGER_BATCHES` |
| CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED | 328,138 | KSL_SELECT_SERVICE | fact | `STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED` |
| CUR_PROFITSWORD_KSL_SALES_BOOKINGS | 4,080 | KSL_SELECT_SERVICE | pacing-side dictionary | `STG_KSL_SELECT_SERVICE_SALES_BOOKINGS` |
| CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS | 9,615 | KSL_SELECT_SERVICE | pacing | `STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS` |
| CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS | 15,084 | KSL_SELECT_SERVICE | pacing | `STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS` |
| CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT | 184,319 | KSL_SELECT_SERVICE | pacing | `STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT` |
| CUR_PROFITSWORD_KSL_SITES | 41 | KSL_SELECT_SERVICE | dictionary | `STG_KSL_SELECT_SERVICE_SITES` |
| CUR_PROFITSWORD_KSL_SITE_GROUPS | 137 | KSL_SELECT_SERVICE | dictionary | `STG_KSL_SELECT_SERVICE_SITE_GROUPS` |
| CUR_PROFITSWORD_PEREGRINE_ACCOUNT_CLASS | 0 | PEREGRINE_RESORTS | dictionary (empty) | `STG_PEREGRINE_RESORTS_ACCOUNT_CLASS` |
| CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED | 323,986 (323,992 at M3) | PEREGRINE_RESORTS | fact | `STG_PEREGRINE_RESORTS_DAILY_EXTENDED` |
| CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR | 257,364 | PEREGRINE_RESORTS | fact | `STG_PEREGRINE_RESORTS_DAILY_LABOR` |
| CUR_PROFITSWORD_PEREGRINE_DATASETS | 12 | PEREGRINE_RESORTS | dictionary | `STG_PEREGRINE_RESORTS_DATASETS` |
| CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES | 29,746 | PEREGRINE_RESORTS | fact | `STG_PEREGRINE_RESORTS_LEDGER_BATCHES` |
| CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED | 121,983 (121,987 at M3) | PEREGRINE_RESORTS | fact | `STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED` |
| CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS | 4,771 | PEREGRINE_RESORTS | pacing-side dictionary | `STG_PEREGRINE_RESORTS_SALES_BOOKINGS` |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS | 0 | PEREGRINE_RESORTS | pacing (empty) | `STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS` |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS | 0 | PEREGRINE_RESORTS | pacing (empty) | `STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS` |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT | 0 | PEREGRINE_RESORTS | pacing (empty) | `STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT` |
| CUR_PROFITSWORD_PEREGRINE_SITES | 6 | PEREGRINE_RESORTS | dictionary | `STG_PEREGRINE_RESORTS_SITES` |
| CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS | 0 | PEREGRINE_RESORTS | dictionary (empty) | `STG_PEREGRINE_RESORTS_SITE_GROUPS` |

Row counts were measured with `COUNT(*)` at M1, and again at M3.

**Fact tables (decided):** daily extended, monthly extended, ledger batches
and daily labor, four per lane. They feed the seeder. Pacing and the bookings
dictionary never do (D-37).

---

## What every lane must supply to staging

| | Used for |
|---|---|
| `SOURCE_LANE` | Key part. The declared lane name. |
| `SOURCE_SITE_CODE` | Key part. The lane's own site, property or entity identifier. |
| `DEPARTMENT` | Key part, as the source holds it. |
| `ACCOUNT_NUMBER` | Raw, malformed and blank included. |
| `STAT_ACCOUNT` | Raw, where the lane has one. |
| `SOURCE_ITEM_ID` | The lane's own line-item identifier, staging only (D-06). |
| `ACCOUNT_KEY` | `coalesce(nullif(trim(ACCOUNT_NUMBER),''), nullif(trim(STAT_ACCOUNT),''), nullif(trim(SOURCE_ITEM_ID),''), '~BLANK~')`, built here. |
| `RECORD_TYPE` | Key part. `AMOUNT` or `STATISTIC`, normalised here. |
| `RECORD_TYPE_SOURCE` | The stating column, or the derivation rule. Never null. |
| `STAT_UNIT_FAMILY` | Where a row carries both a money amount and a statistic value (D-29). |
| `ACCOUNT_DESC` | Carried, and shown in the review report. |
| `ASSET_NAME` | The site or property name, where a dimension supplies one. |
| `DEPARTMENT_NAME` | Where the lane supplies one; null otherwise. |
| `PERIOD_END` | A date, derived per lane. |
| `SCENARIO` | The named scenario, verbatim. |
| `SOURCE_AMOUNT` | As booked, sign included. |
| `STAT_VALUE` | Where the lane holds a statistic measure. |
| `IS_SUBTOTAL` | The source's own total or rollup row. Default `FALSE`. |
| `SUBTOTAL_SOURCE` | How a subtotal was identified, or that the source gives no way to tell. |
| `SOURCE_TABLE` | Which source table the row came from. Never null. |
| `SOURCE_LINE_KEY` | The natural key making a source row addressable, or null. |

---

## Staging rules (decided, both lanes)

Both lanes come from one source system with identical table structures. Each
rule below was measured separately on each lane at M1. **Matching structure
is not evidence that one lane's rules apply to the other.**

### Mapping per fact table

| Staged column | DAILY_EXTENDED | MONTHLY_EXTENDED | LEDGER_BATCHES | DAILY_LABOR |
|---|---|---|---|---|
| `SOURCE_SITE_CODE` | `SITE_TAG` | `SITE_TAG` | `SITE_TAG` | `SITE_TAG` |
| `ASSET_NAME` | `SITE_NAME` | `SITE_NAME` | `SITE_NAME` | `SITE_NAME` |
| `ACCOUNT_NUMBER` | `ACCOUNT_NUMBER` | `ACCOUNT_NUMBER` | `GL_ACCT` | null (none) |
| `STAT_ACCOUNT` | `STAT_ACCOUNT` | `STAT_ACCOUNT` | `STAT_ACCT` | null (none) |
| `SOURCE_ITEM_ID` | `ITEM_TAG` | `ITEM_TAG` | **null** (no `ITEM_TAG`; Q-14) | `LABEL` |
| `DEPARTMENT` | segment 1 of `ACCOUNT_NUMBER` | segment 1 of `ACCOUNT_NUMBER` | segment 1 of `GL_ACCT` | numeric prefix of `DEPARTMENT_LABEL` |
| `DEPARTMENT_NAME` | chart `DEPARTMENT` | chart `DEPARTMENT` | chart `DEPARTMENT` | chart `DEPARTMENT` for the prefix |
| `ACCOUNT_DESC` | `DESCRIPTION` | `DESCRIPTION` | `ITEM_DESCRIPTION` | `LABEL` |
| `PERIOD_END` | `BUSINESS_DATE` | `last_day(PERIOD_DATE)` | `last_day(FISCAL_PERIOD_DATE)` | `BUSINESS_DATE` |
| `SCENARIO` | null | `SCENARIO_NAME` | null | null |
| `SOURCE_AMOUNT` | `AMT` | `AMT` | `AMT` | `AMOUNTS` |
| `STAT_VALUE` | `STAT` | `STAT` | `QTY` | `HOURS` |
| `SOURCE_LINE_KEY` | `SITE_TAG`, `BUSINESS_DATE`, `ITEM_TAG` | `FCID`, `SITE_TAG`, `PERIOD_DATE`, `ITEM_TAG` | `SITE_TAG`, `BATCH_ID`, `GL_ACCT`, `STAT_ACCT`, `ITEM_DESCRIPTION`, `LINE_SEQ` | null (decided, Q-06) |

Every other source column is carried through verbatim under its own name.
That covers `ITEM_TAG`, `AS_OF_DATE`, `FCID`, `YEAR`, `MONTH`, `STATUS`,
`BATCH_ID`, `TYPE_ID`, `DATE_POSTED`, `EFFECTIVE_RATE`, `LABOR_TYPE`, the
load timestamps and the rest. Labor's `PERSON_ID`, `EMPLOYEE_ID` and
`EMPLOYEE_NAME` stay in staging and never reach `SEMANTIC` (decided, Q-06).

**`SOURCE_LINE_KEY` (measured unique, M1 and M3).** It is the listed columns
joined with `|`, each through `coalesce(..., '~BLANK~')`. At M3, every staged
fact table except labor has as many distinct keys as rows; labor's key is
null by decision.

### Text columns

`nullif(trim(x), '')` on every text column carried as a key or key input. No
fact key column carries leading or trailing whitespace, and no `ITEM_TAG` is
an empty string (measured).

### `DEPARTMENT`

- **Accounted rows (decided, Q-03).** `DEPARTMENT` is the text before the
  first `-` of the trimmed account number, a structural split. It is null
  where the account is blank.
- **No account (decided).** The key part becomes `~BLANK~` through the
  sentinel at seed and join time. The staging column itself is not
  rewritten.
- **Malformed codes (measured).** `x10110`, `x10112` and `x10101` contain no
  `-`. The split returns the whole code as the "segment", for example
  `x10110`. This is the source's own text, carried as booked and not
  repaired (Q-12).
- **Balance sheet.** These accounts have segment 1 `000` (measured).
- **Labor (decided, Q-06).** `DEPARTMENT` is the digits before the first `.`
  of `DEPARTMENT_LABEL` (e.g. `125. Housekeeping` gives `125`).
  `DNU F&B` (PEREGRINE, 41 rows) has no prefix, so `DEPARTMENT` is null
  (measured; Q-16).

### `DEPARTMENT_NAME`

- **Source (decided).** The chart's `DEPARTMENT`, looked up by tenant and
  the text before the first `-` of the chart's own trimmed
  `ACCOUNT_NUMBER`.
- **One name per code (measured, M1 and M3).** No (tenant, segment 1) in the
  chart carries more than one `DEPARTMENT` value, so the lookup is unique.
  The lookup is still grouped to one row per code, so the join cannot fan
  out.
- **Chart gaps (measured).** The chart's `DEPARTMENT` is null on 304 KSL
  rows (M1 and M3), including every `000` balance-sheet row. On PEREGRINE it
  was null on 499 rows at M1 and 333 at M3 (Q-17).
- **Labor gaps (measured at M3).** KSL `605` (85 rows) and `898` (8 rows)
  are not a KSL segment 1, so their `DEPARTMENT_NAME` is null. `DNU F&B` (41
  rows) has no prefix. PEREGRINE `415` (3,537 rows), null at M1, is now
  named `Golf & Club` (Q-16).

### `RECORD_TYPE`

Derived in staging and recorded in `RECORD_TYPE_SOURCE`.

| Row shape | `RECORD_TYPE` | Basis |
|---|---|---|
| account present, no stat account | `AMOUNT` | measured: chart `ACCOUNT_KIND = DOLLAR` for every such tag present in the chart |
| account and stat account both present | `AMOUNT`, `STAT_UNIT_FAMILY` set | decided (Q-01, D-29) |
| stat account only | `STATISTIC` | measured: chart `ACCOUNT_KIND = STAT` for every such tag |
| neither | `AMOUNT` | **assumption, Q-15**: rows carry `AMT` and `STAT` side by side |
| labor (no account column) | `AMOUNT` | assumption, Q-15: carries `AMOUNTS` and `HOURS` side by side |

**The trap (measured).** On KSL, 5 account numbers appear both with and
without a stat account (23,843 fact rows at M1, e.g. `100-4006-000`). Under
the rule above both shapes are `AMOUNT`, and both have the same
`ACCOUNT_KEY` (the account number is first in the coalesce). They share one
classification row, which is correct: both carry money on the same account.
PEREGRINE shows none.

### `STAT_UNIT_FAMILY`

- **Code (decided, Q-01).** The first two characters of segment 2 of the
  trimmed `STAT_ACCOUNT`, e.g. `100-9004-000` gives `90`. Null where the
  stat account is blank. It is set on every row with a stat account, paired
  or stat-only.
- **Malformed stat accounts (measured at M3).** `LM-CLEARING` yields `CL`
  (KSL 16 rows, PEREGRINE 98). `xD0101-80530` and the like yield `80` (KSL
  701 rows). Not repaired: these are the source's text, not a validated
  family.
- **Staged values (measured at M3).**
  - KSL: `80`, `90`, `92`, `97`, `98`, `99`, `CL`.
  - PEREGRINE: `90` to `99`, `CL`.

### `ACCOUNT_KEY` (decided, D-06 as amended)

```
coalesce(nullif(trim(ACCOUNT_NUMBER),''), nullif(trim(STAT_ACCOUNT),''),
         nullif(trim(SOURCE_ITEM_ID),''), '~BLANK~')
```

On the ledger `SOURCE_ITEM_ID` is null (Q-14), so KSL's 10,227 blank ledger
rows key to `~BLANK~`. No other staged fact row keys to `~BLANK~` (M3).

### Subtotals (decided, Q-05)

| Rule | `IS_SUBTOTAL` | `SUBTOTAL_SOURCE` |
|---|---|---|
| `ITEM_TAG` starts `TOT` | `TRUE` | `ITEM_TAG prefix TOT: source rollup (owner Q-05)` |
| `ITEM_TAG` starts `RF`, `DVR`, `CFL` or `SEQ` | `FALSE` | `ITEM_TAG prefix <x>: borderline, unflagged (owner Q-05)` |
| any other daily or monthly row | `FALSE` | `ITEM_TAG not a rollup prefix` |
| ledger | `FALSE` | `source gives no way to tell` |
| labor | `FALSE` | `source gives no way to tell` |

Measured at M1 and M3: `TOT*` rows carry no account and no stat account (0
exceptions), and occur only in daily.

### Category inputs carried by staging

Category is derived in transformation (section 6), not here. Staging
carries `FCID` and `SCENARIO_NAME` (monthly) and `SOURCE_TABLE` (all).

---

## Findings common to both lanes (measured at M1)

### Shape

All fact tables are **long**: one measure pair per row, no month columns.
Nothing is unpivoted, so every staging model uses the long identity,
`count(source) = count(STG)`. Pace events carries six amount columns
(`AMT_FOOD` ... `AMT_TOTAL`), but the pacing stream keeps the source shape
and does not unpivot them.

### The account number

- **Format (measured).** `DDD-DDDD-DDD`. Segment 1 is the department code
  and segment 2 the natural account; the chart states this in `SEG1`,
  `SEG2` and `SEG3`.
- **Malformed values (measured).** These are reported, not repaired.
  `x10110`, `x10112`, `x10101`, `xD0406-65009`, `xD0208-40021`,
  `xD0202-40301` appear in `ACCOUNT_NUMBER`/`GL_ACCT`. `LM-CLEARING`,
  `xD0101-80530`, `xD0101-80540`, `xD0208-80021`, `100-9036-000SS`,
  `xx315-9100-0xx`, `xx316-9100-0xx`, `x506-9704-350` appear in the stat
  column. Per-table counts are in M1.md.
- **Chart coverage (measured).** Every daily and monthly account number is
  in the chart. Ledger: KSL has 612 rows over 22 accounts not in the chart;
  PEREGRINE has 10 rows over 8 accounts.

### The section source

- **Section digit (measured).** It is the **leading digit of segment 2**,
  character 5 of the code. The chart confirms it:
  - `STATEMENT = BALANCE SHEET` sits on 1, 2 and 3.
  - `REVENUE` sits on 4.
  - Cost of Sales sits on 5, Payroll & Related on 6, and Other Expenses on 7.
  - Depreciation & Interest and Rent & Other Fixed sit on 8.
  - Capital Reserve sits on 9 (KSL only).
- **Exceptions (measured).** KSL has one chart account with digit 0 and
  `PL_SECTION = BELOW EBITDA` ("MARKET COSTS - RETIRED"), and three
  `STATEMENT = UNMAPPED` accounts.
- **Proposed mapping (for M4).** The section 5 digit table applies
  unchanged. Digit 2 is `Intercompany` in this chart (Q-10).
- **Level 2 (measured).** The chart states no Level 2 (`H3`) sub-category
  outright. `ACCOUNT_TYPE` restates Level 1. `H3` therefore seeds
  `UNCLASSIFIED`.
- **D&A and income tax (measured).** `Depreciation & Interest` mixes D&A
  and interest in one value. Descriptions name depreciation on 4 KSL and 1
  PEREGRINE digit-8 accounts; no account is income tax (Q-11).

### Statistic unit vocabulary

- **Family code (measured).** The first two characters of segment 2 of
  `STAT_ACCOUNT` (`90` ... `99`). The source states no family names.
- **Values seen in the chart (measured).**
  - KSL: `90`, `92`, `97`, `98`, `99`, plus `LE` (`STAT LEDGER MAPPING
    CLEARING`).
  - PEREGRINE: `90`-`99`, plus `LE`, plus malformed `-9`, `5-`, `6-`.
- **Descriptions (measured).** In family `97`, descriptions end in `- H`,
  `- OT` or `- S`. These look like hours, overtime and salaried, but the
  source does not state a unit (*unverified*).
- **Proposed labels (for M4).** `H2 = STAT_nn`, `METRIC_UNIT` null,
  `AGGREGATION_TYPE = UNRATIFIED` (D-38, D-30). The list is enumerated
  every run.

### Category and scenario (derived in transformation)

| Table | Category source | Scenario |
|---|---|---|
| `*_MONTHLY_EXTENDED` | `FCID` joined to `*_DATASETS`; `IS_ACTUALS = TRUE` is ACTUAL, otherwise matched by scenario name | `SCENARIO_NAME` verbatim |
| `*_DAILY_EXTENDED` | `SOURCE_TABLE`: ACTUAL (proposed) | none |
| `*_LEDGER_BATCHES` | `SOURCE_TABLE`: ACTUAL (proposed) | none |
| `*_DAILY_LABOR` | `SOURCE_TABLE`: ACTUAL (proposed) | none |

- **Dictionary coverage (measured).** Every monthly `FCID` is in its
  `DATASETS` table, and the names agree. `DATASETS` is unique on `FCID`.
- **Unmapped scenarios (Q-04).** `Flex`, `RMS - OneYield`,
  `RMS - HiltonGRO/IDeaS`, `5 Year Plan 2026 Final`. Until answered they
  route to `UNKNOWN`.

### Status columns

- `LEDGER_BATCHES.STATUS`: `E` and `N` (measured). Their meaning is not
  stated. Carried verbatim as an attribute.
- Pace `STATUS`: Definite, Tentative, Prospect, Cancelled, Turned Down,
  Lost Business (measured). Carried as an attribute.

### Period checks (measured)

- `PERIOD_DATE = date_from_parts(YEAR, MONTH, 1)` holds on every monthly
  row.
- `FISCAL_PERIOD_DATE` matches `FISCAL_YEAR`/`FISCAL_PERIOD`, and the month
  of `DATE_POSTED`, on every ledger row.

### `AS_OF_DATE` on `DAILY_EXTENDED`

**It is an extract timestamp, not a snapshot date (measured):**
- Each (site, business date) has exactly one `AS_OF_DATE`.
- Each (site, business date, item tag) occurs exactly once.
- `AS_OF_DATE` is never before `BUSINESS_DATE`.
- There are 44 distinct values on 2 calendar days for KSL and 3 values on 1
  day for PEREGRINE.

It is carried verbatim as an attribute. Daily is not a pacing source.

### Subtotal rule: verification (measured at M1)

- **Anchor.** The daily rooms-revenue rollup (`TOTRRRV` KSL, `TOTRRR1`
  PEREGRINE), summed to the month, was compared with Monthly Actuals
  rooms-department section-4 revenue over the complete months.
- **Result.** KSL: 109 of 154 site-months exact, all 154 within 1%.
  PEREGRINE: 4 of 6 exact.

### Blank-account population

- **Size (measured at M1).** Daily: KSL 1,642,750 of 2,014,289 rows and
  PEREGRINE 234,814 of 323,986 have no account and no stat account.
  Monthly: KSL 3,311, PEREGRINE 467. KSL ledger: 10,227, all with zero
  quantity and zero amount.
- **After the reload (M3).** PEREGRINE daily 234,816 and monthly 467; KSL
  unchanged.
- **Keys (decided, Q-02).** Every daily and monthly blank row carries an
  `ITEM_TAG`, which becomes its `ACCOUNT_KEY`. No blank row's `ITEM_TAG` is
  in the chart, so these keys have no chart dictionary behind them.
- **KSL daily blank rows by tag group (measured at M1):**

  | Tag group | Rows |
  |---|---|
  | `TOT` | 896,785 |
  | `RF` | 396,918 |
  | `I*`/`Q*` | 184,177 |
  | other | 164,870 |
  | **Total** | **1,642,750** |

- **PEREGRINE daily blank rows by tag group (measured at M1):**

  | Tag group | Rows |
  |---|---|
  | `TOT` | 144,635 |
  | `I*`/`Q*` | 55,050 |
  | other | 20,637 |
  | `RF` | 14,492 |
  | **Total** | **234,814** |

- **Possible duplicates (measured at M1).** Some blank `I*`/`Q*` rows equal
  an account-coded row with the same site, date, description and amount:
  KSL 103,607, PEREGRINE 42,920. The source states no link. This is reported
  as candidate duplication and not used.

### Overlap: monthly, daily and ledger (measured at M1)

- **Daily and Monthly Actuals** are the same actuals at two grains: about
  99.8% of shared site x month x account keys are equal over complete
  months.
- **The ledger** is the Daily Income Journal (`TYPE_ID = INJ`): revenue and
  balance sheet, with section-4 signs inverted against daily.
- **Consequence.** All three are kept and tagged with `SOURCE_TABLE`, with
  no deduplication (D-25, Q-09).

### Dictionaries

| Dictionary | Supplies | Unique on key | Coverage gaps |
|---|---|---|---|
| Chart of accounts | statement, section, kind, department, item tag | **not** on `ACCOUNT_NUMBER` (KSL 1,578 rows / 1,564 numbers; PEREGRINE 4,259 / 4,161); unique on (`ACCOUNT_NUMBER`, `STAT_ACCOUNT`) and on `ITEM_TAG`; one `DEPARTMENT` per (tenant, segment 1) | ledger accounts listed above; no blank-row tags |
| `DATASETS` | scenario name, `IS_ACTUALS` | yes, on `FCID` | none |
| `SITES` | site name, address | yes, on `SITE_TAG` | none; every fact site is present |
| `SITE_GROUPS` | region membership | many-to-many | KSL group `Term` holds 2 site tags not in `SITES` |
| `ACCOUNT_CLASS` | department-class labels | yes, on `DEPARTMENT_CLASS` | no fact column carries it |

**Empty strings in the chart (measured).**
- `STAT_ACCOUNT` is an empty string, not null, on 1,305 KSL and 3,150
  PEREGRINE rows.
- `ACCOUNT_NUMBER` is an empty string on 13 KSL and 99 PEREGRINE stat-only
  rows (found after M1). Their `SEG1` is null.

Staging carries the raw value and adds `nullif(trim())` cleaned columns
alongside.

### Pacing and pickup

- **As-of date (measured).** The KSL pace tables carry an `AS_OF_DATE`
  distinct from the period (`OCCUPANCY_DATE` or `EVENT_DATE`): 18 snapshots,
  27 Sep-16 Oct 2026.
- **Window (measured).** `DAYS_OUT = period - as_of` on every row, and every
  period is before its as-of date: a trailing window (Q-08).
- **Code columns (measured).** No `ACCOUNT_CODE` value is in GL format
  (209,018 rows). These are CRM codes, never mapped to `ACCOUNT_NUMBER`
  (D-37). `BOOKING_CODE` matches `SALES_BOOKINGS.SALE_SYS_CODE` on 24,699
  rows.
- **Shape.** Staged in its own shape, every source column verbatim, plus
  `RUN_ID`, `SOURCE_LANE` and `SOURCE_TABLE`.
- **PEREGRINE.** All three pace tables are empty. They are staged empty.

### `SALES_BOOKINGS` (decided, Q-07: pacing-side dictionary)

One row per booking, with no measure and no as-of date (measured).
- `BOOKING_ID` repeats: 4 duplicate IDs per lane.
- `SALE_SYS_CODE` is the column pace `BOOKING_CODE` links to.

Staged per lane in its own shape and never seeded.

### `DAILY_LABOR` (decided, Q-06: fact)

- **Grain (measured).** Employee x position x labor type per day, with
  `HOURS`, `AMOUNTS` and `EFFECTIVE_RATE`.
- **No account (measured).** `ACCOUNT_NUMBER` and `STAT_ACCOUNT` are null,
  so `ACCOUNT_KEY` = `LABEL`.
- **Labor types (measured).** KSL 24, PEREGRINE 37.
- **Labels (measured).** No `LABEL` is blank or carries edge whitespace.
- **Not a subset of daily payroll (measured).** It is an independent
  source.

### Anything surprising

- The KSL site group `ALL` is named "Peregrine Hospitality" (Q-13).
- KSL `ACCOUNT_CLASS` includes `TEST` ("Zach Test").
- `DATASETS` includes `Test`, `History Test Data Set` and
  `Pacific Point Resort Test Budget`; none appears in the facts.

---

## Per-lane findings

### KSL_SELECT_SERVICE

- **Sites (measured).** 41.
- **Coverage (measured).**

  | Table | Coverage |
  |---|---|
  | Daily | 1 Jun-15 Oct 2026 |
  | Monthly Actuals | Jun-Oct 2026 |
  | Budget, Flex | to Apr 2027 |
  | Forecasts | to Dec 2026 |
  | Ledger | 1 Jun-15 Oct 2026 |
  | Labor | 1 Jun-15 Oct 2026 |

- **Scenarios in the facts (measured at M1).**

  | FCID | Scenario | Rows |
  |---|---|---|
  | -3 | Actuals | 51,355 |
  | 1 | Primary Forecast | 70,443 |
  | 2 | Budget | 94,991 |
  | 20 | Flex | 83,006 |
  | 23 | RMS - OneYield | 181 |
  | 26 | Budget 2 | 16,571 |
  | 27 | RMS - HiltonGRO/IDeaS | 31 |
  | 115 | 5 Year Plan 2026 Final | 7,097 |
  | 117 | Forecast 2 | 2,190 |
  | 118 | Forecast 3 | 2,273 |
  | | **Total** | **328,138** |

- **Pacing (measured).** All three pace tables are populated.
- **Ledger status (measured).** `E` 164,974 + `N` 6,109 = 171,083.

### PEREGRINE_RESORTS

- **Sites (measured).** 6.
- **Coverage (measured at M1; the M3 reload kept the same date ranges).**

  | Table | Coverage |
  |---|---|
  | Daily | 15 Aug-15 Oct 2026 |
  | Monthly Actuals | Sep-Oct 2026 |
  | Budget, Flex | to Apr 2027 |
  | Forecasts | to Dec 2026 |
  | Budget 2 | Dec 2026-Apr 2027 |
  | Ledger | 2 Jun-15 Oct 2026 |
  | Labor | 1 Jun-15 Oct 2026 |

- **Scenarios in the facts (measured at M1).**

  | FCID | Scenario | Rows |
  |---|---|---|
  | -3 | Actuals | 11,107 |
  | 1 | Primary Forecast | 22,323 |
  | 2 | Budget | 42,337 |
  | 7 | Flex | 36,943 |
  | 13 | Budget 2 | 540 |
  | 14 | Forecast 2 | 8,733 |
  | | **Total** | **121,983** |

  At M3 the table holds 121,987 rows. The per-scenario split was not
  re-measured at M3.
- **Pacing (measured).** All three pace tables are empty.
- **Empty dictionaries (measured).** `ACCOUNT_CLASS` and `SITE_GROUPS` are
  empty.
- **Ledger status (measured).** `E` 25,490 + `N` 4,256 = 29,746.

---

## Corrections

- **After M1.** The Q-02 answer names `LEDGER_BATCHES` as carrying
  `ITEM_TAG`. It does not: its column list (measured at M1) has
  `ITEM_DESCRIPTION` and no `ITEM_TAG`. Raised as Q-14, and built with
  `SOURCE_ITEM_ID` null on the ledger until answered.
- **After M1.** The chart's `ACCOUNT_NUMBER` is an empty string on 13 KSL
  and 99 PEREGRINE stat-only rows. M1 reported `ACCOUNT_NUMBER` as never
  null in the chart, which was true (`IS NULL` = 0) but missed the empty
  strings.
- **M3: the source was reloaded during M2 (Q-17).** All 25 tables were
  recreated between 15:26:36 and 15:27:06 on 2026-10-16. Measured changes:
  - PEREGRINE daily: 323,986 to 323,992 rows (+4 account-only, +2 blank).
  - PEREGRINE monthly: 121,983 to 121,987 (+3 account-only, +1 paired).
  - KSL monthly: count unchanged, paired rows 50,571 to 50,572.
  - PEREGRINE chart: null `DEPARTMENT` 499 to 333, including `415` now
    named `Golf & Club`.
  - KSL counts are otherwise unchanged.

  The M1 figures above stand as what M1 measured. The current figures are
  in M3.md.
