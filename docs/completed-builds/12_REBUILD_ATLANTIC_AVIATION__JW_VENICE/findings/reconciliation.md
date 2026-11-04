# Reconciliation (build 12): does every record arrive?

Rebuilt lanes JW_VENICE and ATLANTIC_AVIATION. Earlier lanes: proven unchanged by check 5 (M6.md).

## Row counts, per lane, every boundary

| Lane | CLN x branches | STG | XFRM (5 streams) | SEM (6 tables) |
|---|---|---|---|---|
| ATLANTIC_AVIATION | OC_DATA 109,995 x 3 = 329,985 | 329,985 | 329,985 | 329,985 |
| JW_VENICE | 808 x 2 + 761 x 2 + 1,044 x 4 + 1,080 x 4 + 8,656 x 2 = 28,946 | 28,946 | 28,946 | 28,946 |

Pacing: none in either lane (built empty).

## Measures (scripts/reconcile_{LANE}.sql, 0 failures each)

| Lane | Table | Metric | CLN | STG | XFRM | SEM |
|---|---|---|---|---|---|---|
| JW_VENICE | FCAST_ACT_FORECAST | AMT | 229,398,511.70 | same | same | same |
| | | STAT | 468,263.65 | same | same | same |
| | FCAST_BY_PERIOD | AMT | 178,359,075.11 | same | same | same |
| | | STAT | 401,192.69 | same | same | same |
| | FTE | STAT | 16,112.69 | same | same | same |
| | HEADCOUNT | STAT | 18,558.00 | same | same | same |
| | MONTHLY_PL_DEPT | AMT | 1,494,899,204.65 | same | same | same |
| | | STAT | 15,792,651.39 | same | same | same |
| ATLANTIC_AVIATION | OC_DATA | AMT as booked | 1,998,865,553.79 | same | - | - |
| | | AMT scaled | 1,998,865,553,787.96 | same | same | same |
| | | STAT as booked | 3,651,404.82 | same | - | - |
| | | STAT scaled | 3,620,460,402.21 | same | same | same |

## Detail vs subtotal and D-48, JW_VENICE

UNKNOWN 18,545 = SOURCE_ROLLUP 9,312 + DUPLICATE_DETAIL 9,233 (FCAST 73, MONTHLY_PL_DEPT 9,160). Losers by rule: Q-02 73 classified FCAST rows; Q-03 8,656 YTD rows; Q-09 14,432 non-TOT_HTL rows; Q-11 192 repeat-hours rows (rules overlap; a subtotal loser stays SOURCE_ROLLUP).

## ATLANTIC before / after by H2 and year (STG as booked -> XFRM)

Every money H2 x1000.0000 every year. Selected (SOURCE_AMOUNT):

| H2 | 2019 before | 2019 after | 2026 before | 2026 after |
|---|---|---|---|---|
| Revenue | 970,875.93 | 970,875,933.14 | 6,048,528.74 | 6,048,528,741.90 |
| Cost of Goods Sold | 444,279.73 | 444,279,731.56 | 2,227,951.42 | 2,227,951,420.99 |
| Payroll | 117,942.91 | 117,942,911.40 | 666,058.39 | 666,058,388.71 |
| Operating Expenses | 134,130.66 | 134,130,662.83 | 1,018,508.04 | 1,018,508,037.25 |
| Liabilities | 0.00 | 0.00 | 239,377,521.50 | 239,377,521,497.44 |
| Assets | 0.00 | 0.00 | 6,857,304.84 | 6,857,304,838.92 |

Statistics (KPIs - JetA Only): Gallons x1000; MPG, Landings, Trips x1; blended 2022-2026 ratio 992.3-993.7, 2019-2021 x1 (no Gallons booked). Full 72-row table: query 01c83179-030a-83ff-0003-4ff21c7c2672.
