# Build 26 field lineage
| Column | BECKONS | HAI_HOSPITALITY |
|---|---|---|
| SOURCE_SITE_CODE | LODGE_CODE, else LOCATION_NAME (SOURCE_SITE_CODE_SOURCE in staging) | HH_MST_LOC_KEY |
| ASSET_NAME | REPORTING_LOCATION_NAME | LOCATION_NAME |
| DEPARTMENT / DEPARTMENT_NAME | DEPARTMENT_TITLE / DEPARTMENT_TITLE | null / null |
| ACCOUNT_NUMBER, ACCOUNT_KEY | ACCOUNT_NO | ACCOUNT_NUMBER |
| ACCOUNT_DESC | ACCOUNT_TITLE | ACCOUNT_NAME |
| RECORD_TYPE | STATISTIC for AROOM / NIGHT / OROOM, else AMOUNT | AMOUNT |
| PERIOD_END | FINANCIAL_PERIOD | PERIOD_END |
| CATEGORY | SPROC_XFRM_BECKONS `cat`: by SOURCE_TABLE | SPROC_XFRM_HAI_HOSPITALITY `cat`: by branch |
| SCENARIO | the table name | AMOUNT_ACTUAL / AMOUNT_BUDGET |
| SOURCE_AMOUNT / STAT_VALUE | *_AMOUNT_BASE | AMOUNT_ACTUAL / AMOUNT_BUDGET |
| CURRENCY_CODE | BASE_CURRENCY (staging, carried to SEM) | 'USD' (staging, Q-07) |
| SOURCE_SIGN_CONVENTION | per table + entity (staging) | PRESENTED |
| IS_SUBTOTAL | false (no total lines) | false |
| SOURCE_LINE_KEY | lodge, location, period, department, account | location, period, calendar date, account, branch |
| H1-H2 | seeder: ILEVELMAPPING1 per key, else account range | seeder: HIERARCHY_LEVEL_1 |
Staging only: BECKONS *_AMOUNT_AUD, ILEVELMAPPING1-3; HAI all source columns (COMP_STATUS, BRAND, CONCEPT, MARKET, hierarchy, fiscal calendar).
