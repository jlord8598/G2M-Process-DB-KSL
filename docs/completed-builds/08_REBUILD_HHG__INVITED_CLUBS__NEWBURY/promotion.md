# Build 08 - promotion record (HHG, INVITED_CLUBS and NEWBURY rebuilt, D-44)

Promotion is done by the owner, outside the build (CLAUDE.md section 7). The
results below are **as reported and verified by the owner**. The build
agent's role has no access to DEV1, so it could not verify them
independently.

| Step | Result (owner) |
|---|---|
| D-47 guarded master merge (`Claude outputs/MASTER_MERGE_D47.sql`) | **0 inserted, 113,858 updated**, each archived to `KSL_MASTER_ACCOUNT_HIERARCHY_HISTORY` first. The build re-seeded INVITED_CLUBS 113,849 + NEWBURY 9 = 113,858 keys (M4), and no key was new. |
| `CLN.UTIL.SPROC_PROMOTE` | **101 of 101** procedures verified, equal to the 101 deployed in `DEV_G2M_AI` at M6. |
| `CLN.UTIL.SPROC_RUN_PIPELINE` | Run. |
| Reconcile in DEV1 (`reconcile_{HHG,INVITED_CLUBS,NEWBURY}.sql` against DEV1) | **0 failures** for all three lanes. |

**Source changed inside the freeze (owner).**
- **`CLN_HERITAGE_GOLF_ROUNDS_DETAIL` was reloaded** at 2026-10-30 12:57 PDT,
  inside the freeze, which ended 13:27.
- **The NEWBURY operating-stats tables also grew.**
- **The build's figures describe the extract held at M6.** The last D-43 check
  was on 2026-10-28 (22 tables, 0 altered), before the reload.
- **DEV1 reconciles to the new data**, because the pipeline was run after the
  reload.
- **The owner has raised the reload with the source owner.**

**State at promotion.**
- **Build approved at stop 4.**
- **HHG:** `ACCOUNT_DESC` and `DEPARTMENT_NAME` come from
  `CLN_HERITAGE_GOLF_ACCOUNTS`. `PARENT_CODE` is carried in staging only.
- **INVITED_CLUBS:**
  - the A6 block mapping applies to 113,849 keys, with A63699 left
    UNCLASSIFIED;
  - `Ind-Total*` rows are flagged `IS_SUBTOTAL`;
  - `UNKNOWN_REASON` is split into SOURCE_ROLLUP, PLANNING_INPUT,
    DUPLICATE_DETAIL and UNCLASSIFIED_ACCOUNT;
  - the 14 Q-12 accounts and A63699 are for the business to spot-check.
- **NEWBURY:** 8 accounts moved to Depreciation & Amortization and 1 to Income
  Taxes.

**Commits.**
- `79630bb`: the build, M1-M6.
- This archive follows in the commit "Archive build 08".
