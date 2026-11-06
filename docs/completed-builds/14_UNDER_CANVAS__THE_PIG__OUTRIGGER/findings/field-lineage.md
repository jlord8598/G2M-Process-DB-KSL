# Field lineage (build 14, new lanes)

| Column | Source |
|---|---|
| SOURCE_SITE_CODE | UNDER_CANVAS detail: leading code of LOCATION; CONSOLIDATED_PL: ENTITY_NAME |
| DEPARTMENT | detail: leading code of DEPARTMENT, else its text; CONSOLIDATED_PL: SOURCE_SECTION_LABEL |
| ACCOUNT_NUMBER / ACCOUNT_KEY | detail: `regexp_substr(trim(ACCOUNT), '^[0-9]+(-[0-9]+)?')`, key = ACCOUNT; CONSOLIDATED_PL: none, key = LINE_ITEM |
| RECORD_TYPE | AMOUNT; STATISTIC for STATISTICAL_ACCOUNTS and the 11 CONSOLIDATED_PL statistic lines |
| SOURCE_AMOUNT / STAT_VALUE | ACTUAL_AMOUNT, as booked |
| IS_SUBTOTAL | CONSOLIDATED_PL line_orders 23, 33, 40, 45, 50, 55, 70, 72, 73, 75, 88, 94, 98, 99, 105, 128, 133, 135 |
| SOURCE_LINE_KEY | SOURCE_ROW_NUMBER |
| H1, H2, P_L_SECTION, NORMAL_BALANCE, VALUE_SIGN | seeder UNDER_CANVAS branch, D-46 blocks (owner Q-07) |
| UNKNOWN_REASON DUPLICATE_DETAIL | transformation, D-48 (every CONSOLIDATED_PL row) |
| CURRENCY_CODE | UNDER_CANVAS 'USD' (owner Q-03); THE_PIG GBP and OUTRIGGER USD recorded in sources.md, no semantic rows |
| PACING columns | every pace-table column verbatim (D-24); OUTRIGGER SOURCE_TABLE renamed EXPORT_LAYOUT in staging (V1 / V2, N-27) |
