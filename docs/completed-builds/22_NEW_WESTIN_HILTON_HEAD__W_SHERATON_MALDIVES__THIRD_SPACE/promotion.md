# Build 22 promotion (owner, 2026-11-13)

Build 22 adds three lanes: WESTIN_HILTON_HEAD, W_SHERATON_MALDIVES and THIRD_SPACE. Gary's freeze held: 10 / 10 tables at every check.
- **WESTIN_HILTON_HEAD:** pace only (Q-02).
  - CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY (2,040 lines) is staged verbatim to SEM_AI_PACING: METRIC_NAME = METRIC, VANTAGE = AS_OF, *RMS* ROOMS / *REV* CURRENCY USD, both additive.
  - The P&L and REF_ACCOUNTS are not staged; they wait for a chart of accounts (N-55). No classification keys.
- **W_SHERATON_MALDIVES (USD):** 1GSOD from FIN_PL_MONTHLY / FIN_PL_SUMMARY; 1BST5 from its owner P&L (FIN_PL_OWNER); the balance sheet (DEBIT) and REF_ACCOUNTS.
  - 302 keys, classified as JW_VENICE's report tables.
  - D-48: MONTHLY beats SUMMARY, including five renamed lines; YTD and "| #n" repeats lose.
  - FIN_PL_OWNER has its own subtotal list. Owner Expenses and Non-Operating Income-Expenses are group subtotals.
  - Q-13: the rent / land rent / liability insurance lines are Below the Line. DEPARTMENT PROFIT is a source rollup (Q-15).
- **THIRD_SPACE (GBP):** FIN_PL_MONTHLY x2 (actual, forecast; budget not in landed data) and REF_ACCOUNTS.
  - 813 keys, classified by line name. Members are STOCK; the other KPIs are FLOW. Cash and debt go to the balance sheet.
  - D-48: CLUBS beats CORP (N-56), and KSL REPORT Total Cash is a duplicate.
  - Sole "Total ..." lines are detail; NFF Central Adjusted EBITDA is a source rollup (Q-15).

Stop 4 approved, after Q-14 to Q-16 and the reseed of the two Third Space NFF Central Adjusted EBITDA keys.

## Results reported by the owner (DEV1)
- **D-47 master merge:** 1,115 inserted (W_SHERATON_MALDIVES 302, THIRD_SPACE 813, WESTIN_HILTON_HEAD 0), 0 updated. This equals the stop-4 expectation.
- **CLN.UTIL.SPROC_PROMOTE:** 190 procedures, 15 classification-source swaps, 2 lanes with no classification (OUTRIGGER, WESTIN_HILTON_HEAD).
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 17 lanes, 52 MAINs, 0 new keys.
- **reconcile_WESTIN_HILTON_HEAD_DEV1.sql, reconcile_W_SHERATON_MALDIVES_DEV1.sql, reconcile_THIRD_SPACE_DEV1.sql:** 0 failures each.

## Build figures (DEV_G2M_AI, M6)
- **Semantic growth:**
  - ACTUAL and FORECAST +20,498 each; BUDGET +1,088; BALANCE_SHEET +354; OPERATING_METRICS +10,020; UNKNOWN +20,824. Total 73,282 = Maldives 14,472 + Third Space 58,810.
  - PACING +2,040 (Westin).
- **Tie-outs:**
  - Maldives revenue and Below the Line equal the source's TOTAL OPERATING REVENUE / TOTAL NON-OP INC/EXP in 40 / 40 hotel-month-branches.
  - Third Space revenue - expense equals Club Adjusted EBITDA in 660 / 660 club-months.
- **Proof:** 287 objects of the 14 other lanes identical to the M2 baseline; run A = final on the 47 new-lane objects.

## Scripts archived
`run_build.sql`, `d43_check.sql`, `build22_hashes.sql`, `build22_new_hashes.sql`, `build22_check2.sql`, and `reconcile_WESTIN_HILTON_HEAD.sql`, `reconcile_W_SHERATON_MALDIVES.sql`, `reconcile_THIRD_SPACE.sql` with their `_DEV1` copies.

## CLAUDE.md changes
None.

## Runbook
`Claude outputs/pipeline-status-2026-10-22.md` is left local (owner); not committed.

## Open items (current at close-out)
- **N-55:** Westin chart of accounts. Re-checked: the P&L balances to zero in 20 / 20 actual months.
- **N-56:** Third Space CORP differs from CLUBS. Re-checked: 28 lines.
- **N-57:** Maldives non-tying totals, including RETAINED PROFIT/(LOSS), and the balance sheet off by -12,955.70 / -13,646.84. Not in landed data: current-year earnings and 1GSOD's September 2026 forecast.
