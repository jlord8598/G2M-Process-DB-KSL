# Build 25 promotion (owner, 2026-11-16)

Build 25 rebuilds **KSL_SELECT_SERVICE** and **PEREGRINE_RESORTS** (D-44), transformation only, to stop the three ProfitSword actual tables being summed. Gary's freeze held: 27 / 27 tables were unchanged since the 01:19 reload.

- **D-48:**
  - for ACTUAL, MONTHLY_EXTENDED (IS_ACTUALS) beats DAILY_EXTENDED and LEDGER_BATCHES at every site-month it carries;
  - DAILY_EXTENDED beats LEDGER_BATCHES where monthly is absent (KSL CAPICOP);
  - the rule covers every section; every ledger line goes to UNKNOWN as DUPLICATE_DETAIL.
- **D-50:** LEDGER_BATCHES is DEBIT, the rest PRESENTED. It is set in transformation by SOURCE_TABLE, because the build was transformation-only (Q-01) and these lanes' staging states no convention (Q-11).
- **Unchanged:** no staging, key or seeder change. No classification row changed and nothing was re-seeded.
- **Found at M1:**
  - the ledger is the Daily Income Journal, booked by debit and credit, and restates monthly revenue with the sign inverted;
  - daily equals monthly Actuals in 99.9% of site-account-months. The "~12%" figure was a grain artefact: daily PERIOD_END is the business date.

## Results reported by the owner (DEV1)
- **D-47 master merge:** 0 inserted, 5 updated.
  - The 5 are 2 PEREGRINE labor keys, Unclassified -> Statistic / DAILY_LABOR under the build 18 rule; these pre-date this build.
  - The other 3 are PEREGRINE department-115 keys at CAYRDOP and CABRDOP. Their DEPARTMENT_NAME was refreshed from HEALTH CLUB REVENUE to PARKING SALARY: the source dictionary relabelled department 115 between DEV1's 11-06 seed and the 11-16 reload.
  - **Why 5, not the 3 expected at stop 4:** the stop-4 count compared SEED_SOURCE, which the merge script does not compare, and omitted the three attribute columns it does compare (ACCOUNT_DESC, ASSET_NAME, DEPARTMENT_NAME). Corrected before the merge ran (findings/M6.md). The KSL seed-note key (170 / 000-3970-000) was correctly left alone.
- **CLN.UTIL.SPROC_PROMOTE:** 203 procedures, 16 classification-source swaps, 2 lanes with no classification.
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 18 lanes, 55 MAINs, 0 new keys.
- **Lines conserved:**
  - KSL 17,023,201 before and after (16,466,152 fact + 557,049 pacing).
  - PEREGRINE 4,112,808 before and after (3,488,989 fact + 623,819 pacing).
- **Income statement stream:** KSL 3,021,928 -> 1,076,022; PEREGRINE 1,279,399 -> 598,413. Both new figures equal this build's final run in DEV_G2M_AI.
- **reconcile_KSL_SELECT_SERVICE_DEV1 and reconcile_PEREGRINE_RESORTS_DEV1:** 0 failures each.

## Build figures (DEV_G2M_AI)

| Lane | Revenue before -> after | EBITDA before -> after | Revenue ties (TOTOPRV) | EBITDA ties |
|---|---|---|---|---|
| KSL | 1,071.3M -> 834.0M | -57.1M -> 271.3M | 516 -> 1,262 of 1,391 | 10 -> 1,015 of 1,398 |
| PEREGRINE | 2,126.1M -> 1,102.9M | 225.2M -> 153.2M | 7 -> 184 of 186 | 0 -> 135 of 186 |

GOP is unanchored (N-68). By lane and year: findings/M6.md.

- **Checks:**
  - parity 203/203;
  - check 2 all 0, except PEREGRINE 2(e) 18,334 rows: "Budget 4" / "Budget 5", UNRESOLVED_CATEGORY, accepted as data-driven, pending Gary (N-21);
  - reconciles 0 failures;
  - check 5: 16 other lanes, 302 objects, 0 differences; the rebuilt lanes identical across runs B, C and D (54 objects);
  - check 6 passed twice.

## Open items
- **N-68:** TOTGOP does not tie GOP. Current in `docs/open-items.md`.
- **N-21:** Budget 4 / 5. Still open with Gary.
- **N-22:** KSL block 86. Unchanged.
