# Field lineage (build 23: HICV new; BEAUMIER rebuilt)

**Where does each column come from?** Read top to bottom: semantic column <- transformation <- staging <- CLN.

## HICV facts (SEM_AI_INCOME_STATEMENT_* and SEM_AI_UNKNOWN)

| Semantic column | Transformation (SPROC_XFRM_HICV) | Staging (SPROC_STG_HICV_PL / _GL) | CLN column |
|---|---|---|---|
| SOURCE_LANE | carried | 'HICV' | - |
| SOURCE_SITE_CODE | carried | nullif(trim(LOCATION_CODE)) | LOCATION_CODE |
| ASSET_NAME | carried | PL: LINE_DESCRIPTION part 4 on CLEAN lines, else null. GL: LOCATION_DESCRIPTION | LINE_DESCRIPTION / LOCATION_DESCRIPTION |
| DEPARTMENT | carried | nullif(trim(COST_CENTER_CODE)) | COST_CENTER_CODE |
| DEPARTMENT_NAME | carried | PL: part 2 on CLEAN lines. GL: COST_CENTER_DESCRIPTION | LINE_DESCRIPTION / COST_CENTER_DESCRIPTION |
| ACCOUNT_NUMBER | carried | nullif(trim(ACCOUNT_CODE)) | ACCOUNT_CODE |
| STAT_ACCOUNT | carried | null | - |
| ACCOUNT_KEY | carried | coalesce(nullif(trim(ACCOUNT_CODE),''),'~BLANK~') | ACCOUNT_CODE |
| RECORD_TYPE / _SOURCE | carried | 'AMOUNT' (every line is money, M1) | - |
| STAT_UNIT_FAMILY | carried | null | - |
| ACCOUNT_DESC | carried | PL: LINE_DESCRIPTION verbatim. GL: ACCOUNT_DESCRIPTION | as named |
| PERIOD_END | carried | PERIOD_DATE | PERIOD_DATE |
| CATEGORY | from SOURCE_MEASURE: ACTUAL_AMOUNT ACTUAL; FORECAST_AMOUNT and PREVIOUS_FORECAST_AMOUNT FORECAST; BUDGET_AMOUNT BUDGET | SOURCE_MEASURE = the unpivoted column name (GL: ACTUAL_AMOUNT) | the four measure columns |
| SCENARIO | carried | the named version (FORECAST_VERSION FORENOV, PREVIOUS_FORECAST_VERSION FOREOCT, BUDGET_VERSION), else the measure column name (D-45). GL: CLN_HICV_FIN_GL_MONTHLY | as named |
| H1-H5, P_L_SECTION, NORMAL_BALANCE, VALUE_SIGN | the one marked CTE on XREF_ACCOUNT_CLASSIFICATION | (seeder branch HICV reads STG_HICV_PL.DESC_PL_CATEGORY and STG_HICV_GL.PL_SUB_CATEGORY_1) | ACCOUNT_CODE digit; LINE_DESCRIPTION; PL_SUB_CATEGORY_1 |
| IS_SUBTOTAL / SUBTOTAL_SOURCE | carried | false / 'no total ... found (M1)' | - |
| SOURCE_AMOUNT | carried | the measure value, as booked | ACTUAL_AMOUNT, FORECAST_AMOUNT, PREVIOUS_FORECAST_AMOUNT, BUDGET_AMOUNT (GL: ACTUAL_AMOUNT) |
| CURRENCY_CODE | carried | 'USD' (owner Q-05, assumption) | - |
| STAT_VALUE | carried | null | - |
| SOURCE_LINE_KEY | carried | PL: ledger tab, account, cost center, LOB, location, LINE_ID, month, measure. GL: ledger, LOB, cost center, location, account, LINE_ID, month | as named |
| SOURCE_TABLE | carried | 'CLN.BOX_INVESTMENT_DATA.<table>' | - |
| VALUE | PROFIT (D-50, Q-16): SOURCE_AMOUNT where VALUE_SIGN is set, else null | - | - |
| UNKNOWN_REASON | DUPLICATE_DETAIL for every GL line (D-48: the P&L carries the month) | - | - |

**Staging-only HICV columns:**

- DESC_SPLIT_STATUS / DESC_SPLIT_RULE (CLEAN, ANCHORED, AMBIGUOUS; Q-15);
- DESC_ACCOUNT_NAME, DESC_PL_CATEGORY and DESC_LOB_NAME;
- SOURCE_SIGN_CONVENTION / _SOURCE;
- CURRENCY_CODE_SOURCE, SCENARIO_SOURCE and ASSET_NAME_SOURCE;
- every raw CLN column, verbatim.

## HICV pacing (SEM_AI_PACING, lane block HICV)

| Column | From |
|---|---|
| SITE | null: the report is portfolio-level |
| SNAPSHOT_DATE | SNAPSHOT_DATE (XFRM AS_OF_DATE) |
| STAY_PERIOD_END | PERIOD_DATE |
| STAY_PERIOD_START, STAY_GRAIN | null: the window WEEK / MTD / YTD is not a D-51 grain; PERIOD_WINDOW is in ATTRIBUTES |
| SEGMENT | SECTION |
| VANTAGE | ACTUAL_SOURCE (CY / PY) for ACTUAL_AMOUNT; 'BUDGET' for BUDGET_AMOUNT |
| METRIC_NAME | ACTUAL_AMOUNT / BUDGET_AMOUNT |
| METRIC_UNIT | from the unit stated in SECTION or LINE_ITEM: % or rate -> PERCENT; per, ASP, VPG -> CURRENCY_PER_UNIT; $'000 / $000's -> CURRENCY_THOUSANDS; $ or the Room Revenue tab -> CURRENCY; Sales-tab lines with no stated unit -> null; otherwise COUNT |
| IS_ADDITIVE | true for COUNT, CURRENCY and CURRENCY_THOUSANDS only |
| CURRENCY_CODE | USD for currency units |
| VALUE | the cell, never scaled |
| IS_LATEST_SNAPSHOT | SNAPSHOT_DATE = max per site and table |
| ATTRIBUTES | every other stream column |

## BEAUMIER additions

**STG_BEAUMIER_BUDGET_USALI:**

- Shaped as STG_BEAUMIER_BUDGET: ACCOUNT_KEY = SOURCE_ITEM_ID = LINE_ITEM; site = HOTEL_CODE.
- ASSET_NAME from STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME.
- CURRENCY_CODE from STG_BEAUMIER_CANCELLATIONS.CURRENCY per hotel (Q-11).
- SOURCE_AMOUNT = BUDGET_AMOUNT (already in units).
- SCENARIO = BUDGET_YEAR (Q-17).
- In transformation, CATEGORY BUDGET from the source table.

**STG_BEAUMIER_OPS_STATS:**

- The 4 measures are unpivoted INCLUDE NULLS.
- STAT_ACCOUNT = ACCOUNT_KEY = the measure column. RECORD_TYPE STATISTIC.
- STAT_VALUE = the cell. SCENARIO = BUDGET_YEAR (Q-14).
- METRIC_UNIT is null and AGGREGATION_TYPE comes from the classification (BUDGET_KEYS STOCK, the rest FLOW).
- Lands in SEM_AI_OPERATING_METRICS, CATEGORY BUDGET.

## After stop 4
- **XFRM_HICV_PACING.BLOCK_HEADER / BLOCK_HEADER_LINE_ORDER:** the last line at or above the row that follows a gap of 2+ blank lines on its tab. Carried in ATTRIBUTES.
- **SEM_AI_PACING.METRIC_UNIT (HICV):** on the Sales tab, from BLOCK_HEADER (Q-23); elsewhere as before.
- **Seeder HICV:** a provision category gives H1 Revenue (Q-21).
- **Seeder BEAUMIER:** with no PL_SECTION on the key, the section comes from STG_BEAUMIER_HIERARCHY.PL_GROUP and Below the Line from LEVEL_2 (Q-24).
