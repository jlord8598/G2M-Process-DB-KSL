# Table usage (build 18)

| Table | Read by | Use |
|---|---|---|
| CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR | SPROC_STG_KSL_SELECT_SERVICE_DAILY_LABOR | every column; AMOUNTS -> SOURCE_AMOUNT, HOURS -> STAT_VALUE |
| CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR | SPROC_STG_PEREGRINE_RESORTS_DAILY_LABOR | same |
| STG_<LANE>_DEPARTMENTS, STG_<LANE>_SITES (staged 11-04) | the two labor models | DEPARTMENT_NAME, ASSET_NAME fallback |
| every other KSL / PEREGRINE CLN.CLEAN table | not read by this build | staged 11-04, unchanged (owner Q-02) |

CUR_PROFITSWORD_DEPARTMENTS was frozen as agreed but not read directly: the labor models read its staged copy.
