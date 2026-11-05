# Open questions - build 13

## Stop 1

| # | Lane | Question | Evidence | Proposal |
|---|---|---|---|---|
| Q-01 | both | Approve the D-46 block mapping (M1.md section 5)? Changes vs today: due-from 20-29 Liabilities -> Assets; 30-38 and 3900-3955 Equity -> Liabilities; 8704-8720 OI/E -> Depreciation & Amortization. Needs a D-44 re-seed of those keys. | Block names and GL_CATEGORY (sources.md) | Approve; re-seed only those keys' H2 / section / balance / sign. |
| Q-02 | both | Subtotals: mark SOURCE_ROLLUP + IS_SUBTOTAL only the formula lines that tie (KSL 829, PEREGRINE 1,788)? The 28 that do not tie (PEREGRINE RF0009; KSL TOTPACET5, RF0155, TOTCLINC, I02016, 23 I* alias lines) and the untestable `=TOT` / expression / no-formula lines (KSL 3.52M + rows, PEREGRINE 0.84M +) would stay UNCLASSIFIED_ACCOUNT, IS_SUBTOTAL false. | Q-16 test, M1.md section 2 | As stated; `=TOT` lines are borderline: your call whether structure (COA IS_TOTAL_LINE / calculated) is enough for them. |
| Q-03 | both | Labor does not restate GL payroll (KSL 18 / 990, PEREGRINE 0 / 34 site-months within 1%; Regular+OT vs 6704+6712 191 / 990). No D-48 rule. Keep labor in UNKNOWN as UNCLASSIFIED_ACCOUNT, or classify it (for example Statistic hours / Payroll detail without a sign)? | M1.md section 3 | Keep as is; no rule. |
| Q-04 | both | ACCOUNT_DESC fill from COA.ACCOUNT_NAME moves 0 rows (already 100%, equal to COA on every row). Drop it? | M1.md section 4 | Drop. |
| Q-05 | both | EBITDA tie-out at stop 4: KSL Rev - 5-7 (937 / 1,360 now), PEREGRINE Rev - 5-7 - 86 (124 / 180) vs the source EBITDA, as a match rate plus 5 largest differences? | M1.md section 6 | Approve. |
| Q-06 | PEREGRINE | Budget 4 (FCID 18, 12,578 rows) and Budget 5 (FCID 19, 5,765 rows): category BUDGET? | DATASETS; 2027-01 to 05 | BUDGET. |

## Owner answers, stop 1

| # | Answer |
|---|---|
| Q-01 | Yes: all three D-46 block changes (20-29 -> Assets; 30-38 and 3900-3955 -> Liabilities; 8704-8720 -> Depreciation & Amortization), D-44 re-seed of the affected keys only. |
| Q-02 | Yes: formula lines that tie, and the untestable `=TOT` lines on the source IS_CALCULATED_LINE flag, are SOURCE_ROLLUP + IS_SUBTOTAL. They are already in UNKNOWN: only the reason changes, no P&L amount moves (confirm at stop 4). The 28 lines that fail the tie test stay UNCLASSIFIED_ACCOUNT and are listed. |
| Q-03 | No D-48 rule. Labor stays where it sits today. |
| Q-04 | Drop the ACCOUNT_DESC fill. |
| Q-05 | Per-lane match rate with the 5 largest differences. PEREGRINE: propose block 86 -> Operating Expenses (D-46) and re-measure. Report KSL's untied site-months by cause. |
| Q-06 | Budget 4 and Budget 5 stay UNKNOWN as UNRESOLVED_CATEGORY; logged for the source owner (N-21). |

## Stop 2

| # | Lane | Question | Evidence | Proposal |
|---|---|---|---|---|
| Q-07 | both | Calculated lines that are untestable but not `=TOT`: an expression the test cannot parse, or no formula (KSL 144 tags / 708,737 rows; PEREGRINE 144 / 43,630). Treat them like `=TOT` (SOURCE_ROLLUP + IS_SUBTOTAL on IS_CALCULATED_LINE), or leave UNCLASSIFIED_ACCOUNT? Today 54,696 / 6,466 of these rows are IS_SUBTOTAL (TOT prefix). | M1.md section 7 | Treat like `=TOT`: same flag, same evidence, no amount moves. |
| Q-08 | KSL | The 28 failing lines include TOTPACET5 and TOTCLINC, IS_SUBTOTAL today by the TOT prefix (47,407 rows). Under Q-02 they become IS_SUBTOTAL false. Confirm. | M1.md section 7 | Confirm (they do not tie). |
| Q-09 | KSL | KSL EBITDA includes block 86 at some site-months (87 of the 423 untied). Map KSL block 86 to Operating Expenses too (D-46, per lane)? KSL block 86: 8680 Other Expense 73 keys, 8690 Acquisition 39, 8691 Property Rent 11, 8694 Other Lease 9. | M1.md section 7 | Not yet: it would break the 937 that tie without it; report at stop 4. |

## Owner answers, stop 2

| # | Answer |
|---|---|
| Q-07 | Yes: untestable expression / no-formula calculated lines are treated like `=TOT`: SOURCE_ROLLUP + IS_SUBTOTAL on IS_CALCULATED_LINE. No amount moves. |
| Q-08 | Confirmed: TOTPACET5 and TOTCLINC failed the tie test; the data overrides the TOT prefix; IS_SUBTOTAL false, UNCLASSIFIED_ACCOUNT, listed. |
| Q-09 | Not yet. At stop 4 report which KSL sites and months the source EBITDA subtracts block 86 from and which not; logged N-22. |

## Stop 4: what needs a person

| Item | For | Where |
|---|---|---|
| D-47 merge: update KSL 1,445 / PEREGRINE 350 unreviewed rows (re-seed), insert new keys | owner | M4.md |
| N-21 Budget 4 / Budget 5 | source owner | open-items |
| N-22 KSL block 86 in EBITDA (site-month list) | source owner | M6.md |
| 28 lines failing the tie test | review | M6.md |
| PEREGRINE 860-8693-000 sign candidate | master review | classification-coverage.md |
