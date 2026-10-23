# Classification coverage - build 04 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: which accounts are classified, and correctly?** Derivation is
build 01's seeder branch for each lane, unchanged (M4). Existing keys keep
build 01's classification, and only keys new to this extract were proposed.

## Coverage (query `01c7e8f0-020a-3bc3-0003-4ff21bba4872`)

| Lane | Keys | Unclassified | Statistic | Balance Sheet | Revenue | Expense | Below the Line | Allocations & Reserves |
|---|---|---|---|---|---|---|---|---|
| KSL_SELECT_SERVICE | 59,110 | 34,901 | 493 | 3,201 | 2,420 | 17,781 | 250 | 64 |
| PEREGRINE_RESORTS | 24,060 | 12,814 | 185 | 645 | 1,084 | 9,297 | 35 | 0 |

- **Arithmetic.** KSL: 34,901 + 493 + 3,201 + 2,420 + 17,781 + 250 + 64 =
  59,110. PEREGRINE: 12,814 + 185 + 645 + 1,084 + 9,297 + 35 = 24,060.
- **Expense by Level 1.**
  - KSL: COGS 762, Payroll 8,348, Opex 8,671.
  - PEREGRINE: COGS 474, Payroll 5,654, Opex 3,169.
- **Statistic families.**
  - KSL: `STAT_90` 215, `STAT_98` 137, `STAT_99` 43, and `UNCLASSIFIED` 98
    (malformed stat codes, Q-12).
  - PEREGRINE: `STAT_90`-`STAT_99` 176, and `UNCLASSIFIED` 9.
  - `METRIC_UNIT` is null on every Statistic key; the source states none.
- **Unclassified.** These keys hold the item-tag rows (rollups and blank-account
  lines) and malformed codes, as at build 01. The counts here include dead keys
  (9 KSL, 2 PEREGRINE), which the M4 list omits because no staged row carries
  them.
- **Rows.**
  - Unclassified: KSL 7,206,938, PEREGRINE 523,347, which equal each lane's
    UNKNOWN stream.
  - Classified: KSL 3,068,732, PEREGRINE 714,821.
- **`H3`** is `UNCLASSIFIED` on every key; the COA states no Level 2.

## `DEPARTMENT_NAME` against build 01 (owner, stop 3; query `01c7e8f0-020a-3b31-0003-4ff21bbac252`)

- **Comparison method.** Build 01 named a department code from the old chart,
  one name per code. That map survives in the build 01 rows of the
  classification table: no code carries more than one name there. Each row
  staged now was compared under both rules.

| Lane | Table | Rows with a department | Build 01's rule would name | Named now (Q-02) | **Lose a name** | Gain a name |
|---|---|---|---|---|---|---|
| KSL | DAILY_EXTENDED | 1,278,813 | 871,210 | 26,068 | **845,183** | 41 |
| KSL | MONTHLY_EXTENDED | 1,180,276 | 1,049,564 | 18,368 | **1,031,276** | 80 |
| KSL | LEDGER_BATCHES | 447,074 | 249,903 | 17,949 | **231,954** | 0 |
| KSL | DAILY_LABOR | 321,372 | 321,122 | 1,939 | **319,183** | 0 |
| **KSL total** | | | | | **2,427,596** | 121 |
| PEREGRINE | DAILY_EXTENDED | 94,121 | 81,434 | 43,638 | **38,641** | 845 |
| PEREGRINE | MONTHLY_EXTENDED | 579,422 | 560,265 | 304,643 | **257,490** | 1,868 |
| PEREGRINE | LEDGER_BATCHES | 30,840 | 20,542 | 13,929 | **7,936** | 1,323 |
| PEREGRINE | DAILY_LABOR | 266,524 | 266,524 | 120,109 | **146,415** | 0 |
| **PEREGRINE total** | | | | | **450,482** | 4,036 |

**Why.**
- **The COA's `DEPARTMENT_NAME` is not a department dictionary.** It holds
  the report grouping each line appears under, and a line is listed once per
  grouping:
  - up to **10 names per department code** on KSL;
  - up to **56 per code, and 56 per account,** on PEREGRINE (query
    `01c7e8f0-020a-3b31-0003-4ff21bbac26a`).

  KSL code `100` alone carries `BALANCE SHEET`, `Balance Sheet`,
  `FRONT OFFICE`, `MISC NON-REVENUE`, `Miscellaneous` and `Rooms`.
- **The Q-02 rule names a code only where its COA names are unanimous,**
  which is 12 of 49 KSL codes and 107 of 139 PEREGRINE codes.
- **Where both rules name a code, the names usually differ.**
  - KSL: 64,203 rows. The COA uses report-group labels such as
    `FRONT OFFICE` where build 01 had `Rooms`.
  - PEREGRINE: 478,283 rows.
- **"Gain"** rows are codes the old chart could not name but the COA names
  unanimously.
- **What would restore the names:** a department list keyed by department
  code (the owner has asked the source owner, Q-02). Until then, existing
  classification rows keep their build 01 `DEPARTMENT_NAME` (insert-only).
  Only the semantic rows, which take the staging value, lost the name.

## Did each account find the right classification?

### Keyword contradiction

**No re-run was needed:** no existing classification changed (M4), and the
5,410 accounts new to this build are seeded by the same digit rule. Build 01's
candidates stand: D&A in section 8 (Q-11) and intercompany in section 2
(Q-10). The 6 `100-9036-000` `AMOUNT` keys (Q-04) are a statistic code booked
as an account. Their description is `STATISTICAL OFFSET`, but they are seeded
`Allocations & Reserves` by digit 9. They are listed for correction in the
master.

### Sign anomaly (query `01c7e8f0-020a-3bc3-0003-4ff21bba4872`)

- **Method.** Per lane, source table and `H1`, compare each key's net
  `SOURCE_AMOUNT` (subtotals excluded) with the class's prevailing direction.
- **Tolerance.** Keys within ±0.005 of zero count on neither side (build 03's
  method).

| Lane | Table | `H1` | Keys | + / - | Prevailing | Outliers (amount) |
|---|---|---|---|---|---|---|
| KSL | daily | Revenue | 2,109 | 1,925 / 150 | + | 150 (-1,275,119.13) |
| KSL | daily | Expense | 15,835 | 14,227 / 1,003 | + | 1,003 (-12,245,447.98) |
| KSL | daily | Below the Line | 225 | 206 / 14 | + | 14 (-513,594.07) |
| KSL | daily | Allocations & Reserves | 41 | 41 / 0 | + | 0 |
| KSL | monthly | Revenue | 2,314 | 2,140 / 152 | + | 152 (-5,695,576.62) |
| KSL | monthly | Expense | 17,548 | 16,214 / 751 | + | 751 (-85,386,857.96) |
| KSL | monthly | Below the Line | 249 | 228 / 19 | + | 19 (-5,201,763.28) |
| KSL | monthly | Allocations & Reserves | 41 | 41 / 0 | + | 0 |
| KSL | ledger | Revenue | 1,929 | 102 / 1,673 | **-** | 102 (936,538.72) |
| KSL | ledger | Expense | 181 | 100 / 70 | + | 70 (-128,356.86) |
| KSL | ledger | Allocations & Reserves | 24 | 17 / 6 | + | 6 (-22,637.00) |
| PEREGRINE | daily | Revenue | 730 | 634 / 73 | + | 73 (-889,369.11) |
| PEREGRINE | daily | Expense | 6,251 | 5,537 / 454 | + | 454 (-843,237.36) |
| PEREGRINE | daily | Below the Line | 19 | 15 / 2 | + | 2 (-14,814.60) |
| PEREGRINE | monthly | Revenue | 1,071 | 945 / 111 | + | 111 (-16,496,793.05) |
| PEREGRINE | monthly | Expense | 9,290 | 8,925 / 303 | + | 303 (-22,711,937.75) |
| PEREGRINE | monthly | Below the Line | 35 | 31 / 4 | + | 4 (-5,347,357.36) |
| PEREGRINE | ledger | Revenue | 527 | 43 / 430 | **-** | 43 (749,745.26) |
| PEREGRINE | ledger | Expense | 42 | 23 / 19 | + | 19 (-205,137.11) |
| PEREGRINE | ledger | Below the Line | 1 | 0 / 1 | - | 0 |

**Reading.**
- **The ledger's revenue runs negative.** This is the journal's own
  convention, recorded at build 01 ("section-4 signs inverted against
  daily"). It is not a misclassification.
- **Daily and monthly expense outliers** (KSL 1,003 and 751 keys) are a
  small share of classes of about 16,000 keys. They were not examined account
  by account in this build.
- **The largest single concentration** is KSL monthly Expense, -85.4M over
  751 keys. Worth a look by account in the master, as build 01's Q-19 was.
- **No account was reclassified.**

## Owner attention in the master, by size

1. KSL 34,901 and PEREGRINE 12,814 unclassified keys: item tags and malformed
   codes, as at build 01.
2. `DEPARTMENT_NAME` lost on 2,427,596 KSL and 450,482 PEREGRINE rows, pending
   a department list (Q-02).
3. KSL monthly expense outliers (-85.4M, 751 keys).
4. 6 `100-9036-000` `AMOUNT` keys seeded `Allocations & Reserves` (Q-04).
