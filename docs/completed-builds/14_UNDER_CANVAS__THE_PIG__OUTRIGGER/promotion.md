# Build 14 promotion (owner, 2026-11-06)

Build 14: new lanes UNDER_CANVAS, THE_PIG, OUTRIGGER from CLN.BOX_INVESTMENT_DATA (12 tables). UNDER_CANVAS: P&L detail with D-46 block mapping (owner Q-07) and the D-48 rule CONSOLIDATED_PL -> DUPLICATE_DETAIL (Q-04); currency USD. THE_PIG (GBP) and OUTRIGGER (USD): pacing-only (Q-06), PACING stream only, no classification keys, no semantic block. Stop 4 approved, including the D-48 text (applied to CLAUDE.md).

## Results reported by the owner

- **D-47 master merge:** 2,725 inserted, 0 updated (= stop 4 expectation; master 369,451 -> 372,176).
- **CLN.UTIL.SPROC_PROMOTE:** 153 procedures moved; 12 classification-source swaps; 2 lanes with no classification (THE_PIG, OUTRIGGER).
- **CLN.UTIL.SPROC_RUN_PIPELINE('DEV1'):** 14 lanes, 43 MAINs, 0 new keys.
- **DEV1 reconcile:** 0 failures for UNDER_CANVAS, THE_PIG and OUTRIGGER.

## Promotion procedure fixes (pacing-only lanes)

Fixed copies in `Claude outputs/`; the previous versions are in `Claude outputs/archive/` (`SPROC_PROMOTE_build13.sql`, `SPROC_RUN_PIPELINE_build13.sql`).

- **SPROC_PROMOTE.sql:** a TRANSFORMATION lane procedure that names no classification table (neither XREF_ACCOUNT_CLASSIFICATION nor KSL_MASTER_ACCOUNT_HIERARCHY) is counted separately as a lane with no classification and needs no swap; every procedure that names one must still swap exactly once. The result string adds "lanes with no classification N".
- **SPROC_RUN_PIPELINE.sql:** lanes are the distinct master SOURCE_LANE values UNION every `SPROC_XREF_{LANE}_MAIN()` in the target's XREF_SNAPSHOT schema, so pacing-only lanes (no master keys) run. Lanes come only from the master and this process's own XREF MAINs, so another team's STAGING / TRANSFORMATION lane in the same database (TRUSTYOU in DEV1) is never picked up.

## Build figures (stop-4 memos)

- GOP tie-out YTD 2026-09 exact: Sales 52,992,340.16, GOP 27,575,053.88; per department labor and controllables exact.
- Classification keys: 2,725 UNDER_CANVAS (126 dictionary-gap keys classified by block).
- Open items raised: N-25 (below-GOP lines, no monthly detail), N-26 (CONSOLIDATED_PL lines 139-153 mis-parsed), N-27 (OUTRIGGER V1 / V2 property map), N-28 (10 sign-test accounts, business review).
