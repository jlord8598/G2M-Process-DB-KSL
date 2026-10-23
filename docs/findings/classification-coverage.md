# Classification coverage - build 06 (DAVIDSON, HHG, HERSHA)

**Which accounts are classified, and correctly?** Coverage comes first,
then the two correctness tests. Figures are from queries at M4 and M6.

## Coverage by lane (staged rows; query `01c7ee57-020a-483e-0003-4ff21bca829e`)

| Lane | Keys | Classified keys | Unclassified keys | Staged rows classified | Staged rows unclassified |
|---|---|---|---|---|---|
| DAVIDSON | 31,785 | 14,053 | 17,732 | 339,168 | 449,040 |
| HHG | 15,369 | 15,369 | 0 | 275,140 | 0 |
| HERSHA | 1,196 | 1,196 | 0 | 106,350 | 0 |

- **Where DAVIDSON's unclassified keys come from**
  (query `01c7ee5f-020a-4834-0003-4ff21bcaa42a`):
  - **PL department sections:** 17,182 keys. These are unmapped by design
    (Q-09).
  - **MR one-segment `x...` accounts:** 550 keys, with no natural account.
- **H2 by lane, with amounts:** see `M4.md`.
- **Statistic keys with a null `METRIC_UNIT`:**
  - DAVIDSON 3,189 (all of its statistics: the source states no unit);
  - HHG 668;
  - HERSHA 147.

## H2 values that need adding (for the owner, stop 4)

| H2 | Lane | Source | Keys | Source rows | Seeded now as |
|---|---|---|---|---|---|
| `Utilities` | DAVIDSON | MR natural 5202-5204 (owner Q-09) | 99 | 1,188 | `Operating Expenses` |

The test was against the CLAUDE.md section 5 standard vocabulary and the H2
values in `DEV_G2M_AI`, not the master (D-03).

## Depreciation & Amortization and Income Taxes

- **None seeded in any of the three lanes.**
- **DAVIDSON:** no dictionary or description identifies them. The MR has
  descriptions only for `ADR` and `Rooms`. The PL sections that might hold
  them are unmapped.
- **What is waiting in the master:** DAVIDSON's 3,590 `Operating Expenses`
  keys and 667 `Other Income / (Expense)` keys may contain them.

## Sign anomaly (query `01c7ee7d-020a-483e-0003-4ff21bca8cba`)

Method: per key, the sum of non-subtotal `SOURCE_AMOUNT` in the
income-statement tables, compared with the prevailing direction of its `H1`
on that lane. Outliers are reported, not reclassified.

| Lane | H1 | Prevailing | Keys | Outlier keys | Outlier absolute amount |
|---|---|---|---|---|---|
| DAVIDSON | Revenue | + | 1,954 | 190 | 8,718,648 |
| DAVIDSON | Expense | + | 7,688 | 156 | 2,601,944 |
| DAVIDSON | Below the Line | + | 339 | 38 | 38,517,590 |
| DAVIDSON | Allocations & Reserves | + | 66 | 17 | 5,914,586 |
| HHG | Revenue | + | 3,583 | 221 | 8,350,557 |
| HHG | Expense | + | 10,670 | 984 | 294,791,959 |
| HHG | Below the Line | + | 418 | 33 | 7,728,367 |
| HERSHA | Revenue | - | 299 | 39 | 1,586,256 |
| HERSHA | Expense | + | 750 | 6 | 987,547 |

- **DAVIDSON books revenue and expense both positive**, so an outlier is a
  negative key: a contra line (discounts, rebates) or a misclassification.
- **HHG's Expense outliers are the largest by amount.** The same pattern was
  reported in build 02, and HHG's classification rows are unchanged.

## Keyword contradiction (same query)

A candidate list, not proof:
- a `Revenue` key whose description says expense, payroll, wage, salary,
  cost or benefit;
- an `Expense` key whose description says revenue, income or sales.

| Lane | H1 | Keys | Absolute amount |
|---|---|---|---|
| DAVIDSON | Revenue | 32 | 164,530 |
| HERSHA | Expense | 75 | 18,157,168 |
| HHG | Expense | 104 | 41,408,827 |

DAVIDSON's MR has no account descriptions, so this test reaches only PL
lines with worded sections.
