# Build 16: resume after the lost connection (session 2, 2026-11-10)

## What had completed (query history and files)
- Run A and Run B of `scripts/run_build.sql` both completed. Run B ran 14:12:30 to 14:18:30 PST; its hash statement ran 14:18:33 to 14:25:06 PST, and `check5_build16_runB.csv` (208 objects) was saved from it. File timestamps are in local MST (one hour ahead of PST).
- Run A = Run B on all 208 objects (content and rest hashes): 0 differ.
- No M4 or M5 memo was written. Nothing ran against the database after 14:25:06 PST until this session.
- **M3.md holds only the Q-03 (a) addendum (1,292 bytes).** The main staging memo appears to have been overwritten by it. The file is untracked, so git cannot recover it. The supporting CSVs (`M3_proof.csv`, `check5_build16_M3.csv`) are intact.

## D-43
15:04:01 PST: 61 / 61 tables unchanged; 416 minutes of freeze left (ends 22:00 PST).

## Run B against the view run, excluding the build's changed columns
`check5_build16_runB.csv` REST_HASH vs `check5_build16_viewrun.csv`: 191 / 207 identical. The 16 that differ are the DAVIDSON and HHG objects carrying the Q-03 columns (STG_DAVIDSON_FULL_YEAR_PL, STG_DAVIDSON_HOTEL_MONTHLY_REPORT, STG_HHG_BUDGET_BY_CLUB, STG_HHG_TR12_DATA and their XFRM / SEM descendants). That is expected under Q-03 (a).

## M6 view-run proof (`scripts/build16_m6_viewrun_proof.sql`)
- **Defect found and fixed.** The script re-inserted ACCOUNT_DESC, DEPARTMENT_NAME and PARENT_CODE with `object_insert(..., t.col::variant, true)`. On a row where the column is null, that drops the key, while the view-run hash (`object_construct_keep_null`) keeps it as JSON null, so every object with a sparse column mismatched. All 308 occurrences now read `coalesce(t.col::variant, parse_json('null'))`.
- The fixed script is run as one statement per lane, plus the lane's classification rows (full content excluding LAST_SEEN_RUN_ID). Results: `M6_viewrun_proof.csv`.

| Lane | Objects | Match view run (rows + hash, unmapped 0) |
|---|---|---|
| ALTERRA | 15 | 15 |
| ATLANTIC_AVIATION | 14 | 14 |
| BEAUMIER | 18 | 18 |
| DAVIDSON | 15 | 15 |
| HERSHA | 16 | 16 |
| HHG | 23 | 23 |
| JW_VENICE | 18 | 18 |
| NEWBURY | 21 | 21 |
| OUTRIGGER | - | **failed: not run** |
| THE_PIG | - | not run |
| UNDER_CANVAS | - | not run |
| INVITED_CLUBS | - | not run |

Total so far: 140 / 140 objects.

## Stop
The OUTRIGGER statement failed with: `Warehouse 'G2M_MCP_AGENT_WH' cannot be resumed because resource monitor 'G2M_MCP_AGENT_RM' has exceeded its quota.` Per the owner's instruction, the build stops at a failed split statement. The quota is outside this role's control. Nothing was retried or routed elsewhere.

The first INVITED_CLUBS attempt (unfixed script, query 01c853ca-030a-a146-0003-4ff21cd62b1a) ran for over 8 minutes and was cancelled once the defect was found. Its credit use likely contributed to the quota.

## Not yet done
M4 to M6 checks (2, 4, 5 classification assertion, 6 at M6), the four review lists, the rebuilt-lane key report write-up (`M4_keys_pre/post.csv` exist: KEYS and LIVE_HASH identical for every lane; CLS_HASH moved on the 10 lanes that ran, consistent with LAST_SEEN_RUN_ID; to be confirmed with a hash excluding it), the CLAUDE.md D-48 / D-50 name updates, the five M6 documents, `reconcile_{LANE}.sql`.
