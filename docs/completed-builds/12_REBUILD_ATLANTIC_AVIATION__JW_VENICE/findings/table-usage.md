# Table usage (build 12): how were the tables wired?

| CLN.BOX_INVESTMENT_DATA table | Used | Procedure and column |
|---|---|---|
| CLN_JW_VENICE_MONTHLY_PL_DEPT | yes (new) | SPROC_STG_JW_VENICE_MONTHLY_PL_DEPT: every column (raw carried; ACTUAL_AMOUNT, BUDGET_AMOUNT unpivoted) -> seeder JW branch, SPROC_XFRM_JW_VENICE |
| CLN_JW_VENICE_FCAST_ACT_FORECAST | yes | SPROC_STG_JW_VENICE_FCAST_ACT_FORECAST (unchanged); SPROC_XFRM_JW_VENICE (D-48 Q-02 on ACTUAL 2026-08) |
| CLN_JW_VENICE_FCAST_BY_PERIOD | yes | SPROC_STG_JW_VENICE_FCAST_BY_PERIOD (unchanged); SPROC_XFRM_JW_VENICE (D-48 Q-02 on ACTUAL 2025-08) |
| CLN_JW_VENICE_FTE | yes | SPROC_STG_JW_VENICE_FTE (unchanged) |
| CLN_JW_VENICE_HEADCOUNT | yes | SPROC_STG_JW_VENICE_HEADCOUNT (unchanged) |
| CLN_JW_VENICE_ACCOUNTS | yes | SPROC_STG_JW_VENICE_ACCOUNTS (dictionary, unchanged) |
| CLN_JW_VENICE_CAPEX | no | out of scope (Q-08) |
| CLN_ATLANTIC_AVIATION_OC_DATA | yes | SPROC_STG_ATLANTIC_AVIATION_OC_DATA (+ SOURCE_UNIT_SCALE from LINE_ITEM); SPROC_XFRM_ATLANTIC_AVIATION (scale) |
| CLN_ATLANTIC_AVIATION_ACCOUNTS | yes | SPROC_STG_ATLANTIC_AVIATION_ACCOUNTS (dictionary, unchanged) |

Other tables visible under the role belong to earlier builds and were not read (scope confirmed at stop 1; M1.md). Retired objects: none. New procedure: SPROC_STG_JW_VENICE_MONTHLY_PL_DEPT (129 deployed).
