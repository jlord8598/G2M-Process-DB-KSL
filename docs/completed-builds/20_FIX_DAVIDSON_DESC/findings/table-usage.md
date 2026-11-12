# Table usage (build 20)

| Object | Read by | Column |
|---|---|---|
| CLN_DAVIDSON_REF_ACCOUNT_LOOKUP | SPROC_STG_DAVIDSON_ACCOUNT_LOOKUP | every column |
| STG_DAVIDSON_ACCOUNT_LOOKUP | SPROC_STG_DAVIDSON_HOTEL_MONTHLY_REPORT, SPROC_STG_DAVIDSON_HOTEL_BUDGET | CONCATENATED_PROFITSWORD_STRING; the six segment reference ids and names; ACCOUNT_NAME (retired test) |
| CLN_DAVIDSON_PACE_GROUP_ANNUAL | nothing (N-51) | - |

The other Davidson tables are wired as in build 19.
