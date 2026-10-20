# Classification coverage - which accounts are classified, and correctly?

Regenerated on 2026-10-19 from live queries after the Q-04 re-run
(`M6-q04-rerun.md`). The classification table holds 64,667 keys: KSL 42,808,
PEREGRINE 21,859. Every key is `UNREVIEWED`.

**What Q-04 did and did not change here.** It changed category, which is
not a classification column, so **no account's classification changed**:
the table's content hash is 3748558483767381456, the same as at M4 and M6,
and every run inserted 0 keys. What changed is where rows land: rows that
were held in `SEM_UNKNOWN` for an unresolved category now reach the
classified table their `H1` routes to. Coverage by row therefore rose in
the tables; coverage by account did not move.

## Coverage

By semantic destination, rows and `abs(SOURCE_AMOUNT)`.

| Lane | Destination | Rows | abs amount | M6 rows | Change |
|---|---|---|---|---|---|
| KSL | income statement (3 tables) | 620,849 | 2,838,763,323.99 | 533,546 | +87,303 |
| KSL | balance sheet | 190,283 | 3,024,592,772.11 | 188,625 | +1,658 |
| KSL | operating metrics | 53,888 | 605,913,542.80 | 53,257 | +631 |
| KSL | unknown: `UNCLASSIFIED_ACCOUNT` | 1,831,009 | 23,586,246,666.85 | 1,830,303 | +706 (from `BOTH`) |
| KSL | unknown: `UNRESOLVED_CATEGORY` | 0 | 0 | 89,592 | -89,592 |
| KSL | unknown: `BOTH` | 0 | 0 | 706 | -706 |
| | **KSL total** | **2,696,029** | | 2,696,029 | 0 |
| PEREGRINE | income statement (3 tables) | 219,586 | 1,614,965,105.64 | 182,851 | +36,735 |
| PEREGRINE | balance sheet | 21,471 | 1,348,611,070.44 | 21,471 | 0 |
| PEREGRINE | operating metrics | 3,132 | 616,134,821.78 | 2,915 | +217 |
| PEREGRINE | unknown: `UNCLASSIFIED_ACCOUNT` | 504,666 | 4,497,476,921.41 | 504,646 | +20 (from `BOTH`) |
| PEREGRINE | unknown: `UNRESOLVED_CATEGORY` | 0 | 0 | 36,952 | -36,952 |
| PEREGRINE | unknown: `BOTH` | 0 | 0 | 20 | -20 |
| | **PEREGRINE total** | **748,855** | | 748,855 | 0 |

**Arithmetic.**
- KSL: 620,849 + 190,283 + 53,888 + 1,831,009 = 2,696,029.
- PEREGRINE: 219,586 + 21,471 + 3,132 + 504,666 = 748,855.
- The KSL `UNCLASSIFIED_ACCOUNT` abs amount is M6's 23,451,421,893.58 plus
  the 706 former `BOTH` rows' 134,824,773.26; PEREGRINE's is M6's
  4,497,215,477.41 plus 261,444.00.

**Rows reaching a classified account** (anything not `UNCLASSIFIED_ACCOUNT`
or `BOTH`):

| Lane | Classified rows | Share of fact rows | Of which in a classified table |
|---|---|---|---|
| KSL | 865,020 | 32.1% | 865,020 (M6: 775,428) |
| PEREGRINE | 244,189 | 32.6% | 244,189 (M6: 207,237) |

The classified-row count is unchanged from M6, because those rows already
had a classified account; at M6, 89,592 KSL and 36,952 PEREGRINE of them
were held in `SEM_UNKNOWN` for their category. **Now every row with a
classified account is in a classified table.**

**The unclassified population** is the blank-account rows: item tags, labor
labels and `TOT*` rollups. They have no GL account and therefore no section
digit. It is a property of the source, not a rule failure (M4.md breaks it
down by cause). It is now the whole of `SEM_UNKNOWN`.

**By key** (query `01c7d6c8-020a-2b37-0003-4ff21b867756`, unchanged from M6):
- **Classified to a money or balance sheet `H1`:** KSL 16,542, PEREGRINE
  8,957.
- **`Statistic`:** KSL 330, PEREGRINE 141.
- **`Unclassified`:** KSL 25,936, PEREGRINE 12,761.

**Waiting in the master for Level 2 and later.** `H3`-`H5` are
`UNCLASSIFIED` on every key (0 keys have any set), because the chart states
no Level 2. These groups also wait:
- **Q-11, depreciation named in section 8:** KSL 4 accounts (99 keys),
  PEREGRINE 1 account (1 key). Seeded `Other Income / (Expense)`.
- **Q-10, intercompany seeded `Liabilities`:** KSL 28 accounts (62 keys),
  PEREGRINE 1 (1 key).

## Did each account find the right classification?

### Keyword contradiction (candidates, not proof)

This test reads account descriptions against the classification, both in
`XREF_ACCOUNT_CLASSIFICATION`. That table is byte-identical to M6 (hash
above), so the result is the M6 result:

| Lane | Pattern | Accounts | Keys | Examples |
|---|---|---|---|---|
| KSL | description names revenue or sales; `H1` Expense | 59 | 566 | `180-5200-000 COST OF SALES - FOOD`, `180-5204-000 COST OF SALES - NON ALCOHOLIC BEVERAGES`, `180-5208-000 COST OF SALES - BEER` |
| KSL | description names a P&L item; `H1` Balance Sheet | 28 | 79 | `000-1052-001 CASH IN BANK - PAYROLL`, `000-1052-130 PAYROLL - 1ST BANK (FLACCOP)` |
| PEREGRINE | description names revenue or sales; `H1` Expense | 186 | 413 | `194-5412-000 Cost of Sales - Audio Visual`, `194-5432-000 COS Miscellaneous Revenue`, `250-5200-000 Cost of Sales - Food` |
| PEREGRINE | description names a P&L item; `H1` Balance Sheet | 6 | 12 | `000-1052-001 Cash in Bank - Payroll`, `000-1052-020 CASSDOP-Payroll - Wells Fargo 5723` |

**On reading, these are false positives.**
- "Cost of Sales" accounts are section 5 COGS, correctly `Expense`.
- "Payroll" cash accounts are bank balances, correctly `Balance Sheet`.

No candidate suggests a misclassification. None was reclassified.

### Sign anomaly (the stronger test)

**Method, as at M6.** Per lane and `SOURCE_TABLE`, each account's net
`SOURCE_AMOUNT` in `SEM_INCOME_STATEMENT_ACTUAL` and `SEM_BALANCE_SHEET` is
compared with the prevailing direction for its `H1`. Accounts netting to
zero are excluded. Re-run live (query
`01c7d6bd-020a-2b08-0003-4ff21b8648d2`).

**Source convention (measured).**
- **Daily and monthly book both revenue and expense positive.** The
  prevailing direction is `+` for every `H1`.
- **The ledger inverts revenue.** It is `-` for Revenue on both lanes, and
  for Expense on KSL.

So outliers are judged within a source table, never across.

| Lane | Source | `H1` | + accounts | - accounts | Prevailing | Outlier accounts | Outlier rows | Outlier amount |
|---|---|---|---|---|---|---|---|---|
| KSL | DAILY | Revenue | 131 | 20 | + | 20 | 2,941 | -408,130.12 |
| KSL | DAILY | Expense | 814 | 90 | + | 90 | 6,414 | -3,356,661.21 |
| KSL | DAILY | Below the Line | 8 | 1 | + | 1 | 33 | -4,736,537.42 |
| KSL | DAILY | Allocations & Reserves | 1 | 0 | + | 0 | 0 | 0 |
| KSL | DAILY | Balance Sheet | 171 | 142 | + | 142 | 20,854 | -91,871,230.71 |
| KSL | MONTHLY | Revenue | 131 | 20 | + | 20 | 276 | -408,130.12 |
| KSL | MONTHLY | Expense | 828 | 76 | + | 76 | 1,700 | -3,351,995.09 |
| KSL | MONTHLY | Below the Line | 8 | 1 | + | 1 | 33 | -4,736,537.42 |
| KSL | MONTHLY | Allocations & Reserves | 1 | 0 | + | 0 | 0 | 0 |
| KSL | MONTHLY | Balance Sheet | 180 | 134 | + | 134 | 6,139 | -171,040,436.10 |
| KSL | LEDGER | Revenue | 14 | 127 | - | 14 | 3,175 | 203,764.00 |
| KSL | LEDGER | Expense | 13 | 27 | - | 13 | 1,196 | 452,437.35 |
| KSL | LEDGER | Allocations & Reserves | 8 | 1 | + | 1 | 63 | -4,509.00 |
| KSL | LEDGER | Balance Sheet | 79 | 10 | + | 10 | 20,016 | -15,852,770.74 |
| PEREGRINE | DAILY | Revenue | 367 | 31 | + | 31 | 641 | -530,582.32 |
| PEREGRINE | DAILY | Expense | 2,688 | 183 | + | 183 | 1,412 | -607,379.97 |
| PEREGRINE | DAILY | Below the Line | 8 | 2 | + | 2 | 5 | -13,703.43 |
| PEREGRINE | DAILY | Balance Sheet | 118 | 87 | + | 87 | 3,286 | -71,249,613.17 |
| PEREGRINE | MONTHLY | Revenue | 338 | 34 | + | 34 | 79 | -408,115.95 |
| PEREGRINE | MONTHLY | Expense | 2,417 | 371 | + | 371 | 1,229 | -1,156,582.73 |
| PEREGRINE | MONTHLY | Below the Line | 7 | 3 | + | 3 | 6 | -823,103.35 |
| PEREGRINE | MONTHLY | Balance Sheet | 116 | 88 | + | 88 | 526 | -158,068,612.74 |
| PEREGRINE | LEDGER | Revenue | 26 | 248 | - | 26 | 643 | 560,115.81 |
| PEREGRINE | LEDGER | Expense | 20 | 19 | + | 19 | 370 | -202,866.78 |
| PEREGRINE | LEDGER | Below the Line | 0 | 1 | - | 0 | 0 | 0 |
| PEREGRINE | LEDGER | Balance Sheet | 14 | 37 | - | 14 | 4,078 | 75,653,568.68 |

"Accounts" here are distinct `ACCOUNT_KEY` per lane, source and `H1`.

**Changed from M6: one line.** KSL MONTHLY Balance Sheet outlier rows 5,989
to 6,139 (+150) and outlier amount -171,187,555.55 to -171,040,436.10
(+147,119.45). The account counts (180 / 134 / 134 outliers) did not change.
The test sums `SEM_BALANCE_SHEET`, which now includes the 1,658 KSL `Flex`
balance sheet rows; 150 of them sit on outlier accounts and net +147,119.45
there. Every income statement line is unchanged, because the test reads
`SEM_INCOME_STATEMENT_ACTUAL` and Q-04 added only `FORECAST` rows.

**Caveat this change exposes.** Because `SEM_BALANCE_SHEET` mixes
categories (D-16), the KSL MONTHLY Balance Sheet line now nets Actuals,
Budget and Forecast scenarios together for each account. It was already
mixed at M6 (Budget and Primary Forecast rows were there); Flex adds to it.
The test is weak for `Balance Sheet` for that reason too.

**How to read this.**
- **Revenue and expense outliers are small.** They are mostly allowances,
  rebates and contra entries, which run against their class by nature.
  Each is a candidate to check in the master as either a contra account or
  a misclassification.
- **Balance sheet outliers are expected.** Debit-balance assets and
  credit-balance liabilities share one `H1`, so mixed directions are normal
  there.
- **The KSL `Below the Line` outlier** (1 account, -4,736,537.42 on both
  daily and monthly) is the single largest income-statement outlier. Check
  it first (Q-19).
- **No account was reclassified.** Every sign is carried as booked.

## `RECORD_TYPE` / `H1` disagreements

None on either lane: `H1 = Statistic` exactly when `RECORD_TYPE = STATISTIC`
(2,696,029 and 748,855 rows checked in the four `XFRM` streams).
