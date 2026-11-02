# Build 09 - promotion record (INVITED_CLUBS rebuilt, D-44)

Promotion is done by the owner, outside the build (CLAUDE.md section 7). The
results below are **as reported and verified by the owner**. The build
agent's role has no access to DEV1 and could not verify them.

| Step | Result (owner) |
|---|---|
| D-47 guarded master merge | **0 inserted, 24,139 updated.** The build re-seeded 23,984 keys (M4). Owner: the other 155 are keys the DEV1 run of 2026-10-30 had inserted into the master under the old rules, which the build seeded new under the build 09 rules. |
| `CLN.UTIL.SPROC_PROMOTE` | **101 procedures moved, 8 swaps.** That equals the 101 deployed in `DEV_G2M_AI` at M6. |
| `CLN.UTIL.SPROC_RUN_PIPELINE('DEV1')` | Ran clean. It added **69 new keys** to the master: KSL 46, Peregrine 23. Neither lane was in this build. |
| Reconcile in DEV1 | **0 failures.** |

**State at promotion:**
- **Approval:** stop 4 approved, including the D-44 amendment (METRIC_UNIT
  and AGGREGATION_TYPE are re-seedable; CLAUDE.md and AGENTS.md).
- **INVITED_CLUBS ACTUAL H2 Revenue** is A4 GL only: 2023 1,441,640,558.55;
  2024 1,486,447,090.44; 2025 1,471,447,778.69; 2026 to Oct
  1,249,903,154.69.
- **Other Income / (Expense)** is +230,006,420.33, from the 36 A50 accounts
  (Q-16). They are listed for business review in `findings/M4.md`.
- **The source was reloaded inside the freeze** (13:22-13:23) and
  re-baselined with `HASH_AGG(*)` (Q-14). Every M1 figure re-ran identically.
- **Build 08 rows changed value in this extract** (Q-15). They were accepted
  as new source data.

**Carried forward** to `docs/open-items.md`:
- N-1 (future-period ACTUAL changes);
- N-2 (ACCOUNTS not unique on entity + account);
- Q-09 (Covers members).

**Commits:** the build and this archive are committed together, in one
commit.
