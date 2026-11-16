# Open questions (build 24: FIX_DAVIDSON_CLASSIFICATION)

## Stop 2 (end of M1)
- **Q-01. The premise of A.**
  - The unclassified monthly and budget keys are not in mixed department sections. All 156 + 164 are one-segment ACCOUNT strings (`x...`, `NEW 0x`, `957399100`), which have no ledger segment.
  - The six-segment accounts, 5200 included, are already classified.
  - The rule you described (classify by ledger account) is the right idea, but the ledger account has to come from somewhere: REF_ACCOUNTS.ALIAS states it. Approve the alias rule?
    - A one-segment ACCOUNT's natural account = segment 2 of its REF_ACCOUNTS.ALIAS (one alias per string), mapped through the lane's existing natural-account table.
    - It is staged as a new column (ALIAS_NATURAL_ACCOUNT), and the key does not change.
    - It settles MONTHLY 140 of 156 and BUDGET 144 of 164 strings.
- **Q-02. What the alias cannot settle.**
  - (a) 29 strings whose alias is a 9xxx statistic ledger, staged AMOUNT (MONTHLY 15 / 19,774.07; BUDGET 14 / 61,247.19). Reclassifying them as STATISTIC would change RECORD_TYPE, which is a key part, so it is not allowed under D-44. Leave them Unclassified?
  - (b) 7 strings with no usable alias: `NEW 02` (712,005.00), `NEW 03`, `NEW 03b`, `NEW 02b`, `957399100` (-22,105.94), and `x405993010` (alias `PEXEC-5000-...-DNU-...`, monthly 6,720 / budget 21,828). Leave them Unclassified, or do you know their ledger?
  - `x405993010`'s alias does carry natural 5000 (Payroll), but its fifth segment is DNU (do not use). Proposed: leave it as unclassified.
- **Q-03. The summary already in the P&L.**
  - 36,912 staged summary lines reach the income statement today, through the classified sections (MISCELLANEOUS INCOME, NON-OPERATING on ALL_DEPARTMENT, and the four SUMMARY-sheet sections). 22,320 of them are IS_SUBTOTAL.
  - "No summary line enters the P&L in this build" therefore means a D-48 rule that also moves these classified lines to UNKNOWN as DUPLICATE_DETAIL (subtotals as SOURCE_ROLLUP?). Is that intended?
  - It changes the published P&L for every DAVIDSON hotel-month the summary covers. The alternative is to leave them as they are and touch only the unclassified summary lines.
- **Q-04. B1: the subtotal rule.**
  - Extend IS_SUBTOTAL to every all-capitals line (19,896 more source lines) with SUBTOTAL_SOURCE saying so? The tie rate rises from 56.0% to 68.6% of totals.
  - The rest are mostly differences ("PROFIT", "LESS: ALLOWANCES", "NET ALLOCATION"), which no sum of detail can reproduce. Their flag is still correct.
  - SOURCE_ROLLUP for every IS_SUBTOTAL summary line in UNKNOWN?
- **Q-05. B2: "| #n" lines.**
  - Total-named "| #n" lines repeat their first line: 4,409 of 4,428 are equal. Proposed: SOURCE_ROLLUP, as the totals they repeat.
  - Detail-named "| #n" lines are not repeats: 568 of 826 differ (6,010,671 absolute). They are distinct lines sharing a name. Proposed: treat them as summary detail (Q-06), not as repeats.
  - The 19 differing total-named lines and the 26 with no first line would be listed in the findings. Agree?
- **Q-06. B3: DUPLICATE_DETAIL behind the monthly report.**
  - The overlap cannot be proved line by line from landed data. The summary has no account code; name matching links 13.2% of summary detail cells, and where it links, 86% of actual cells are equal.
  - At hotel + month + section, the matched totals differ (678.2M against 461.1M). The two tables are also different file vintages (summary actuals as of 2026-09-01, MR report month to 2026-10-01).
  - Options:
    - (a) DUPLICATE_DETAIL for all summary detail under a D-48 rule "FIN_PL_MONTHLY beats FIN_PL_SUMMARY for every DAVIDSON hotel-month the MR carries", applied by site and period. The roll-up hotel (no HOTEL_CODE) and any hotel-month the MR lacks would stay as they are.
    - (b) A new reason other than DUPLICATE_DETAIL; but D-48 is the only route for a classified row, and these rows are unclassified, so they can only carry an account reason.
    - (c) Leave them as UNCLASSIFIED_ACCOUNT.
  - Recommended: (a), with the match evidence recorded as partial, not proved.
- **Q-07. Two mapping vocabularies.** If you want a better B3 proof, the summary SECTION names and the mapping's DEPARTMENT_NAME differ (ADMINISTRATIVE & GENERAL / ADMINISTRATION & GENERAL, IT / INFORMATION TECHNOLOGY, UTILITIES / ENERGY, WATER, AND WASTE, BANQUETS / BANQUETS & CATERING ...). A section crosswalk is not in landed data. Should I propose one (owner-approved, by name), or leave B3 at the measured rate?

## Owner answers (stop 2, first round)
- **Q-01:** approved. The one-segment codes take the ledger account from their REF_ACCOUNTS six-segment ALIAS, through the lane's existing account table. The key is unchanged.
- **Q-02:** agreed. The statistic-ledger aliases (15 monthly, 14 budget) and the strings with no usable alias (NEW 02 / 02b / 03 / 03b, 957399100, x405993010 with its DNU alias) stay unclassified, logged as not in landed data.
- **Q-05:** agreed. Total-named "| #n" lines are repeats; detail-named "| #n" lines are distinct detail.
- **Q-03, Q-04, Q-06, Q-07:** held, pending the measurements in `M1_addendum.md`.

## Owner answers (stop 2, second round)
- **Q-03 / Q-06 / Q-07:** a new D-48 rule. FIN_PL_MONTHLY wins over FIN_PL_SUMMARY for every DAVIDSON hotel-month, and every summary line leaves the P&L for UNKNOWN:
  - SOURCE_ROLLUP: totals, profit and EBITDA lines, and the three group roll-up rows (Davenport Collection, Islamorada, Mackinac Island Bike Shop);
  - repeats: total-named "| #n" lines;
  - DUPLICATE_DETAIL: everything else.

  The evidence goes in sources.md. PINCEN Oct 2026 actual is logged as not in landed data at monthly level (expected in the next monthly file); the summary is not kept for it.
- **Q-04:** the all-capitals subtotal flag applies to summary lines, for labelling.
- **Before M2:** the monthly report's own GOP is to be checked for total or profit lines sitting in expense (report only).

## Before M2
- **Q-08. The monthly report's natural-account map** (`M1_addendum2.md`).
  - Move 6000 and 7100-7400 to Below the Line / Other Income / (Expense), and 7600 the same (the interest vs D&A split is not in landed data).
  - 7000 Management Fee: (a) Below the Line, or (b) keep Operating Expenses.
  - 5990 Allocations: (a) Expense / Operating Expenses, or (b) as is.
  - Re-seed the affected keys (363 in the DEV_G2M_AI snapshot; 364 in the master) under D-44.

## Open items carried at stop 4 (not in landed data)
- O-1: Q-02 strings left Unclassified (monthly 744 lines / 26,494.07; budget 444 / 812,358.21).
- O-2: PINCEN Oct 2026 actual: revenue differs from summary (1.15M).
- O-3: GOP gaps after build 24, 46 actual / 14 forecast hotel-months: RINGMI 10, PMITWR 10, PINBSI 10, PINAMC 5 (revenue ties; expense side), RMICAD 10 (revenue differs, -1.90M), PINCEN 1. Cause not in landed data.
- O-4 (owner): CLAUDE.md D-48 entry for DAVIDSON (FIN_PL_MONTHLY over FIN_PL_SUMMARY), needed for checks 2(e) / 2(m) to name it.
