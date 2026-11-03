# Build 10 - promotion record (HHG and HERSHA rebuilt, D-44)

Promotion is done by the owner, outside the build (CLAUDE.md section 7). The
results below are **as reported and verified by the owner**. The build
agent's role has no access to DEV1 and could not verify them.

| Step | Result (owner) |
|---|---|
| D-47 guarded master merge | **174 inserted, 3,153 updated** (old rows archived to `KSL_MASTER_ACCOUNT_HIERARCHY_HISTORY`). The 174 inserts are HERSHA's TB keys; the build's 7 other new HERSHA keys were already in the master. The 3,153 updates equal the HHG re-seed (M4). |
| `CLN.UTIL.SPROC_PROMOTE` | **106 procedures moved, 8 swaps.** That equals the 106 deployed in `DEV_G2M_AI` at M6. |
| `CLN.UTIL.SPROC_RUN_PIPELINE('DEV1')` | Ran clean. It added **74 new keys** to the master: KSL 14, Peregrine 60. Neither lane was in this build. |
| Reconcile in DEV1 | **0 failures**, HHG and HERSHA. |

**State at promotion:**
- **Approval:** stop 4 approved, including D-48 (source precedence; CLAUDE.md
  sections 3 and 4, check 2(e) amended, new check 2(m)).
- **HHG:** the H2 mapping now follows the chart of accounts (Q-03, Q-04,
  Q-09). ACTUAL income-statement totals are unchanged: 2025 266,916,169.46;
  2026 559,247,232.13 (`findings/M6.md`).
- **HERSHA:** ACTUAL comes from TB at its 12 hotels and from GL at hotels 118,
  149 and 230. FORECAST stays on GL (D-48). ACTUAL revenue is
  -192,165,637.65 (before: -40,830,893.93).
- **Freeze (D-43):** clean at every check through stop 4.

**Carried forward:** `docs/open-items.md`, N-1 to N-7.

**Commits:** the build, the D-48 CLAUDE.md change and this archive are
committed together, in one commit.
