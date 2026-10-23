# Sources - build 05 (rebuild of KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**State: end of M6 (stop 4).** Written from queries run in this session against
`CLN.CLEAN`. Statements are marked *measured* or *decided*.

**Scope (owner).** A rebuild (D-44) with two purposes only:
1. `DEPARTMENT_NAME` from `CUR_PROFITSWORD_DEPARTMENTS`;
2. `SCENARIO` never null (D-45).

**Build 04's profile stands**
(`docs/completed-builds/04_REBUILD_KSL_SELECT_SERVICE__PEREGRINE_RESORTS/sources.md`).
Only what these changes touch is re-measured here, plus the source changes
D-43 requires reporting.

---

## Source schema and freeze

- **Source:** `CLN.CLEAN`.
- **Freeze (D-43):** from **2026-10-23 08:23:25.583 PDT** (database clock at
  the first query) to **2026-10-25 08:23 PDT** (owner).
- **Extract (owner, Q-01):** the 06:50 PDT reload, taken before the freeze.
  **Superseded by the 09:14 reload during the freeze, confirmed intended by
  the source owner (Q-06).** The baseline below is the 09:14 extract.
- **Against build 04's records (measured, query `01c7ecbb-020a-418d-0003-4ff21bc23e0e`):
  they do not match.**
  - All 27 tables were last altered **2026-10-23 06:49:58.419 to 06:50:43.489
    PDT**, before this freeze began. Build 04 recorded 2026-10-22 13:41.
  - The extract gained about one day (Q-01).

| Table | Build 04 rows | Now | `last_altered` (PDT, 2026-10-23) |
|---|---|---|---|
| CUR_PROFITSWORD_DEPARTMENTS | - (new) | 2,647 | 06:50:43.489 |
| CUR_PROFITSWORD_KSL_ACCOUNT_CLASS | 54 | 54 | 06:50:05.027 |
| CUR_PROFITSWORD_KSL_COA | 8,634 | 8,634 | 06:50:03.967 |
| CUR_PROFITSWORD_KSL_DAILY_EXTENDED | 8,049,208 | 8,063,150 | 06:50:16.957 |
| CUR_PROFITSWORD_KSL_DAILY_LABOR | 434,051 | 434,986 | 06:50:27.034 |
| CUR_PROFITSWORD_KSL_DATASETS | 24 | 24 | 06:50:02.137 |
| CUR_PROFITSWORD_KSL_LEDGER_BATCHES | 574,556 | 575,700 | 06:50:23.383 |
| CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED | 1,217,855 | 1,217,914 | 06:50:09.821 |
| CUR_PROFITSWORD_KSL_SALES_BOOKINGS | 10,348 | 10,390 | 06:50:30.910 |
| CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS | 27,733 | 27,733 | 06:50:39.104 |
| CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS | 47,979 | 47,979 | 06:50:33.575 |
| CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT | 481,337 | 481,337 | 06:50:36.849 |
| CUR_PROFITSWORD_KSL_SITES | 41 | 41 | 06:49:58.419 |
| CUR_PROFITSWORD_KSL_SITE_GROUPS | 137 | 137 | 06:50:00.303 |
| CUR_PROFITSWORD_PEREGRINE_ACCOUNT_CLASS | 123 | 123 | 06:50:07.454 |
| CUR_PROFITSWORD_PEREGRINE_COA | 22,554 | 22,554 | 06:50:06.058 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED | 350,583 | 357,288 | 06:50:19.934 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR | 266,565 | 268,362 | 06:50:28.888 |
| CUR_PROFITSWORD_PEREGRINE_DATASETS | 12 | **13** (`Budget 3`, FCID 17) | 06:50:03.128 |
| CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES | 31,791 | 32,225 | 06:50:24.667 |
| CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED | 589,229 | 593,686 | 06:50:12.609 |
| CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS | 5,050 | 5,084 | 06:50:32.214 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS | 481,730 | 481,730 | 06:50:41.336 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS | 62,929 | 62,929 | 06:50:34.802 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT | 79,160 | 79,160 | 06:50:37.957 |
| CUR_PROFITSWORD_PEREGRINE_SITES | 6 | 6 | 06:49:59.369 |
| CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS | 13 | 13 | 06:50:01.235 |

- **New date ranges (measured).**
  - Daily ends 2026-10-22 on both lanes; labor ends 2026-10-21.
  - Ledger is posted to 2026-10-22 (KSL) and 2026-10-21 (PEREGRINE).
  - Start dates are unchanged.

## Baseline for this build (owner, Q-06; measured, query `01c7ecf8-020a-3bc3-0003-4ff21bc3f21e`)

The 09:14 reload was confirmed intended by the source owner. **These are the
`last_altered` values every later milestone is checked against** (max
**09:14:32.938**). Fact sums are recorded too, so that a later reload can be
detected by content and not only by row count.

| Table | Rows | `last_altered` (PDT, 2026-10-23) | sum(amount) / sum(stat) |
|---|---|---|---|
| CUR_PROFITSWORD_DEPARTMENTS | 1,523 | 09:14:32.938 |  |
| CUR_PROFITSWORD_KSL_ACCOUNT_CLASS | 54 | 09:13:59.183 |  |
| CUR_PROFITSWORD_KSL_COA | 8,634 | 09:13:58.282 |  |
| CUR_PROFITSWORD_KSL_DAILY_EXTENDED | 8,063,150 | 09:14:10.169 | 42,015,541,204.62 / 971,716,535.33 |
| CUR_PROFITSWORD_KSL_DAILY_LABOR | 434,986 | 09:14:18.901 | 63,284,142.79 / 2,747,136.37 |
| CUR_PROFITSWORD_KSL_DATASETS | 24 | 09:13:56.370 |  |
| CUR_PROFITSWORD_KSL_LEDGER_BATCHES | 575,700 | 09:14:15.402 | 647,816,253.53 / 4,345,713.11 |
| CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED | 1,217,914 | 09:14:03.648 | 18,343,084,951.28 / 39,874,123.23 |
| CUR_PROFITSWORD_KSL_SALES_BOOKINGS | 10,390 | 09:14:21.823 |  |
| CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS | 27,733 | 09:14:29.191 |  |
| CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS | 47,979 | 09:14:23.854 |  |
| CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT | 481,337 | 09:14:27.043 |  |
| CUR_PROFITSWORD_KSL_SITES | 41 | 09:13:52.206 |  |
| CUR_PROFITSWORD_KSL_SITE_GROUPS | 137 | 09:13:54.207 |  |
| CUR_PROFITSWORD_PEREGRINE_ACCOUNT_CLASS | 123 | 09:14:01.245 |  |
| CUR_PROFITSWORD_PEREGRINE_COA | 22,554 | 09:14:00.341 |  |
| CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED | 357,288 | 09:14:12.679 | 3,374,765,269.96 / 58,649,237.21 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR | 268,362 | 09:14:20.554 | 40,067,552.19 / 1,524,197.95 |
| CUR_PROFITSWORD_PEREGRINE_DATASETS | 13 | 09:13:57.287 |  |
| CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES | 32,225 | 09:14:16.829 | 176,955,960.59 / 629,871.00 |
| CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED | 593,686 | 09:14:05.399 | 12,255,530,295.30 / 1,079,440,524.02 |
| CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS | 5,084 | 09:14:22.733 |  |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS | 481,730 | 09:14:31.015 |  |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS | 62,929 | 09:14:25.303 |  |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT | 79,160 | 09:14:28.170 |  |
| CUR_PROFITSWORD_PEREGRINE_SITES | 6 | 09:13:53.207 |  |
| CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS | 13 | 09:13:55.264 |  |

The earlier table below (06:50 reload) is kept as what M1 first measured.

## Lanes (owner, D-44)

`KSL_SELECT_SERVICE` and `PEREGRINE_RESORTS`, rebuilt under their existing
names.
- **The 26 tables** keep their build 04 roles.
- **`CUR_PROFITSWORD_DEPARTMENTS`** is one table holding both tenants (column
  `TENANT`: `KSL`, `PEREGRINE`). It would be staged once per lane,
  losslessly, as `STG_{LANE}_DEPARTMENTS` (D-26); each lane's model passes
  all rows through, carrying `TENANT`.
- **Lanes in `DEV_G2M_AI`:** BEAUMIER, HERSHA, HHG, INVITED_CLUBS,
  KSL_SELECT_SERVICE, NEWBURY and PEREGRINE_RESORTS, all archived. Parity
  91/91 clean.

---

## `CUR_PROFITSWORD_DEPARTMENTS` (measured)

- **Columns:** `TENANT`, `SITE_TAG`, `DEPT_CODE`, `DEPARTMENT_GENERIC`,
  `DEPARTMENT_OUTLET`, `OUTLET_SOURCE`, `ALL_SPELLINGS`.
- **Unique on (`TENANT`, `SITE_TAG`, `DEPT_CODE`):** 2,647 rows, 2,647 keys,
  raw and trimmed. There is no edge whitespace, and no blank generic or
  outlet value.
- **Size.** KSL: 1,813 rows, 37 sites, 49 codes. PEREGRINE: 834 rows, 6
  sites, 139 codes.
- **`ALL_SPELLINGS`** lists the COA report-group names per code with counts,
  for example `RESTAURANT 1 (105) | Food (105) | Miscellaneous (10) | ...`.
  It is the build 04 multiplicity, stated.

**`OUTLET_SOURCE` (query `01c7ecbc-020a-418d-0003-4ff21bc23e4e`).**

| Tenant | Source | Rows | Outlet differs from generic | Outlet contains `-` | Outlet contains a position word |
|---|---|---|---|---|---|
| KSL | COA | 1,484 | 0 | 0 | 0 |
| KSL | LABOR | 329 | 329 | 69 | 47 |
| PEREGRINE | COA | 608 | 0 | 0 | 0 |
| PEREGRINE | LABOR | 226 | 226 | 185 | 55 |

- **`COA` outlets** always equal the generic name.
- **`LABOR` outlets** are taken from labor `DEPARTMENT_LABEL` / `LABEL` text,
  and often include a position or a code. Examples:
  - `Housekeeping-Room Attendant`
  - `Pequin-181. Server`
  - `Accounting & Finance-805-Accounting Associate`
  - `Cattlemans Bar-191. Restaurant Supervisor`
- **167/181 (measured).** `DEPARTMENT_OUTLET = '3-Meal Restaurant'` (length
  17), `OUTLET_SOURCE = 'LABOR'`, generic `RESTAURANT 1`. The same value
  appears at sites 168, 170 and 177.
  - The "3" seen in DEV1 matches this value cut at its first hyphen.
  - No outlet in this table is purely numeric.

**Coverage against the facts (query `01c7ecbc-020a-3e71-0003-4ff21bc313ce`).**
The join is exact on tenant, `SITE_TAG` and department code. Department code
is segment 1 of the account (labor: the `DEPARTMENT_LABEL` prefix), as built
in build 04.

| Lane | Table | Rows | With a department | Named by build 04's rule | **Matched in DEPARTMENTS** | % of rows with a department | Of which via a `LABOR` outlet |
|---|---|---|---|---|---|---|---|
| KSL | daily | 8,063,150 | 1,280,934 | 26,120 | **1,152,083** | 89.94 | 642,961 |
| KSL | monthly | 1,217,914 | 1,180,332 | 18,368 | **1,071,445** | 90.77 | 695,835 |
| KSL | ledger | 575,700 | 448,006 | 18,001 | **422,788** | 94.37 | 173,400 |
| KSL | labor | 434,986 | 322,307 | 1,942 | **300,646** | 93.28 | 295,194 |
| PEREGRINE | daily | 357,288 | 95,830 | 44,467 | **95,830** | 100.00 | 76,751 |
| PEREGRINE | monthly | 593,686 | 583,866 | 306,864 | **583,866** | 100.00 | 499,791 |
| PEREGRINE | ledger | 32,225 | 31,257 | 14,092 | **31,257** | 100.00 | 15,177 |
| PEREGRINE | labor | 268,362 | 268,321 | 120,790 | **268,321** | 100.00 | 268,202 |

- **Named rows, build 04's rule against this join, on this extract:**
  - KSL: 64,431 against **2,946,962** (of 3,231,579 with a department).
  - PEREGRINE: 486,213 against **979,274** (of 979,274).
- **`LABOR`-sourced outlets** would name 1,807,390 KSL and 859,921 PEREGRINE
  rows (Q-03).
- **KSL unmatched: 284,617 (Q-04).**
  - 225,393 are at sites absent from the table: `CAPLSOP`, `CASCHOP`,
    `MAFBWOP`, `CAPICOP`.
  - 59,224 are on 79 codes absent at present sites: the malformed codes
    (`x...`, `D0...`), `10110.H197`, `605` and `900`.

**Rule (decided, Q-03 option (b)).** `DEPARTMENT_NAME = DEPARTMENT_GENERIC`
from `STG_{LANE}_DEPARTMENTS` on an exact join of tenant (`KSL` /
`PEREGRINE`), `SITE_TAG` and department code; null where no row matches
(Q-04). `DEPARTMENT_OUTLET` is not used: `LABOR`-sourced outlets hold job
titles, and `COA`-sourced outlets equal the generic name. The coverage
table above is the 06:50 version; the 09:14 coverage is in M1.md. The department name stays an attribute, not a
key part: existing classification rows keep their stored names (insert-only),
and keys do not move.

---

## D-45: `SCENARIO` per model (measured, `sql/` and query `01c7ecbc-020a-4584-0003-4ff21bc2596e`)

| Model (both lanes) | Today | D-45 rule | Value |
|---|---|---|---|
| `MONTHLY_EXTENDED` | `SCENARIO_NAME` | **source scenario name** | verbatim; 0 null or blank on either lane |
| `DAILY_EXTENDED` | null | **table name** | `CUR_PROFITSWORD_{T}_DAILY_EXTENDED` |
| `LEDGER_BATCHES` | null | **table name** | `CUR_PROFITSWORD_{T}_LEDGER_BATCHES` |
| `DAILY_LABOR` | null | **table name** | `CUR_PROFITSWORD_{T}_DAILY_LABOR` |
| any model | - | **measure column name** | **none applies.** No KSL/PEREGRINE fact model unpivots (build 04: all long). |
| pacing (3 per lane) | no `SCENARIO` column | - | Own shape (D-24); no semantic model. |

- **Category is unchanged.** It still comes from `SOURCE_TABLE` (daily,
  ledger, labor) or from `DATASETS` (monthly); `SCENARIO` does not route.
- **Monthly scenarios now (measured).**
  - KSL: Actuals, Primary Forecast, Budget, Budget 2, Flex, Forecast 2,
    Forecast 3, RMS - OneYield, RMS - HiltonGRO/IDeaS,
    5 Year Plan 2026 Final, Smart Forecast.
  - PEREGRINE: Actuals, Primary Forecast, Budget, Budget 2, **Budget 3
    (new, Q-02)**, Flex, Forecast 2.
  - Every monthly `FCID` is in `DATASETS`.

---

## Keys

Neither change touches a key part: `DEPARTMENT_NAME` and `SCENARIO` are not
in the five-part key. The D-44 key report runs at M4 as in build 04.

## Corrections

- **After stop 1 (Q-06).** All 27 tables were recreated at 09:13:52-09:14:32
  PDT, during the freeze.
  - `DEPARTMENTS` is now 1,523 rows, still unique on (tenant, site, code).
    It adds the four KSL sites and a column, `OUTLET_SPELLINGS`, and drops
    rows and codes.
  - The coverage figures above are M1's; the post-reload figures are in
    `open-questions.md` Q-06.
  - The build is stopped until the owner confirms.
- **Q-03 decided (b).** `DEPARTMENT_NAME = DEPARTMENT_GENERIC`; the outlet is
  not used.
