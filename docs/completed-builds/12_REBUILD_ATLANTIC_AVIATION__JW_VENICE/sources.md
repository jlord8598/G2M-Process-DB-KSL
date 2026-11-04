# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

---

## Source schema

`CLN.BOX_INVESTMENT_DATA`. **Load freeze (D-43):** the 9 tables of the two
rebuilt lanes, from 2026-11-04 10:35:36.393 PST to 2026-11-05 06:00
America/Los_Angeles (owner Q-01).
- **Baseline:** `HASH_AGG(*)` per table, values in `findings/M1.md`
  section 1.
- **Check:** `scripts/d43_check.sql`, at every stop.

## Lane declaration (owner, build 12 kickoff)

| Lane | Source tables | Notes |
|---|---|---|
| JW_VENICE | ACCOUNTS, FCAST_ACT_FORECAST, FCAST_BY_PERIOD, FTE, HEADCOUNT, **MONTHLY_PL_DEPT (new)** | **Rebuilt (D-44)** to stage MONTHLY_PL_DEPT. CAPEX stays out of scope (Q-08). |
| ATLANTIC_AVIATION | ACCOUNTS, OC_DATA | **Rebuilt (D-44)** to scale the dollar measures, Gallons and Fuel Margin x1000 (Q-07). |

**Rebuild rule (D-44):** the key rule of build 11 is kept unchanged.
- **Reference:** `docs/completed-builds/11_ALTERRA__ATLANTIC_AVIATION__JW_VENICE/sources.md`.
- **Keys:** every existing key is reproduced. New keys are MONTHLY_PL_DEPT's
  only.
- **Master (D-03):** 1,149 / 156 keys, 100% matched, 0 reviewed rows, 0
  conflicts.

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

Measured against this extract unless marked *unverified*. **Build 11's
findings stand except where this section changes them.** They are reproduced
below for reference and marked "(build 11)".

### JW_VENICE: changes in build 12

**MONTHLY_PL_DEPT** (8,656 rows, one file "AUG - PL.xlsm"):
- **Grain:** 17 department sheets x line (`LINE_ORDER`) x period (2025-08,
  2026-08) x `PERIOD_TYPE` (MONTH, YTD); unique (8,656 distinct).
- **Measures:**
  - ACTUAL on all rows: `ACTUAL_SOURCE_SCENARIO` "LAST YEAR" for 2025-08,
    "ACTUAL" for 2026-08.
  - BUDGET on the 4,328 2026-08 rows.
  - No FORECAST.
- **Shape:** wide, **2 measure columns unpivoted** (ACTUAL, BUDGET), so
  8,656 x 2 = 17,312 staged rows.
- **Key:** SITE = PROPERTY_NAME (as the other JW tables); DEPARTMENT =
  DEPARTMENT (the sheet); ACCOUNT_KEY = LINE_ITEM as `SOURCE_ITEM_ID`.
- **The join to ACCOUNTS** (DEPARTMENT = DEPARTMENT_DESCRIPTION, LINE_ITEM =
  ACCOUNT_DESCRIPTION) is 100%. That gives 2,164 classification keys.
- **`SECTION` is unusable:** "TOTAL HOTEL REVENUE" on 8,520 rows, a parse
  carry-over. Reported, not repaired.
- **`SOURCE_LINE_KEY`:** DEPARTMENT | LINE_ORDER | LINE_ITEM | PERIOD_DATE |
  PERIOD_TYPE | branch.
- **`RECORD_TYPE`:** STATISTIC for the 98xxxx hour accounts and the named
  statistics (Rooms Sold, Total Rooms, Total Guests in House, TOTAL OCC
  ROOMS & OCC PT, DEPARTMENT VOLUME, the 0010-0309 stat codes, hours,
  SALES/HOUR, AVERAGE RATE, % TO TOT WAGES, CPV lines, NUMBER OF ...);
  else AMOUNT.

**`H1` / `H2` (D-46, account blocks; owner Q-04):**

| Block | `H1` / `H2` |
|---|---|
| 3xxxxx | Revenue / Revenue |
| 4xxxxx | Expense / Cost of Goods Sold |
| 51, 52, 54, 56, 58xxxx | Expense / Payroll |
| 6xxxxx | Expense / Operating Expenses |
| 7xxxxx except 701110 | Expense / Operating Expenses (fees 706001, 701120; fixed expenses, insurance, property taxes 701025, 701727, 720901, 720910, 730108, 740002; A&G / S&M accounts 76-79xxxx; allocation credit 759101) |
| 701110 | Below the Line / Other Income / (Expense) (replacement reserve, below EBITDA) |
| 98xxxx and named statistics | Statistic / the line text |

**Test:** Revenue - COGS - Payroll - OpEx on TOT_HTL's GL-account rows equals
the owner's EBITDA excl. owner expenses, 2026-08 1,303,456.44 and 2025-08
1,518,519.50; 0 unplaced lines.

**Subtotals (Q-16 test):**
- **Every named money line is `SOURCE_ROLLUP`.** Each named group equals the
  accounts above it in 100% of cells, and the 13 chain totals hold in 68 of
  68.
- **Lone totals:** 0.

**D-48 rules (owner Q-02, Q-03, Q-09, Q-11), as built in SPROC_XFRM_JW_VENICE:**
- **MONTHLY_PL_DEPT beats FCAST_ACT_FORECAST / FCAST_BY_PERIOD** for ACTUAL
  in 2025-08 and 2026-08 (18 of 18 mapped lines exact in each month). Every
  other FCAST month stays. 73 classified FCAST rows lose.
- **MONTH beats YTD.** YTD = January-August cumulative, exact. 8,656 rows.
- **TOT_HTL beats every other sheet** (Q-09 (a), replacing Q-05's CB rule):
  TOT_HTL's GL-account rows are the detail; the 16 department sheets (CB
  included) lose. 14,432 rows.
- **The first 98xxxx hours block beats its repeat** (`<code> | <text> | #n`;
  96 / 96 account-cells equal; Q-11). 192 rows.
- A losing row whose key is Unclassified (a source subtotal) keeps
  SOURCE_ROLLUP; only classified losers are DUPLICATE_DETAIL (9,233 rows).

**Test, as built:** Revenue - COGS - Payroll - Operating Expenses (VALUE) on
SEM_AI_INCOME_STATEMENT_ACTUAL, MONTHLY_PL_DEPT rows: 2026-08 1,303,456.44 and
2025-08 1,518,519.50, equal to the owner P&L.

**Currency:** CURRENCY_CODE EUR (owner Q-10: the report header states "Currency Code: EUR"). No landed JW column states it.

**Not in landed data:**
- the Minor Operated department sheet;
- JW's currency;
- FX rates.

#### JW_VENICE (build 11)

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

### ATLANTIC_AVIATION: changes in build 12

**Scaling (owner Q-07):** `SOURCE_UNIT_SCALE` = 1000 for every dollar line,
for Gallons and for Fuel Margin; 1 for MPG, Landings and Trips (N-17) and
the other ratios.
- **Why:** the template states "(000's)", and Fuel Revenue / Gallons = 5.11
  per gallon as stored, which proves Gallons are in thousands.
- **Where:** staging keeps source values and states the scale;
  transformation multiplies.
- **Reconcile:** CLN = STG unscaled; CLN x scale = XFRM = SEM.

**Currency:** not stated in landed data (Q-10).

#### ATLANTIC_AVIATION (build 11)

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

---

## Corrections

None yet.

## Build 12 staging (M3)

- STG_JW_VENICE_MONTHLY_PL_DEPT: CLN_JW_VENICE_MONTHLY_PL_DEPT (8,656 rows) wide x 2 (ACTUAL, BUDGET) = 17,312. RECORD_TYPE and IS_SUBTOTAL as in M3.md. The repeated 98xxxx block restates the first (Q-11).
- STG_ATLANTIC_AVIATION_OC_DATA: + SOURCE_UNIT_SCALE / SOURCE_UNIT_SCALE_SOURCE (Q-07). Values as booked.

## Build 12 classification, transformation and semantic (M4-M6)

- Seeder JW_VENICE branch: + MONTHLY_PL_DEPT, account blocks as above; 2,164 new keys, 0 re-seeded. ATLANTIC_AVIATION branch unchanged.
- SPROC_XFRM_JW_VENICE: + MONTHLY_PL_DEPT and the four D-48 rules above.
- SPROC_XFRM_ATLANTIC_AVIATION: SOURCE_AMOUNT, STAT_VALUE and VALUE x SOURCE_UNIT_SCALE (Q-07); SOURCE_UNIT_SCALE / _SOURCE carried on the five streams.
- Semantic: CURRENCY_CODE after SOURCE_AMOUNT in every lane block of the six models: USD (KSL_SELECT_SERVICE, PEREGRINE_RESORTS, HHG, NEWBURY, HERSHA, INVITED_CLUBS, DAVIDSON, ATLANTIC_AVIATION), EUR (JW_VENICE), MIXED (BEAUMIER, N-19), UNCONFIRMED (ALTERRA, N-18).
