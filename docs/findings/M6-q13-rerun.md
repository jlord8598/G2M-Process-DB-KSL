# M6 rerun after Q-13 - INVITED_CLUBS A6 range

Owner, after stop 4: the INVITED_CLUBS A6 range is not Payroll. A6 accounts seed
H1 `Expense`, H2 `UNCLASSIFIED`, so `P_L_SECTION`, `NORMAL_BALANCE` and
`VALUE_SIGN` are null. Every other INVITED_CLUBS rule is unchanged.

## What changed

- **Code.** The INVITED_CLUBS branch of `SPROC_XREF_ACCOUNT_CLASSIFICATION`, and
  nothing else:
  - the H2 line for digit 6 now gives `'UNCLASSIFIED'`;
  - a separate `seed_source` for digit 6 cites Q-13;
  - the branch comment is updated.

  The seeder diff against HEAD is still additive: +433 lines, 0 deleted. No
  other lane's branch, and no STG, XFRM or SEM code, changed.
- **Data.** The one approved delete:
  `delete from XREF_ACCOUNT_CLASSIFICATION where source_lane = 'INVITED_CLUBS'`
  removed 225,833 rows, exactly the lane's key count (query
  `01c7e2ba-020a-3b25-0003-4ff21baceac6`). Run A then reseeded 225,833 keys.

## Pre-checks

D-43: 0 of the 14 in-scope tables were altered after 2026-10-19
15:40:44.535 PDT (checked at 2026-10-21 13:41:44 PDT, inside the freeze window).

## Runs

| Run | XREF INVITED_CLUBS | Note |
|---|---|---|
| A | inserted 225,833 | reseed after the delete |
| B | inserted 0 (HERSHA 0, BEAUMIER 0) | idempotency |
| fault | - | check 6 |
| C | inserted 0 | after the restore; the state now deployed |

## Stream counts, INVITED_CLUBS (unchanged)

| Stream | Before | After |
|---|---|---|
| INCOME_STATEMENT | 20,387,874 | 20,387,874 |
| BALANCE_SHEET | 9,857,187 | 9,857,187 |
| OPERATING_METRICS | 12,443,505 | 12,443,505 |
| PACING | 0 | 0 |
| UNKNOWN | 8,612,946 | 8,612,946 |

The counts do not move because routing is by H1, and A6 is still `Expense`.

SEM_AI totals are also unchanged: ACTUAL 7,495,848; BUDGET 6,977,100;
FORECAST 7,125,147; BS 10,068,941; OM 12,614,333; UNKNOWN 10,951,781.

## Payroll, INVITED_CLUBS

| | Before | After |
|---|---|---|
| XREF keys, H2 Payroll | 113,857 (460 accounts) | **0** |
| XFRM IS rows, H2 Payroll | 7,010,886 | **0** |
| Payroll `SOURCE_AMOUNT` | 8,991,012,008.32 | **0** |
| Payroll `VALUE` | -8,991,012,008.32 | **0** |

The same 7,010,886 rows are now in IS as `Expense` / `UNCLASSIFIED`.
`SOURCE_AMOUNT` is unchanged and `VALUE` is null on all of them.

By category, rows and `SOURCE_AMOUNT`:

- ACTUAL: 2,336,962 rows, 5,921,257,236.90.
- FORECAST: 2,336,962 rows, 1,536,239,420.95.
- BUDGET: 2,336,962 rows, 1,533,515,350.47.

## Lists (ordered, a key on exactly one)

| List | Before | After |
|---|---|---|
| Unclassified, INVITED_CLUBS | 23,885 | **137,742** (23,885 H1 Unclassified + 113,857 A6) |
| Awaiting sign, INVITED_CLUBS | 29,881 (Balance Sheet floor) | **29,881** (unchanged) |
| Awaiting sign, BEAUMIER | 93 | 93 |
| Awaiting sign, HERSHA | 0 | 0 |

## Checks

| # | Check | Result | Evidence |
|---|---|---|---|
| 1 | Completeness | **PASS** | stream counts above; reconcile scripts |
| 2 | (a)-(l) | **PASS**, all 0 | three reconcile scripts, 0 failures each |
| 3 | Sums per measure | **PASS** | same scripts |
| 4 | Parity | **PASS** | 90 of 90, exit 0, after run C |
| 5 | Idempotency and earlier builds | **PASS** | see below |
| 6 | Fault propagates | **PASS** | see below |
| - | Invariant 7 | **PASS** | SEMANTIC holds 6 tables |
| - | Line endings | **PASS** | 146 files, all LF, `.sql` ASCII |

**Check 5.**

- Before -> A: exactly five of the 50 build-03 objects changed, all of them
  INVITED_CLUBS:
  - the XREF slice;
  - `XFRM_INVITED_CLUBS_INCOME_STATEMENT`;
  - the three SEM IS slices.
- A = B = C on 50 of 50 objects.
- The HERSHA and BEAUMIER hashes are unchanged from before the fix.
- The 88 earlier-build objects are equal to the baseline after A, B and C.

**Check 6.**

- Fault: a faulted `SPROC_STG_INVITED_CLUBS_META_ACCOUNT` (`1/0` at the top),
  called through `SPROC_STG_INVITED_CLUBS_MAIN`.
- The MAIN raised the model's division by zero (query
  `01c7e2cc-020a-3b2a-0003-4ff21bae6012`).
- All seven `STG_INVITED_CLUBS_*` tables kept their run-B times (13:50:14 to
  13:51:07), so nothing after the fault ran.
- The file was then redeployed, parity passed, and run C ran clean.
