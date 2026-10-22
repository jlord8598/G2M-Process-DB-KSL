# Table usage - build 03 (HERSHA, INVITED_CLUBS, BEAUMIER)

**The question: how were the tables wired?** Every table in
`CLN.BOX_INVESTMENT_DATA`: 29 listed at M1, of which 14 are in scope and 15
out of scope.

## In scope

| CLN table | Read by | Staged as | Then read by (column) |
|---|---|---|---|
| `CLN_HERSHA_GL_ACTUAL` | `SPROC_STG_HERSHA_GL_ACTUAL` | `STG_HERSHA_GL_ACTUAL` (fact, x2) | seeder HERSHA branch (key parts, `ACCOUNT_NUMBER` digit); `SPROC_XFRM_HERSHA` (common block, `MEASURE_COLUMN` -> category) |
| `CLN_HERSHA_GL_STAT` | `SPROC_STG_HERSHA_GL_STAT` | `STG_HERSHA_GL_STAT` (fact, x2) | same two (`RECORD_TYPE` STATISTIC; `MEASURE_COLUMN`) |
| `CLN_HERSHA_ACCOUNTS` | `SPROC_STG_HERSHA_ACCOUNTS` | `STG_HERSHA_ACCOUNTS` (dict) | **none.** It states only descriptions, which the facts carry themselves; it is the evidence for Q-03. |
| `CLN_INVITED_CLUBS_ESSBASE_EXTRACT` | `SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT` | `STG_INVITED_CLUBS_ESSBASE_EXTRACT` (fact, x3) | seeder INVITED_CLUBS branch (key parts, `META_ACCOUNT_TYPE`, `ACCOUNT_NUMBER` A-digit); `SPROC_XFRM_INVITED_CLUBS` (common block, `MEASURE_COLUMN`) |
| `CLN_INVITED_CLUBS_META_ACCOUNT` | `SPROC_STG_INVITED_CLUBS_META_ACCOUNT` | `STG_INVITED_CLUBS_META_ACCOUNT` | `SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT` reads `ACCOUNT`, `ACCOUNT_TYPE`, `DATA_TYPE`, `ALIAS_DEFAULT` (from STAGING) |
| `CLN_INVITED_CLUBS_META_ENTITY` | `SPROC_STG_INVITED_CLUBS_META_ENTITY` | `STG_INVITED_CLUBS_META_ENTITY` | ESSBASE model reads `ENTITY`, `ALIAS_DEFAULT` -> `ASSET_NAME` |
| `CLN_INVITED_CLUBS_META_DEPARTMENT` | `SPROC_STG_INVITED_CLUBS_META_DEPARTMENT` | `STG_INVITED_CLUBS_META_DEPARTMENT` | ESSBASE model reads `DEPARTMENT`, `ALIAS_DEFAULT` -> `DEPARTMENT_NAME` |
| `CLN_INVITED_CLUBS_META_LOCATION` | `SPROC_STG_INVITED_CLUBS_META_LOCATION` | `STG_INVITED_CLUBS_META_LOCATION` | **none.** `LOCATION` is not in the key (Q-10); carried raw on the fact. |
| `CLN_INVITED_CLUBS_META_SUBACCOUNT` | `SPROC_STG_INVITED_CLUBS_META_SUBACCOUNT` | `STG_INVITED_CLUBS_META_SUBACCOUNT` | **none** (same) |
| `CLN_INVITED_CLUBS_ACCOUNTS` | `SPROC_STG_INVITED_CLUBS_ACCOUNTS` | `STG_INVITED_CLUBS_ACCOUNTS` | **none.** It repeats `META_ACCOUNT`. |
| `CLN_BEAUMIER_BP` | `SPROC_STG_BEAUMIER_BP` | `STG_BEAUMIER_BP` (fact) | seeder BEAUMIER branch (`ACCOUNT_KEY`, `PL_SECTION`, `PL_LINE`, `EBITDA_GROUP`); `SPROC_XFRM_BEAUMIER` (`SOURCE_TABLE`, `SCENARIO` -> category) |
| `CLN_BEAUMIER_BUDGET` | `SPROC_STG_BEAUMIER_BUDGET` | `STG_BEAUMIER_BUDGET` (fact) | same two |
| `CLN_BEAUMIER_CANCELLATIONS` | `SPROC_STG_BEAUMIER_CANCELLATIONS` | `STG_BEAUMIER_CANCELLATIONS` (pacing) | `SPROC_XFRM_BEAUMIER` (all columns -> `XFRM_BEAUMIER_PACING`; `BUSINESS_DATE` -> `AS_OF_DATE`). Never read by the seeder (D-37). |
| `CLN_BEAUMIER_ACCOUNTS` | `SPROC_STG_BEAUMIER_ACCOUNTS` | `STG_BEAUMIER_ACCOUNTS` | **none.** The line item names are on the facts. |

**Reads flow downhill.** The ESSBASE model reads its META dictionaries from
**STAGING**, not CLN. No seeder branch reads CLN.

## Out of scope (owner, stop 1)

| Tables | Why |
|---|---|
| `CLN_HERITAGE_GOLF_*` (6): `ACCOUNTS`, `CLUB_LIST`, `FORECAST_ANAPLAN`, `REFERENCES`, `ROUNDS_DETAIL`, `TR12_DATA` | Build 02 (lane HHG). Not read by this build. |
| `CLN_NEWBURY_BOSTON_*` (9): `ACCOUNTS`, `OPERATING_STATS_BGT`, `_EVENTSANDOOO`, `_FCST`, `_PYACT`, `_SHOPS`, `OTB_1DAY_PICKUP`, `OTB_3DAY_PICKUP`, `TRIAL_BALANCE` | Build 02 (lane NEWBURY). Not read by this build. |

## Shared objects this build added to

| Object | Change |
|---|---|
| `SPROC_XREF_ACCOUNT_CLASSIFICATION` | 3 branches; 430 insertions, 0 deletions |
| `XREF_ACCOUNT_CLASSIFICATION` | 1,196 + 225,833 + 1,178 rows |
| `SPROC_SEM_AI_*` (6) | 3 lane blocks each; 681 insertions, 0 deletions |

Earlier builds are unchanged: 88 of 88 hashes equal the pre-M2 baseline.
