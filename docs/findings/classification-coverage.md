# Classification coverage - build 02 (HHG, NEWBURY)

**The question: which accounts are classified, and correctly?**
Classification table `DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION`,
lanes HHG and NEWBURY; derivation in the HHG and NEWBURY branches of
`SPROC_XREF_ACCOUNT_CLASSIFICATION` (rules in `M4.md`).

## Coverage

| Lane | Keys | Classified (`H1` <> Unclassified) | Unclassified | Fact rows on classified keys | Fact rows unclassified |
|---|---|---|---|---|---|
| HHG | 15,369 | 15,369 (100%) | 0 | 275,140 of 275,140 | 0 |
| NEWBURY | 782 | 781 | 1 | 48,960 of 52,120 | 3,160 (BGT/PYACT, Q-19) |

| Lane | `H1` / `H2` | Keys | How derived |
|---|---|---|---|
| HHG | Revenue / Revenue | 3,595 | TR12 digit 4; Anaplan 12 items (Q-04) |
| HHG | Expense / Cost of Goods Sold | 1,023 | TR12 digit 5; Anaplan 2 items |
| HHG | Expense / Payroll | 4,703 | TR12 digit 6; Anaplan 7 items |
| HHG | Expense / Operating Expenses | 4,961 | TR12 digit 7; Anaplan 8 items |
| HHG | Below the Line / Other Income / (Expense) | 419 | TR12 digit 8; Anaplan `Other Income` |
| HHG | Statistic / STAT_9 | 618 | dept 999 (owner Q-01) |
| HHG | Statistic / ROUNDS_COUNT | 50 | rounds (owner Q-07) |
| NEWBURY | Revenue / Revenue | 78 | digit 4 |
| NEWBURY | Expense / Cost of Goods Sold | 21 | digit 5 |
| NEWBURY | Expense / Payroll | 284 | digit 6 |
| NEWBURY | Expense / Operating Expenses | 159 | digit 7 |
| NEWBURY | Below the Line / Other Income / (Expense) | 35 | digit 8 |
| NEWBURY | Allocations & Reserves / UNCLASSIFIED | 37 | digit 9 |
| NEWBURY | Statistic / 19 sub-account labels | 167 | `VALUE_TYPE STAT` |
| NEWBURY | Unclassified | 1 | no account (Q-19) |

Totals: HHG 15,369; NEWBURY 782.

- **`H3`:** `UNCLASSIFIED` on every key; neither source states a Level 2.
- **`METRIC_UNIT`:** null on all 835 Statistic keys (668 HHG, 167 NEWBURY).
- **`AGGREGATION_TYPE`:** `UNRATIFIED` on all 835.
- **D&A and income tax:** **not separated** in NEWBURY (Q-14). 7 depreciation,
  3 amortization and 1 income tax key sit in `Other Income / (Expense)`.
  HHG has no descriptions, so none can be found there.

## Did each account find the right classification?

### Keyword contradiction (query `01c7dd9f-020a-3554-0003-4ff21b9b1742`)

A candidate list, not proof. 129 keys matched:

| Pattern | Lane | Keys | Reading |
|---|---|---|---|
| `Below the Line`, description says Depr / Amort / Tax | NEWBURY | 14 | **Real.** The 11 D&A and income tax keys of Q-14, plus 3 property/other tax keys (830005 Real Estate Taxes, 830500 Personal Property Taxes, 831499 Other Taxes). These are operating taxes, not income tax, and section 8 is where the source puts them. |
| `Expense`, description says "Sales" / "Revenue" | NEWBURY | 9 | False positives: 3 "Cost of Sales" COGS lines, sales/revenue-management payroll titles (4), "Sales & Marketing Systems", "Outside Sales Representation". |
| `Expense`, description says "Sales" | HHG | 106 | False positives: the Anaplan `Food & Beverage Cost of Sales` and `Merchandise Cost of Sales` items across 53 locations. |

No reclassification made.

### Sign anomaly (query `01c7dd9f-020a-3608-0003-4ff21b9b67a2`)

Per lane, source table and `H1`: each key's net `SOURCE_AMOUNT` against the
prevailing direction of its class. `SOURCE_AMOUNT` is as booked.

| Lane | Table | `H1` | Keys | + | - | 0 | Prevailing | Outlier keys | Outlier amount |
|---|---|---|---|---|---|---|---|---|---|
| HHG | TR12 | Revenue | 2,959 | 2,604 | 219 | 136 | + | 219 | -8,329,590.64 |
| HHG | TR12 | Expense | 9,786 | 8,835 | 252 | 699 | + | 252 | -17,176,545.51 |
| HHG | TR12 | Below the Line | 366 | 281 | 33 | 52 | + | 33 | -7,728,366.83 |
| HHG | ANA | Revenue | 636 | 479 | 2 | 155 | + | 2 | -20,966.00 |
| HHG | ANA | Expense | 901 | 0 | 749 | 152 | - | 0 | 0 |
| HHG | ANA | Below the Line | 53 | 51 | 0 | 2 | + | 0 | 0 |
| NEWBURY | TB | Revenue | 78 | 73 | 3 | 2 | + | 3 | -1,830,671.06 |
| NEWBURY | TB | Expense | 464 | 431 | 8 | 25 | + | 8 | -69,702.10 |
| NEWBURY | TB | Below the Line | 35 | 26 | 7 | 2 | + | 7 | -212,556,331.18 |
| NEWBURY | TB | Allocations & Reserves | 37 | 1 | 36 | 0 | - | 1 | +11,863,488.05 |

Reading:
- **Two sign conventions within one lane.** HHG TR12 books revenue and
  expense both positive, and Anaplan books expense negative. That is source
  convention, not misclassification.
- **The consequence for `VALUE`** (`SOURCE_AMOUNT x VALUE_SIGN`, Debit -1) on
  HHG Anaplan forecast (query `01c7dda1-020a-3608-0003-4ff21b9b67ea`):

  | `H1` | `SOURCE_AMOUNT` | `VALUE` |
  |---|---|---|
  | Revenue | 873,713,372.93 | 873,713,372.93 |
  | Expense | -555,230,827.20 | +555,230,827.20 |
  | Below the Line | 6,635,096.15 | null (sign null) |
  | **Total** | **325,117,641.88** | **1,428,944,200.12** |

  - `VALUE` on HHG Anaplan is therefore not a net figure, and a consumer
    must not net it.
  - On TR12 the same rule gives revenue + and expense -, which is the intended
    reading.
  - **This needs an owner decision**: either a per-lane sign rule for Anaplan
    or a correction in the master. It is reported, not repaired.
- **NEWBURY Below the Line, 7 negative keys, -212.6M.** Dominated by
  `870215-Depr Expense-FF&E Reserve` (-206,407,739.14 actual, Q-14). A
  depreciation line booked as a large credit is either a reserve reversal or a
  source error, and worth a person's look.
- **The TR12 outliers (504 keys, -33.2M in all) and the small NEWBURY revenue
  and expense outliers** are candidates for contra accounts or
  misclassification. They are listed by query, not reclassified.

## Owner attention, by size

1. HHG Anaplan `VALUE` sign convention: 1.43B gross against 325.1M net.
2. NEWBURY `870215` and the D&A/tax keys in section 8 (Q-14).
3. NEWBURY BGT/PYACT, unclassified: 3,160 rows, 249.2M (Q-19).
4. HHG TR12 sign outliers: 504 keys, -33.2M.
