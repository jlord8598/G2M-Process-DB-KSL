# Classification coverage (build 12): which accounts are classified, and correctly?

## Coverage, rebuilt lanes (snapshot keys)

| Lane | Keys | Classified (not Unclassified) | Unclassified | of which source subtotals |
|---|---|---|---|---|
| ATLANTIC_AVIATION | 1,149 | unchanged from build 11 | 476 listed (VW_XREF_UNCLASSIFIED) | as build 11 |
| JW_VENICE | 2,320 | 1,297 new + build 11's | 910 listed | 867 of the 2,164 new keys |

New JW keys: 160 Revenue, 25 COGS, 242 Payroll, 412 Operating Expenses, 2 Other Income / (Expense), 456 Statistic, 867 Unclassified (subtotals) = 2,164.

## Independent anchor: EBITDA

- JW_VENICE: 2026-08 1,303,456.44 and 2025-08 1,518,519.50 = the owner P&L, to the cent.
- ATLANTIC_AVIATION: 1,674 of 1,674 site-months tie to the source Adj. EBITDA after scaling.

## Sign anomaly (JW MONTHLY_PL_DEPT accounts, ACTUAL, net by account)

| H2 | + accounts | - accounts | Outliers | Outlier amount | Accounts (largest first) |
|---|---|---|---|---|---|
| Cost of Goods Sold | 5 | 2 | 2 | -134,603.37 | 414092, 431061 |
| Operating Expenses | 105 | 8 | 8 | -468,159.63 | 759101 (allocation credit, owner-placed), 664901, 656003, 658001, 770117, 794106, 656203, 765256 |
| Payroll | 42 | 3 | 3 | -132,502.60 | 560344, 511001, 510617 |
| Revenue | 54 | 7 | 7 | -35,718.86 | 300160, 361951, 300610, 361945, 361904, 331063, 350053 |
| Other Income / (Expense) | 1 | 0 | 0 | 0.00 | |

Candidates only (credits, reversals, allowances); not reclassified. ATLANTIC's classification is unchanged from build 11; scaling multiplies by a positive factor, so its sign test is unchanged.

## Keyword contradiction

No H2 assigned by keyword: JW MONTHLY_PL_DEPT H2 comes from account blocks only. Nothing to list.
