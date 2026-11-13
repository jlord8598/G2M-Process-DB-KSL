# Open questions - build 21

- **Q-01.** Gary's freeze: confirm it covers CLN_PIG_HOTELS_* (loaded 06:48) and every CLN_DAVIDSON_* table (08:10), and the window, before M2.
- **Q-02.** Davidson was reloaded today: FIN_PL_SUMMARY is -1,524 lines and REF_ACCOUNTS -1, and a new CLN_DAVIDSON_FIN_BUDGET_SUMMARY (239,616) appeared. Restage Davidson on today's extract (FIN_PL_SUMMARY moves) and leave BUDGET_SUMMARY unstaged and logged; or stage it in this build?
- **Q-03.** THE_PIG C00635-900 Rent, C00640-900 Property and Other Taxes, C00645-900 Insurance: Below the Line / Other Income / (Expense), or Expense / Operating Expenses?
- **Q-04.** Treat C00850-650 / -700 "Total Dept Expenses" and the three -998 "Total Food & Beverage" cost lines as detail (they are the only lines for those departments; IS_SUBTOTAL false)?
- **Q-05.** Pig budget is empty: unpivot ACTUAL and FORECAST only (x2), with BUDGET_AMOUNT carried raw? Or x3 with an all-null budget branch?
- **Q-06.** CURRENCY_CODE 'GBP' derived from CURRENCY 'British Pound' on every line (as Beaumier / JW carry ISO codes)?
- **Q-07.** PIC (Cotswolds) Sep: P&L 632 sold rooms against pace 800 (revenue -38.3k). Log for the source owner, build as stated?
- **Q-08.** One revenue-category code is named differently in REF_REVENUE_CATEGORIES and MAPPING: which wins, the REF table (proposed) or MAPPING?
- **Q-09.** Keep the staging name STG_DAVIDSON_ACCOUNT_LOOKUP (reading MAPPING, MAPPING's column names), or rename it STG_DAVIDSON_ACCOUNT_MAPPING and retire the old model? Proposed: rename and retire.
- **Q-10.** Pig statistics: H2 = the line code (C00001-050 etc., D-38); Occupancy % not additive, METRIC_UNIT null. Approve?

## Owner answers (stop 2)
Q-01 freeze confirmed; Q-02 BUDGET_SUMMARY logged (N-52), re-baseline; Q-03 non-operating below GOP (peer lanes: Below the Line / Other Income / (Expense)); Q-04 detail; Q-05 x2, budget not in landed data (N-54); Q-06 GBP; Q-07 P&L is the source, N-53; Q-08 segment table name in SEGMENT_BUILT, mapping text for exact matches; Q-09 renamed, old model retired; Q-10 non-additive statistic as peers.

## Stop 3
- **Q-11.** Today's REF_ACCOUNTS reload gives a ledger-name-only description ("Other Expenses") to almost every Davidson string, and under the approved rule it beats the mapping's fuller text ("5200:Other Expenses | Lounge | Dishwashing Supplies") on about 400,000 lines. Options: (a) keep the rule as approved (REF_ACCOUNTS wins; shorter text); (b) mapping first (LOOKUP_EXACT, then SEGMENT_BUILT), REF_ACCOUNTS only where neither applies, i.e. the Rooms / ADR and non-six-segment strings; (c) REF_ACCOUNTS wins only where its text is more than the ledger name. Recommended: (b), since the mapping is the fuller version of the same chart.

## Owner answers (stop 3)
- Q-11: option (b), with the reason recorded in the rule; 5 budget placeholders logged in N-49.

