# Field lineage (build 21)

| Column | Source | Rule |
|---|---|---|
| STG_THE_PIG_PL_MONTHLY.SOURCE_SITE_CODE / ASSET_NAME | HOTEL_CODE / HOTEL_NAME | OL a site like any other |
| .DEPARTMENT / ACCOUNT_KEY | ACCOUNT_LINE_NUMBER | after the dash / whole code |
| .RECORD_TYPE | ACCOUNT_LINE_NUMBER | C00001 / C00008 / C00010-050 STATISTIC, else AMOUNT |
| .ACCOUNT_DESC | STG_THE_PIG_ACCOUNTS.ACCOUNT_DESCRIPTION | entity + string |
| .SCENARIO / measure | ACTUAL_AMOUNT, FORECAST_AMOUNT | x2; BUDGET_AMOUNT raw only |
| SEM_AI_* (THE_PIG).CURRENCY_CODE | constant 'GBP' | owner Q-06 (CURRENCY 'British Pound') |
| STG_DAVIDSON_HOTEL_MONTHLY_REPORT / HOTEL_BUDGET.ACCOUNT_DESC | STG_DAVIDSON_ACCOUNT_MAPPING, else the six segment tables (else mapping names, else raw code), else REF_ACCOUNTS | Q-08, Q-11 |
