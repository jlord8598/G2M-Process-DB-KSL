# Table usage - build 02 (HHG, NEWBURY)

**The question: how were the tables wired?** Every table in
`CLN.BOX_INVESTMENT_DATA` (15 listed at M1; all in scope, none out of scope),
with the procedure that reads it and the columns each downstream procedure
uses. No table is unused.

## HHG

| CLN table | Read by | Staged as | Then read by | Columns used downstream |
|---|---|---|---|---|
| `CLN_HERITAGE_GOLF_TR12_DATA` | `SPROC_STG_HHG_TR12_DATA` | `STG_HHG_TR12_DATA` (fact) | `SPROC_XREF_ACCOUNT_CLASSIFICATION` (HHG branch); `SPROC_XFRM_HHG` | seeder: key parts, `ACCOUNT_NUMBER` (digit), `SOURCE_TABLE`, attributes; XFRM: common block, `SCENARIO` (category) |
| `CLN_HERITAGE_GOLF_FORECAST_ANAPLAN` | `SPROC_STG_HHG_FORECAST_ANAPLAN` | `STG_HHG_FORECAST_ANAPLAN` (fact) | same two | seeder: `ACCOUNT_KEY` (= `LINE_ITEM`) against the Q-04 map, `SOURCE_TABLE`; XFRM: `SCENARIO` |
| `CLN_HERITAGE_GOLF_ROUNDS_DETAIL` | `SPROC_STG_HHG_ROUNDS_DETAIL` | `STG_HHG_ROUNDS_DETAIL` (fact) | same two | seeder: `RECORD_TYPE`, `SOURCE_TABLE`; XFRM: `SOURCE_TABLE` (category) |
| `CLN_HERITAGE_GOLF_ACCOUNTS` | `SPROC_STG_HHG_ACCOUNTS`; **also** `SPROC_STG_HHG_TR12_DATA` | `STG_HHG_ACCOUNTS` (dictionary) | none downstream of staging | `SPROC_STG_HHG_TR12_DATA` reads `FULL_ACCOUNT_STRING`, `ACCOUNT_DESCRIPTION` for `ACCOUNT_DESC` (null on every TR12 string, Q-02) |
| `CLN_HERITAGE_GOLF_CLUB_LIST` | `SPROC_STG_HHG_CLUB_LIST`; **also** `SPROC_STG_HHG_ROUNDS_DETAIL` | `STG_HHG_CLUB_LIST` (dictionary) | none | `SPROC_STG_HHG_ROUNDS_DETAIL` reads `CLUB_CODE`, `CLUB_NAME` for `ASSET_NAME` |
| `CLN_HERITAGE_GOLF_REFERENCES` | `SPROC_STG_HHG_REFERENCES` | `STG_HHG_REFERENCES` (dictionary) | **none** | Staged losslessly; nothing reads it. `CLUB_NUMBER` is the TR12 entity, but the owner ruled site keys as written (Q-03), so no model joins it. 9 TR12 entities are absent from it. |

## NEWBURY

| CLN table | Read by | Staged as | Then read by | Columns used downstream |
|---|---|---|---|---|
| `CLN_NEWBURY_BOSTON_TRIAL_BALANCE` | `SPROC_STG_NEWBURY_TRIAL_BALANCE` | `STG_NEWBURY_TRIAL_BALANCE` (fact, x3) | seeder (NEWBURY branch); `SPROC_XFRM_NEWBURY` | seeder: key parts, `ACCOUNT_NUMBER` (digit), `STAT_UNIT_FAMILY` (H2 of STAT keys); XFRM: common block, `MEASURE_COLUMN` (category) |
| `CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT` | `SPROC_STG_NEWBURY_OPERATING_STATS_BGT` | `STG_NEWBURY_OPERATING_STATS_BGT` (fact) | same two | seeder: key parts (one `~BLANK~` key, Q-19); XFRM: `SCENARIO` |
| `CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT` | `SPROC_STG_NEWBURY_OPERATING_STATS_PYACT` | `STG_NEWBURY_OPERATING_STATS_PYACT` (fact) | same two | as BGT |
| `CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST` | `SPROC_STG_NEWBURY_OPERATING_STATS_FCST` | `STG_NEWBURY_OPERATING_STATS_FCST` (pacing) | `SPROC_XFRM_NEWBURY` (pacing) | own columns; `FILE_REPORT_DATE` as `AS_OF_DATE`. Never read by the seeder (D-37). |
| `CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS` | `SPROC_STG_NEWBURY_OPERATING_STATS_SHOPS` | `STG_NEWBURY_OPERATING_STATS_SHOPS` (pacing) | `SPROC_XFRM_NEWBURY` (pacing) | own columns; `REPORTED_DATE` as `AS_OF_DATE` (Q-13, Q-20) |
| `CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP` | `SPROC_STG_NEWBURY_OTB_1DAY_PICKUP` | `STG_NEWBURY_OTB_1DAY_PICKUP` (pacing) | `SPROC_XFRM_NEWBURY` (pacing) | own columns; `REPORT_DATE` as `AS_OF_DATE` |
| `CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP` | `SPROC_STG_NEWBURY_OTB_3DAY_PICKUP` | `STG_NEWBURY_OTB_3DAY_PICKUP` (pacing) | `SPROC_XFRM_NEWBURY` (pacing) | as 1DAY. 16,908 rows are identical to 1DAY rows; both kept (Q-16). |
| `CLN_NEWBURY_BOSTON_ACCOUNTS` | `SPROC_STG_NEWBURY_ACCOUNTS`; **also** `SPROC_STG_NEWBURY_TRIAL_BALANCE` | `STG_NEWBURY_ACCOUNTS` (dictionary) | none | `SPROC_STG_NEWBURY_TRIAL_BALANCE` reads `FULL_ACCOUNT_STRING`, `ACCOUNT_DESCRIPTION`, `DEPARTMENT_DESCRIPTION` |
| `CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO` | `SPROC_STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO` | `STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO` (dictionary) | **none** | Staged losslessly (owner Q-12: a dictionary). No model joins it; it describes dates, not accounts. |

## A wiring note against CLAUDE.md

**Three fact staging models read a CLN dictionary directly:**
- `SPROC_STG_HHG_TR12_DATA` reads `ACCOUNTS`.
- `SPROC_STG_HHG_ROUNDS_DETAIL` reads `CLUB_LIST`.
- `SPROC_STG_NEWBURY_TRIAL_BALANCE` reads `ACCOUNTS`.

They do so only to fill `ACCOUNT_DESC`, `DEPARTMENT_NAME` and `ASSET_NAME`,
the pattern build 01's staging used. The seed reads `STAGING` only, as §3
requires: every dictionary is also staged, and neither seeder branch reads
CLN.

## Shared objects this build added to

| Object | Change |
|---|---|
| `XREF_SNAPSHOT.SPROC_XREF_ACCOUNT_CLASSIFICATION` | `HHG` and `NEWBURY` branches |
| `XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION` | 15,369 HHG + 782 NEWBURY rows |
| `SEMANTIC.SPROC_SEM_AI_*` (6) | `HHG` and `NEWBURY` lane blocks |

Every earlier-build object is unchanged: 42 of 42 hashes equal the pre-M2
baseline (M6.md).
