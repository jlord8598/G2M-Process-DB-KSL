# Classification coverage - build 03 (HERSHA, INVITED_CLUBS, BEAUMIER)

**The question: which accounts are classified, and correctly?**

- **Final state:** after the Q-13 rerun (run C). INVITED_CLUBS A6 seeds H1
  `Expense`, H2 `UNCLASSIFIED`.
- **Before/after of that change:** `M6-q13-rerun.md`.
- **Derivation:** the build 03 branches of `SPROC_XREF_ACCOUNT_CLASSIFICATION`.
- **Rules as first seeded:** `M4.md`, left as written. Its Payroll figures
  describe the pre-Q-13 state.

## Coverage (query `01c7e2d8-020a-3b31-0003-4ff21bae4626`)

| Lane | Keys | `H1` classified | `H1` Unclassified | of classified: `H2` UNCLASSIFIED | Fact rows in classified streams | Fact rows in UNKNOWN |
|---|---|---|---|---|---|---|
| HERSHA | 1,196 | 1,196 | 0 | 0 | 106,350 | 0 |
| INVITED_CLUBS | 225,833 | 201,948 | 23,885 | **113,857** (460 A6 accounts) | 42,688,566 | 8,612,946 |
| BEAUMIER | 1,178 | 1,178 | 0 | 0 | 53,144 | 0 |

The INVITED_CLUBS rows add up: 42,688,566 + 8,612,946 = 51,301,512 staged
fact rows.

- **A6 (Q-13).** The 113,857 keys route to the income statement on H1
  `Expense`:
  - 7,010,886 IS rows;
  - `P_L_SECTION`, `NORMAL_BALANCE` and `VALUE_SIGN` are null;
  - `VALUE` is null on every row; `SOURCE_AMOUNT` is carried as booked.

  They have a statement but no section, and need a Level 1 in the master.
- **`H3`:** `UNCLASSIFIED` on every key, all three lanes.
- **`METRIC_UNIT`:** null on every Statistic key (HERSHA 147, INVITED_CLUBS
  21,739; BEAUMIER has none).
- **INVITED_CLUBS H1-unclassified accounts (131):** the composition is from
  M4, unchanged by Q-13. The H1 Unclassified count is still 23,885 keys.
  - 114 expense members with no A-code digit;
  - 14 saved-assumption currency accounts;
  - 3 `[Total Base Dues]` accounts not in META.

## Did each account find the right classification?

### Keyword contradiction (query `01c7e2d8-020a-3b26-0003-4ff21bae3572`)

A candidate list, not proof. No reclassification was made.

| Lane | Pattern | Accounts | Reading |
|---|---|---|---|
| INVITED_CLUBS | Payroll with no labour word | **0** | No INVITED_CLUBS key seeds Payroll after Q-13. The former 351-of-460 finding is resolved into `H2 UNCLASSIFIED`. |
| INVITED_CLUBS | Expense with "Revenue"/"Income" | 6 | `A63009 Federal Income Tax`, now `H2 UNCLASSIFIED` with the rest of A6. The other 5 are revenue-commission and health-contra lines (`A60462`, `A60463`, `A63197`-`A63199`): contra accounts, plausibly correct. |
| INVITED_CLUBS | Revenue with "Payroll" | 3 | `A40250-52 Payroll: Service Charge Distribution`: revenue-typed in META (Q-16). |
| HERSHA | Payroll with no labour word | 3 | `610000 Operating Expenses` and `630000 Management Fees` (the Q-03 list). `603100 Supplemental Pay` is labour by meaning; the keyword list misses it. |
| HERSHA | Expense with "Income" | 1 | `700000 Non-Operating Income`, on the Q-03 list (714000 is the fourth). |

### Sign anomaly (query `01c7e2d8-020a-3b2d-0003-4ff21badd7f6`; INVITED_CLUBS `01c7e2d8-020a-3b35-0003-4ff21bae2586`)

- **Method.** Per lane, table and `H1`, compare each key's net `SOURCE_AMOUNT`
  with the class's prevailing direction. Subtotal rows are excluded.
- **Unchanged by Q-13.** The test groups by `H1`, and A6 is still `Expense`.
- **INVITED_CLUBS uses a ±0.005 tolerance.**
  - Some keys net to effectively zero: 237 expense keys and 24 revenue keys.
  - Float summation order can flip their sign between runs.
  - Strict `> 0` counts therefore drift by a few keys. M6 counted 7,432 and
    3,655; this run counts 7,428 and 3,660. The amounts are identical.
  - With the tolerance, near-zero keys count on neither side.
- **HERSHA and BEAUMIER:** strict counts, matching M6 exactly.

| Lane | Table | `H1` | Keys | + | - | Prevailing | Outliers | Outlier amount |
|---|---|---|---|---|---|---|---|---|
| HERSHA | GL_ACTUAL | Revenue | 299 | 39 | 257 | - | 39 | 1,586,255.71 |
| HERSHA | GL_ACTUAL | Expense | 750 | 728 | 6 | + | 6 | -987,547.02 |
| INVITED_CLUBS | ESSBASE | Revenue | 34,655 | 26,278 | 7,420 | + | 7,420 | -4,203,724,393.61 |
| INVITED_CLUBS | ESSBASE | Expense | 114,933 | 108,531 | 3,537 | + | 3,537 | -1,901,732,897.94 |
| BEAUMIER | BP | Revenue | 304 | 286 | 18 | + | 18 | -415,465.65 |
| BEAUMIER | BP | Expense | 731 | 10 | 721 | - | 10 | 63,991.97 |
| BEAUMIER | BP | Below the Line | 93 | 11 | 82 | - | 11 | 101,136.33 |
| BEAUMIER | BUDGET | Revenue | 319 | 299 | 18 | + | 18 | -88,050.20 |
| BEAUMIER | BUDGET | Expense | 718 | 8 | 708 | - | 8 | 33,733.71 |
| BEAUMIER | BUDGET | Below the Line | 93 | 14 | 79 | - | 14 | 240,396.64 |

Reading:
- **The prevailing signs confirm each source's convention.**
  - HERSHA: revenue negative, expense positive.
  - BEAUMIER: revenue positive, expense negative.
  - INVITED_CLUBS: both positive.
  - Hence the Q-04 consumer note.
- **INVITED_CLUBS revenue: 7,420 keys run negative, -4.20B** (Q-14).
  - It includes the stated contra lines (discounts, allowances, health-revenue
    contra), but the population is too large to be only that.
  - It is now the strongest misclassification signal in the lane.
- **HERSHA revenue: 39 positive keys** (1.59M). Allowance lines such as
  `400400 Rooms Allowances` run positive by nature, so these are likely contra
  accounts.
- **BEAUMIER outliers are small**: under 0.5M in each class.

## Owner attention in the master, by size

1. **INVITED_CLUBS: 460 A6 accounts** (113,857 keys) at `Expense` /
   `UNCLASSIFIED`, needing a Level 1 (Q-13).
2. **INVITED_CLUBS: 7,420 negative revenue keys** (-4.20B; Q-14).
3. **INVITED_CLUBS: 131 H1-unclassified accounts** (8,612,946 rows).
4. **HERSHA: the four Q-03 accounts.**
5. **BEAUMIER: `Owners Expenses` / `Holdings`** Below the Line (Q-15).
6. **INVITED_CLUBS: `A40250-52`** typed revenue (Q-16).
