# Field lineage (build 18)

| Column (labor rows) | Source |
|---|---|
| SOURCE_AMOUNT | CUR_PROFITSWORD_<T>_DAILY_LABOR.AMOUNTS (wages), as booked |
| STAT_VALUE | HOURS |
| STAT_UNIT_FAMILY | 'HOURS', set in staging (build 18, D-29) |
| H1 / H2 / METRIC_UNIT / AGGREGATION_TYPE | classification: Statistic / DAILY_LABOR / CURRENCY / FLOW (seeder labor rule) |
| ACCOUNT_KEY / ACCOUNT_DESC | LABEL (unchanged) |
| DEPARTMENT / DEPARTMENT_NAME | LABEL number / STG_<LANE>_DEPARTMENTS (unchanged) |
| PERIOD_END | BUSINESS_DATE (daily, unchanged) |
| SOURCE_LINE_KEY | null (owner Q-03) |

PERSON_ID, EMPLOYEE_ID, EMPLOYEE_NAME and EFFECTIVE_RATE stay in staging. Every other column and lane is unchanged.
