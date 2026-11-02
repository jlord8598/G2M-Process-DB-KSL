# Classification coverage - build 09 (INVITED_CLUBS)

**Which accounts are classified, and correctly?** Query
`01c826cd-030a-75fb-0003-4ff21c5a9eae`.

## Coverage

| Keys | H1 classified | H1 Unclassified | Statistic keys with null METRIC_UNIT |
|---|---|---|---|
| 226,536 | 197,563 | 28,973 | 21,928 (non-currency statistics; the 14,564 currency DUES / KPI keys carry `currency`) |

**Re-seed (`M4.md`):** 23,984 keys changed.
- **Out of H2 Revenue:** 21,515 Revenue keys (11,086 + 935 + 7,401 + 2,093). Revenue now holds only the 169
  A4 GL members.
- **To Statistic:** 2,402 dues keys, from Unclassified.
- **Plan-entity GL:** 67 keys, now Unclassified.

## Sign anomaly (non-subtotal income-statement rows, all categories; outliers reported, not reclassified)

| H1 | Prevailing | Accounts | Outliers | Outlier absolute amount |
|---|---|---|---|---|
| Revenue | + | 169 | 51 | 663,110,830.02 |
| Expense | + | 445 | 35 | 1,132,448,339.05 |
| Below the Line | + | 58 | 9 | 69,269,514.97 |

## Keyword contradiction (candidates, not proof)

| H1 | Test | Accounts | Absolute amount |
|---|---|---|---|
| Expense | description contains revenue / income | 5 | 225,491,957.25 |
| Revenue | description contains expense / cost | 0 | - |

## For the business review

- **The 36 A50 GL accounts** now in Other Income / (Expense) (table in
  `M4.md`): 230,006,420.33 net ACTUAL.
- **The 7 residual UNCLASSIFIED_ACCOUNT members** (`M5.md`).
