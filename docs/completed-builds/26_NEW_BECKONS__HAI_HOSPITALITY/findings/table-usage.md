# Build 26 table usage
| Table | Used | Procedure / columns |
|---|---|---|
| CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS | yes | SPROC_STG_BECKONS_ACTUALS: every column (TRANSACTION_AMOUNT_BASE measure; ILEVELMAPPING1 read by the seeder) |
| CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_BUDGET | yes | SPROC_STG_BECKONS_BUDGET: every column (BUDGET_AMOUNT_BASE measure) |
| CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT | yes | SPROC_STG_HAI_HOSPITALITY_INCOME_STATEMENT: every column (AMOUNT_ACTUAL, AMOUNT_BUDGET measures; HIERARCHY_LEVEL_1 read by the seeder) |
| CLN_HAI_HOSPITALITY_FINANCIALS_ILEVEL | no | out of scope (owner); not visible to this role |
| CLN_HAI_HOSPITALITY_FINANCIALS_OVERWATCH | no | out of scope (owner); not visible to this role |
Read-only: CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY (lane-name check and merge expectation, D-03).
