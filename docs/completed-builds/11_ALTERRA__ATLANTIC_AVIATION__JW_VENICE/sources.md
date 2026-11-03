# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

---

## Source schema

`CLN.BOX_INVESTMENT_DATA`. **Load freeze (D-43):** the 11 tables below, from
the first successful read, 2026-11-03 11:27:31.297 PST, to 2026-11-04 06:00
America/Los_Angeles. After 06:00 the build continues only while the D-43
check shows no change.

**Baseline:** `HASH_AGG(*)` per table (query
`01c82b8f-030a-7dfd-0003-4ff21c6bc326`), checked at every stop. The values are
in `findings/M1.md` section 1.

| Table | Rows | `last_altered` (PST) |
|---|---|---|
| CLN_ALTERRA_ACCOUNTS | 1,370 | 2026-11-03 10:42:02.921 |
| CLN_ALTERRA_MONTHLY_FINANCIALS | 38,781 | 2026-11-03 10:42:01.446 |
| CLN_ALTERRA_PACE_BY_STAY_MONTH | 10,320 | 2026-11-03 10:41:58.277 |
| CLN_ATLANTIC_AVIATION_ACCOUNTS | 1,149 | 2026-11-02 15:08:54.493 |
| CLN_ATLANTIC_AVIATION_OC_DATA | 109,995 | 2026-11-02 15:08:53.163 |
| CLN_JW_VENICE_ACCOUNTS | 2,360 | 2026-11-03 10:04:06.632 |
| CLN_JW_VENICE_CAPEX | 200 | 2026-11-03 10:04:00.418 (out of scope, Q-05) |
| CLN_JW_VENICE_FCAST_ACT_FORECAST | 808 | 2026-11-03 10:04:02.072 |
| CLN_JW_VENICE_FCAST_BY_PERIOD | 761 | 2026-11-03 10:04:03.319 |
| CLN_JW_VENICE_FTE | 1,044 | 2026-11-03 10:03:58.337 |
| CLN_JW_VENICE_HEADCOUNT | 1,080 | 2026-11-03 10:03:56.667 |

## Lane declaration (owner, build 11 kickoff and stop 1)

| Lane | Source tables | Notes |
|---|---|---|
| ALTERRA | ACCOUNTS, MONTHLY_FINANCIALS, PACE_BY_STAY_MONTH | New lane |
| ATLANTIC_AVIATION | ACCOUNTS, OC_DATA (OfficeConnect pulls) | New lane |
| JW_VENICE | ACCOUNTS, FCAST_ACT_FORECAST, FCAST_BY_PERIOD, FTE, HEADCOUNT | New lane. CAPEX is out of scope (Q-05, N-9). MONTHLY_PL_DEPT is not in landed data (Q-03, N-8). |

**Granted, out of scope:** the other 38 tables in `CLN.BOX_INVESTMENT_DATA`,
which belong to earlier builds' lanes. Listed, not read.

**Lane names (D-32):**
- **Free in `DEV_G2M_AI`:** the 8 `SOURCE_LANE` values in use are BEAUMIER,
  DAVIDSON, HERSHA, HHG, INVITED_CLUBS, KSL_SELECT_SERVICE, NEWBURY and
  PEREGRINE_RESORTS.
- **Free in `docs/completed-builds/` and `sql/`.**
- **Master (read under the amended D-03):** 0 keys for any of the three, and
  no similar lane name (query `01c82ba3-030a-7dfd-0003-4ff21c6bc66a`). It holds
  364,527 keys across the 8 existing lanes, 0 of them reviewed.

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
| `SCENARIO` | The named scenario, verbatim; where the source names none, the stating table or measure column name (D-45). Never null. |
| `SOURCE_AMOUNT` | As booked, **sign included**. Never strip a negative - that is a silent repair (invariant 3). |
| `STAT_VALUE` | Where the lane holds a statistic measure. |
| `IS_SUBTOTAL` | The source's own total or rollup row. Default `FALSE`. |
| `SUBTOTAL_SOURCE` | How a subtotal was identified, or that the source gives no way to tell. |
| `SOURCE_TABLE` | Which source table the row came from. Never null. |
| `SOURCE_LINE_KEY` | The natural key making a source row addressable, or null. |

---

## Per-lane findings

Every statement is *measured* against this extract unless marked *unverified*.

### ALTERRA

**Shape:**
- **MONTHLY_FINANCIALS:** wide, **3 measure columns unpivoted** (ACTUAL_AMOUNT,
  FORECAST_AMOUNT, BUDGET_AMOUNT), so 38,781 x 3 = 116,343 staged rows.
- **ACCOUNTS:** long.
- **PACE_BY_STAY_MONTH:** pacing, long, its own shape.

**The account number:** none. LINE_ITEM is the source's line identifier: 104
values, of the form "Revenue - Paid Pass" or "Expenses - Payroll - Rooms".
- `ACCOUNT_NUMBER` and `STAT_ACCOUNT` are null.
- `SOURCE_ITEM_ID` = LINE_ITEM, so `ACCOUNT_KEY` = LINE_ITEM (D-06).
- 0 blank line items.

**Key:** `SOURCE_SITE_CODE` = ENTITY (21); `DEPARTMENT` = SECTION (13 values
+ null, the null sentinel-coalesced).
- **Why SECTION is needed:** 6 entity / line item pairs occur under two
  sections.
- **Unique:** (ENTITY, SECTION, LINE_ITEM, PERIOD_DATE) is unique.
- **Count:** 1,370 classification keys, one per ACCOUNTS row.

**Section source:** a dictionary. `ACCOUNTS.DEPARTMENT_DESCRIPTION` =
MONTHLY_FINANCIALS.SECTION, stated in words. No digit.
- **ACCOUNTS** is a catalogue of the facts: one row per entity x section x
  line item, `ROW_COUNT` summing to 38,781, `SOURCE_TABLE` always
  MONTHLY_FINANCIALS.
- **It has no** account code, parent, alias or type.

**`RECORD_TYPE`:** derived. STATISTIC for SECTION in (Skier Visits, KPIs);
otherwise AMOUNT.
- **`RECORD_TYPE_SOURCE`:** 'SECTION rule (Skier Visits, KPIs)'.
- **No line item appears both as money and as a statistic** under the same
  entity and section.

**Statistic vocabulary (D-38):**
- **H2 is the section name:** "Skier Visits" (9 items: Paid / Season Pass /
  Comp / Employee / Other / Total Skier Visits, Rooms Available, Total
  Occupied Rooms, Occupancy (%)) and "KPIs" (CMH, 5 items).
- **No unit is stated**, so `METRIC_UNIT` is null.

**Category and scenario:**
- **Category comes from the measure column:** ACTUAL / FORECAST / BUDGET.
- **SCENARIO** = the column name (D-45).
- **Filled cells by measure:**
  - ACTUAL: 36,977 cells, 2024-06 to 2026-08.
  - FORECAST: 1,661 cells, 2026-09 to 2027-07, **all 0.00**.
  - BUDGET: 0 cells.
  - Both blank measures are logged as N-11.

**Text columns:**
- `ACTUAL_TEXT` is always null.
- `FORECAST_TEXT` is "No Data Available" on 143 rows.
- Carried as attributes.

**Period:** PERIOD_DATE, a month-end. 38 months, 2024-06 to 2027-07.

**Files:** one, "Alterra Mountain Company - Monthly Performance_Aug 2026_Submitted.xlsx" (report month 2026-08).
- **`SOURCE_LINE_KEY`:** ACTUAL_SOURCE_FILE_PATH | ACTUAL_SOURCE_ROW_NUMBER, or
  the forecast pair for forecast-only rows.

**Sign:** revenue and expense both booked positive. Profit lines carry their
own sign.

**Entities:**
- **38 months:** 15 resorts, CMH (heli-skiing, the KPIs section), Corporate
  (section "Expenses") and Ski Butlers (segment sections).
- **27 months, null section:** Aspenware, Aviation, MWHS.
- **Aviation is not Atlantic Aviation:** 0 of 27 months match ATLANTIC Total
  Company revenue, at x1 or x1000.

**`H1` / `H2` mapping (approved, stop 1):**

| Section (keys) | `H1` / `H2` |
|---|---|
| Revenue (310) | Revenue / Revenue |
| Cost of Sales (155) | Expense / Cost of Goods Sold |
| Operating Labor (151) | Expense / Payroll |
| Operating Expenses (154), G&A (96), Expenses (11) | Expense / Operating Expenses |
| Undistributed Expenses (180) | Expense / Operating Expenses; "Other - Commercial Properties", "Other - Real Estate" -> Below the Line / Other Income / (Expense) (Q-07) |
| Skier Visits (132), KPIs (5) | Statistic / the section name |
| Gross Operating Profit from Operations (150) | rollup (below) |
| Ski Butlers: Alterra Resorts (5), Other Resorts (5), Consolidated (5) | Other Resorts by line name (Revenue -> Revenue, Cost of Sales -> COGS, Payroll -> Payroll, Departmental Direct -> Operating Expenses); Alterra Resorts by line name and then **D-48 loser**; Consolidated rollup |
| null section (11) | by line name (Q-08): Revenue - Other -> Revenue; Expenses - Other G&A -> Operating Expenses; EBITDA, Revenue - Total, Expenses - Payroll - Total -> rollup |

- **Level 2 (`H3`):** none stated.
- **D&A and Income Taxes:** none stated (0 accounts).

**Subtotals:** `IS_SUBTOTAL` + `SOURCE_ROLLUP` (`H1` Unclassified).
- **Rule (`SUBTOTAL_SOURCE`), as amended by Q-15 and replaced by the Q-16
  data test (owner, stop 4):**
  - Ski Butlers SECTION = Consolidated (25 of 25, M1);
  - or a computed profit line: LINE_ITEM starts "EBITDA" or "Departmental
    Profit", or Gross Operating Profit by SECTION or by LINE_ITEM;
  - or a "Total" line (LINE_ITEM contains Total; not "Total Occupied Rooms",
    a measure) that **equals the sum of its own line family's detail within 1%
    in at least 95% of its ACTUAL months.**
- **A Total that fails the test is a lone total:**
  - It is classified by its family (Revenue, Payroll, Operating Expenses,
    COGS), with `SUBTOTAL_SOURCE` "lone total (Q-15)".
  - The test runs per entity, section and line in
    `SPROC_STG_ALTERRA_MONTHLY_FINANCIALS` (CTE `q16`).
- **Line families (named from the line text; same entity and section):**

  | Total line | Family (detail lines) |
  |---|---|
  | Revenue - Total | every Revenue line not containing Total |
  | Revenue - Total Operations | the same, except Revenue - SG&A |
  | Revenue - Total - Lift | Paid Lift Tickets, Paid Pass |
  | Revenue - Total - Mountain Operations | Paid Lift Tickets, Paid Pass, Mountain - Other |
  | Revenue - Total - Net Rooms | Gross Rooms, Home Owners (contra, negated) |
  | Revenue - Total - Lodging | Gross Rooms, Home Owners (negated), Other - Rooms |
  | Revenue - Total - Trip | Revenue - Trip... (none exist) |
  | Expenses - Cost of Sales / Payroll / Departmental Direct - Total | Expenses - Cost of Sales / Payroll / Departmental Direct - ... |
  | Expenses - Total G&A, Total - Expenses | the section's non-total lines |
  | Undist. Op-Ex - Total, Total Undistributed | the section's non-total lines except Other - Commercial Properties and Other - Real Estate (OI/E, Q-07) |
  | Total Skier Visits | Paid, Season Pass, Comp, Employee, Other Visits |

- **Pass 2:** a total that is lone in pass 1 counts as detail of Revenue -
  Total and Revenue - Total Operations, so CMH's Revenue - Total is not
  counted twice.
- **The Undistributed family excludes the two "Other - ..." lines**
  (measured): with them excluded, Undist. Op-Ex - Total equals its family in
  27 of 27 months at every resort. With them included, it matches in 4-21 of
  27 at 7 resorts (query `01c82c2d-030a-7f62-0003-4ff21c6e8cb6`).
- **Treatment changed by Q-16 vs Q-15** (query
  `01c82c30-030a-7f4d-0003-4ff21c6dcdca`): exactly 2 lines, both CMH,
  rollup -> classified Revenue as lone totals:
  - Revenue - Total - Trip (ACTUAL 152,089,883.76);
  - Revenue - Total - Lodging (7,582,403.87).
- **Unchanged:** the 7 Q-15 lone totals stay lone, and every other total
  stays a rollup.
- **Contra line (owner, Q-17):** "Revenue - Home Owners" stays `H1` Revenue /
  `H2` Revenue, with `VALUE_SIGN` -1 so `VALUE` reduces revenue.
  `SOURCE_AMOUNT` is unchanged, as booked. It is the one key in this lane whose
  sign does not follow `NORMAL_BALANCE` (D-13; see `findings/M6.md`).

**Duplicates, D-48 (owner, Q-01):** the resorts' "... - Rentals & Repairs -
Ski Butlers" lines beat Ski Butlers' "Alterra Resorts" section.
- **Measured:** an exact copy, 27 of 27 months on each of Revenue
  (18,564,338), Payroll (4,376,477), Departmental Direct (2,277,776), COS
  (38,288) and GOP (11,871,798).
- **Treatment:** the Ski Butlers copy rows go to `UNKNOWN` as
  `DUPLICATE_DETAIL`, keeping `H1`-`H5`. Check 2(m) applies.

**Pacing (PACE_BY_STAY_MONTH):**
- **As-of date:** SNAPSHOT_DATE, distinct from STAY_MONTH: 5 snapshots,
  2026-10-30 to 2026-11-03, 10 files, 6 file dates.
- **Unique** on (SNAPSHOT_DATE, DESTINATION, HOTEL_NAME, STAY_MONTH,
  MARKET_SEGMENT_CATEGORY): 10,320 of 10,320.
- **Coverage:** 12 destinations, 43 hotels, stay months 2026-01 to 2027-12,
  segments Transient / Group.
- **Measures:** TODAY / STLY_DOW / ST2Y_DOW x ROOMS_COMMIT / ROOM_REVENUE_OTB.
- **No code column** looks like a GL account.
- **Never feeds the seeder.**
- **Not a restatement of MONTHLY_FINANCIALS:** for closed stay months against
  the 11-03 snapshot, Gross Rooms matches 27 of 96 cells, Total Lodging 4 and
  Net Rooms 0.

### ATLANTIC_AVIATION

**Shape:** OC_DATA is wide, **3 measure columns unpivoted** (ACTUAL, FORECAST,
BUDGET), so 109,995 x 3 = 329,985 rows. ACCOUNTS is long.

**The account number:** none, apart from 4 line items whose text begins with a
GL number (543019, 543025, 700066, 711810).
- `ACCOUNT_KEY` = LINE_ITEM (75 values) as `SOURCE_ITEM_ID`.
- The numbered text is carried, not parsed.

**Key:** SITE = ENTITY (19, including `Total Company`, `IS_ROLLUP` = TRUE);
DEPARTMENT = SECTION as stored.
- **Unique** on (ENTITY, SECTION, LINE_ITEM, PERIOD_DATE): 109,995 of 109,995.
- **Count:** 1,149 classification keys = ACCOUNTS rows.

**Section, as stored:** every row of the 18 sites carries "KPIs - JetA Only",
a label that applies only to the first block, so it looks like a parse
carry-over. **Reported, not repaired.** `Total Company` rows carry 10 true
sections.

**Section source:** ACCOUNTS.DEPARTMENT_DESCRIPTION under `Total Company`. Each
line item is mapped by the section stated for it there (approved, stop 1).
- **Covers 54 of the sites' 61 line items.**
- **The other 7:**
  - the 4 numbered GL lines and One Time Adjustments -> Below the Line / OI/E
    (Q-10);
  - "Revenue | Revenue | #3" -> bridge rollup (Q-10);
  - "Corporate Operating Expenses", one hidden Vertiports row with all
    measures null (a section header parsed as a line) -> Unclassified.

**`H1` / `H2` mapping:**

| Total Company section | `H1` / `H2` |
|---|---|
| Revenue | Revenue / Revenue |
| Cost of Sales | Expense / Cost of Goods Sold |
| FBO Operating Expenses, Corporate Operating Expenses | Expense / Operating Expenses; **Salaries and Benefits and Salaries and Benefits - Corp -> Expense / Payroll** (Q-09); Corporate Other Income/Expense -> Below the Line / OI/E |
| Debt Reporting, Debt Breakdown, Revolver; Debt: Long-Term Debt, Other Debt | Balance Sheet / Liabilities; Cash (Ending Balance) -> Balance Sheet / Assets |
| KPIs - JetA Only: Landings, Trips, Gallons, MPG | Statistic / "KPIs - JetA Only" |
| KPIs - JetA Only: Fuel Margin | Statistic, as a classifier override (owner, Q-13, the B09-D4 pattern): `RECORD_TYPE` AMOUNT, `METRIC_UNIT` currency, `AGGREGATION_TYPE` FLOW. It never adds into the P&L. Basis logged as N-12. |
| Gross Profit; Pre-Corporate OpEx EBITDA, Adj. EBITDA; Debt-section bridge (Revenue / COS / OpEx #2 #3, Non-Cash, Operating One-Times, Unadjusted / OfficeConnect EBITDA, Check); Net Debt, Check - Debt, Check total vs all pieces; Total Debt, Total Debt Outstanding, Total Balance Sheet Debt | rollup (below) |

**`RECORD_TYPE`:** derived. STATISTIC for LINE_ITEM in (Landings, Trips,
Gallons, MPG); otherwise AMOUNT. Fuel Margin stays AMOUNT (Q-13).
- **Statistic H2:** "KPIs - JetA Only". No unit stated.
- **MPG is margin per gallon:** Fuel Margin / Gallons = MPG in 487 of 487
  non-zero cells.

**Category, scenario, period:**
- **Category:** from the measure column. SCENARIO = the column name.
- **Coverage:**
  - ACTUAL: 2019-01 to 2026-12 (105,638 cells);
  - FORECAST and BUDGET: 2026 only, 13,680 cells each, **within 1% on 13,617**
    (N-10).
- **Period:** PERIOD_DATE, a month-end, 96 months.
- **Files:** one, "KSL Qtly Template - September 2026 - ilevel W Debt Info_1.
  10.29.2026.xlsx".
- **`SOURCE_LINE_KEY`:** the measure's file path | source cell.

**Scale:** values look like thousands (unverified; not stated in landed data).

**Sign:** revenue and costs positive at the operating sites. `Corp` books some
revenue lines negative.

**Source flags:**
- `IS_SUBTOTAL`: 11,164 rows.
- `IS_HIDDEN_ROW`: 40,993 rows, carried as an attribute.
- `IS_ROLLUP`: 6,314 rows, the `Total Company` entity.

**Subtotals:** `IS_SUBTOTAL` + `SOURCE_ROLLUP`.
- **Rule:**
  - the source `IS_SUBTOTAL`;
  - plus the computed lines it does not flag (the rollup row of the table
    above);
  - plus `Total Company` rows of any line the sites also carry.
- **Total Company's own debt and revolver lines** stay classified (Balance
  Sheet).
- **Source flag verified against the detail (entity x month):** Total
  Revenue, Total COS, Total Gross Profit, Total FBO OpEx and Total Corp OpEx
  1,767 of 1,767 each; Total Debt 1,761 of 1,767.
- **Q-02 condition, passed:** Total Company vs the sum of the 18 sites, by
  month, ACTUAL (query `01c82ba3-030a-7dfb-0003-4ff21c6b96fe`):
  - Total Revenue 93 of 93 within 1% (100%);
  - Total OpEx (FBO + Corp) 89 of 93 (95.7%);
  - Adj. EBITDA 89 of 93 (95.7%).
  - So it is treated as `SOURCE_ROLLUP`.

### JW_VENICE

**Shape:**
- **FCAST_ACT_FORECAST and FCAST_BY_PERIOD:** wide, **2 measure columns**
  (ACTUAL, FORECAST), 1,616 and 1,522 rows.
- **FTE and HEADCOUNT:** wide, **4** (ACTUAL, FORECAST, PREVIOUS_FORECAST,
  BUDGET), 4,176 and 4,320 rows.
- **ACCOUNTS:** long.

**The account number:** none. One entity, "JW Marriott Venice".

**Keys:**
- **FCAST tables:** SITE = PROPERTY_NAME; DEPARTMENT = SECTION;
  `ACCOUNT_KEY` = LINE_ITEM. 69 + 68 keys, 97 distinct across both. SECTION
  is needed because ROOMS, SPA, etc. occur under both OPERATING REVENUE and
  DEPARTMENT PROFIT.
- **FTE / HEADCOUNT (Q-04):** DEPARTMENT = DEPARTMENT_LABEL (29 / 30);
  `ACCOUNT_KEY` = the table subject, `FTE` or `HEADCOUNT`, as
  `SOURCE_ITEM_ID`.
- **DEPARTMENT_CODE** is null on the subtotal rows (108 FTE, 144 HEADCOUNT
  rows). It is carried as an attribute.

**Section source:** SECTION, in words, on the fact rows and in
ACCOUNTS.DEPARTMENT_DESCRIPTION.
- **ACCOUNTS rows:** 2,360 in total; 196 describe landed tables. 2,164
  describe the missing MONTHLY_PL_DEPT (N-8).

**`H1` / `H2` mapping (approved, stop 1):**

| Section | `H1` / `H2` |
|---|---|
| OPERATING REVENUE, SALES | Revenue / Revenue |
| UNDISTRIBUTED OPERATING EXP | Expense / Operating Expenses: A&G, IT & Telecom, Energy, POM, CNTR TRAIN & RELOC, S&M, BASE / INCENTIVE MGMT FEE, PRE-OPENING, Owner Expenses, REPLACEMENT RESERVE. Below the Line / OI/E: NON-OP INC/EXP EXCL. OWNER EXP., OWNER INTEREST & INCOME TAX (Q-11) |
| KEY STATISTICS | Statistic / "KEY STATISTICS"; **CREDIT CARD EXPENSE -> Expense / Operating Expenses** (money) |
| Isolated / One off costs (to be input by Marriott) | Below the Line / Other Income / (Expense) |
| FTE, HEADCOUNT | Statistic / "FTE", "HEADCOUNT" |
| DEPARTMENT PROFIT; TOTAL ... lines; GROSS OPERATING PROFIT, INCOME BEFORE NON-OP INC/EXP, EBITDA EXCL. OWNER EXPENSES, EBITDA, EBITDA Less REPLACEMENT RESV, NET DUE TO/(FROM) OWNER, RETAINED PROFIT/(LOSS) | rollup |

**`RECORD_TYPE`:** derived. STATISTIC for SECTION = KEY STATISTICS except
CREDIT CARD EXPENSE, and for every FTE / HEADCOUNT row; otherwise AMOUNT.
- **No unit stated.**
- **`AGGREGATION_TYPE`:** `UNRATIFIED`. FTE and HEADCOUNT read as stock but
  the source does not say (unverified).

**Category, scenario, period:**
- **Category:** from the measure column. SCENARIO = the column name.
- **ACT_FORECAST:** ACTUAL 2026-01 to 08, from "7+5 with August actualised".
  FORECAST 2026-08 (as-of 07-31, the "6+6" file) and 2026-09 to 12 (as-of
  08-31).
- **BY_PERIOD:** ACTUAL 2025-01 to 12 only, from the "6+6 with July
  actualised" file. `ACTUAL_REPORT_AS_OF_DATE` is 2025-12-31, so this is
  prior-year actual.
- **FTE / HEADCOUNT:** 2024-01 to 2026-12. ACTUAL 928 / 960 cells, FORECAST
  116 / 120, PREVIOUS_FORECAST 116 / 120, BUDGET 348 / 360.
- **Period:** PERIOD_DATE, a month-end.

**Sign:** revenue and expense positive.

**Overlap:**
- **FCAST_ACT_FORECAST vs FCAST_BY_PERIOD:** 0 shared periods, so not a
  restatement and no D-48 rule.
- **Text columns:** `ACTUAL_TEXT` / `FORECAST_TEXT` hold "-" on 6 / 1 rows.

**Subtotals:** `IS_SUBTOTAL` + `SOURCE_ROLLUP`.
- **FCAST rule:** LINE_ITEM starts "TOTAL" or "TOT ", SECTION = DEPARTMENT
  PROFIT, plus the computed lines in the rollup row above.
- **FCAST verified:** TOTAL OPERATING REVENUE / TOTAL SALES vs their leaves
  12 of 12 in each table.
- **FTE / HEADCOUNT:** the source `IS_SUBTOTAL` (ROOMS, F&B, A&G; HEADCOUNT
  adds a fourth). **Structure only:** it matches the preceding department
  block in 32 of 96 (FTE) and 32 of 128 (HEADCOUNT), so the subtotal groups
  are not contiguous.

**Not in landed data:** MONTHLY_PL_DEPT (N-8). CAPEX is out of scope (N-9).

---

## Corrections

Measured at M3 (`findings/M3.md`); each narrows an approved rule to what it was
meant to cover.

1. **"Total" lines that are statistics.**
   - **ALTERRA:** "Total Skier Visits" is a true total (405 of 405 cells equal
     the sum of the five visit lines), so it is marked.
   - **ALTERRA:** "Total Occupied Rooms" is a measure, not a sum, so it is not
     marked.
   - **JW_VENICE:** the KEY STATISTICS lines TOTAL OCCUPANCY, TOTAL REVPAR and
     TOTAL HOURS WORKED are measures, so they are not marked.
2. **ATLANTIC Total Company, the Debt-section bridge line named plain
   "Revenue."** The sites carry it as "Revenue | Revenue | #2", which the Q-10
   list names. Total Company carries it as "Revenue" (288 rows, ACTUAL sum
   7,495.50) and is now marked too. After this, Total Company's unmarked
   lines are exactly its 7 balance-sheet lines: TL1-1, Tl1-2, Accumulated
   Amort, Current Debt, Deferred Financing, Long Term Debt, Cash (Ending
   Balance).
