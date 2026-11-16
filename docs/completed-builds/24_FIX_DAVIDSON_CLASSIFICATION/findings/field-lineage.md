# Build 24 field lineage (new / changed)
| Column | Source | Rule |
|---|---|---|
| STG_*_HOTEL_MONTHLY_REPORT / _BUDGET.ALIAS_ACCOUNT_STRING | CLN_DAVIDSON_REF_ACCOUNTS.ALIAS via STG_DAVIDSON_ACCOUNTS (min per FULL_ACCOUNT_STRING) | one-segment ACCOUNT, no stated natural |
| .ALIAS_NATURAL_ACCOUNT | segment 2 of that alias | six-segment alias only |
| STG_DAVIDSON_FULL_YEAR_PL.IS_SUBTOTAL | LINE_ITEM | adds all-capitals non-statistic lines |
| .SUBTOTAL_SOURCE | LINE_ITEM | adds repeat / all-capitals texts |
| .SUMMARY_LINE_KIND | IS_ROLLUP, REPORT_SHEET, LINE_ITEM | ROLLUP_ROW / STATISTIC / TOTAL_REPEAT / SUBTOTAL / DETAIL |
| XFRM_DAVIDSON_*.UNKNOWN_REASON | SOURCE_TABLE, SUMMARY_LINE_KIND, H1 | D-48 (M5.md) |
