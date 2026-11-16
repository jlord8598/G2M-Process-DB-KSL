# Build 23 promotion (owner, 2026-11-16)

Build 23 adds lane **HICV** and rebuilds **BEAUMIER** (D-44) for its 2027 budget. Gary's freeze held: 18 / 18 tables at every check, the last at 11:38.

- **HICV (USD, owner assumption Q-05):**
  - FIN_PL_MONTHLY x4 (ACTUAL, FORECAST FORENOV, PREVIOUS_FORECAST FOREOCT, BUDGET), FIN_GL_MONTHLY, REF_ACCOUNTS and REF_PROPERTY_ROOM_KEYS (reference). The three weekly reports go to SEM_AI_PACING. OPS_PRIORITIES_WEEKLY is not staged (Q-10).
  - 13,215 keys. H1 from the account digit; H2 from the GL sub-category, then the P&L's stated category, with the description parse anchored on the 26 stated categories (Q-15).
  - Provision is contra-revenue, H1 Revenue (Q-21).
  - D-48: the P&L beats the GL in every month, and all 15,257 GL lines go to UNKNOWN.
- **BEAUMIER:**
  - FIN_BUDGET_MONTHLY_USALI (PROFIT, per-hotel currency, SCENARIO 2027) and OPS_STATS_MONTHLY x4 (statistics; keys STOCK, the rest FLOW) added.
  - 1,181 existing keys reproduced and unchanged; 47 new.
  - 3 USALI keys are classified through STG_BEAUMIER_HIERARCHY (Q-24).

Stop 4 approved, after Q-20 to Q-24: the D-48 / D-50 register entries, and the reseed of 297 HICV and 3 BEAUMIER keys (`scripts/reseed_build23.sql`).

## Results reported by the owner (DEV1)
- **D-47 master merge:** 13,262 inserted (HICV 13,215, BEAUMIER 47), 0 updated. This equals the stop-4 expectation (13,262 insert, 0 update, 0 reviewed conflicts).
- **CLN.UTIL.SPROC_PROMOTE:** 203 procedures, 16 classification-source swaps, 2 lanes with no classification.
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 18 lanes, 55 MAINs, 448 new keys (KSL_SELECT_SERVICE 18, PEREGRINE_RESORTS 15, DAVIDSON 415).
  - These came from today's reload of those lanes' sources, not from this build. The DAVIDSON keys are profiled below.
- **reconcile_HICV_DEV1.sql and reconcile_BEAUMIER_DEV1.sql:** 0 failures each.

## Build figures (DEV_G2M_AI, after stop 4)
- **HICV semantic lines:**

  | Table | Lines |
  |---|---|
  | ACTUAL | 341,688 |
  | BUDGET | 341,688 |
  | FORECAST | 683,376 (FORENOV and FOREOCT, told apart only by SCENARIO) |
  | UNKNOWN | 15,257 |
  | PACING | 16,584 |

- **BEAUMIER semantic lines:**

  | Table | Lines |
  |---|---|
  | ACTUAL | 9,251 |
  | BUDGET | 24,436 (+7,622) |
  | FORECAST | 27,059 |
  | OPERATING_METRICS | 528 |
  | UNKNOWN | 346 |
  | PACING | 203,940 |

- **Proof:**
  - 315 objects of the 16 other lanes identical to the M2 baseline, at M3, M6 and after stop 4.
  - 41 HICV and BEAUMIER objects identical across two runs.
  - reconcile_HICV and reconcile_BEAUMIER: 0 failures.

## DAVIDSON: the 415 new keys of the DEV1 pipeline run (report only)
Read from CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY, run RUN_20261116_114923_331. DEV1 itself is not visible to G2M_MCP_AGENT.

- **What they are:** no new hotel. All 16 sites already exist, including ~BLANK~ (Davenport Collection).
  - 153 keys are on 113 accounts new to DAVIDSON.
  - 6 keys sit on 3 departments new at their site: PALLO at RINGMI, PBAN2 at PMITWR, and BANQUETS 2 at ~BLANK~.
  - The rest are new combinations of known site, department and account. 261 keys combine a known account and department at a known site.
  - Largest sites: PMITWR Three Waters 77, PMIGRA Davenport Grand 75, ~BLANK~ 61, RINGMI Grand Hotel 41.
- **By H1:**

  | H1 | Keys |
  |---|---|
  | Unclassified | 299 |
  | Expense | 77 (Payroll 39, Operating Expenses 36, Cost of Goods Sold 2) |
  | Statistic | 24 (natural accounts 9101 and 9102) |
  | Revenue | 14 |
  | Below the Line | 1 |
  | **Total** | **415** |

- **Unclassified: 299 (72%), 187 accounts, all 16 sites.** Every one has the same cause: the DAVIDSON rule (build 19, Q-09) leaves a department section that mixes revenue and expense unmapped. Restaurant 2 and 9, Room Service, Banquets and Lounge are the largest.
- No change was made.

## Scripts archived
- `run_build.sql`, `d43_check.sql`;
- `build23_hashes.sql`, `build23_beaumier_hashes.sql`, `build23_m6_hashes.sql`;
- `reseed_build23.sql`;
- `reconcile_HICV.sql` and `reconcile_BEAUMIER.sql`, with their `_DEV1` copies.

## CLAUDE.md changes
- D-48: HICV (build 23).
- D-50: HICV FIN_PL_MONTHLY and FIN_GL_MONTHLY PROFIT, with the Interest On Senior Notes exception; BEAUMIER FIN_BUDGET_MONTHLY_USALI PROFIT.

## Runbook
Left local and not committed: `Claude outputs/` is git-ignored.

## Open items (current at close-out)
N-58 to N-64 are re-read and still accurate. Promotion changed none of their facts.

| Item | Subject |
|---|---|
| N-58 | USALI currency comment conflict |
| N-59 | HICV P&L cost scope |
| N-60 | Interest On Senior Notes sign |
| N-61 | GL lines combined before landing (low priority) |
| N-62 | the 27th category, 6,552 unparsed lines |
| N-63 | contra and allocation accounts |
| N-64 | Sales-tab rows with no stated unit |
