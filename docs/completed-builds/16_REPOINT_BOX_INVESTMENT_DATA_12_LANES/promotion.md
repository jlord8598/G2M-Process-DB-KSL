# Build 16 promotion (owner, 2026-11-10)

Build 16: repoint the 12 CLN.BOX_INVESTMENT_DATA lanes (ALTERRA, ATLANTIC_AVIATION, BEAUMIER, DAVIDSON, HERSHA, HHG, INVITED_CLUBS, JW_VENICE, NEWBURY, OUTRIGGER, THE_PIG, UNDER_CANVAS) from the old-name compatibility views to the source's renamed tables (2026-11-10 rename). SOURCE_TABLE carries the new names (Q-01 b), so 45 downstream literals changed (24 transformation, 21 seeder). The JW FCAST and PIG pace pairs became one table each. The HERSHA view filters were kept as a one-build exception (Q-02; N-36, N-37). The four join literals were renamed so dictionary fill matches the pre-rename baselines (Q-03 a). Freeze from 11:58:29 PST to 22:00 PST; 61 / 61 tables unchanged at every check. Stop 4 approved.

## Results reported by the owner

- **D-47 master merge:** 58 inserted (DAVIDSON 57, HHG 1), 0 updated (= stop 4 / Q-06 expectation; all first seen in the pre-repoint view run, new source data).
- **CLN.UTIL.SPROC_PROMOTE:** 155 procedures moved; 12 classification-source swaps; 2 lanes with no classification.
- **CLN.UTIL.SPROC_RUN_PIPELINE('DEV1'):** 14 lanes, 43 MAINs; 197 new master keys (KSL_SELECT_SERVICE 147, PEREGRINE_RESORTS 50).
- **DEV1 reconcile (`reconcile_ALL_DEV1.sql`):** TOTAL FAILURES 0 across all 12 lanes.

Note: the 197 new keys are in the two lanes build 16 did not touch. In DEV_G2M_AI those lanes hashed identical to the M2 baseline (52 / 52), so the new keys come from DEV1's own run of those lanes, not from this build. Worth checking against KSL_SELECT_SERVICE / PEREGRINE_RESORTS's source before the next build of either.

## Build figures (stop-4 memos)

- Semantic = today's view run on 207 / 207 objects (Q-03 columns excepted on the four join models).
- Keys: every existing key reproduced, 0 new, 0 dead in DEV_G2M_AI; classification rows identical to the view run.
- Checks 1-6 pass in all 12 lanes; parity 155, self-test 6 / 6; run A = run B 208 / 208.

## Scripts archived with this build

`run_build.sql`, `reconcile_{12 lanes}.sql`, `reconcile_ALL_DEV1.sql`, `d43_check.sql`, `build16_hashes.sql`, `earlier_build_hashes.sql`, `build16_m3_proof.sql`, `build16_m3_checks13.sql`, `build16_m6_viewrun_proof.sql`.

## CLAUDE.md changes applied

D-48 and D-50 table names updated to the new names; the JW_VENICE D-48 rule reworded for the merged FCAST table (`claude-md-diff.md`).

## Open items raised

N-36 (HERSHA budget-only rows not staged), N-37 (HERSHA non-preferred stat rows not staged), N-38 (seeder MIN(source_table) tie-break depends on name sort order).
