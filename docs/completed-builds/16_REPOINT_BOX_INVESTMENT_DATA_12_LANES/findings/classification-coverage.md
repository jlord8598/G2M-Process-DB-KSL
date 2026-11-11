# Classification coverage (build 16)

The classification is unchanged by the repoint: every lane's rows equal the view run (LAST_SEEN_RUN_ID excluded). There are 0 new keys this run. The expected master merge is 58 inserts (from new source content, M4), 0 updates and 0 conflicts with reviewed rows.

## Review lists (per lane; counts and absolute SOURCE_AMOUNT, sorted by amount within each list)
| Lane | New keys | Unclassified keys | Unclassified rows | Unclassified abs amount | Awaiting-sign keys (floor) | Awaiting-sign rows | Awaiting-sign abs amount | Awaiting category rows |
|---|---|---|---|---|---|---|---|---|
| ATLANTIC_AVIATION | 0 | 476 | 136197 | 1400250572086.72 | 151 | 43452 | 606411954511.24 | 0 |
| INVITED_CLUBS | 0 | 28973 | 9175815 | 60583081052.84 | 32399 | 10333374 | 3527690163260.89 | 0 |
| ALTERRA | 0 | 368 | 34164 | 24354071301.97 | 30 | 2430 | 14847452.77 | 0 |
| DAVIDSON | 0 | 17781 | 451488 | 6297031228.33 | 733 | 19272 | 1568427454.37 | 0 |
| JW_VENICE | 0 | 911 | 9336 | 1695395626.63 | 10 | 98 | 10569214.59 | 0 |
| UNDER_CANVAS | 0 | 91 | 91 | 559505549.17 | 0 | 0 | 0 | 0 |
| NEWBURY | 0 | 1 | 3592 | 307884660.07 | 64 | 4176 | 329803746.23 | 0 |
| BEAUMIER | 0 | 0 | 0 | 0 | 93 | 5636 | 102565571.98 | 0 |
| HERSHA | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| HHG | 0 | 0 | 0 | 0 | 470 | 8196 | 97333128.49 | 0 |

- **Unclassified** counts H1 Unclassified plus UNKNOWN rows whose H1 is null under an account reason (UNCLASSIFIED_ACCOUNT, SOURCE_ROLLUP, PLANNING_INPUT; INVITED_CLUBS' DUPLICATE_DETAIL rows also have H1 null).
- **Awaiting sign** is the D-13 floor (Below the Line Mixed, Allocations & Reserves, Balance Sheet seed null by design).
- **Awaiting a category:** 0 rows in every lane.
- No tail was cut. OUTRIGGER and THE_PIG are pacing-only and have no keys.

## Sign anomaly (candidates; not reclassified)
Per lane and H2: an account (site, department, account key) whose net SOURCE_AMOUNT runs opposite to the majority of accounts in its class. Subtotals are excluded. Outliers only:
| Lane | H2 | Accounts | Outliers | Outlier amount |
|---|---|---|---|---|
| ALTERRA | Cost of Goods Sold | 90 | 6 | -557653.99 |
| ALTERRA | Operating Expenses | 334 | 4 | -6243553.07 |
| ALTERRA | Other Income / (Expense) | 11 | 3 | 1440292.97 |
| ALTERRA | Revenue | 206 | 2 | -6319978.7 |
| ATLANTIC_AVIATION | Cost of Goods Sold | 48 | 4 | -157048785.45 |
| ATLANTIC_AVIATION | Operating Expenses | 131 | 2 | -25635.73 |
| ATLANTIC_AVIATION | Payroll | 20 | 1 | 0 |
| ATLANTIC_AVIATION | Revenue | 62 | 2 | -397803.5 |
| BEAUMIER | Operating Expenses | 616 | 7 | 77563.69 |
| BEAUMIER | Other Income / (Expense) | 93 | 11 | 337678.94 |
| BEAUMIER | Payroll | 116 | 2 | 5739.44 |
| BEAUMIER | Revenue | 331 | 25 | -613010.64 |
| DAVIDSON | Cost of Goods Sold | 535 | 7 | -17389.78 |
| DAVIDSON | Operating Expenses | 3281 | 78 | -1862856.85 |
| DAVIDSON | Other Income / (Expense) | 326 | 40 | -38681441.76 |
| DAVIDSON | Payroll | 3533 | 70 | -723259.46 |
| DAVIDSON | Revenue | 1886 | 192 | -8718691.79 |
| DAVIDSON | UNCLASSIFIED | 47 | 17 | -5914585.93 |
| HERSHA | Cost of Goods Sold | 80 | 1 | -106849.76 |
| HERSHA | Operating Expenses | 20 | 5 | -1038205.88 |
| HERSHA | Payroll | 676 | 6 | -702758.21 |
| HERSHA | Revenue | 309 | 40 | 2898509.73 |
| HHG | Cost of Goods Sold | 1056 | 164 | -41714589.56 |
| HHG | Depreciation & Amortization | 128 | 1 | -1475550.78 |
| HHG | Operating Expenses | 7551 | 458 | -107518897.43 |
| HHG | Other Income / (Expense) | 439 | 41 | -6258662.14 |
| HHG | Payroll | 1868 | 334 | -157897003.77 |
| HHG | Revenue | 3176 | 213 | -13257295.24 |
| INVITED_CLUBS | Cost of Goods Sold | 3608 | 684 | -951568797.81 |
| INVITED_CLUBS | Depreciation & Amortization | 340 | 7 | -5591699.6 |
| INVITED_CLUBS | Income Taxes | 17 | 4 | -45848169 |
| INVITED_CLUBS | Operating Expenses | 72349 | 1564 | -552923649.81 |
| INVITED_CLUBS | Other Income / (Expense) | 2450 | 522 | -748215670.52 |
| INVITED_CLUBS | Payroll | 35808 | 1362 | -73450863.18 |
| INVITED_CLUBS | Revenue | 13805 | 4591 | -680269144.55 |
| JW_VENICE | Cost of Goods Sold | 7 | 1 | -196240 |
| JW_VENICE | Operating Expenses | 135 | 8 | -658462.28 |
| JW_VENICE | Payroll | 46 | 3 | -191668.6 |
| JW_VENICE | Revenue | 82 | 8 | -44488.86 |
| NEWBURY | Cost of Goods Sold | 21 | 1 | -22756.08 |
| NEWBURY | Operating Expenses | 153 | 3 | -26160.76 |
| NEWBURY | Other Income / (Expense) | 24 | 6 | -6148592.04 |
| NEWBURY | Payroll | 265 | 4 | -20785.26 |
| NEWBURY | Revenue | 76 | 3 | -1830671.06 |
| NEWBURY | UNCLASSIFIED | 38 | 1 | 11863488.05 |
| UNDER_CANVAS | Cost of Goods Sold | 201 | 16 | -1569.33 |
| UNDER_CANVAS | Operating Expenses | 1461 | 29 | -47771.99 |
| UNDER_CANVAS | Payroll | 689 | 30 | -44977.16 |
| UNDER_CANVAS | Revenue | 151 | 69 | 53837121.67 |

This account grain includes department, unlike build 15's, so the figures are not comparable with that memo. Semantic is equal to the view run, so these outliers predate build 16. ALTERRA's Revenue outliers include the D-13 contra line.

## Keyword contradiction
Not re-run. No description or classification changed in this build (view-run equality), so the archived lane records stand.
