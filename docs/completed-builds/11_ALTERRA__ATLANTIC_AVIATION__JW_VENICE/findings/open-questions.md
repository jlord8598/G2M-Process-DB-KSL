# Open questions - build 11

| # | Lane | Question | Proposal | Blocks |
|---|---|---|---|---|
| Q-01 | ALTERRA | Ski Butlers' "Alterra Resorts" section restates the resorts' "... - Rentals & Repairs - Ski Butlers" lines exactly (27 of 27 months on all 5 lines, M1 section 4). Keep both? | Keep both. The Ski Butlers copy goes to `UNKNOWN` as `DUPLICATE_DETAIL`; the resort lines stay classified. | M4 |
| Q-02 | ATLANTIC_AVIATION | `Total Company` (`IS_ROLLUP`) matches the sum of the 18 sites on 77.4% of shared cells. How should it be treated? | Total Company rows of lines the sites carry: `IS_SUBTOTAL` + `SOURCE_ROLLUP`. Its debt / revolver lines (no site carries them) stay classified. | M3 |
| Q-03 | JW_VENICE | `CLN_JW_VENICE_MONTHLY_PL_DEPT` is named by ACCOUNTS (2,164 accounts) but is not in landed data. | Build without it and record it for the source owner. ACTUAL then comes from the FCAST summary tables only. | - |
| Q-04 | JW_VENICE | FTE and HEADCOUNT share department labels but measure different things. A shared key would give them one unit (check 2(d)). | `DEPARTMENT` = DEPARTMENT_LABEL, `ACCOUNT_KEY` = the table subject (`FTE` / `HEADCOUNT`) as `SOURCE_ITEM_ID`. Or another identifier you name. | M3 |
| Q-05 | JW_VENICE | CAPEX is vendor purchase lines with no account or department. Which stream does it feed, and what is its key? | Balance Sheet / Assets, `ACCOUNT_KEY` = `CAPEX` (the table subject). Or out of scope. | M3 |
| Q-06 | ATLANTIC_AVIATION | Fuel Margin: money or a statistic (per gallon)? | STATISTIC with the KPIs | M3 |
| Q-07 | ALTERRA | Undistributed "Other - Commercial Properties" and "Other - Real Estate": income or expense? | Below the Line / Other Income / (Expense) | M4 |
| Q-08 | ALTERRA | 11 null-section keys (Aspenware, Aviation, MWHS, Corporate). | Map by line name: Revenue - Other -> Revenue; Expenses - Other G&A -> Operating Expenses; EBITDA and Total lines -> rollup | M4 |
| Q-09 | ATLANTIC_AVIATION | Salaries and Benefits (FBO and Corp) sit in the operating expense sections. Should they be Payroll? | Follow the section: Operating Expenses | M4 |
| Q-10 | ATLANTIC_AVIATION | The "Debt" section's EBITDA bridge lines (Revenue / COS / OpEx #2 #3, Non-Cash, Operating One-Times, Unadjusted / OfficeConnect EBITDA, Check), the 4 numbered GL lines and One Time Adjustments: what are they? | Rollup / bridge: `SOURCE_ROLLUP`, `H1` Unclassified. Numbered GL lines -> Below the Line / OI/E. | M4 |
| Q-11 | JW_VENICE | OWNER INTEREST & INCOME TAX mixes interest and tax. | Below the Line / Other Income / (Expense); Income Taxes left unmapped | M4 |
| Q-12 | ATLANTIC_AVIATION | OC FORECAST and BUDGET agree on 13,617 of 13,680 cells. Is BUDGET a real budget? | Keep both as named; record for the source owner | - |

**Owner check (not the build's, D-03):** confirm the master holds no keys for
ALTERRA, ATLANTIC_AVIATION or JW_VENICE.

## Owner answers, stop 1

| # | Answer | Done |
|---|---|---|
| D-03 | Amend CLAUDE.md: "Classification never derives from CLN.XREF. The build may read KSL_MASTER_ACCOUNT_HIERARCHY only to report the key-match rate and conflicts with reviewed rows; it never writes." Confirm the master holds no keys for the three lanes. Diff at stop 4; not committed. | Amended (D-03, plus the 4 sentences that contradicted it: sections 2, 7, 11 and D-47). Master: 0 keys for each lane, query `01c82ba3-030a-7dfd-0003-4ff21c6bc66a`. |
| Q-01 | Yes, as a D-48 rule: resort Ski Butlers lines beat the Ski Butlers "Alterra Resorts" copy. Check 2(m) applies. | Added to the D-48 rule list |
| Q-02 | Yes, if Total Company vs the sum of the 18 sites is within 1% in 95% or more of months on Total Revenue, total OpEx and EBITDA. | Passed: 100% / 95.7% / 95.7% (93 months), query `01c82ba3-030a-7dfb-0003-4ff21c6b96fe` |
| Q-03 | Build without MONTHLY_PL_DEPT; log N-8. | N-8 |
| Q-04 | As proposed. | |
| Q-05 | CAPEX out of scope; log it. | N-9 |
| Q-06 | Statistic if per-gallon in size; ask if dollar-sized. | **Dollar-sized**: raised as Q-13 |
| Q-07, Q-08, Q-10, Q-11 | As proposed. | |
| Q-09 | Payroll: salaries and benefits are Payroll whatever their section. | |
| Q-12 | Keep both; log with ALTERRA's all-zero FORECAST and empty BUDGET. | N-10, N-11 |

## New at stop 2

| # | Lane | Question | Proposal | Blocks |
|---|---|---|---|---|
| Q-13 | ATLANTIC_AVIATION | **Fuel Margin is dollar-sized, not per gallon.** 487 non-zero cells: median 1,059.87, max 40,828.99, on the same (thousands) scale as Fuel Gross Profit. Fuel Margin / Gallons = MPG in 487 of 487 cells, so **MPG is the per-gallon margin** and Fuel Margin is the total. Fuel Margin equals Fuel Gross Profit within 1% in 25 of 487 cells (median ratio 0.873). Money or statistic? | Money, as a computed margin: `IS_SUBTOTAL` + `SOURCE_ROLLUP`, like the Gross Profit lines. MPG stays a statistic. | M3 |
| Q-14 | all | **AGENTS.md still says "`CLN.XREF` is out of scope"** (line 44), which now disagrees with the amended D-03. Amend it to match? | "`CLN.XREF` is out of scope for classification; the master may be read only as `CLAUDE.md` D-03 allows." | - |

## After stop 2

| # | Result | Next |
|---|---|---|
| Q-13 | **Condition failed.** Fuel Margin = Fuel Gross Profit (= Fuel Revenue - Fuel COS) within 1% on 25 of 544 cells (4.6%). Median ratio 0.77-0.95 at most entities (`M1.md` section 9). | Owner. Proposal: **STATISTIC**, with the other "KPIs - JetA Only" lines (Landings, Trips, Gallons, MPG). It is a KPI on a narrower (likely Jet-A only, unverified) basis, so it routes to operating metrics with `SOURCE_AMOUNT` null and its value in `STAT_VALUE`. It never sums with the P&L. MPG stays a statistic. |
| Q-14 | AGENTS.md amended as proposed (uncommitted). | Diff at stop 4 |

**Q-13 answer (owner):** Fuel Margin is an operating metric, following the B09-D4 pattern: `H1` Statistic, `RECORD_TYPE` AMOUNT, `METRIC_UNIT` currency, `AGGREGATION_TYPE` FLOW. It never adds into the P&L. MPG stays a statistic (STATISTIC). The basis question is logged as N-12.

## Before M4 (build stopped; no M4 DDL run)

| # | Lane | Question | Proposal | Blocks |
|---|---|---|---|---|
| Q-15 | ALTERRA | **Seven "... - Total" lines are the only figure their entity / section carries.** The approved rule ("LINE_ITEM contains Total"; Q-08 for the null-section lines) marks them `SOURCE_ROLLUP`, which would take them out of the income statement. Each has no detail line beneath it in the source (queries `01c82c02-030a-7f5b-0003-4ff21c6e200e`, `01c82c00-030a-7dfd-0003-4ff21c6d6322`). ACTUAL: Corporate / (no section) **Expenses - Payroll - Total 230,503,060.94** and **Revenue - Total 13,788,880.27**. Corporate EBITDA = ("Revenue - Total") minus ("Total - Expenses") minus ("Expenses - Payroll - Total") in 27 of 27 months, so both are in Corporate's EBITDA. CMH / Operating Labor **Expenses - Payroll - Total 34,104,768.82**, CMH's only payroll line. Ski Butlers / Other Resorts **Revenue - Total 14,678,398.12, Expenses - Payroll - Total 3,771,912.91, Expenses - Departmental Direct - Total 1,496,829.78, Expenses - Cost of Sales - Total -22,646.12**. Other Resorts GOP = its Revenue less these three in 24 of 24 months, and Other Resorts appears nowhere else (Consolidated = Alterra Resorts + Other Resorts; Alterra Resorts is the D-48 loser). | **(a)** Classify the seven as their family (Revenue, Payroll, Operating Expenses, Cost of Goods Sold), `IS_SUBTOTAL` FALSE, `SUBTOTAL_SOURCE` "lone total: the only figure for its entity / section (Q-15)". Every other approved rollup stands (Corporate Total - Expenses has 9 detail lines, 27 of 27; resorts' totals have detail). **(b)** Keep the approved rule: 298,321,204.72 of ACTUAL leaves the income statement. | M4 |

**Also measured (informational, for the stop-4 tie-out):**
- **ALTERRA's GOP section does not follow one formula.** "Departmental Profit -
  Total" equals Revenue - Total less the Cost of Sales, Payroll and
  Departmental Direct totals in only 85 of 459 entity-months.
- **ALTERRA's EBITDA** (Undistributed Expenses section) equals Departmental
  Profit - Total less Expenses - Total G&A less the undistributed expense
  lines in 362 of 459 (query `01c82c01-030a-7dfd-0003-4ff21c6d6366`).
- **ATLANTIC Total Company debt lines** vs the sites: Long-Term Debt and Total
  Debt 93 of 93 months; Other Debt 81 of 93. They are rollups as approved.

**Q-15 answer (owner):** (a), as a rule: a "Total" line is `SOURCE_ROLLUP` only when its entity and section also carry detail lines. A total with no detail beneath it is classified by its family, `SUBTOTAL_SOURCE` = "lone total (Q-15)". Applied at M4; catches exactly the 7 lines (`sources.md`).

## Raised at stop 4 (from the EBITDA tie-out, `M6.md` section 2)

| # | Lane | Question | Proposal | Blocks |
|---|---|---|---|---|
| Q-16 | ALTERRA | **CMH "Revenue - Total - Trip" (152,089,883.76) and "Revenue - Total - Lodging" (7,582,403.87) have no component lines, but the Q-15 rule marks them `SOURCE_ROLLUP`** because CMH's Revenue *section* has other detail lines. Revenue - Total = Trip + Lodging + the detail lines in 12 of 12 non-zero months. So 159,672,287.63 of CMH revenue leaves the income statement. Is that the intended reading of "detail beneath it"? | Narrow the test from entity + section to the line's own family: a "... - Total - X" line is a rollup only when lines of family X exist in the same entity and section (for CMH, no "Revenue - Trip ..." or "Revenue - ... Rooms" lines). The 7 Q-15 lines still qualify; this adds the 2 CMH lines. Re-measure before applying. | promotion of ALTERRA |
| Q-17 | ALTERRA | **"Revenue - Home Owners" is a deduction booked positive.** Revenue - Total - Net Rooms = Revenue - Gross Rooms - Revenue - Home Owners at every resort (M1). Classified Revenue (Credit, +1), it is added to revenue. Against the source EBITDA this overstates by 2 x Home Owners: netting it explains most of each resort's tie-out gap over the 27 months, e.g. Blue 93,953,150.93 of 97,981,992.24 and Mammoth 94,973,718.36 of 97,817,186.62 (query `01c82c1b-030a-7f55-0003-4ff21c6e5636`). | **(a)** Route "Revenue - Gross Rooms" and "Revenue - Home Owners" to `UNKNOWN` as `SOURCE_ROLLUP` components and classify "Revenue - Total - Net Rooms" as Revenue (the net is the booked figure). **(b)** Keep as is and record the contra line for the master (`H3` Revenue Adjustments with a per-account sign there). Not a repair either way: no amount changes. | promotion of ALTERRA |

## Owner answers, stop 4

| # | Answer | Done |
|---|---|---|
| Q-16 | Replace the Q-15 test with a data test: a Total line is `SOURCE_ROLLUP` only when it equals the sum of its own line family's detail within 1% in at least 95% of months; otherwise lone total by family. Report every line whose treatment changes. | Applied in staging; 2 lines change (CMH Trip, Lodging), `sources.md` |
| Q-17 | "Revenue - Home Owners" stays Revenue as a contra line, `VALUE_SIGN` flipped. Net Rooms, if its own line, is a rollup under the Q-16 test. | Seeder ALTERRA branch; Net Rooms passes Q-16 at 15 of 15 resorts (rollup) |
| scale | Do not rescale ATLANTIC; log for the source owner. | N-13 |
| diffs | CLAUDE.md and AGENTS.md diffs approved; not committed. | |

## Raised at the second stop 4

| # | Item | Proposal |
|---|---|---|
| Q-18 | **Q-17 conflicts with D-13 and check 2(l).** D-12 / D-13 make `VALUE_SIGN` a fixed function of `NORMAL_BALANCE` (from `H2`), and 2(l) asserts it. The Home Owners keys (Revenue, Credit, `VALUE_SIGN` -1) are exactly the 2(l) exceptions (`M6.md`). | Add to D-13: "Exception: a contra line approved by the owner for a lane and listed here carries the opposite sign; it keeps its `H2`, `P_L_SECTION` and `NORMAL_BALANCE`. **Contra lines:** ALTERRA (build 11): Revenue - Home Owners." Amend 2(l) to exempt listed contra lines. Not edited: awaiting approval. |

## Owner answers, final stop 4

| # | Answer | Done |
|---|---|---|
| Q-18 | Yes: add the contra-line exception to D-13 and amend check 2(l). | CLAUDE.md D-13 and 2(l) amended (uncommitted). ALTERRA check 2 re-run: 2(l) = 0, with the 15 contra keys checked for the opposite sign (query `01c82c48-030a-7f58-0003-4ff21c6f94be`). |
| residuals | Accepted. The 7 resorts' residuals are the Q-07 OI/E lines, which our EBITDA leaves out by design. Log CMH "Revenue - SG&A" for the business review. | N-14 |
| process | Deleting the ALTERRA snapshot rows was fine for a new lane with no master keys; ask first next time. | noted |
