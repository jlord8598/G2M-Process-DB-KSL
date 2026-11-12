# Build 20 promotion (owner, 2026-11-12)

Build 20, FIX_DAVIDSON_DESC: a D-44 rebuild of DAVIDSON, descriptions only (N-49). ACCOUNT_DESC is filled in staging from CLN_DAVIDSON_REF_ACCOUNT_LOOKUP:
1. the existing REF_ACCOUNTS description wins;
2. else LOOKUP_EXACT (exact account string);
3. else SEGMENT_BUILT (segment names);
4. else null; ACCOUNT_DESC_SOURCE carries the tag.

- **Retired rule:** a line or name saying RETIRED or DO NOT USE, or starting zDNU, is chosen last, then the first alphabetically.
- **Format:** ledger | cost center | revenue category | sales item | spend category | labor type.
- **Unchanged:** keys, amounts, routing and classification (no re-seed, Q-02). Gary's freeze (to 22:00 MT) held: 6 / 6 at every check. Stop 4 approved.

## Results reported by the owner (DEV1)
- **D-47 master merge:** 0 inserted, 0 updated, as expected at stop 4.
- **CLN.UTIL.SPROC_PROMOTE:** 162 procedures, 12 classification-source swaps.
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 0 new keys.
- **reconcile_DAVIDSON_DEV1.sql:** 0 failures.
- **DEV1 blank Davidson descriptions, SEM_AI_INCOME_STATEMENT_ACTUAL:** 113,568 -> 5,028, the same as in DEV_G2M_AI.

## Build figures (DEV_G2M_AI, M6)
- **Semantic Davidson blank lines:** 557,604 -> 129,132.
- **Keys filled:** AMOUNT 9,391 (8,878 exact + 513 segment-built); STATISTIC 859 (756 + 103).
- **Proof:** every Davidson object identical to M2 excluding the description columns; the 13 other lanes' 261 objects identical; run A = run B = final.

## Scripts archived
`run_build.sql`, `d43_check.sql`, `build20_hashes.sql`, `build20_davidson_hashes.sql`, `build20_check2.sql`, `reconcile_DAVIDSON.sql` and `reconcile_DAVIDSON_DEV1.sql`.

## CLAUDE.md changes
None. The rule lives in the two staging models and in this build's sources.md.

## Open items
N-49 updated: what stays blank is "not in landed data":
- labor-hour / utility statistic codes, 558 strings;
- non-six-segment keys, 175;
- retired or prefixed cost centers, 65;
- other codes the lookup lacks, 117.
