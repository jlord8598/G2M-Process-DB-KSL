# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

---

## Source schema

`CLN.DATA_SHARE` (new; schema created 2026-11-04 09:58 by G2M_SYSADMIN). Read access confirmed for all three tables. CLN_HAI_HOSPITALITY_FINANCIALS_ILEVEL and _OVERWATCH are not visible to this role (out of scope; not profiled).

**These are landed copies, not the live share** (measured): BASE TABLEs owned by G2M_SYSADMIN, created by load on 11-04 and unaltered since, 30-day Time Travel, no clustering. Tasks, streams and dynamic tables in the schema: none visible (SHOW is privilege-filtered, so not proof). Whether a refresh is scheduled is unverified (Q-01).

| Table | row_count | created = last_altered (PST) | HASH_AGG(*) |
|---|---|---|---|
| CLN_BECKONS_INCOME_STATEMENT_ACTUALS | 58,556 | 2026-11-04 12:30:05 | -7855247829544083558 |
| CLN_BECKONS_INCOME_STATEMENT_BUDGET | 68,477 | 2026-11-04 12:30:07 | 6361584687308303984 |
| CLN_HAI_HOSPITALITY_INCOME_STATEMENT | 169,616 | 2026-11-04 14:04:43 | -650502652644412764 |

## Lane declaration

| Lane | Source tables | Notes |
|---|---|---|
| BECKONS | CLN_BECKONS_INCOME_STATEMENT_ACTUALS, CLN_BECKONS_INCOME_STATEMENT_BUDGET | new; luxury lodges (AU, NZ, CA, CL) and Beckons corporate |
| HAI_HOSPITALITY | CLN_HAI_HOSPITALITY_INCOME_STATEMENT | new; restaurant group (UCHI, LORO), not hotels |

Names (owner): unused in docs/completed-builds/, in DEV_G2M_AI's classification table and in the master (measured).

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

## Per-lane findings (measured unless marked)

### BECKONS
- **Shape:** long, one line per lodge x location x month x department x account. Unique in BUDGET; 1 repeated pair in ACTUALS.
- **Sites:** LODGE_CODE, 11 lodges: ATA, CWL, DEN, HUK, LON, PAT, SAN, SLK, SOL, SYD, TLB. Plus LOCATION_NAME "UNKNOWN" with no LODGE_CODE in ACTUALS (695 lines, 2023-09 to 2026-11).
- **Periods:** FINANCIAL_PERIOD, month-end, 2023-01-31 to 2026-12-31 (48 months), in both tables. ACTUALS carry lines for 2026-11 (292) and 2026-12 (7), past today (Q-06).
- **Scenario:** one per table, no scenario column (D-45: the table name). They do not overlap on scenario: 386 lodge-months appear in both (actual against budget); 123 are actual-only and 7 budget-only. **Forecast: not in landed data.**
- **Currency:** BASE_CURRENCY per lodge: AUD (DEN, LON, SLK, SOL, SYD, TLB), NZD (HUK), CAD (CWL), USD (ATA, PAT, SAN, UNKNOWN). Two amounts per line: *_AUD (converted) and *_BASE (local). They differ on 26,651 actual and 17,948 budget lines (Q-02).
- **Accounts:** two charts.
  - 5-digit at most lodges (4 revenue, 5 cost of sales, 6 payroll, 7 operating / undistributed, 8 M&A / corporate, 9 other / suspense).
  - 7-digit Spanish chart at the Chilean entities (SAN, ATA, PAT; 4 ventas, 5 costo, 6 gastos incl. sueldos, 7 / 8 FX difference, deferred tax).
  - Statistics in BUDGET only, in the amount column: AROOM (available rooms), NIGHT (bed nights), OROOM (occupied rooms). 63 of their lines differ between AUD and BASE, i.e. counts were FX-converted (Q-04).
- **Source section:** ILEVELMAPPING1/2/3, an iLevel mapping in words (36 values, e.g. "Revenue - Gross Rooms", "Expenses - Payroll - Rooms", "Undist. Op-Ex - ..."). Null on 8,657 actual and 11,733 budget lines (431 / 228 accounts).
  - "Revenue - Total", "Expenses - Payroll - Total" and "Expenses - Management Fees - Total" are **mapping names, not total lines**: they hold real GL accounts (wages 61010, management fees 75001-75005, sundry revenue 49020).
  - "Tierra Hotels Corporate EBITDA" holds SAN's whole 7-digit chart (revenue, cost, payroll, rent): a reporting bucket, not a total line.
- **Subtotals:** no account or department title names a total, subtotal, profit or EBITDA (searched both tables). IS_SUBTOTAL would be FALSE everywhere, by structure.
- **Sign:** not one convention per table (Q-03).
  - ACTUALS: PROFIT at every lodge (revenue +, costs -). UNKNOWN location is the reverse (revenue -85.5M, costs +; DEBIT-like).
  - BUDGET: PROFIT at the 5-digit lodges; PRESENTED at the Tierra 7-digit entities (ATA, PAT, SAN: costs +).
- **Size:** ACTUALS sum to 14.8M AUD against BUDGET 254.4M AUD; the gap is mostly in unmapped and Chilean-chart lines. Not reconciled at M1.

### HAI_HOSPITALITY
- **Shape:** long, one line per location x fiscal period x calendar month x account, unique.
  - A 5-week fiscal period that spans calendar months has one line per month, splitting the period's actual (e.g. P7 2026: 2,633 / 55,932 / 4,185). The lines add; they do not repeat. AMOUNT_BUDGET sits on one of them.
- **Sites:** HH_MST_LOC_KEY (32-character hash), 51 locations, 18 legal entities. Brands UCHI and LORO; concepts UCHI, UCHIKO, UCHIBA, LORO, OTHER; LOCATION_TYPE RESTAURANT or OTHER (corporate entities). 4 lines have a null key (UCHI BOSTON, 2026-08 / 09).
- **Periods:** retail fiscal calendar, 12 periods a year (4-4-5), PERIOD_END on Sundays, 2023-02-05 to 2026-09-27 (45 periods). FISCAL_DATE and CALENDAR_DATE are month-firsts.
- **Scenarios:** **not actuals only.** AMOUNT_ACTUAL and AMOUNT_BUDGET on the same line; budget non-zero on 93,329 lines, in every fiscal year 2023-2026 (1,222.4M against 1,172.0M actual). **Forecast: not in landed data.**
- **Currency:** not stated in the table (all US locations; unverified, Q-07).
- **Accounts:** NNNN-NNN, 236 accounts; first digit 4 sales and discounts, 5 COGS, 6 labor, 7 operating / pre-opening, 8 occupancy / D&A, 9 overhead, interest, other, tax.
  - The source states its hierarchy: HIERARCHY_LEVEL_1-5, EXCEL_SUMMARY_HIERARCHY, GL_PARENT_GROUP, COST_CLASS, SORT_ORDER.
  - One labor account sits in the 4xxx range: 4804-000 EMPLOYEE PURCHASES (HIERARCHY_LEVEL_1 SALARIES AND WAGES).
- **Subtotals:** none. No total / profit lines; every account carries one leaf hierarchy. OVERHEAD 9101-000 OVERHEAD ALLOCATED (corporate, -56.3M) and 9102 / 9103 (restaurants, +56.3M) are an allocation that nets to zero within the lane, not a total.
- **Sign:** PRESENTED. Sales +, costs +; SALES DISCOUNTS - (contra revenue); INCOME TAXES net -4.8M.
- **No statistic lines.**

---

### Build 26 rules (owner stop 2 and addendum)
- BECKONS measure = *_AMOUNT_BASE with CURRENCY_CODE = BASE_CURRENCY; AUD staged only (Q-02). STAT_VALUE for AROOM / NIGHT / OROOM from base (Q-04); 63 of their lines differ AUD vs base (FX-converted counts).
- D-50 per table + entity (Q-03): ACTUALS PROFIT, UNKNOWN DEBIT; BUDGET PROFIT, ATA / PAT / SAN PRESENTED.
- Classification: ILEVELMAPPING1 per key first, proven account range for blanks (Q-08, Q-09, addendum A; M4.md).
- **Build rule, overriding the iLevel mapping (owner, pre-promotion):** depreciation and amortisation by account title go to Below the Line / Other Income / (Expense) at every BECKONS site, on both charts: 5-digit titles containing DEPRECIAT / AMORTIS / AMORTIZ (76001-76004, 76006, 76007), and the Chilean 62xx depreciacion / amortizacion / intereses titles (stop 4). Consistent with the Chilean chart and the peer lanes. The rule sits ahead of the mapping in the seeder branch.
- Site UNKNOWN (no LODGE_CODE): a Tierra central entity on the 7-digit chart (276 of 277 accounts shared with ATA / PAT / SAN), kept as stated (Q-10).
- Beckons - Sydney (SYD) is the management company: it books 75001-75005 with the opposite sign of each lodge (LON, SLK 47 / 47 months mirror, TLB 46 / 47, SOL 44 / 47, HUK 1 / 47 because the lodge books NZD) and 49101 / 49102 fee revenue (Capella, Clayoquot). Intercompany, not eliminated (addendum B, N-75).
- HAI: COMP_STATUS_PERIOD single value 2026-09-01 (one snapshot); USD by MARKET (all US cities); AMOUNT_BUDGET is the BUDGET (Q-05).
- Nov-Dec 2026 BECKONS actuals (Q-06): 2026-11 292 lines (20 zero), net -399,818, absolute 6,293,396; 2026-12 7 lines (3 zero), net 72,795. Non-zero: kept as landed, logged (N-70).

---

## Corrections

**When a measurement contradicts something written here, correct it and say
so.** A finding that a documented rule is wrong is worth more than a clean run.
