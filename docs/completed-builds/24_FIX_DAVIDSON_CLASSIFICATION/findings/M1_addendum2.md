# M1 addendum 2 - the monthly report's GOP (build 24)

**Report only. Stopped before M2 for a decision on Q-08.** All figures are from today's CLN with the deployed natural-account map.

## PMIHST, March 2026 (revenue ties the summary exactly)

| H1 / H2 (deployed map) | Natural account: ledger (source) | Lines | Actual |
|---|---|---|---|
| Revenue / Revenue | 4101 Transient Room 708,990.67; 4102 Group Room 224,464.00; 4104 Other Room 17,546.60; 4201 Food 363,605.69; 4202 Beverage 197,353.83; 4203 Other F&B 111,656.91; 4302 Parking 108,311.20; 4305 Spa 236,408.81; 4306 Gift Shop 61,774.32; 4307 Retail 61,609.75; 4400 Miscellaneous Income 66,373.58; 4900 Allowances -240.85 | 148 | **2,157,854.51** |
| Expense / Payroll | 5000-5006 (Salaries and Wages ... Employee Benefits) | 383 | 1,018,095.94 |
| Expense / Payroll | **6000 Income - Non Operating** | 1 | **1,185.79** |
| Expense / COGS | 5100 Cost of Sales and Other Revenue; 5110 Cost of Services | 54 | 214,772.18 |
| Expense / Operating Expenses | 5200 Other Expenses; 5201 System; 5202 Energy; 5203 Water and Sewer; 5204 Waste | 309 | 434,288.46 |
| Expense / Operating Expenses | **7000 Management Fee Expense** | 1 | **48,546.00** |
| Expense / Operating Expenses | **7100 Non-Operating Rent; 7200 Non-Operating Insurance; 7300 Non-Operating Property and Other Taxes; 7400 Non-Operating Other** | 10 | **261,915.67** |
| Expense / Operating Expenses | **7600 Interest, Depreciation, and Amortization** | 7 | **623,739.72** |
| Allocations & Reserves / UNCLASSIFIED | 5990 Allocations | 11 | -10,641.89 |
| Below the Line | 8000 Replacement Reserve | 2 | 0.00 |

- **No total, subtotal or profit line exists in the monthly report.** Every line is a six-segment account, and no ledger name in landed data contains "total", "profit" or "EBITDA" (0 matches).
- **The negative GOP is a classification problem.**
  - The deployed map seeds every 7xxx account Expense / Operating Expenses by the section digit (build 19, Q-09 "as proposed"). That is 934,201.39 this month; every one is a non-operating or below-GOP ledger by its own name.
  - 6000 "Income - Non Operating" is seeded Payroll by its digit.
- **Reconciled to the summary sheet for this hotel-month:**

  | Step | Monthly report | Summary |
  |---|---|---|
  | Revenue - 5xxx expense | 490,697.93 | Gross Operating Profit 483,302 (difference 7,396) |
  | Less 5990 Allocations (-10,641.89) | GOP + alloc 501,339.82 | - |
  | Less 7000 Management Fee 48,546.00 | - | House Profit 434,756 = 483,302 - 48,546 (Management Fees 48,546; ties) |

  Under the deployed map the MR GOP is -444,689.25.

## All hotel-months (MR and summary overlap, summary GOP present)

| | ACTUAL (149 hotel-months) | FORECAST (47) |
|---|---|---|
| Summary Gross Operating Profit | 145,108,593 | 20,073,980 |
| MR GOP, deployed map | -24,267,831 (ties 0 hotel-months) | -28,846,531 (0) |
| MR GOP, revenue - 5xxx (6xxx / 7xxx out of operating) | 140,248,491 (ties 36) | 18,523,804 (8) |
| MR GOP, also netting 5990 Allocations | **ties 80** (sum of differences -6,888) | **ties 28** (-2,416) |
| Management Fee 7000 = summary Management Fees | 149 / 149 | 45 / 47 |

Of the 69 actual hotel-months that still don't tie:

- 15 are explained by an equal revenue gap (RMICAD, PINAMC, PINSIE), where the summary's revenue differs from the MR's.
- 54 differ otherwise, mostly RINGMI (+1.97M over 10 months), RMICAD (-1.90M, all a revenue gap), PMITWR (+0.55M, 0.19M of it revenue), PINBSI (+0.21M) and RMIHKK (-0.18M).
- A line-level cause for these is not in landed data; the summary has no account code.

**Amount in the P&L on below-GOP ledgers classified as operating, all hotel-months:**

| Ledger | Hotel-months | Actual | Forecast |
|---|---|---|---|
| 6000 Income - Non Operating (as Payroll) | 108 | 535,223 | 192,530 |
| 7000 Management Fee Expense | 192 | 8,836,921 | 3,821,679 |
| 7100 Non-Operating Rent Expense | 156 | 830,715 | 437,278 |
| 7200 Non-Operating Insurance Expense | 192 | 15,440,891 | 5,326,581 |
| 7300 Non-Operating Property and Other Taxes | 192 | 12,352,248 | 5,684,832 |
| 7400 Non-Operating Other Expense | 192 | 6,249,341 | 1,412,926 |
| 7600 Interest, Depreciation, and Amortization | 168 | 121,100,140 | 60,141,359 |
| **Total** | | **165,345,479** | **77,017,185** |

## Proposed fix (Q-08): change the lane's natural-account map, in the seeder branch
| Natural | Ledger (source) | Now | Proposed | Why |
|---|---|---|---|---|
| 6000 | Income - Non Operating | Expense / Payroll | Below the Line / Other Income / (Expense) | named non-operating income |
| 7100, 7200, 7300, 7400 | Non-Operating Rent / Insurance / Property and Other Taxes / Other | Expense / Operating Expenses | Below the Line / Other Income / (Expense) | named non-operating; below House Profit on the summary sheet |
| 7600 | Interest, Depreciation, and Amortization | Expense / Operating Expenses | Below the Line / Other Income / (Expense) | one ledger holds interest and D&A together. The split is not in landed data, so neither Depreciation & Amortization nor Interest can be chosen; Other Income / (Expense) is the honest parent. |
| 7000 | Management Fee Expense | Expense / Operating Expenses | **owner choice:** (a) Below the Line / Other Income / (Expense), so computed GOP matches the summary's GOP; or (b) keep Operating Expenses (USALI puts management fees between GOP and EBITDA, and the standard hierarchy has no such Level 1) | ties the summary's Management Fees 149 / 149 |
| 5990 | Allocations | Allocations & Reserves / UNCLASSIFIED | **owner choice:** (a) Expense / Operating Expenses, so allocations net inside GOP (exact GOP ties go from 36 to 80 actual hotel-months); or (b) leave as is | -4,254,857 actual in total, a credit |

**Consequences:**

- Other Income / (Expense) is Mixed, so these lines publish SOURCE_AMOUNT with VALUE null (D-13), as every Mixed line does.
- No key moves.
- **Keys to re-seed (D-44), DEV_G2M_AI snapshot:** 363.

  | Natural | Keys |
  |---|---|
  | 6000 | 11 |
  | 7000 | 18 |
  | 7100 | 24 |
  | 7200 | 38 |
  | 7300 | 49 |
  | 7400 | 41 |
  | 7600 | 88 |
  | 5990 | 94 |

  The master holds 364 DAVIDSON keys at these naturals, 0 reviewed: the 363, plus at least one from the DEV1 11-16 run (presumably from the reload; not checked key by key). The D-47 merge would update them, archiving the old rows first. Keys new in the reload, at these naturals, would be inserted under the new map.
- **Not changed:** 8000 Replacement Reserve (Below the Line); 5000-5006, 5100 / 5110 and 5200-5204 / 5900; revenue.
