# Classification coverage - build 08 (HHG, INVITED_CLUBS, NEWBURY)

**Which accounts are classified, and correctly?**
- **HHG:** no classification row changed.
- **INVITED_CLUBS and NEWBURY:** re-seeded once (D-44, owner Q-08; `M4.md`).
  113,849 and 9 keys changed classification columns only, and no key moved.
- **Coverage** (query `01c80aa7-010a-66ea-0003-4ff21c1a8c12`):

| Lane | Keys | H1 classified | H1 Unclassified | H2 UNCLASSIFIED | Statistic keys (null `METRIC_UNIT`) | IS keys awaiting a sign |
|---|---|---|---|---|---|---|
| HHG | 15,369 | 15,369 | 0 | 0 | 668 | 419 |
| INVITED_CLUBS | 225,833 | 201,948 | 23,885 | 23,893 | 21,739 | 406 |
| NEWBURY | 782 | 781 | 1 | 38 | 167 | 63 |

- **INVITED_CLUBS H2 UNCLASSIFIED** = the H1 Unclassified keys + the 8 A63699
  keys (H1 Expense, owner Q-05).
- **INVITED_CLUBS awaiting sign:** the 398 OI/E keys (Mixed) plus earlier
  ones.
- **NEWBURY awaiting sign** fell from 72 to 63: the 9 re-seeded keys now carry -1.

## H2 values added in this build

`Depreciation & Amortization` and `Income Taxes` (both standard hierarchy
H2s; no new names) appear for the first time:
- in INVITED_CLUBS: 344 and 21 keys;
- in NEWBURY: 8 and 1 keys.

INVITED_CLUBS also gains `Payroll` (36,442 keys) and `Cost of Goods Sold` /
`Operating Expenses` in A6.

## For the business to spot-check (owner Q-12)

These are the 14 accounts where the A6 block and the `ACCTS-*` parent
disagree; the block applies. A63699 stays UNCLASSIFIED. The table is in
`sources.md`: A60005, A60201, A60202, A60203, A60205, A60206, A60207, A60208,
A60211, A60517, A60518, A60528, A62424, A62431; and A63699.
