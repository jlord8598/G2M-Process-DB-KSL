# Open questions - build 22

- **Q-01.** Gary's freeze: confirm it covers the 10 tables (Westin / Third Space 09:39, Maldives 09:48) before M2.
- **Q-02.** Westin REF_ACCOUNTS has no descriptions at all (account, department, parent), and GOP cannot be derived from the landed data (blocks 4-7 exactly offset revenue in Aug). Build on the digit rule with blank descriptions and log "not in landed data", or ask the source owner for the chart first?
- **Q-03.** Westin classification by leading digit: 3 Revenue, 4 COGS, 5 Payroll, 6 / 7 Operating Expenses, 9 STATISTIC (H2 = 2-digit block code). Approve? (The 9 block mixes counts, hours and money-like values; 94 / 97 may be money.)
- **Q-04.** Maldives D-48 (as JW): MONTHLY beats SUMMARY per 1GSOD section + line + month; YTD lines in SUMMARY and OWNER go to UNKNOWN; the first line beats its "| #2" repeat; OWNER MONTH stays as 1BST5's only P&L. Approve?
- **Q-05.** Maldives subtotals: mark the capitalised total lines (TOTAL ..., group headers with detail, GOP, EBITDA ...) IS_SUBTOTAL, list to follow at M3. Approve the approach?
- **Q-06.** Currency, not in landed data for all three: Westin USD, Maldives USD, Third Space GBP? Confirm each.
- **Q-07.** Westin group pace: SEM_AI_PACING with METRIC as METRIC_NAME, VANTAGE = AS_OF (CY / PY), RMS = ROOMS, REV = CURRENCY, both additive; line key file | row | period. Approve?
- **Q-08.** Third Space CORP repeats 1,307 CLUBS lines (1,279 equal, 28 differ). D-48: CLUBS beats CORP for the same entity + section + line + month? And which wins on the 28 that differ?
- **Q-09.** Third Space: classify by LINE_ITEM (SECTION is shifted on some lines)?
- **Q-10.** Third Space gym lines: membership revenue as Revenue; member counts Statistic (Beginning / Closing Members STOCK, Adds / Losses / Freeze FLOW); PT sessions and visits Statistic FLOW. CASH AND DEBT lines: Balance Sheet (Cash, Debt) and Capex as Statistic? Corporate / Other Adjustments: Below the Line or Operating Expenses? The KSL REPORT / "Third Space" group entities: keep as sites, or UNKNOWN as SOURCE_ROLLUP?

## Owner answers (stop 2)
- Q-01 freeze confirmed.
- Q-02 / Q-03 Westin pace only; offset codes in N-55.
- Q-04 / Q-05 approved.
- Q-06 USD / USD / GBP, recorded as assumptions.
- Q-07 approved.
- Q-08 CLUBS beats CORP; the 28 are in N-56.
- Q-09 by line name.
- Q-10:
  - opening / closing members point-in-time (STOCK); adds, losses, freezes, PT sessions and visits FLOW;
  - cash and debt to SEM_AI_BALANCE_SHEET;
  - KSL REPORT Total Cash is a duplicated total (UNKNOWN DUPLICATE_DETAIL); the other group lines are group-only and stay;
  - adjustments are detail (all zero, no duplicates).

## Before M3
- **Q-11.** Maldives: DEPARTMENT PROFIT "TOTAL FOOD & BEVERAGE" and "TOTAL NON-OP INC/EXP" never tie to their detail (M2), so the approved rule leaves them as detail and they double-count. Options:
  - (a) flag them IS_SUBTOTAL anyway as named totals (SOURCE_ROLLUP), recording that they do not tie (the shown detail is incomplete);
  - (b) leave them as detail as the rule says.
  Recommended: (a).
- **Q-12.** Maldives VALIDATION OF PROFIT CON block (21-23 lines that re-state other lines, e.g. NET HOUSE PROFIT, ALL ACTIVITY IN DEPT 0690): all SOURCE_ROLLUP?

## Owner answers (before M3)
- Q-11: flag both; N-57; no plug lines.
- Q-12: rollups where they restate; the non-restating lines are shown at M3.

## Stop 3
- **Q-13.** The VALIDATION lines that restate nothing (M3 table): leave as detail? In particular, MONTHLY Fixed Rent / Land Min Rent / Liability Insurance carry real 1GSOD costs that MONTHLY shows nowhere else. As detail they are counted once and classified with the undistributed / non-operating lines, which is proposed. The ALL ACTIVITY / NET HOUSE PROFIT / DIFFERENCE lines look like checks and would double-count as detail: UNKNOWN as SOURCE_ROLLUP instead?


## Owner answer (stop 3)
- Q-13: agreed. The control-check lines are rollups; MONTHLY Fixed Rent / Land Min Rent / Liability Insurance are detail, Below the Line. Staging approved.

## Stop 4 (before promotion)
- **Q-14.** M4-M5 found three double counts and one loss in the Maldives and Third Space tie-out. The fixes below apply the approved rules (Q-04, Q-05, Q-08, Q-11), but each widens them, so please confirm. Details in M5.
  - (a) Maldives PL_OWNER has its own subtotal list. In the 1BST5 owner P&L, RESTAURANTS, LOUNGES, SPA and the like are single lines; flagged by the MONTHLY name list they lost 680,633 of September revenue.
  - (b) MONTHLY "Owner Expenses" is a subtotal; it equals Owner Activity in 24 / 24 months.
  - (c) D-48 "monthly beats summary" matches five SUMMARY lines to MONTHLY twins under another name or section. Each is equal on every branch.
  - (d) RETAINED PROFIT/(LOSS) (owner P&L) does not tie in 7 / 12 and is flagged by name as Q-11 (N-57).
  - (e) Third Space: seven source-flagged sole totals are detail, as THE_PIG Q-04.
- **Q-15.** Two lines have no approved rule and sit in UNKNOWN as UNCLASSIFIED_ACCOUNT: Third Space "NFF Central Adjusted EBITDA" (144 lines) and Maldives DEPARTMENT PROFIT (computed, as JW_VENICE). Leave them?
- **Q-16.** The Maldives balance sheet does not sum to 0 at 2026-08-31 (-12,955.70) or 2026-09-30 (-13,646.84). Reported as landed (N-57); no plug.

## Owner answers (stop 4)
- Q-14: confirmed, and written into sources.md as build rules. Reseeding the 302 new Maldives keys is fine.
- Q-15: both lines go to UNKNOWN tagged as computed rollups (SOURCE_ROLLUP), as JW's DEPARTMENT PROFIT, not as unclassified.
- Q-16: no plug; current-year earnings are not in landed data (N-57). 1GSOD's missing September forecast is logged as not in landed data.
- Runbook file: stays local, not force-added.
- Approved for promotion.

## Found while applying stop 4 (inside the approved rules; reported, not asked)
- The Q-13 Below the Line rule lost to the subtotal flag, because MONTHLY's Fixed Rent / Land Min Rent / Liability Insurance share a key with SUMMARY's rollup lines of the same names. So those three MONTHLY lines sat in UNKNOWN. The seeder now tests Q-13 first, and the SUMMARY copies lose to MONTHLY by D-48 (a).
- That exposed "Non-Operating Income-Expenses" as their group line (equal in 36 / 36 month-branches). It is flagged a subtotal under Q-05 / Q-14, like Owner Expenses.
- Below the Line still equals TOTAL NON-OP INC/EXP in 40 / 40 hotel-month-branches.
- The Third Space NFF Central Adjusted EBITDA keys were not reseeded: they were already Unclassified, so only the row tag changed. Their SEED_SOURCE still reads the line-name text.
- Owner approved reseeding both (new this build). Done: deleted, then reseeded by the final run (813 keys, 2 inserted). SEED_SOURCE now reads "source subtotal or computed line: SOURCE_ROLLUP"; H1 is still Unclassified.
