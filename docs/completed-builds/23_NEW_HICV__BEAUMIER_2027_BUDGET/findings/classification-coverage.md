# Classification coverage (build 23: HICV new; BEAUMIER rebuilt)

**Which accounts are classified, and correctly?** All figures are from `XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION` and the semantic tables, queried 2026-11-16.

## Coverage

| Lane | H1 | H2 | Keys | Accounts |
|---|---|---|---|---|
| HICV | Revenue | Revenue | 2,013 | 173 |
| HICV | Expense | Payroll | 3,550 | 55 |
| HICV | Expense | Operating Expenses | 3,447 | 186 |
| HICV | Expense | Cost of Goods Sold | 1,561 | 42 |
| HICV | Expense | Other Income / (Expense) | 105 | 42 |
| HICV | Expense | Depreciation & Amortization | 36 | 4 |
| HICV | Expense | UNCLASSIFIED | 78 | 39 |
| HICV | Below the Line | Operating Expenses | 1,263 | 55 |
| HICV | Below the Line | Revenue | 297 | 2 |
| HICV | Below the Line | Depreciation & Amortization | 149 | 2 |
| HICV | Below the Line | Other Income / (Expense) | 69 | 13 |
| HICV | Below the Line | Income Taxes | 4 | 2 |
| HICV | Below the Line | UNCLASSIFIED | 33 | 14 |
| HICV | Allocations & Reserves | UNCLASSIFIED | 610 | 20 |
| BEAUMIER | Revenue | Revenue | 333 | 39 |
| BEAUMIER | Expense | Operating Expenses | 616 | 63 |
| BEAUMIER | Expense | Payroll | 117 | 13 |
| BEAUMIER | Expense | Cost of Goods Sold | 22 | 2 |
| BEAUMIER | Below the Line | Other Income / (Expense) | 93 | 12 |
| BEAUMIER | Statistic | BUDGET_KEYS / _OPENING_DAYS / _ROOMS_AVAILABLE / _ROOMS_SOLD | 11 each | 1 each |
| BEAUMIER | Unclassified | UNCLASSIFIED | 3 | 3 |

**HICV:**

- 13,215 keys. Every key has a routed H1; none is Unclassified.
- H2 is UNCLASSIFIED on 721 keys: 610 Allocations & Reserves (digit 9, by design), 78 at digit 7 and 33 at digit 8, where no stated cost category exists.
- **How the 7/8 keys got their H2** (Q-15 order): first GL PL_SUB_CATEGORY_1 of the key or account, else the P&L DESC_PL_CATEGORY of the key or account. The SEED_SOURCE column names which, per key.

**BEAUMIER:**

- 1,228 keys. The 1,181 existing keys are reproduced and unchanged; 47 are new.
- The 3 Unclassified keys are USALI line names at a hotel for the first time: HVT Affiliation/Representation, HLG Branding, HPN Room service Food. USALI states no PL_SECTION.
- The 44 statistic keys have a null METRIC_UNIT; the source states none (D-38).

**D&A and income taxes found (HICV):** D&A on 6 accounts (185 keys), income taxes on 2 accounts (4 keys).

**Mixed sign (VALUE null):** Other Income / (Expense) on 174 HICV keys (55 accounts) and 93 BEAUMIER keys.

## Sign anomaly (the stronger test)

Method: account sums over ACTUAL + BUDGET, compared with the prevailing direction of their H1 on the lane. The source books profit-signed: revenue positive, costs negative.

| Lane | H1 | Prevailing | Accounts | Outliers | Outlier absolute amount |
|---|---|---|---|---|---|
| HICV | Expense | negative | 244 | 16 | 259,969,198 |
| HICV | Below the Line | negative | 64 | 7 | 157,281,723 |
| HICV | Revenue | positive | 159 | 11 | 52,966,642 |
| HICV | Allocations & Reserves | positive | 11 | 4 | 17,852,001 |
| BEAUMIER | Below the Line | negative | 12 | 1 | 192,060.96 |
| BEAUMIER | Revenue | positive | 39 | 2 | 86,994.14 |
| BEAUMIER | Expense | negative | 78 | 2 | 1,708.15 |

**Largest outliers (HICV):**

| Account | Description | H1 / H2 | Sum | Reads as |
|---|---|---|---|---|
| 777805 | Interest On Senior Notes | Expense / Other Income / (Expense) | +135,026,837 | Booked positive in the P&L (N-60); the GL books it negative. Known; as booked (Q-13, Q-16). |
| 878901 | Allocation Other | Below the Line / Operating Expenses | +116,155,687 | An allocation credit. |
| 500020 | Salary & Wages Contra | Expense / Payroll | +65,683,337 | A contra by name. |
| 888861 | Federal Income Taxes | Below the Line / Income Taxes | +36,276,590 | A tax benefit, or an expense-positive booking. |
| 777823 | Amortization of Financing Cost | Expense / Other Income / (Expense) | +27,762,484 | The interest-expense group (Q-06). |
| 340805 / 340804 / 372002 / 300101 | discounts, merchandise discounts, management fee contra, closing cost contra | Revenue / Revenue | -17.0M / -11.2M / -9.8M / -8.8M | Contra revenue by name. |
| 498901 | COS-Vacation Ownership Sales | Expense / Cost of Goods Sold | +16,135,392 | A cost-of-sales credit. |

None is reclassified. Contra lines would need an owner entry in D-13.

## Keyword contradiction (candidate list, not proof)

- **HICV Revenue keys whose description names a cost:** 13 accounts. Examples:
  - 300101 FFS Closing Cost Contra;
  - 399041 Rental Package Costs;
  - 303701 Down Payment Forfeiture;
  - 399069 Closing Costs Income.

  All are digit-3 accounts, and several are contra or recovery lines by name. HICV descriptions embed the cost-center name, so "Sales Operating Expenses" in the description makes some matches noise.
- **HICV Expense keys naming revenue or income:** 0.
- **BEAUMIER:** 0 in either direction.

## After stop 4 (Q-21, Q-24)
- **HICV:** the 297 provision keys (2 accounts) are now Revenue / Revenue, so Revenue / Revenue has 2,310 keys on 175 accounts and Below the Line / Revenue none.
  - The sign test now lists the provision accounts among the Revenue outliers: 13 outliers, 1,110,476,544 absolute. They are negative as booked, which is contra-revenue by your ruling.
- **BEAUMIER:** the 3 USALI keys are classified through the hierarchy (M6_stop4.md). Coverage: Revenue / Revenue 334 keys, Expense / Operating Expenses 618, none Unclassified.
