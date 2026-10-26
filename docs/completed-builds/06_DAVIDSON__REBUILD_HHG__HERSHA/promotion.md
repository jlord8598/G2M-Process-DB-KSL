# Build 06 - promotion record (DAVIDSON new; HHG and HERSHA rebuilt)

Promotion is done by the owner, outside the build (CLAUDE.md section 7). The
results below are **as reported by the owner** on 2026-10-23. The build
agent's role has no access to DEV1 (query
`01c7fd95-010a-58c5-0003-4ff21beed6c2`: `SHOW DATABASES LIKE 'DEV1'` returns
no rows), so it could not verify them independently.

| Step | Result (owner) |
|---|---|
| Master insert (`CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`) | **31,785 DAVIDSON keys** inserted. That equals the DAVIDSON classification rows in `DEV_G2M_AI` at M6. HHG and HERSHA were rebuilt (D-44) with 0 new keys, so they add none. |
| `CLN.UTIL.SPROC_PROMOTE` | **100 of 100** procedures verified. That equals the 100 deployed in `DEV_G2M_AI` at M6. |
| `CLN.UTIL.SPROC_RUN_PIPELINE` | **8 lanes, 25 MAINs**: 8 x 3 per-source MAINs + `SPROC_SEM_AI_MAIN`. |
| Reconcile in DEV1 (`reconcile_{DAVIDSON,HHG,HERSHA}.sql` with `DEV_G2M_AI.` replaced by `DEV1.`) | **0 failures** for DAVIDSON, HERSHA and HHG. |

**State at promotion.**
- **Build approved at stop 4.**
- **Q-11 closed:** `Utilities` stays under `Operating Expenses`; no new H2.
- **9201** approved as STATISTIC.
- **For the business (master H2):** 17,182 DAVIDSON PL department-section
  keys are `Unclassified` by design (`findings/open-questions.md`).
- **Q-07 and Q-09** are decided by the owner from data; the source owner is
  to confirm.

**Commits.**
- `eda2735`: the build, M1-M6.
- `c3d727a`: work in progress at M3.
- This archive follows in the commit "Archive build 06".
