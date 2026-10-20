# M6 re-run - Q-04 scenario mapping

Status: **complete, at stop 4.** `M6.md` is the original M6 memo and is not
changed; this memo records the re-run after the owner answered Q-04. Every
figure comes from a query run in this session on 2026-10-19 against the
deployed objects and the live source.

## What changed

**The owner's answer (Q-04).** Map `Flex`, `RMS - OneYield`,
`RMS - HiltonGRO/IDeaS` and `5 Year Plan 2026 Final` to `CATEGORY =
'FORECAST'`, with `SCENARIO` kept verbatim, in both lanes.

**The names were taken from the staged `DATASETS`** (bracketed to expose
whitespace; none present):

| Lane | FCID | `SCENARIO_NAME` | Mapped |
|---|---|---|---|
| KSL | 20 | `Flex` | yes |
| KSL | 23 | `RMS - OneYield` | yes |
| KSL | 27 | `RMS - HiltonGRO/IDeaS` | yes |
| KSL | 115 | `5 Year Plan 2026 Final` | yes |
| PEREGRINE | 7 | `Flex` | yes |
| PEREGRINE | 16 | `5 Year Plan 2026` | **no**: a different name, not in the answer. It has no fact rows in this extract (no value awaits a category, list 4). |
| PEREGRINE | 11 | `RMS` | **no**: not in the answer. No fact rows in this extract. |

The same four names are listed in both lanes' code, as instructed. In
PEREGRINE only `Flex` exists, so the other three match nothing there.

**The code.** One `when` branch added to the `cat` CTE of each
`SPROC_XFRM_{LANE}`, after the existing `FORECAST` branch, plus the header
comment. Nothing else in either file changed:
- `SPROC_XFRM_KSL_SELECT_SERVICE.sql` was rewritten in full.
- `SPROC_XFRM_PEREGRINE_RESORTS.sql` was generated from it by name
  replacement, as at M5. A diff against the previous PEREGRINE file shows
  only the four comment lines and the four-line branch (8 insertions, 1
  deletion).

| Procedure | M6 MD5 | New MD5 (file = deployed) |
|---|---|---|
| `SPROC_XFRM_KSL_SELECT_SERVICE` | `0b2c1bc8ca8848d42d7c99602b88ab9c` | `b2898a41897829a62fc1ed0c5a8198fc` |
| `SPROC_XFRM_PEREGRINE_RESORTS` | `0ae8e10f2ce80296f22523fbbab7d34d` | `331f44d03f9e41cdfc5fb081885acfb0` |

The other 39 procedures are unchanged.

## Source (Q-17 watch)

`max(last_altered)` over the 25 `CLN.CLEAN` tables was
`2026-10-19 07:39:56.040 -0700` before the change, after build run 2 and
after the final build. **The source did not reload during this re-run.** It
is the same extract as M6.

## Runs

| Run | STG | XREF | XFRM | SEM |
|---|---|---|---|---|
| 1 | `..._102453_452`, `..._102521_034` | `..._102542_625`, `..._102547_750` (inserted 0, 0) | `..._102553_594`, `..._102607_156` | `RUN_20261019_102617_384` |
| 2 | `..._102710_062`, `..._102732_081` | `..._102751_352`, `..._102755_302` (inserted 0, 0) | `..._102758_918`, `..._102812_183` | `RUN_20261019_102821_913` |
| check 6 (faulted) | `..._103413_219`, `..._103435_161` | `..._103455_007`, `..._103459_363` | stopped | not run |
| final, after restore | `..._103628_871`, `..._103655_304` | `..._103718_330`, `..._103723_599` (inserted 0, 0) | `..._103727_884`, `..._103741_668` | `RUN_20261019_103753_922` |

All `RUN_ID`s are `RUN_20261019_*`; STG and XREF are KSL then PEREGRINE.
The harness is run as in M6: the body of `scripts/run_build.sql` sent
inline with its comment blocks removed, same calls in the same order.

## Checks

### Check 1, completeness: PASS

| Lane | Fact staging | `IS` + `BS` + `OM` + `UNKNOWN` | Pace staging | `PACING` |
|---|---|---|---|---|
| KSL | 2,696,029 | 620,849 + 190,283 + 53,888 + 1,831,009 = 2,696,029 | 244,438 | 244,438 |
| PEREGRINE | 748,855 | 219,586 + 21,471 + 3,132 + 504,666 = 748,855 | 8,898 | 8,898 |

| Lane | `ACTUAL` + `BUDGET` + `FORECAST` = `XFRM_IS` | `BS` | `OM` | `UNKNOWN` | Six tables | Fact staging |
|---|---|---|---|---|---|---|
| KSL | 359,425 + 108,847 + 152,577 = 620,849 | 190,283 | 53,888 | 1,831,009 | 2,696,029 | 2,696,029 |
| PEREGRINE | 110,223 + 42,557 + 66,806 = 219,586 | 21,471 | 3,132 | 504,666 | 748,855 | 748,855 |

Source to staging: equal on all 25 tables (reconcile scripts, below).

### Check 2, classification integrity: PASS

Run as defined in CLAUDE.md section 9 (query `01c7d6b9-020a-2b08-0003-4ff21b86483a`):

| | Against | Result |
|---|---|---|
| a | `XREF_SNAPSHOT` | 0 |
| b | `XREF_SNAPSHOT` | 0 |
| c | `STAGING` left join `XREF_SNAPSHOT` | 0 |
| d | `XREF_SNAPSHOT` | 0 |
| e | four `H1`-routed `XFRM` streams, both lanes | 0 |
| f | `XREF_SNAPSHOT` and `XFRM` | 0 |
| g | the three `SEM_INCOME_STATEMENT_*` | 0 |
| h | the three `SEM_INCOME_STATEMENT_*` and `SEM_BALANCE_SHEET` | 0 |
| i | all six `SEM` tables | 0 |
| j | `SEM_UNKNOWN` | 0 |
| k | `XREF_SNAPSHOT` and all six `SEM` tables | 0 |
| l | `XREF_SNAPSHOT` | 0 |

**`RECORD_TYPE` / `H1` disagreements:** 0 on both lanes (2,696,029 and
748,855 rows checked).

**(g) is the check that matters for this change.** The newly mapped rows
all landed in `SEM_INCOME_STATEMENT_FORECAST` with `CATEGORY = 'FORECAST'`,
or in balance sheet / operating metrics carrying `CATEGORY = 'FORECAST'`.

### Check 3, amount reconciliation: PASS

Both reconcile scripts were run after the final build:

| Script | Query | Rows checked | `FAIL` | Total failure count |
|---|---|---|---|---|
| `reconcile_KSL_SELECT_SERVICE.sql` | `01c7d6ba-020a-2bbb-0003-4ff21b86a2f6` | 57 | 0 | **0** |
| `reconcile_PEREGRINE_RESORTS.sql` | `01c7d6bb-020a-2b54-0003-4ff21b85ea6a` | 57 | 0 | **0** |

**Every figure is identical to the M6 run.** The mapping moves rows between
destinations; it changes no amount and no row in any source table. The
per-table bridge of the moved rows is below ("The move").

### Check 4, parity: PASS

- Line-ending check first: `OK: 61 file(s) scanned, all LF, all .sql ASCII`, exit 0.
- **After deploying the two files:** live `md5(procedure_definition)` on
  `INFORMATION_SCHEMA.PROCEDURES`, 41 procedures; `parity_check.py`: 41 OK,
  exit 0.
- **After the check 6 restore:** a fresh live query, 41 procedures;
  `parity_check.py`: 41 OK, exit 0. 41 `.sql` files under `sql/`.
- The self-test is unchanged: `M2-parity-selftest.md`.

### Check 5, idempotency: PASS

**Method.** Runs 1 and 2 through `scripts/run_build.sql` on the same
extract. `HASH_AGG(*)` over `select * exclude (run_id)` for every base table
in the four schemas; the classification table excludes
`LAST_SEEN_RUN_ID`. 42 tables.

| Tables compared | Bit-identical | Different |
|---|---|---|
| 42 | **42** | 0 |

**Run-2 hashes of the deliverable tables** (equal to run 1, and equal again
after the final build):

| Table | Rows | Hash | Same as M6? |
|---|---|---|---|
| SEM_INCOME_STATEMENT_ACTUAL | 469,648 | 4366641615106434847 | yes |
| SEM_INCOME_STATEMENT_BUDGET | 151,404 | 44660025581903630 | yes |
| SEM_INCOME_STATEMENT_FORECAST | 219,383 | 2150654489103823260 | no: gained the Q-04 rows |
| SEM_BALANCE_SHEET | 211,754 | 552326711160311572 | no: gained KSL Flex |
| SEM_OPERATING_METRICS | 57,020 | -3359789021322500752 | no: gained Flex, OneYield |
| SEM_UNKNOWN | 2,335,675 | -5870168174827310604 | no: lost them |
| XREF_ACCOUNT_CLASSIFICATION | 64,667 | 3748558483767381456 | yes, same as M4 |

**ACTUAL and BUDGET hash exactly as at M6**, which is direct evidence the
change touched nothing outside the four scenarios. The 25 staging tables
also hash identically between runs.

**The classification assertion.** Every run inserted 0 rows on both lanes,
and the hash, which includes every classification value and
`FIRST_SEEN_RUN_ID`, is unchanged. Category is not a classification
column, so no key was re-proposed (D-04).

### Check 6, fault propagation, model inside a MAIN: PASS

Re-used the M6 fault: the deployed `SPROC_XFRM_KSL_SELECT_SERVICE` was
replaced with a body evaluating `1/0`, its file untouched, then
`run_build.sql` was run.

| Requirement | Evidence |
|---|---|
| Error surfaces with its origin named | `Uncaught exception of type 'STATEMENT_ERROR' on line 25 at position 4 : Uncaught exception of type 'STATEMENT_ERROR' on line 16 at position 4 : Uncaught exception of type 'EXPRESSION_ERROR' on line 5 at position 9 : Division by zero` (query `01c7d6be-020a-2e85-0003-4ff21b860afe`). Harness line 25 is the call to `SPROC_XFRM_KSL_SELECT_SERVICE_MAIN` (file line 53, as in M6); MAIN line 16 its call to the model; model line 5 `v := 1/0`. |
| Every MAIN before it completed | `$RUN_BUILD_COMPLETED` lists both STG MAINs (`models=13`) and both XREF MAINs (`inserted=0`), `RUN_20261019_103413_219`, `..._103435_161`, `..._103455_007`, `..._103459_363`. |
| Nothing after it ran | `$RUN_BUILD_STARTED` = `SPROC_XFRM_KSL_SELECT_SERVICE_MAIN`. `XFRM_PEREGRINE_RESORTS_UNKNOWN` still carried `RUN_20261019_102812_183` and `SEM_UNKNOWN` `RUN_20261019_102821_913`, both run 2. |

**Restore.** Redeployed from the file; live MD5
`b2898a41897829a62fc1ed0c5a8198fc`, identical to before the fault. A clean
full build followed (SEM `RUN_20261019_103753_922`), and every `XFRM`,
`SEM` and `XREF` table hashes exactly as in run 2. Parity re-run: 41 OK.
`DEV_G2M_AI` holds `STAGING` 25, `XREF_SNAPSHOT` 4 (1 table, 3 views),
`TRANSFORMATION` 10, `SEMANTIC` 6; no `TMP*` objects.

## The move: Q-04 rows from `SEM_UNKNOWN` into the classified tables

**Before (M6, `RUN_20261019_080450_329`), the Q-04 rows in `SEM_UNKNOWN`:**

| Lane | Scenario | Reason | `H1` | Rows | `SOURCE_AMOUNT` | `STAT_VALUE` |
|---|---|---|---|---|---|---|
| KSL | 5 Year Plan 2026 Final | UNRESOLVED_CATEGORY | Revenue | 1,612 | 259,826,449.4951 | 1,974,179.8876 |
| KSL | 5 Year Plan 2026 Final | UNRESOLVED_CATEGORY | Expense | 5,067 | 174,654,863.7498 | 7,713,625 |
| KSL | 5 Year Plan 2026 Final | UNRESOLVED_CATEGORY | Allocations & Reserves | 418 | 10,417,431.1027 | 79,774 |
| KSL | Flex | UNRESOLVED_CATEGORY | Revenue | 6,931 | 168,254,809.0064 | 1,334,843.8432 |
| KSL | Flex | UNRESOLVED_CATEGORY | Expense | 72,265 | 149,500,088.6198 | 1,972,320.7751 |
| KSL | Flex | UNRESOLVED_CATEGORY | Below the Line | 534 | 14,131,652.18 | 0 |
| KSL | Flex | UNRESOLVED_CATEGORY | Allocations & Reserves | 268 | 6,730,192.3607 | 0 |
| KSL | Flex | UNRESOLVED_CATEGORY | Balance Sheet | 1,658 | 126,292,545.80 | 0 |
| KSL | Flex | UNRESOLVED_CATEGORY | Statistic | 626 | 0 | -3,253,181.99 |
| KSL | Flex | BOTH | (unclassified) | 706 | 134,761,375.2422 | 712,383.7119 |
| KSL | RMS - OneYield | UNRESOLVED_CATEGORY | Revenue | 177 | 11,670,513 | 67,049 |
| KSL | RMS - OneYield | UNRESOLVED_CATEGORY | Statistic | 5 | 0 | 146 |
| KSL | RMS - HiltonGRO/IDeaS | UNRESOLVED_CATEGORY | Revenue | 31 | 1,782,229.54 | 11,796 |
| PEREGRINE | Flex | UNRESOLVED_CATEGORY | Revenue | 2,109 | 117,173,341.0029 | 1,630,150.5948 |
| PEREGRINE | Flex | UNRESOLVED_CATEGORY | Expense | 34,531 | 196,114,157.1415 | 1,865,543.9336 |
| PEREGRINE | Flex | UNRESOLVED_CATEGORY | Below the Line | 95 | 31,947,870.2232 | 0 |
| PEREGRINE | Flex | UNRESOLVED_CATEGORY | Statistic | 217 | 311,089.8564 | 5,860,037.1021 |
| PEREGRINE | Flex | BOTH | (unclassified) | 20 | 261,444 | 2,728 |

Totals: KSL 90,298 rows (Flex 82,988, 5YP 7,097, OneYield 182, HiltonGRO 31);
PEREGRINE 36,972. These match M6.md list 4.

**After (this run), the same rows:**

| Lane | Scenario | Now in | Reason | Rows | `SOURCE_AMOUNT` | `STAT_VALUE` | `VALUE` |
|---|---|---|---|---|---|---|---|
| KSL | 5 Year Plan 2026 Final | FORECAST | - | 7,097 | 444,898,744.3476 | 9,767,578.8876 | 85,171,585.7453 |
| KSL | Flex | FORECAST | - | 79,998 | 338,616,742.1669 | 3,307,164.6183 | 18,754,720.3866 |
| KSL | Flex | BALANCE_SHEET | - | 1,658 | 126,292,545.80 | 0 | null |
| KSL | Flex | OPERATING_METRICS | - | 626 | 0 | -3,253,181.99 | - |
| KSL | Flex | UNKNOWN | UNCLASSIFIED_ACCOUNT | 706 | 134,761,375.2422 | 712,383.7119 | - |
| KSL | RMS - OneYield | FORECAST | - | 177 | 11,670,513 | 67,049 | 11,670,513 |
| KSL | RMS - OneYield | OPERATING_METRICS | - | 5 | 0 | 146 | - |
| KSL | RMS - HiltonGRO/IDeaS | FORECAST | - | 31 | 1,782,229.54 | 11,796 | 1,782,229.54 |
| PEREGRINE | Flex | FORECAST | - | 36,735 | 345,235,368.3676 | 3,495,694.5284 | -78,940,816.1386 |
| PEREGRINE | Flex | OPERATING_METRICS | - | 217 | 311,089.8564 | 5,860,037.1021 | - |
| PEREGRINE | Flex | UNKNOWN | UNCLASSIFIED_ACCOUNT | 20 | 261,444 | 2,728 | - |

**Every row went where its `H1` routes it** (section 3):
- **FORECAST** takes the income-statement `H1`s: KSL 5YP 1,612 + 5,067 +
  418 = 7,097; KSL Flex 6,931 + 72,265 + 534 + 268 = 79,998; PEREGRINE Flex
  2,109 + 34,531 + 95 = 36,735.
- **Balance sheet and operating metrics** take `Balance Sheet` and
  `Statistic` rows, which also carry `CATEGORY = 'FORECAST'` there (D-16).
- **726 rows stay in `SEM_UNKNOWN`** (KSL 706, PEREGRINE 20). They were
  `BOTH`; now their category resolves to `FORECAST` and only the account is
  unclassified, so they are `UNCLASSIFIED_ACCOUNT` with `CATEGORY` populated
  and `UNRESOLVED_CATEGORY_VALUE` null (2(j) holds).
- **Rows moved out of `SEM_UNKNOWN`:** KSL 87,303 + 1,658 + 631 = 89,592;
  PEREGRINE 36,735 + 217 = 36,952. With the 726 that stayed: 90,298 and
  36,972, the M6 totals.

## Every figure that changed from M6

### `SEMANTIC`, per table and lane

| Lane | Table | M6 rows | Now | Change | Explained by |
|---|---|---|---|---|---|
| KSL | ACTUAL | 359,425 | 359,425 | 0 | |
| KSL | BUDGET | 108,847 | 108,847 | 0 | |
| KSL | FORECAST | 65,274 | 152,577 | +87,303 | 5YP 7,097 + Flex 79,998 + OneYield 177 + HiltonGRO 31 |
| KSL | BALANCE_SHEET | 188,625 | 190,283 | +1,658 | Flex `Balance Sheet` |
| KSL | OPERATING_METRICS | 53,257 | 53,888 | +631 | Flex 626 + OneYield 5 `Statistic` |
| KSL | UNKNOWN | 1,920,601 | 1,831,009 | -89,592 | the sum of the three rows above |
| PEREGRINE | ACTUAL | 110,223 | 110,223 | 0 | |
| PEREGRINE | BUDGET | 42,557 | 42,557 | 0 | |
| PEREGRINE | FORECAST | 30,071 | 66,806 | +36,735 | Flex income statement |
| PEREGRINE | BALANCE_SHEET | 21,471 | 21,471 | 0 | PEREGRINE Flex has no `Balance Sheet` rows |
| PEREGRINE | OPERATING_METRICS | 2,915 | 3,132 | +217 | Flex `Statistic` |
| PEREGRINE | UNKNOWN | 541,618 | 504,666 | -36,952 | 36,735 + 217 |

Six-table totals unchanged: KSL 2,696,029, PEREGRINE 748,855. Combined
table counts: ACTUAL 469,648 and BUDGET 151,404 unchanged; FORECAST 95,345
to 219,383 (+124,038 = 87,303 + 36,735); BALANCE_SHEET 210,096 to 211,754
(+1,658); OPERATING_METRICS 56,172 to 57,020 (+848 = 631 + 217); UNKNOWN
2,462,219 to 2,335,675 (-126,544 = 89,592 + 36,952).

**Measures, the bridge.** `SOURCE_AMOUNT` and `STAT_VALUE` move with their
rows; the totals per lane do not change.

| Lane | Table | Measure | M6 | Now | Change | Moved rows |
|---|---|---|---|---|---|---|
| KSL | FORECAST | `SOURCE_AMOUNT` | 321,635,839.8341 | 1,118,604,068.8886 | +796,968,229.0545 | 444,898,744.3476 + 338,616,742.1669 + 11,670,513 + 1,782,229.54 |
| KSL | FORECAST | `STAT_VALUE` | 3,899,733.0365 | 17,053,321.5424 | +13,153,588.5059 | 9,767,578.8876 + 3,307,164.6183 + 67,049 + 11,796 |
| KSL | FORECAST | `VALUE` | 58,875,098.2419 | 176,254,146.9138 | +117,379,048.6719 | 85,171,585.7453 + 18,754,720.3866 + 11,670,513 + 1,782,229.54 |
| KSL | BALANCE_SHEET | `SOURCE_AMOUNT` | 590,695,620.09 | 716,988,165.89 | +126,292,545.80 | Flex |
| KSL | OPERATING_METRICS | `SOURCE_AMOUNT` | 523,594,223.42 | 523,594,223.42 | 0 | moved rows carry 0 |
| KSL | OPERATING_METRICS | `STAT_VALUE` | -10,736,819.85 | -13,989,855.84 | -3,253,035.99 | -3,253,181.99 + 146 |
| KSL | UNKNOWN | `SOURCE_AMOUNT` | 11,021,000,401.6405 | 10,097,739,626.786 | -923,260,774.8545 | 796,968,229.0545 + 126,292,545.80 |
| KSL | UNKNOWN | `STAT_VALUE` | 271,907,391.189103 | 262,006,838.673203 | -9,900,552.5159 | 13,153,588.5059 - 3,253,035.99 |
| PEREGRINE | FORECAST | `SOURCE_AMOUNT` | 311,017,272.68 | 656,252,641.0476 | +345,235,368.3676 | Flex |
| PEREGRINE | FORECAST | `STAT_VALUE` | 7,577,253.681 | 11,072,948.2094 | +3,495,694.5284 | Flex |
| PEREGRINE | FORECAST | `VALUE` | 22,804,098.7538 | -56,136,717.3848 | -78,940,816.1386 | Flex |
| PEREGRINE | OPERATING_METRICS | `SOURCE_AMOUNT` | 615,823,731.9201 | 616,134,821.7765 | +311,089.8564 | Flex |
| PEREGRINE | OPERATING_METRICS | `STAT_VALUE` | 51,035,484.4418 | 56,895,521.5439 | +5,860,037.1021 | Flex |
| PEREGRINE | UNKNOWN | `SOURCE_AMOUNT` | 3,311,182,418.31282 | 2,965,635,960.08882 | -345,546,458.224 | 345,235,368.3676 + 311,089.8564 |
| PEREGRINE | UNKNOWN | `STAT_VALUE` | 45,459,375.260966 | 36,103,643.630466 | -9,355,731.6305 | 3,495,694.5284 + 5,860,037.1021 |

Every change equals the moved rows exactly; each lane's gains and losses
net to zero. ACTUAL, BUDGET and PEREGRINE BALANCE_SHEET are unchanged on
every measure.

**PEREGRINE FORECAST `VALUE` turned negative.** Flex's signed `VALUE` is
-78,940,816.14 because its expense rows (34,531, Debit, sign -1) outweigh
its revenue rows (2,109, Credit, +1). That is the sign rule working on a
scenario that is mostly expense lines, not an error; 2(h) holds.

### `TRANSFORMATION`

| Lane | Stream | M6 | Now | Change |
|---|---|---|---|---|
| KSL | INCOME_STATEMENT | 533,546 | 620,849 | +87,303 |
| KSL | BALANCE_SHEET | 188,625 | 190,283 | +1,658 |
| KSL | OPERATING_METRICS | 53,257 | 53,888 | +631 |
| KSL | UNKNOWN | 1,920,601 | 1,831,009 | -89,592 |
| KSL | PACING | 244,438 | 244,438 | 0 |
| PEREGRINE | INCOME_STATEMENT | 182,851 | 219,586 | +36,735 |
| PEREGRINE | BALANCE_SHEET | 21,471 | 21,471 | 0 |
| PEREGRINE | OPERATING_METRICS | 2,915 | 3,132 | +217 |
| PEREGRINE | UNKNOWN | 541,618 | 504,666 | -36,952 |
| PEREGRINE | PACING | 8,898 | 8,898 | 0 |

The same moves, one layer up. Staging, the classification table and pacing
are unchanged.

### `UNKNOWN_REASON`

| Lane | Reason | M6 rows | Now |
|---|---|---|---|
| KSL | UNCLASSIFIED_ACCOUNT | 1,830,303 | 1,831,009 (+706 from `BOTH`) |
| KSL | UNRESOLVED_CATEGORY | 89,592 | 0 |
| KSL | BOTH | 706 | 0 |
| PEREGRINE | UNCLASSIFIED_ACCOUNT | 504,646 | 504,666 (+20 from `BOTH`) |
| PEREGRINE | UNRESOLVED_CATEGORY | 36,952 | 0 |
| PEREGRINE | BOTH | 20 | 0 |

**`SEM_UNKNOWN` now holds only unclassified accounts.** No row on either
lane is waiting for a category.

## The four lists

Amounts are `SOURCE_AMOUNT` as booked, sorted by amount; the tail was not
cut.

**1. New this run.** 0 keys on both lanes (`VW_XREF_NEW_THIS_RUN`).
Unchanged from M6.

**2. Unclassified.** Unchanged from M6 in keys, rows and amount; the rows
now carry reason `UNCLASSIFIED_ACCOUNT` only.

| Lane | Keys (`VW_XREF_UNCLASSIFIED`) | Rows | Amount |
|---|---|---|---|
| KSL_SELECT_SERVICE | 25,936 | 1,831,009 | 10,097,739,626.79 |
| PEREGRINE_RESORTS | 12,761 | 504,666 | 2,965,635,960.09 |

**3. Awaiting sign.** The permanent floor: all three `H1` values seed a null
sign by design. Keys are unchanged (`VW_XREF_AWAITING_SIGN`); rows grew
because the Q-04 rows of these keys now reach the signed tables.

| Lane | `H1` | Keys | M6 rows | Rows | M6 amount | Amount | Change explained |
|---|---|---|---|---|---|---|---|
| KSL | Balance Sheet | 2,004 | 188,625 | 190,283 | 590,695,620.09 | 716,988,165.89 | Flex 1,658 rows, 126,292,545.80 |
| KSL | Below the Line | 159 | 2,459 | 2,993 | 40,026,957.63 | 54,158,609.81 | Flex 534 rows, 14,131,652.18 |
| KSL | Allocations & Reserves | 52 | 1,453 | 2,139 | 29,526,557.38 | 46,674,180.84 | Flex 268 + 5YP 418 = 686 rows, 6,730,192.36 + 10,417,431.10 |
| PEREGRINE | Below the Line | 22 | 271 | 366 | 79,872,230.52 | 111,820,100.74 | Flex 95 rows, 31,947,870.22 |
| PEREGRINE | Balance Sheet | 457 | 21,471 | 21,471 | 84,159,644.88 | 84,159,644.88 | none |

**4. Values awaiting a category.** **None on either lane** (M6: the four
Q-04 values, 90,298 KSL and 36,972 PEREGRINE rows).

## The five documents

Regenerated from live queries in this re-run: `reconciliation.md`,
`field-lineage.md`, `classification-coverage.md`, `table-usage.md`,
`open-questions.md` (Q-04 recorded as answered).

## For the owner at stop 4

- **Nothing blocks.** All six checks pass with evidence; both reconcile
  scripts report zero failures; the source did not reload.
- **Q-04 is closed.** Q-08, Q-17, Q-18 and Q-19 remain open, none blocking.
- **Two PEREGRINE scenarios were not mapped** because they were not named:
  `5 Year Plan 2026` (FCID 16) and `RMS` (FCID 11). Neither has rows in this
  extract. If either gains rows later they will route to `SEM_UNKNOWN` as
  `UNRESOLVED_CATEGORY`, which is the intended behaviour; recorded under
  Q-04.
