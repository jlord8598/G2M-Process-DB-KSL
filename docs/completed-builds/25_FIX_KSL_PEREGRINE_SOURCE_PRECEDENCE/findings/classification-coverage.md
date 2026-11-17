# Build 25 classification coverage
No classification changed (no seeder change, no re-seed).

| Lane | Keys | New this build | Unclassified (not new) | Awaiting sign (floor: A&R + BS) |
|---|---|---|---|---|
| KSL_SELECT_SERVICE | 61,581 | 191 | 30,700 | 3,459 (3,308) |
| PEREGRINE_RESORTS | 26,318 | 85 | 11,024 | 674 (659) |

- **Values awaiting a category:** PEREGRINE "Budget 4" (12,578 lines, 182,682,062) and "Budget 5" (5,771 lines, 65,998,007), Q-09. KSL none.
- **Sign anomaly** (SEM_AI_INCOME_STATEMENT_ACTUAL after the change; key amount against its H1's prevailing direction):

  | Lane | H1 | Keys | Outliers | Outlier amount |
  |---|---|---|---|---|
  | KSL | Revenue | 2,189 | 156 | -1,922,584 |
  | KSL | Expense | 16,989 | 871 | -21,953,274 |
  | KSL | Below the Line | 244 | 18 | -2,584,401 |
  | KSL | Allocations & Reserves | 41 | 0 | 0 |
  | PEREGRINE | Revenue | 1,029 | 115 | -6,360,245 |
  | PEREGRINE | Expense | 8,993 | 405 | -9,821,625 |
  | PEREGRINE | Below the Line | 22 | 2 | -545,766 |

  Candidates only (contra lines such as allowances and rebates); not reclassified. Before this build, the ledger's negative revenue made the sign test meaningless for these lanes.
- **Keyword contradiction:** not re-run. No classification changed; build 13's list stands.
