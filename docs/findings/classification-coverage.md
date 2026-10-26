# Classification coverage - build 07 (BEAUMIER, NEWBURY)

**Which accounts are classified, and correctly?** The classification rows
are unchanged from builds 03 and 02: hash-equal to pre-build, 0 new keys
(`M4.md`). The figures below are re-measured on this extract (query
`01c7fee1-010a-58f2-0003-4ff21bf4daa2`).

## Coverage

| Lane | Keys | Classified | Unclassified | Statistic keys (null `METRIC_UNIT`) |
|---|---|---|---|---|
| BEAUMIER | 1,178 | 1,178 | 0 | 0 |
| NEWBURY | 782 | 781 | 1 | 167 |

- **NEWBURY's one unclassified key:** 249,305,174 absolute (`M4.md` review
  report).
- **Awaiting-sign floor:** BEAUMIER 93 keys, NEWBURY 72 keys.

## Sign anomaly (non-subtotal income-statement rows; outliers reported, not reclassified)

| Lane | H1 | Prevailing | Keys | Outlier keys | Outlier absolute amount |
|---|---|---|---|---|---|
| BEAUMIER | Revenue | + | 333 | 21 | 502,013 |
| BEAUMIER | Expense | - | 752 | 11 | 84,115 |
| BEAUMIER | Below the Line | - | 93 | 11 | 280,252 |
| NEWBURY | Revenue | + | 78 | 3 | 1,830,671 |
| NEWBURY | Expense | + | 464 | 8 | 69,702 |
| NEWBURY | Below the Line | + | 35 | 7 | 212,556,331 |
| NEWBURY | Allocations & Reserves | - | 37 | 1 | 11,863,488 |

## Keyword contradiction (candidates, not proof)

| Lane | H1 | Keys | Absolute amount |
|---|---|---|---|
| BEAUMIER | Expense | 10 | 4,626,586 |
| NEWBURY | Expense | 9 | 68,646,446 |

## H2 values to add

None. No classification row changed.
