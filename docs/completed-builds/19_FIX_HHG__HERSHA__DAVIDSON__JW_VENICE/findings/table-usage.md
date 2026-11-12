# Table usage (build 19)

| Object | Read by | Writes |
|---|---|---|
| STG_HHG_MEMBERSHIP_MONTHLY | seeder HHG branch, SPROC_XFRM_HHG | - |
| STG_DAVIDSON_HOTEL_BUDGET | seeder DAVIDSON branch, SPROC_XFRM_DAVIDSON | - |
| STG_JW_VENICE_CAPEX | seeder JW_VENICE branch, SPROC_XFRM_JW_VENICE | - |
| STG_JW_VENICE_PACE_OTB_DAILY, STG_JW_VENICE_PACE_SEGMENT_MONTHLY | SPROC_XFRM_JW_VENICE (pacing stream only; never the seeder) | - |
| STG_HHG_BUDGET_BY_CLUB | also SPROC_XFRM_HHG's D-48 membership rule (club + month + account) | - |
| XFRM_JW_VENICE_PACING | SPROC_SEM_AI_PACING (JW block) | - |
| CLN_HERSHA_FIN_BUDGET_MONTHLY, CLN_JW_VENICE_FIN_PL_OWNER, CLN_JW_VENICE_OPS_STATS_MONTHLY, CLN_DAVIDSON_PACE_GROUP_ANNUAL | nothing (not staged; owner) | - |
