# Table usage (build 23: HICV new; BEAUMIER rebuilt)

**How were the tables wired?** `CLN.BOX_INVESTMENT_DATA` shows 113 tables to G2M_MCP_AGENT (live, 2026-11-16). 18 belong to this build's two lanes, and 95 are out of scope.

## In scope: HICV (8)

| CLN table | Used | Procedure | Columns read | Lands in |
|---|---|---|---|---|
| CLN_HICV_FIN_PL_MONTHLY | yes | SPROC_STG_HICV_PL | every column; measures ACTUAL_AMOUNT, FORECAST_AMOUNT, PREVIOUS_FORECAST_AMOUNT, BUDGET_AMOUNT; key LOCATION_CODE, COST_CENTER_CODE, ACCOUNT_CODE; LINE_DESCRIPTION (parsed) | STG_HICV_PL -> XFRM_HICV_INCOME_STATEMENT -> SEM_AI_INCOME_STATEMENT_ACTUAL / BUDGET / FORECAST |
| CLN_HICV_FIN_GL_MONTHLY | yes | SPROC_STG_HICV_GL | every column; ACTUAL_AMOUNT; key as above; PL_SUB_CATEGORY_1 (seeder H2) | STG_HICV_GL -> XFRM_HICV_UNKNOWN (D-48) -> SEM_AI_UNKNOWN |
| CLN_HICV_REF_ACCOUNTS | yes | SPROC_STG_HICV_ACCOUNTS | every column | STG_HICV_ACCOUNTS. A dictionary; no stream or seeder reads it. The seeder takes its categories from the facts. |
| CLN_HICV_REF_PROPERTY_ROOM_KEYS | yes | SPROC_STG_HICV_ROOM_KEYS | every column | STG_HICV_ROOM_KEYS. Reference only (Q-07): 2008-2023, no 2025-26 base in landed data. |
| CLN_HICV_OPS_KPI_WEEKLY | yes | SPROC_STG_HICV_KPI_WEEKLY | every column; ACTUAL_AMOUNT, BUDGET_AMOUNT, SNAPSHOT_DATE | XFRM_HICV_PACING -> SEM_AI_PACING |
| CLN_HICV_OPS_TREND_WEEKLY | yes | SPROC_STG_HICV_TREND_WEEKLY | as KPI | XFRM_HICV_PACING -> SEM_AI_PACING |
| CLN_HICV_PACE_RESERVATIONS_WEEKLY | yes | SPROC_STG_HICV_RESERVATIONS_WEEKLY | as KPI | XFRM_HICV_PACING -> SEM_AI_PACING |
| CLN_HICV_OPS_PRIORITIES_WEEKLY | **no** | none | - | Reference only, owner Q-10: 96 text status notes, 0 numeric. |

## In scope: BEAUMIER (10 in the freeze baseline)

| CLN table | Used | Procedure | Lands in |
|---|---|---|---|
| CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI | yes (new) | SPROC_STG_BEAUMIER_BUDGET_USALI | STG_BEAUMIER_BUDGET_USALI -> XFRM_BEAUMIER_INCOME_STATEMENT / _UNKNOWN -> SEM_AI_INCOME_STATEMENT_BUDGET / SEM_AI_UNKNOWN |
| CLN_BEAUMIER_OPS_STATS_MONTHLY | yes (new) | SPROC_STG_BEAUMIER_OPS_STATS | STG_BEAUMIER_OPS_STATS -> XFRM_BEAUMIER_OPERATING_METRICS -> SEM_AI_OPERATING_METRICS |
| CLN_BEAUMIER_FIN_FORECAST_VERSIONS | yes (unchanged) | SPROC_STG_BEAUMIER_BP | IS / UNKNOWN streams, BUDGET / FORECAST |
| CLN_BEAUMIER_FIN_BUDGET_MONTHLY | yes (unchanged) | SPROC_STG_BEAUMIER_BUDGET | IS stream, ACTUAL / BUDGET |
| CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY | yes (unchanged) | SPROC_STG_BEAUMIER_CANCELLATIONS | XFRM_BEAUMIER_PACING -> SEM_AI_PACING; its CURRENCY is read by BP, BUDGET and USALI |
| CLN_BEAUMIER_REF_ACCOUNTS | yes (unchanged) | SPROC_STG_BEAUMIER_ACCOUNTS | STG_BEAUMIER_ACCOUNTS (dictionary) |
| CLN_BEAUMIER_REF_HIERARCHY_PL_LINE | yes (unchanged) | SPROC_STG_BEAUMIER_HIERARCHY | STG_BEAUMIER_HIERARCHY (dictionary) |
| CLN_BEAUMIER_REF_PROPERTIES | yes (unchanged) | SPROC_STG_BEAUMIER_LOCATION_MAP | STG_BEAUMIER_LOCATION_MAP; HOTEL_NAME is read by BP, BUDGET, USALI and OPS_STATS |
| CLN_BEAUMIER_PACE_PRODUCTION_MONTHLY | **no** | none | Not read by any procedure, as in the lane's earlier builds. In the freeze baseline only. |
| CLN_BEAUMIER_REF_ACCOUNT_MAPPING | **no** | none | Not read by any procedure, as in the lane's earlier builds. In the freeze baseline only. |

**Correction to `scripts/d43_check.sql`:** its header says the 8 existing Beaumier tables are tables "the rebuilt lane reads". In fact the lane reads 6 of them. The check itself, on counts and `last_altered`, is unaffected.

## Out of scope (95)

- The tables of the 16 earlier-build lanes: ALTERRA, ATLANTIC_AVIATION, DAVIDSON, HERITAGE_GOLF (HHG), HERSHA, INVITED_CLUBS, JW_VENICE, NEWBURY_BOSTON, OUTRIGGER, PIG_HOTELS (THE_PIG), THIRD_SPACE, UNDER_CANVAS, WESTIN_HILTON_HEAD and W_SHERATON_MALDIVES.
- The control tables CLN_UTIL_FILE_MAP, CLN_UTIL_RAW_NOT_BUILT and CLN_UTIL_TABLE_MAP.

They were never staged or profiled by this build, and their objects in DEV_G2M_AI are unchanged (check 5: 315 objects, 0 differences).
