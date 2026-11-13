# Classification coverage (build 22)

## Coverage
- **W_SHERATON_MALDIVES:** 302 keys; 144 Unclassified.
  - Source rollups (SOURCE_ROLLUP), including DEPARTMENT PROFIT (Q-15).
  - UNCLASSIFIED_ACCOUNT, 342 lines: the MARRIOTT / MANAGER PROFIT CONTRIB lines (all zero) and "validation Other Operated".
- **THIRD_SPACE:** 813 keys; 118 Unclassified. All are source rollups, NFF Central Adjusted EBITDA included (Q-15); 0 UNCLASSIFIED_ACCOUNT.
- **WESTIN_HILTON_HEAD:** no keys (pace only).

## Keyword test
134 hits, all false positives: "sales" in Third Space "Expenses - Cost of Sales - ..." and "Undist. Op-Ex - Sales and Marketing", and in Maldives "SALES & MARKETING". Reported, not reclassified.

## Sign test
Accounts running against their class: 30, reported, not reclassified.
- Third Space Revenue - Member Credit at 17 clubs (-101,217 to -1,362,460): a contra-revenue.
- Third Space Revenue - Membership - Other at 8 clubs (-62.50 to -437.50), and CANARY WHARF Revenue - Food & Beverage - Other (-83,328).
- Third Space Undist. Op-Ex - Other at NFF (-143,192.06), and Sales and Marketing at Corporate (-45,962.50, twice).
- Maldives 1BST5 REPLACEMENT RESERVE (-365,011.62, a reserve release). It is the only Maldives outlier after the stop 4 changes.
