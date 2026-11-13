# Sources - this build (22: WESTIN_HILTON_HEAD, W_SHERATON_MALDIVES, THIRD_SPACE)

Source CLN.BOX_INVESTMENT_DATA. New lanes. Freeze: to confirm (Q-01).

| Lane | Table | Rows | Loaded |
|---|---|---|---|
| WESTIN_HILTON_HEAD | CLN_WESTIN_HILTON_HEAD_FIN_PL_MONTHLY | 37,212 | 11-13 09:39 |
| WESTIN_HILTON_HEAD | CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY | 2,040 | 11-13 09:39 |
| WESTIN_HILTON_HEAD | CLN_WESTIN_HILTON_HEAD_REF_ACCOUNTS | 1,842 | 11-13 09:39 |
| W_SHERATON_MALDIVES | CLN_W_SHERATON_MALDIVES_FIN_PL_MONTHLY | 3,948 | 11-13 09:48 |
| W_SHERATON_MALDIVES | CLN_W_SHERATON_MALDIVES_FIN_PL_OWNER | 272 | 11-13 09:48 |
| W_SHERATON_MALDIVES | CLN_W_SHERATON_MALDIVES_FIN_PL_SUMMARY | 558 | 11-13 09:48 |
| W_SHERATON_MALDIVES | CLN_W_SHERATON_MALDIVES_FIN_BALANCE_SHEET | 138 | 11-13 09:48 |
| W_SHERATON_MALDIVES | CLN_W_SHERATON_MALDIVES_REF_ACCOUNTS | 421 | 11-13 09:48 |
| THIRD_SPACE | CLN_THIRD_SPACE_FIN_PL_MONTHLY | 29,405 | 11-13 09:39 |
| THIRD_SPACE | CLN_THIRD_SPACE_REF_ACCOUNTS | 850 | 11-13 09:39 |

Currency (owner Q-06, assumptions, not in landed data): WESTIN_HILTON_HEAD USD; W_SHERATON_MALDIVES USD; THIRD_SPACE GBP.
Scope (owner Q-02): WESTIN_HILTON_HEAD is pace-only in this build (PACE_GROUP_MONTHLY); FIN_PL_MONTHLY and REF_ACCOUNTS wait for a chart of accounts (N-55).

Not in landed data:
- currency (all three lanes);
- Westin account descriptions;
- 1BST5 monthly P&L history;
- Third Space budget.

## Build rules (owner, build 22)
- **W_SHERATON_MALDIVES subtotals (Q-05, Q-11, Q-12):** IS_SUBTOTAL for the named totals that tie to their detail in every month (M2 list).
  - Also flagged: DEPARTMENT PROFIT "TOTAL FOOD & BEVERAGE" and "TOTAL NON-OP INC/EXP", which never tie because the source does not show all of their detail (N-57; no plug lines).
  - Also flagged: the VALIDATION OF PROFIT CON lines that restate another line or are all zero.
  - Validation lines that restate nothing stay detail (listed in M3).
- **THIRD_SPACE:** classified by LINE_ITEM (Q-09).
  - IS_SUBTOTAL: the source flag plus the verified EBITDA chain (Gross Profit, Club EBITDA, Club Adjusted EBITDA, HOC Adjusted EBITDA).
  - KPIs are statistics: Beginning / Closing Members STOCK; Adds, Losses, Net Freeze, PT sessions, Visits FLOW.
- **W_SHERATON_MALDIVES owner P&L subtotals (owner Q-14):** FIN_PL_OWNER (1BST5) has its own subtotal list, separate from 1GSOD's FIN_PL_MONTHLY / FIN_PL_SUMMARY list. Its outlet lines (RESTAURANTS, LOUNGES, SPA, MISCELLANEOUS INCOME, ...) and ADMINISTRATIVE & GENERAL are single lines, so they are detail. Every listed total ties to its detail in all populated branches, with two exceptions:
  - Total INV Factors in 0480 restates GROSS OPERATING PROFIT;
  - RETAINED PROFIT/(LOSS) does not tie (7 / 12) and is flagged by name, as Q-11 (N-57).
- **W_SHERATON_MALDIVES group lines (owner Q-14):** in FIN_PL_MONTHLY, "Owner Expenses" is a subtotal; it equals Owner Activity in 24 / 24 months. "Non-Operating Income-Expenses" is a subtotal too; it equals the three Q-13 VALIDATION lines in 36 / 36 populated month-branches (stop 4, same rule).
- **W_SHERATON_MALDIVES summary-to-monthly matching through renamed lines (owner Q-14, D-48 rule a):** each of these FIN_PL_SUMMARY MONTH lines equals its FIN_PL_MONTHLY twin on every branch, and loses to it:
  - OWNER EXPENSE -> Owner Expenses;
  - Other Owner Expense -> Owner Activity;
  - UNDISTRIBUTED Liability Insurance / Land Min Rent Exp 701101 / Fixed Rent Expense -> the VALIDATION OF PROFIT CON lines of those names.
- **W_SHERATON_MALDIVES Q-13 lines:** MONTHLY's VALIDATION Fixed Rent Expense / Land Min Rent Exp 701101 / Liability Insurance are Below the Line detail. The seeder tests this rule before the subtotal rule, because the key is shared with the SUMMARY lines of these names, which are rollups (Q-12).
- **W_SHERATON_MALDIVES DEPARTMENT PROFIT (owner Q-15):** every line, repeats included, is a computed departmental profit and a source rollup (SOURCE_ROLLUP), as JW_VENICE.
- **THIRD_SPACE totals with no detail beneath them (owner Q-14):** source-flagged totals that are the only line of their kind are detail, as THE_PIG Q-04: Expenses - Payroll - Total, Total Visits, Total Debt, Total Capex, Total Cash, Total Head Office Costs, Total NFF Central Costs. Expenses - Total includes payroll (416 / 416 club-months).
- **THIRD_SPACE NFF Central Adjusted EBITDA (owner Q-15):** a computed line and a source rollup.
- **Not in landed data (owner Q-16):** Maldives current-year earnings (the balance sheet does not sum to 0, N-57; no plug); 1GSOD's forecast for September 2026 (FIN_PL_SUMMARY carries no forecast).