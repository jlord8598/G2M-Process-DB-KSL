# Open questions (build 23)

## Stop 2 (end of M1)
- **Q-01. Freeze.** Please confirm Gary's freeze covers the 8 HICV tables at the 2026-11-16 07:56 loads (and the two Beaumier tables once visible). M2 waits for this.
- **Q-02. Beaumier 2027 tables not visible.** CLN_BEAUMIER_OPS_STATS_MONTHLY and CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI are ACTIVE in CLN_UTIL_TABLE_MAP, but G2M_MCP_AGENT cannot see them ("does not exist or not authorized").
  - Please grant them, or confirm they are built.
  - Until then, part B cannot be profiled, the overlap with STG_BEAUMIER_BUDGET (2025-26 only) cannot be tested, and no precedence can be proposed.
  - Do you want the build to continue HICV-only and add Beaumier later, or to wait?
- **Q-03. HICV P&L vs GL (D-48).** The two tables overlap on Sep 2025 and Sep 2026 and disagree (Sep 2026 revenue 231.7M vs 322.7M; 372 of 7,512 shared cells equal). Options:
  - (a) The P&L wins every month; the GL's two months go to UNKNOWN as DUPLICATE_DETAIL. This gives one continuous actual series (Jan 2025 - Oct 2026), consistent with the forecast and budget.
  - (b) The GL wins for Sep 2025 and Sep 2026 (ledger-level, like HERSHA's trial balance); the P&L's actuals for those two months go to UNKNOWN. This mixes two actual definitions across months.
  - (c) The GL is not staged.
  - Recommended: (a).
- **Q-04. Timeshare classification** (H1 from the account digit; H2 by mapping). Proposed, against the peer lanes:
  - VOI sales, rental, club, HOA / property-management / management fees, fee-for-service, retail and resort income -> Revenue / Revenue.
  - Financing income (interest on owner mortgages) -> Revenue / Revenue, because it is core timeshare income, not treasury interest. Alternative: Below the Line / Other Income / (Expense).
  - Loan-loss provision and down-payment forfeiture -> Revenue / Revenue (a contra, under D-13?). Alternative: Expense / Operating Expenses.
  - Cost of vacation ownership (digit 4) -> Expense / Cost of Goods Sold.
  - Digit 5 -> Payroll.
  - Interest expense, D&A, income taxes -> Below the Line (Other Income / (Expense), Depreciation & Amortization, Income Taxes).
  - Cost reimbursement revenue / expense: kept gross, both sides.
  - Which source states the H2 mapping? Either the GL's PL_SUB_CATEGORY_1 (covers 94.3% of P&L amount; 61 P&L accounts not covered) or the P&L's stated category in LINE_DESCRIPTION (all accounts; the parse fails on 13% of lines).
- **Q-05. Currency:** USD (assumed; no currency column)?
- **Q-06. Sign convention (D-50):** PROFIT for both tables (revenue positive, costs negative)? In the P&L, interest expense (+3.46M) and mortgage-servicing expense (+4.33M) are positive in Sep 2026, which would publish as income. Report as booked (no repair), or treat as contra lines?
- **Q-07. Room keys:** stage as a dictionary only (2008-2023; no 2024-26 keys, not in landed data)?
- **Q-08. Weekly KPI / TREND / RESERVATIONS:** all three to the PACING stream and SEM_AI_PACING?
  - SNAPSHOT_DATE = report date; VANTAGE = CY / PY; SEGMENT = SECTION.
  - The window (WEEK / MTD / YTD) is part of METRIC_NAME or ATTRIBUTES.
  - Units: counts, CURRENCY (USD; "$'000" / "$000's" carried as stated, not scaled), and ratios / % non-additive.
  - Alternative: the KPIs to operating metrics, which would put snapshots and overlapping windows in a summable table.
- **Q-09. Key:** site = LOCATION_CODE, department = COST_CENTER_CODE, account = ACCOUNT_CODE, with ledger and LOB carried but not keyed? The same account + cost center + location appears under 7 ledgers at location 12701020, so one classification would cover every ledger.
- **Q-10. OPS_PRIORITIES_WEEKLY:** text (96 status notes, 0 numeric). Logged as reference only, not staged, per your rule.

## Owner answers (stop 2)
- Q-01: freeze confirmed (HICV, 2026-11-16 loads). Q-02: Beaumier granted, profiled, added to the baseline.
- Q-03: the P&L wins every month; the GL's two months go to UNKNOWN as DUPLICATE_DETAIL.
- Q-04: rulings agreed. H2 from the GL hierarchy where it covers the account, the description category otherwise; the unclean 13% listed at M3.
- Q-05: USD, an assumption. Q-06: as booked, not flipped; monthly check done (sources.md). Q-07: dictionary. Q-08: SEM_AI_PACING. Q-09: key approved. Q-10: reference only.

## Before M2
- **Q-11. Beaumier USALI currency.** The table comment says EUR for every hotel, but the existing lane carries HGB and HSB as CHF. Use the lane's per-hotel currency (HGB, HSB CHF; the rest EUR)?
- **Q-12. Q-03 in light of the P&L's scope.** The P&L carries far less of the cost of sales than the GL in the same month (Sep 2026: payroll -20.3M against -138.2M; sales commissions 0 against -30.7M; total 134.2M against 80.4M). With the P&L winning, HICV semantic will show that scope. Confirm Q-03 stands?
- **Q-13. Q-06 interest expense.** Interest On Senior Notes (777805) is positive in the P&L in 21 / 22 months but negative (a cost) in the GL, so it is not a credit reducing expense. Report as booked, as you said, and log it as an open item for the source owner?
- **Q-14. Beaumier OPS_STATS:**
  - SCENARIO = the measure column name (D-45)?
  - BUDGET_KEYS STOCK; rooms sold, rooms available and opening days FLOW; units ROOMS / ROOMS / DAYS?

## Owner answers (before M2)
- Q-11: the lane's per-hotel currency; the table comment's conflict logged (N-58).
- Q-12: the P&L still wins; the narrower cost scope logged (N-59) and recorded in sources.md.
- Q-13: as booked; logged (N-60).
- Q-14: CATEGORY BUDGET, SCENARIO = the raw source label (budget year); the measure is the statistic account; keys STOCK, the rest FLOW.

## Stop 3 (end of M3)
- **Q-15. H2 for the HICV P&L lines whose description does not split cleanly** (Q-04). The list is in `docs/findings/hicv_ambiguous_descriptions.csv`: 1,663 descriptions, 42,432 source lines, 135 accounts. 1,620 descriptions split into 6 parts and 43 into 7. The cause is a bare hyphen inside a name ("Non-recurring", "Check-Out", "Villa- HOA").
  - Staging carries `DESC_PL_CATEGORY` only where the split is clean, and null otherwise. Nothing is inferred.
  - Measured: for the 42,432 lines, the same account's clean lines state exactly one category for 1,272 lines, more than one for 4,128, and none at all for 37,032.
  - Proposed for the M4 seeder, which is per key, not per line:
    - (1) the GL's PL_SUB_CATEGORY_1 where the GL covers the account (your Q-04 rule);
    - (2) otherwise the key's own clean category where all its clean lines state one;
    - (3) otherwise H2 UNCLASSIFIED, corrected in the master.
  - Agree? The alternative is to stop at (1) and send everything else to UNCLASSIFIED.
- **Q-16. Sign convention entries for D-50.** Staged `SOURCE_SIGN_CONVENTION`:
  - HICV FIN_PL_MONTHLY and FIN_GL_MONTHLY: PROFIT (your Q-06: as booked);
  - BEAUMIER FIN_BUDGET_MONTHLY_USALI: PROFIT, as the lane's existing budget;
  - OPS_STATS has no money.

  Confirm for the D-50 register?
- **Q-17. SCENARIO for the Beaumier USALI budget.** The table names no scenario. I applied your Q-14 rule for its sister table: SCENARIO = BUDGET_YEAR ('2027'). Under D-45 read strictly it would be the table name, `CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI`. Keep the budget year?
- **Q-18. HICV P&L SCENARIO on empty measure cells.** SCENARIO is the version the source names (FORENOV, FOREOCT), and the measure column name where it names none (ACTUAL_AMOUNT, BUDGET_AMOUNT; BUDGET_VERSION is null on every line).
  - The versions are populated only on the lines whose amount is populated. So the unpivoted empty cells carry the column name: 313,214 empty FORECAST_AMOUNT cells read FORECAST_AMOUNT, and 170,844 empty PREVIOUS_FORECAST_AMOUNT cells read PREVIOUS_FORECAST_AMOUNT.
  - This is verbatim and carries no amount. I recorded it rather than change the rule. No action unless you want otherwise.
- **Q-19. GL SOURCE_LINES_COMBINED.** 9,084 of the 15,257 GL lines have SOURCE_LINES_COMBINED > 1 (maximum 8, total 46,044): the landing layer combined source lines before CLN.
  - Carried as booked. The GL loses to the P&L everywhere (Q-03), so this changes no figure.
  - Log as an open item for the source owner?

## Owner answers (stop 3)
- **Q-15:** fix the parse first, by anchoring on the known category names; then the fallbacks, in order, for what is left.
  - Done (M4): 35,880 of the 42,432 lines resolve.
  - The 6,552 left are 251 "Cost of vacation ownership" descriptions on one account and 1 "Impairment" description (N-62).
  - The seeder uses the GL sub-category, then the P&L category, of the key and then of the account.
- **Q-16:** PROFIT for the HICV P&L, the HICV GL and the BEAUMIER USALI budget. Interest On Senior Notes is reported as booked.
- **Q-17:** "2027", the source's BUDGET_YEAR.
- **Q-18:** no change. 683,376 of 1,366,752 cells are empty; they are kept as in the peer lanes (2,675,732 empty INVITED_CLUBS lines in the budget table alone).
- **Q-19:** logged as N-61, low priority.

## Stop 4 (end of M6)
- **Q-20. Register entries for CLAUDE.md** (yours to write; the agent does not edit it):
  - D-48: HICV (build 23): `CLN_HICV_FIN_PL_MONTHLY` beats `CLN_HICV_FIN_GL_MONTHLY` in every month the P&L carries (all GL months), and the GL lines go to UNKNOWN as DUPLICATE_DETAIL (Q-03, Q-12).
  - D-50: HICV (build 23): FIN_PL_MONTHLY and FIN_GL_MONTHLY PROFIT. BEAUMIER (build 23): FIN_BUDGET_MONTHLY_USALI PROFIT (Q-16).
- **Q-21. Loan-loss provision accounts on digit 8.** Your Q-04 ruling (provision -> Revenue) meets the digit rule (8 -> Below the Line). The result is H1 Below the Line / H2 Revenue on 297 keys (2 accounts), with VALUE_SIGN +1, in the income statement. Keep, or change H1 to Revenue in the master?
- **Q-22. Contra candidates (D-13).** The sign-anomaly test lists accounts running against their class. Add any to D-13 as contra lines, or correct them in the master? Examples:
  - 500020 Salary & Wages Contra (+65.7M);
  - revenue contras 340805, 340804, 372002 and 300101 (-8.8M to -17.0M each);
  - 878901 Allocation Other (+116.2M).

  Nothing was reclassified.
- **Q-23. HICV TREND Sales-tab units.** 4,358 SEM_AI_PACING rows carry no METRIC_UNIT and IS_ADDITIVE false: the Sales-tab channel lines whose unit is stated only on a header row above them ("Close Rate", "ASP ($'s)", "Gross Volume ($000's)"). Reading the unit from line order would be inference. Leave them null, or have the source state the unit per line?
- **Q-24. BEAUMIER: 3 Unclassified USALI keys** (HVT Affiliation/Representation, HLG Branding, HPN Room service Food; 20 lines, -2,919.50 EUR / CHF).
  - USALI states no PL_SECTION, and the same line names are classified at other hotels.
  - Correct in the master after promotion, or map USALI lines through STG_BEAUMIER_HIERARCHY? The second is a changed H2 mapping for a rebuilt lane, which needs your approval.
- **Classification changes for the rebuilt lane (stop 4, D-44):** none.
  - The 1,181 existing BEAUMIER keys hash identically before and after (`8409854223578525169`). No key's H1 or H2 changed, and no re-seed was run.
  - The 47 new keys are inserts.

## Owner answers (stop 4)
- **Q-20:** add both register entries yourself.
  - Done: D-48 HICV and D-50 HICV / BEAUMIER are in CLAUDE.md, including the Interest On Senior Notes exception.
- **Q-21:** provision is contra-revenue, as a seeder build rule.
  - Done: 297 keys re-seeded, Below the Line -> Revenue.
  - VALUE_SIGN stays +1. The source is PROFIT-signed, so the booked negative already reduces revenue. No D-13 opposite-sign entry was added, because it would change no VALUE.
- **Q-22:** no reclassification. Logged as N-63.
- **Q-23:** fill the unit down within unambiguous blocks.
  - Done for the Sales tab: 5 headers, one line item per LINE_ORDER in all 36 groups.
  - Left unitless and logged: the block headed "Sales" (1,656 rows) and the 1,584 rows above the first header (N-64).
- **Q-24:** map the 3 keys through STG_BEAUMIER_HIERARCHY. Done (M6_stop4.md).
