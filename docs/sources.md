# Sources - build 04 (rebuild of KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**State: end of M6 (stop 4).** Written from queries run in this session against
`CLN.CLEAN`, and updated with the owner's stop-1 answers (Q-01 to Q-07). Every
statement is marked *measured* (confirmed against this extract), *unverified*
(noted, not tested) or *decided* (the owner's answer). Figures and query IDs
are in `docs/findings/M1.md`.

**This build is a rebuild (D-44).** Both lanes were first built in build 01.
Its record, `docs/completed-builds/01_KSL_SELECT_SERVICE__PEREGRINE_RESORTS/`,
shows how the key was built, and the rebuild must build it the same way. Build
01's decisions stand unless this extract contradicts them; they are listed
below as *decided (build 01)*.

---

## Source schema

- **Source:** `CLN.CLEAN`.
- **Load freeze (D-43):** from **2026-10-22 14:27:32.991 PDT**, the database
  clock at the first query of this build, to **2026-10-25 14:27 PDT** (decided, Q-07).
- **Last reload before the freeze (measured).** All 26 tables were last
  altered between 13:41:01.502 and 13:41:45.385 PDT on 2026-10-22, about 46
  minutes before the freeze began. Before each milestone's checks,
  `last_altered` is compared with the table below.

### `last_altered`, every in-scope table (measured, 2026-10-22)

| Table | Rows | `last_altered` (PDT) |
|---|---|---|
| CUR_PROFITSWORD_KSL_ACCOUNT_CLASS | 54 | 13:41:09.314 |
| CUR_PROFITSWORD_KSL_COA | 8,634 | 13:41:08.315 |
| CUR_PROFITSWORD_KSL_DAILY_EXTENDED | 8,049,208 | 13:41:20.754 |
| CUR_PROFITSWORD_KSL_DAILY_LABOR | 434,051 | 13:41:28.898 |
| CUR_PROFITSWORD_KSL_DATASETS | 24 | 13:41:06.009 |
| CUR_PROFITSWORD_KSL_LEDGER_BATCHES | 574,556 | 13:41:25.379 |
| CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED | 1,217,855 | 13:41:14.621 |
| CUR_PROFITSWORD_KSL_SALES_BOOKINGS | 10,348 | 13:41:32.827 |
| CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS | 27,733 | 13:41:43.157 |
| CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS | 47,979 | 13:41:36.662 |
| CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT | 481,337 | 13:41:40.527 |
| CUR_PROFITSWORD_KSL_SITES | 41 | 13:41:01.502 |
| CUR_PROFITSWORD_KSL_SITE_GROUPS | 137 | 13:41:03.902 |
| CUR_PROFITSWORD_PEREGRINE_ACCOUNT_CLASS | 123 | 13:41:11.827 |
| CUR_PROFITSWORD_PEREGRINE_COA | 22,554 | 13:41:10.673 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED | 350,583 | 13:41:22.656 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR | 266,565 | 13:41:30.696 |
| CUR_PROFITSWORD_PEREGRINE_DATASETS | 12 | 13:41:07.326 |
| CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES | 31,791 | 13:41:26.607 |
| CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED | 589,229 | 13:41:16.870 |
| CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS | 5,050 | 13:41:34.390 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS | 481,730 | 13:41:45.385 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS | 62,929 | 13:41:38.462 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT | 79,160 | 13:41:41.834 |
| CUR_PROFITSWORD_PEREGRINE_SITES | 6 | 13:41:02.872 |
| CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS | 13 | 13:41:05.001 |

`row_count` is from `CLN.INFORMATION_SCHEMA.TABLES` (query
`01c7e887-020a-3f6d-0003-4ff21bb8b372`). The fact counts were confirmed with
`COUNT(*)` (query `01c7e888-020a-3fff-0003-4ff21bb80ec6`).

---

## Lane declaration

**Rebuilt lanes (owner, D-44):** `KSL_SELECT_SERVICE` and `PEREGRINE_RESORTS`.
They keep their names, so their classification rows, and the master's rows for
them with any corrections, still apply.

**Why (owner).**
- `CUR_PROFITSWORD_CHART_OF_ACCOUNTS` was removed from this role.
- `CUR_PROFITSWORD_KSL_COA` and `CUR_PROFITSWORD_PEREGRINE_COA` were added,
  taken straight from the API with a different structure.
- History was loaded back to 2024.

**Name check (measured, D-32).** The `SOURCE_LANE` values in `DEV_G2M_AI`
(the classification table and the six semantic tables) are `BEAUMIER`,
`HERSHA`, `HHG`, `INVITED_CLUBS`, `KSL_SELECT_SERVICE`, `NEWBURY` and
`PEREGRINE_RESORTS`. Each is recorded in `docs/completed-builds/`. The two
rebuilt names are already in use by these same lanes, which is the one reuse
D-44 allows.

**Table assignment (decided, Q-01: 13 tables per lane).**

| Table | Lane | Role | Build 01 staging table | Change |
|---|---|---|---|---|
| CUR_PROFITSWORD_KSL_COA | KSL_SELECT_SERVICE | dictionary | - | **new**; staged as `STG_KSL_SELECT_SERVICE_COA` |
| CUR_PROFITSWORD_PEREGRINE_COA | PEREGRINE_RESORTS | dictionary | - | **new**; staged as `STG_PEREGRINE_RESORTS_COA` |
| CUR_PROFITSWORD_{T}_DAILY_EXTENDED | each tenant's lane | fact | `STG_{LANE}_DAILY_EXTENDED` | unchanged columns |
| CUR_PROFITSWORD_{T}_MONTHLY_EXTENDED | each tenant's lane | fact | `STG_{LANE}_MONTHLY_EXTENDED` | unchanged columns |
| CUR_PROFITSWORD_{T}_LEDGER_BATCHES | each tenant's lane | fact | `STG_{LANE}_LEDGER_BATCHES` | unchanged columns |
| CUR_PROFITSWORD_{T}_DAILY_LABOR | each tenant's lane | fact | `STG_{LANE}_DAILY_LABOR` | unchanged columns |
| CUR_PROFITSWORD_{T}_SALES_PACE_EVENTS / _ROOMS / _TRANSIENT | each tenant's lane | pacing | `STG_{LANE}_SALES_PACE_*` | unchanged columns; PEREGRINE now populated |
| CUR_PROFITSWORD_{T}_SALES_BOOKINGS | each tenant's lane | pacing-side dictionary (build 01 Q-07) | `STG_{LANE}_SALES_BOOKINGS` | unchanged columns |
| CUR_PROFITSWORD_{T}_DATASETS | each tenant's lane | dictionary | `STG_{LANE}_DATASETS` | unchanged columns |
| CUR_PROFITSWORD_{T}_SITES | each tenant's lane | dictionary | `STG_{LANE}_SITES` | unchanged columns |
| CUR_PROFITSWORD_{T}_SITE_GROUPS | each tenant's lane | dictionary | `STG_{LANE}_SITE_GROUPS` | unchanged columns; PEREGRINE now 13 rows |
| CUR_PROFITSWORD_{T}_ACCOUNT_CLASS | each tenant's lane | dictionary | `STG_{LANE}_ACCOUNT_CLASS` | unchanged columns; PEREGRINE now 123 rows |

- `{T}` is `KSL` for `KSL_SELECT_SERVICE` and `PEREGRINE` for
  `PEREGRINE_RESORTS` (decided, build 01). The 26 visible tables are 13 per
  tenant, and every one is assigned. No table is out of scope.
- **Column lists (measured).** For the 24 tables carried over from build 01,
  every column the build 01 staging code reads is still present under the same
  name and type (query `01c7e888-020a-3f6e-0003-4ff21bb8a3be`).
- **Retired (owner).** `STG_SHARED_CHART_OF_ACCOUNTS` and
  `SPROC_STG_SHARED_CHART_OF_ACCOUNTS`. In `sql/`, the procedure is called
  only by the two rebuilt lanes' staging MAINs, and nothing reads its table
  (measured).

---

## The old chart's role, and the new COA

### What `CUR_PROFITSWORD_CHART_OF_ACCOUNTS` supplied in build 01 (measured in `sql/`)

| Use | Where | Needed by the key? |
|---|---|---|
| **`DEPARTMENT_NAME`** | Every fact staging model of both lanes (8 files) read `CLN.CLEAN.CUR_PROFITSWORD_CHART_OF_ACCOUNTS` **directly**, grouped to one name per (tenant, segment 1 of `ACCOUNT_NUMBER`) with `min(department)`, and left-joined on the fact's department code. | No. `DEPARTMENT_NAME` is an attribute. |
| `STG_SHARED_CHART_OF_ACCOUNTS` | Built by both staging MAINs; **read by nothing** downstream. The seeder and the transformation models do not reference it. | No. |
| **M1 evidence only** | `ACCOUNT_KIND` (DOLLAR / STAT) backed the `RECORD_TYPE` rule. `STATEMENT` and `PL_SECTION` confirmed the section digit at character 5. `SEG1` confirmed the department segment. | No. Each rule reads fact columns only; the chart was the independent anchor. |

**So the chart supplied department names, plus the M1 evidence behind the
`RECORD_TYPE` and section rules. Nothing in the classification key, the
seeder or the routing read it.**

### The new COA (measured, queries `01c7e888-020a-3b26-0003-4ff21bb879a2`, `01c7e88b-*`, `01c7e88c-*`)

**Columns.**
- `TENANT`, `TAG`, `ACCOUNT_NUMBER`, `ACCOUNT_NAME`, `STAT_ACCT_NUMBER`.
- `DEPARTMENT_NAME`, `DEPARTMENT_NAME_KEY`.
- `GL_CATEGORY` (a `:`-delimited flag string), and `GL_CATEGORY_FLAGS`
  (the same as an array).
- `BUD_FORMULA`.
- `ACCT_DEPT_SEGMENT`, `ACCT_MAIN_SEGMENT`, `ACCT_SUB_SEGMENT`.
- Flags `IS_CALCULATED_LINE`, `HAS_BUD_FORMULA`, `IS_TOTAL_LINE`,
  `IS_RETIRED`.
- Load timestamps.

The old chart's `STATEMENT`, `PL_SECTION`, `ACCOUNT_KIND`, `ACCOUNT_TYPE`,
`DEPT_GROUP`, `FIRST_PERIOD` and `LAST_PERIOD` are gone.

| | KSL | PEREGRINE |
|---|---|---|
| Rows | 8,634 | 22,554 |
| Tenants | 1 (`KSL`) | 1 (`PEREGRINE`) |
| Distinct `TAG` (never blank) | 5,616 | 16,399 |
| Rows with an account number / distinct accounts | 5,364 / 3,343 | 15,547 / 11,322 |
| Rows with a stat account number / distinct | 836 / 591 | 5,513 / 4,588 |
| Shape: account only / paired / stat only / neither | 4,568 / 796 / 40 / 3,230 | 10,296 / 5,251 / 262 / 6,745 |
| `IS_TOTAL_LINE` / `IS_CALCULATED_LINE` / `IS_RETIRED` | 1,093 / 3,270 / 1,596 | 3,662 / 7,007 / 46 |
| Distinct `DEPARTMENT_NAME` / `DEPARTMENT_NAME_KEY` | 85 / 75 | 204 / 196 |
| Distinct `ACCT_DEPT_SEGMENT` | 49 | 139 |

**Grain.** The COA is not unique on `TAG`: there are 8,634 rows for 5,616 KSL
tags. It is unique on (`TAG`, `DEPARTMENT_NAME_KEY`) on both lanes (KSL 7,410,
PEREGRINE 21,857 combinations) (*measured*). One line is listed once per
department view.

**Department name is no longer one per code (measured).**
- `ACCT_DEPT_SEGMENT` always equals segment 1 of `ACCOUNT_NUMBER` (0
  mismatches).
- **KSL: 37 of 49 codes carry more than one `DEPARTMENT_NAME`**, up to 10.
  Code `100` maps both to `BALANCE SHEET` and to `FRONT OFFICE`.
- **PEREGRINE: 32 of 139 codes carry more than one**, up to 56.
- Of the accounts, 1,850 of 3,343 KSL and 1,437 of 11,322 PEREGRINE carry more
  than one name.
- **The vocabulary changed.**
  - KSL build 01 named code `100` `Rooms`. The new COA's `min()` gives
    `BALANCE SHEET`.
  - PEREGRINE `150` changed from `Food & Beverage` to `OUTLET 1`.
  - 42 of 52 KSL and 123 of 126 PEREGRINE build-01 department codes would
    receive a different name under a `min()` lookup.
  - 3 KSL build-01 codes are absent from the new COA.

  This is Q-02.

**`DEPARTMENT_NAME` rule (decided, Q-02).** The COA `DEPARTMENT_NAME` for the
fact's department code (`ACCT_DEPT_SEGMENT`, equal to segment 1 of the
account; labor: the `DEPARTMENT_LABEL` prefix), **only where that code has
exactly one distinct name in the lane's COA; otherwise null.** KSL names 12 of
49 codes, PEREGRINE 107 of 139. This replaces build 01's chart lookup in all 8
fact models.

**Fact links (measured).** Every daily and monthly `ITEM_TAG` is a COA `TAG`
(KSL 3,555 tags, 9,267,063 rows; PEREGRINE 8,577 tags, 939,812 rows; 0
missing). However, a tag can carry several department names: 6,580,838 KSL
rows and 328,450 PEREGRINE rows sit on such tags.

**Subtotal flags (measured).**
- `IS_TOTAL_LINE` is set on every `TOT*` tag row (KSL 1,072, PEREGRINE
  3,657), which corroborates build 01's Q-05 rule.
- It is also set on a few non-`TOT` tags:
  - KSL, 21 rows: `CFLWTD`, `CFLWWD`, `RF0032`, `ARTOTAL`, `GCOS`, `GTR`,
    `I00058`, `I00114`, `I00382`, `I09306`, `TGEX`, `TGL`, `TGLPT`, `TGOE`,
    `TGPTEB`, `TPTFBPY`.
  - PEREGRINE, 5 rows: `ARMTOTAL`, `ARTOTAL`, `NETEDEX`, `NETLDEX`.

  See Q-05.

**Subtotal rule (decided, Q-05; refinement pending, Q-08).**

| Rule | `IS_SUBTOTAL` | `SUBTOTAL_SOURCE` |
|---|---|---|
| `ITEM_TAG` starts `TOT` | `TRUE` | `ITEM_TAG prefix TOT: source rollup (owner Q-05)` |
| `ITEM_TAG` is a COA `IS_TOTAL_LINE` tag, not `TOT*` | `TRUE` | `COA IS_TOTAL_LINE (owner Q-05, build 04)` |
| `ITEM_TAG` starts `RF`, `DVR`, `CFL` or `SEQ`, not COA-flagged | `FALSE` | `ITEM_TAG prefix <x>: borderline, unflagged (owner Q-05)` |
| any other daily or monthly row | `FALSE` | `ITEM_TAG not a rollup prefix` |
| ledger, labor | `FALSE` | `source gives no way to tell` |

No tag has mixed `IS_TOTAL_LINE` values across its COA rows (*measured*).
**Q-08 (decided, stop 2):** the COA-flag rule applies only to tags with no
account and no stat account on any COA row. `I00058`, `I00114` and `I00382`
(13,601 account-coded rows) stay `FALSE`, with `SUBTOTAL_SOURCE` = `COA
IS_TOTAL_LINE on account-coded detail: unflagged (owner Q-08)`. Built at M3;
the sample comparison is in M3.md.

**`GL_CATEGORY` against the section digit (measured, unverified as a rule).**
- `GREV` sits on digit 4, `GEXP` on 5 to 8, and `GLAB` on 6 (with 7 and 9 on
  KSL).
- `CR`, `SR`, `RCV` and `LDG` sit on 1 to 3.

It is broadly consistent with the build 01 digit rule, and is a candidate
anchor at M4. It does not replace the digit rule.

---

## Can the five-part key be built exactly as in build 01?

**Yes, from the fact tables alone (measured).** Every key input is a fact
column, and all are still present:

| Key part | Build 01 rule (decided, build 01) | Source columns |
|---|---|---|
| `SOURCE_LANE` | the declared lane | - |
| `SOURCE_SITE_CODE` | `SITE_TAG` | all four facts |
| `DEPARTMENT` | segment 1 of `ACCOUNT_NUMBER` / `GL_ACCT` (Q-03); labor: digits before the first `.` of `DEPARTMENT_LABEL` (Q-06) | facts only |
| `ACCOUNT_KEY` | `coalesce(account, stat account, SOURCE_ITEM_ID, '~BLANK~')`; `SOURCE_ITEM_ID` = `ITEM_TAG` (daily, monthly), null (ledger, Q-14), `LABEL` (labor) (Q-02, Q-06) | facts only |
| `RECORD_TYPE` | `STATISTIC` when the stat account is present and the account blank, else `AMOUNT` (Q-01, Q-15) | facts only |

**Preliminary key test (measured, query
`01c7e889-020a-3b2c-0003-4ff21bb81abe`).** The build 01 rule, applied
read-only to this extract, was compared with the existing classification rows.

| Lane | Existing keys | Reproduced | New in this extract | Existing, not produced |
|---|---|---|---|---|
| KSL_SELECT_SERVICE | 42,808 | 42,798 | 16,302 | 10 |
| PEREGRINE_RESORTS | 21,859 | 21,857 | 2,201 | 2 |

- **Not produced (12) (query `01c7e889-020a-3bc3-0003-4ff21bb895ea`).**
  - KSL: 6 labor labels and item tags, 3 `TOT*` tags at `VTKMLOP`, and
    `100-4000-000` at `VARNAOP`.
  - PEREGRINE: `MSNR31` at `CASSDOP`, and one labor label at `PACBROP`.

  **None reappears at the same site under another department or record
  type**, so no account changed key; these are absent from this extract (dead
  keys, kept, D-14).
- **New (query `01c7e88a-020a-3bfa-0003-4ff21bb8c282`).**
  - **History:** KSL 16,169 of 16,302 and PEREGRINE 1,747 of 2,201 occur only
    before 2026-06.
  - **Sites:** no new key is on a new site.
  - **Accounts:** 4,215 KSL and 1,195 PEREGRINE carry an account key unseen
    before.
- **The 5 KSL new keys that reuse a known account at the same site (query
  `01c7e88a-020a-3b26-0003-4ff21bb87a1e`).**
  - All are `100-9036-000` on the **ledger**, May and June 2025, at 5 sites.
  - The source booked the stat code in `GL_ACCT` (`STAT_ACCT` null), so the
    unchanged rule makes them `AMOUNT` keys in department `100`.
  - The existing `~BLANK~`/`STATISTIC` key for the same identifier is still
    reproduced.
  - This is new data under the same rule, not a moved key (Q-04).

The formal D-44 key report runs at M4, against the staging tables.

---

## Category and scenario

**Rule (decided, build 01, Q-04 at stop 4).**
- `DAILY_EXTENDED`, `LEDGER_BATCHES` and `DAILY_LABOR` are ACTUAL.
- `MONTHLY_EXTENDED` goes by `FCID` joined to `DATASETS`:
  - `IS_ACTUALS` → ACTUAL;
  - `Budget`, `Budget 2` → BUDGET;
  - `Primary Forecast`, `Forecast 2`, `Forecast 3`, `Flex`,
    `RMS - OneYield`, `RMS - HiltonGRO/IDeaS`, `5 Year Plan 2026 Final` →
    FORECAST.
- Anything else → UNKNOWN (`UNRESOLVED_CATEGORY`).

**Scenarios in the facts (measured, query `01c7e888-020a-3de2-0003-4ff21bb85bb6`).**
Every fact `FCID` is in its `DATASETS` table, and the names agree.

| Lane | FCID | Scenario | Rows | Periods | Build 01 category |
|---|---|---|---|---|---|
| KSL | -3 | Actuals | 325,037 | 2024-01 to 2026-10 | ACTUAL |
| KSL | 1 | Primary Forecast | 343,597 | 2024-01 to 2026-12 | FORECAST |
| KSL | 2 | Budget | 235,077 | 2024-01 to 2027-04 | BUDGET |
| KSL | 20 | Flex | 236,129 | 2024-01 to 2027-04 | FORECAST |
| KSL | 23 | RMS - OneYield | 12,108 | 2024-01 to 2026-10 | FORECAST |
| KSL | 26 | Budget 2 | 40,440 | 2025-01 to 2027-04 | BUDGET |
| KSL | 27 | RMS - HiltonGRO/IDeaS | 2,887 | 2024-01 to 2026-10 | FORECAST |
| KSL | **70** | **Smart Forecast** | **1,083** | 2024-01 to 2025-02 | **none (Q-03)** |
| KSL | 115 | 5 Year Plan 2026 Final | 10,313 | 2026-01 to 2027-04 | FORECAST |
| KSL | 117 | Forecast 2 | 6,824 | 2024-01 to 2026-12 | FORECAST |
| KSL | 118 | Forecast 3 | 4,360 | 2026-01 to 2026-12 | FORECAST |
| PEREGRINE | -3 | Actuals | 197,163 | 2024-01 to 2026-10 | ACTUAL |
| PEREGRINE | 1 | Primary Forecast | 208,011 | 2024-01 to 2026-12 | FORECAST |
| PEREGRINE | 2 | Budget | 82,570 | 2026-01 to 2027-04 | BUDGET |
| PEREGRINE | 7 | Flex | 63,796 | 2026-01 to 2027-04 | FORECAST |
| PEREGRINE | 13 | Budget 2 | 540 | 2026-12 to 2027-04 | BUDGET |
| PEREGRINE | 14 | Forecast 2 | 37,149 | 2026-01 to 2026-12 | FORECAST |

KSL rows sum to 1,217,855 and PEREGRINE to 589,229, matching each table's
`COUNT(*)`.

**Smart Forecast (measured, queries `01c7e88b-020a-3b2c-0003-4ff21bb81b5e`, `01c7e88b-020a-3b2c-0003-4ff21bb81b7a`).**
- **What it holds.** KSL FCID 70 has 1,083 rows over 14 sites, from 2024-01
  to 2025-02, on 8 rooms-revenue accounts (`100-4000-*`, `100-4004-000`,
  `100-4006-000`, `100-4008-003`, `100-4010-000`). Every row carries an
  account and an `I00*` item tag; there is no stat-only or blank row.
- **It is not actuals.** Of the 1,043 site x account x month cells that also
  exist in Actuals, `AMT` agrees with Actuals within 0.50 on only 4, and with
  Primary Forecast on 4.
- **It is a genuine projection,** confined to the past, so it is a historical
  forecast.

**`DATASETS` names with no fact rows (measured).** These would route to
UNKNOWN if rows appear (Q-03):
- KSL: `RMS - HyattPRiO`, `Competitive Set 1`, `Competitive Set 2`,
  `Property CS Data`, `Property CS Data 2`, `RMS - Duetto`,
  `Smart Forecast Lower Bounds`, `Smart Forecast Upper Bounds`,
  `RMS - Concerto`, `Test`, `History Test Data Set`,
  `Pacific Point Resort Test Budget`, `Budget DNS`.
- PEREGRINE: `Competitive Set 1`, `Property CS Data`, `Smart Forecast`
  (FCID 10), `RMS`, `Test`, `5 Year Plan 2026`.

---

## Coverage periods (measured, query `01c7e888-020a-3fff-0003-4ff21bb80ec6`)

| Table | KSL | PEREGRINE |
|---|---|---|
| Daily extended | 2024-01-01 to 2026-10-21 (8,049,208) | 2026-08-15 to 2026-10-21 (350,583) |
| Monthly extended | 2024-01 to 2027-04 (1,217,855) | 2024-01 to 2027-04 (589,229) |
| Ledger | 2024-01 to 2026-10 (574,556) | 2026-06 to 2026-10 (31,791) |
| Labor | 2024-01-01 to 2026-10-20 (434,051) | 2026-06-01 to 2026-10-20 (266,565) |
| Pace transient (as-of) | 2026-09-27 to 2026-10-22 (481,337) | 2026-10-19 to 2026-10-22 (79,160) |
| Pace rooms (as-of) | 2026-09-27 to 2026-10-22 (47,979) | 2026-10-19 to 2026-10-22 (62,929) |
| Pace events (as-of) | 2026-09-27 to 2026-10-22 (27,733) | 2026-10-19 to 2026-10-22 (481,730) |

- **The history reaches 2024 on all four KSL facts, but only on PEREGRINE
  monthly.** PEREGRINE daily, ledger and labor did not gain history (Q-07).
- **KSL daily is 3.9x build 01's** (2,050,067 at build 01 M6).

---

## Per-lane findings (measured at M1; figures in `M1.md`)

Both lanes come from one system with identical table structures, and each
finding below was measured on each lane separately.

**Unchanged from build 01 (measured).**
- **Shape:** every fact table is long; the identity is `count(source) =
  count(STG)` on every model.
- **Account number:** format `DDD-DDDD-DDD`; the section digit is character
  5; `DEPARTMENT` is segment 1, which equals the COA's `ACCT_DEPT_SEGMENT`.
- **`RECORD_TYPE`:** the paired-row trap behaves as at build 01. The KSL
  accounts that appear both alone and paired (now 7) are `AMOUNT` either
  way, under one key.
- **Subtotals:** `TOT*` rows carry no account and no stat account and occur
  only in daily.
- **Line keys:** `SOURCE_LINE_KEY` is unique on daily, monthly and ledger.
- **Periods:** they derive as at build 01. The daily `AS_OF_DATE` is an
  extract timestamp.
- **Dictionaries:** `DATASETS` and `SITES` are unique, and every fact site
  and `FCID` is covered.
- **Overlap:** daily equals Monthly Actuals on 99.77% (KSL) and 100%
  (PEREGRINE) of keys over complete months.

**Changed in this extract (measured).**
- **History:** back to 2024 on every KSL fact and on PEREGRINE monthly
  (Q-07).
- **KSL ledger stat codes in `GL_ACCT`:** `100-9036-000` and
  `900-9999-000`. These are new `AMOUNT` keys (Q-04, report only).
- **KSL 2024 labor department labels** have no numeric prefix (112,679
  rows), so `DEPARTMENT` is null (Q-09).
- **Malformed KSL codes** have grown to 212 account and 31 stat values. One
  account carries a trailing tab (Q-12).
- **Statistic families:** KSL adds `81`, `83` and `BO` (from malformed
  codes).
- **Pacing:** the forward position is now present; PEREGRINE pace tables
  are populated (Q-10).
- **Ledger status:** a new `S` (KSL, 49 rows; Q-11).
- **`ACCOUNT_CLASS` and `SITE_GROUPS`:** PEREGRINE's are populated (123 and
  13 rows).
- **Category:** Smart Forecast maps to FORECAST (Q-03); every scenario with
  rows now maps.

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
| `SOURCE_AMOUNT` | As booked, **sign included**. |
| `STAT_VALUE` | Where the lane holds a statistic measure. |
| `IS_SUBTOTAL` | The source's own total or rollup row. Default `FALSE`. |
| `SUBTOTAL_SOURCE` | How a subtotal was identified, or that the source gives no way to tell. |
| `SOURCE_TABLE` | Which source table the row came from. Never null. |
| `SOURCE_LINE_KEY` | The natural key making a source row addressable, or null. |

---

## Corrections

- **M3 (Q-13).** PEREGRINE ledger `SITE_NAME` is null on 9,468 rows at 4
  sites (2026-06 to 2026-08). `SITES` states the name for all four. It is
  reported, not repaired.

- **After stop 1.** Smart Forecast now maps (Q-03); the freeze end is
  confirmed (Q-07).
- The blank template's `ACCOUNT_KEY` row omitted `SOURCE_ITEM_ID`; it is
  restored above per D-06 (as in builds 01 and 03).
