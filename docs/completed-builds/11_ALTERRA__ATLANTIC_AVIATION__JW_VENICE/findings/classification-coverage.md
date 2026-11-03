# Classification coverage - build 11 (ALTERRA, ATLANTIC_AVIATION, JW_VENICE)

**Which accounts are classified, and correctly?**

## Coverage (`M4.md`)

| Lane | Keys | Classified | `SOURCE_ROLLUP` | Other Unclassified |
|---|---|---|---|---|
| ALTERRA | 1,370 | 1,000 | 370 | 0 |
| ATLANTIC_AVIATION | 1,149 | 673 | 475 | 1 (empty header row) |
| JW_VENICE | 156 | 113 | 43 | 0 |

**Not identified in any lane:**
- **D&A and Income Taxes:** none stated, 0 accounts.
- **`H3` (Level 2):** none stated, so all `UNCLASSIFIED`.
- **`METRIC_UNIT`:** stated for no statistic (null), except Fuel Margin
  currency (Q-13).

## The independent anchor: the source's own EBITDA (`M6.md` section 2)

| Lane | Entity-months within 1% |
|---|---|
| ATLANTIC_AVIATION | **1,674 of 1,674 (100%)**: every site's Revenue - COGS - Payroll - Operating Expenses equals its Adj. EBITDA to the cent |
| ALTERRA | 139 of 567 (24.5%) |
| JW_VENICE | 0 of 20 |

**ALTERRA by entity** (query `01c82c1a-030a-7f58-0003-4ff21c6e6aa2`; source vs computed EBITDA, 27 months each):

| Entity | Within 1% | Difference | Reading |
|---|---|---|---|
| Corporate, Aspenware, Aviation, MWHS | 27 of 27 | 0.00 | ties |
| Ski Butlers | 0 | -11,871,797.77 | the D-48 copy's GOP, excluded by design |
| CMH | 2 | -159,599,560.60 | Q-16: Trip and Lodging totals marked rollup |
| Blue | 0 | 97,981,992.24 | Q-17: Home Owners 2 x 46,976,575.47 |
| Mammoth / June | 0 | 97,817,186.62 | Q-17 |
| Deer Valley | 0 | 94,612,486.78 | Q-17 |
| Tremblant | 0 | 52,069,839.22 | Q-17 |
| Snowshoe | 0 | 50,809,868.00 | Q-17 |
| Steamboat | 0 | 40,356,756.85 | Q-17 + 10,462,662.03 residual |
| Palisades | 0 | 33,601,016.12 | Q-17 + 7,950,336.36 |
| Winter Park | 0 | 27,675,823.81 | Q-17 + 7,913,481.95 |
| Stratton | 0 | 21,777,288.49 | Q-17 + 5,177,243.31 |
| Sugarbush | 0 | 10,490,651.23 | Q-17 + 1,677,182.71 |
| Solitude | 0 | 9,664,301.98 | Q-17 + 1,380,318.44 |
| Schweitzer | 0 | 7,696,194.51 | Q-17 + 1,410,136.39 |
| Big Bear | 5 | 2,133,033.70 | no Home Owners; residual |
| Crystal | 8 | 859,870.69 | residual |
| ABasin | 16 | 365,205.93 | residual |

**The residuals** come from the source's GOP section, which does not follow
one formula: 85 of 459 entity-months (`open-questions.md`).

**JW_VENICE:** its departmental expenses are not in the income statement
(only netted in DEPARTMENT PROFIT, a rollup). The detail is not in landed data
(N-8).

## Sign anomaly and keyword contradiction

- **Sign anomaly:** found by the anchor above, not by a separate scan.
  "Revenue - Home Owners" is a deduction booked positive inside Revenue
  (Q-17). It is reported, not reclassified.
- **Keyword contradiction:** "Expenses - Non-Operating - Insurance" sits in
  ALTERRA's Undistributed section and is classified Operating Expenses by the
  approved section map. It is a candidate only, not reclassified.
- **The full per-account sign scan was not run for this build.** The tie-out
  covered every entity-month instead.
