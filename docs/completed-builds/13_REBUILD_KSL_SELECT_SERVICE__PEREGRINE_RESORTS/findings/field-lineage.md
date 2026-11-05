# Field lineage (build 13 changes)

Columns not listed are as in build 05 / build 04 field-lineage (archived).

| Column | Source |
|---|---|
| IS_SUBTOTAL, SUBTOTAL_SOURCE (daily, monthly) | staging: no ACCOUNT_NUMBER / STAT_ACCOUNT, COA `IS_CALCULATED_LINE` on `ITEM_TAG`, COA `BUD_FORMULA` kind, and the M1 Q-16 fail list |
| H1, H2, P_L_SECTION, NORMAL_BALANCE, VALUE_SIGN | seeder: section digit and account block (characters 5-8 of the account), D-46 (owner Q-01, Q-05) |
| UNKNOWN_REASON SOURCE_ROLLUP | transformation: Unclassified key and IS_SUBTOTAL |
| UNRESOLVED_CATEGORY_VALUE Budget 4 / Budget 5 | transformation: DATASETS scenario name with no category mapping |
