# Build 21 promotion (owner, 2026-11-13)

Build 21: D-44 rebuilds of THE_PIG and DAVIDSON. Gary's freeze held: 16 / 16 tables at every check.
- **THE_PIG:** the P&L lane is added.
  - CLN_PIG_HOTELS_FIN_PL_MONTHLY, x2 actual / forecast (budget not in landed data, N-54), and REF_ACCOUNTS.
  - 1,044 keys, classified by line code: rent, property taxes and insurance Below the Line (USALI, as the peer lanes); the "Total ..." lines are detail; Occupancy % a non-additive statistic.
  - Currency GBP. Pacing is unchanged.
- **DAVIDSON:** descriptions only.
  - The account mapping is CLN_DAVIDSON_REF_ACCOUNT_MAPPING (identical to the retired REF_ACCOUNT_LOOKUP), plus the six segment tables.
  - Order (Q-11): exact mapping text, then segment-built (segment-table name, else mapping name, else raw code), then REF_ACCOUNTS. REF_ACCOUNTS now carries only the ledger name.
  - Only 5 budget placeholders (60 lines) stay blank.

Stop 4 approved.

## Results reported by the owner (DEV1)
- **D-47 master merge:** THE_PIG 1,044 inserted / 0 updated; DAVIDSON 0 / 0. This equals the stop-4 expectation.
- **CLN.UTIL.SPROC_PROMOTE:** 170 procedures, 13 classification-source swaps, 1 lane with no classification (OUTRIGGER; THE_PIG now has keys).
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 8 new keys (the normal KSL / PEREGRINE daily pickup).
- **reconcile_THE_PIG_DEV1.sql and reconcile_DAVIDSON_DEV1.sql:** 0 failures each.
- **Retired:** SPROC_STG_DAVIDSON_ACCOUNT_LOOKUP and STG_DAVIDSON_ACCOUNT_LOOKUP were dropped in DEV1 by hand.

## Build figures (DEV_G2M_AI, M6)
- **THE_PIG semantic:** ACTUAL and FORECAST +12,144 each; OPERATING_METRICS +768. Actual revenue 46,526,571.91 GBP; expense 28,753,924.33.
- **DAVIDSON:** 60 of 1,037,604 semantic lines without a description; FULL_YEAR_PL -1,524 x 2 from the 11-13 reload.
- **Proof:** 251 objects (12 other lanes + THE_PIG pacing) identical; run A = run B = final.

## Scripts archived
`run_build.sql`, `d43_check.sql`, `build21_hashes.sql`, `build21_rebuilt_hashes.sql`, `build21_davidson_hashes.sql`, `build21_check2.sql`, `reconcile_THE_PIG.sql`, `reconcile_DAVIDSON.sql` and their `_DEV1` copies.

## CLAUDE.md changes
None.

## Runbook
`Claude outputs/pipeline-status-2026-10-22.md` step 2 now states the expected SPROC_PROMOTE counts: 170 procedures, 13 of 13 swaps, 1 lane with no classification.

## Open items
- N-49 updated: only the 5 budget placeholders remain, not in landed data.
- Added: N-52 (Davidson FIN_BUDGET_SUMMARY not staged), N-53 (The Pig in the Cotswolds Sep tie-out) and N-54 (The Pig budget not in landed data).
