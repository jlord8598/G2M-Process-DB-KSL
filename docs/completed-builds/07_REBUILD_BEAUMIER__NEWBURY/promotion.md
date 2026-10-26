# Build 07 - promotion record (BEAUMIER and NEWBURY rebuilt, D-44)

Promotion is done by the owner, outside the build (CLAUDE.md section 7). The
results below are **as reported and verified by the owner** on 2026-10-26. The
build agent's role has no access to DEV1, so it could not verify them
independently.

| Step | Result (owner) |
|---|---|
| Master insert (`CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`) | **0 new keys**, as expected. Both lanes were rebuilt (D-44): at M6, BEAUMIER reproduced 1,178 of 1,178 keys and NEWBURY 782 of 782, with 0 new, 0 dead and 0 moved. |
| `CLN.UTIL.SPROC_PROMOTE` | **101 of 101** procedures verified. That equals the 101 deployed in `DEV_G2M_AI` at M6, which includes the new `SPROC_STG_BEAUMIER_LOCATION_MAP`. |
| `CLN.UTIL.SPROC_RUN_PIPELINE` | **8 lanes, 25 MAINs**. The BEAUMIER and NEWBURY streams are identical to the build. |
| Reconcile in DEV1 (`reconcile_{BEAUMIER,NEWBURY}.sql` with `DEV_G2M_AI.` replaced by `DEV1.`) | **0 failures** for BEAUMIER and NEWBURY. |

**State at promotion.**
- **Build approved at stop 4.**
- **BEAUMIER:** `ASSET_NAME` is filled on 100% of BP rows (35,567) and BUDGET
  rows (17,577), from `CLN_BEAUMIER_LOCATION_MAP`. The new
  `ASSET_NAME_SOURCE` column records the source.
- **NEWBURY:** `TRIAL_BALANCE` `SCENARIO` nulls went from 46,087 to 0 (D-45).
- **Q-06 accepted:** no stream-level rest hash was taken before M3. The rule
  for future rebuilds was added to `CLAUDE.md` under D-44.

**Commits.**
- `9a6e29d`: the build, M1-M6.
- `f7fcd1c`: stop 1.
- `445d841`: in-progress milestones.
- This archive follows in the commit "Archive build 07".
