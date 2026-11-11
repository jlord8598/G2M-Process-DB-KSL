# Field lineage (build 16): where each column comes from

Unchanged from each lane's archived build record except:

| Column | Change |
|---|---|
| SOURCE_TABLE (STG, XFRM, SEM, every lane) | The new CLN table name, as a literal in the staging model (Q-01 b). The JW FCAST pair and the PIG pace pair each share one name; the halves stay distinct through SOURCE_OBJECT (JW, staging) and PACE_YEAR / SOURCE_OBJECT (PIG, staging) |
| PROPERTY_NAME (staging, 22 models) | `portfolio_name as property_name`: the same values (M1: 62 / 62 views equal) |
| PORTFOLIO_NAME, ENTITY_NAME, ACCOUNT_TYPE (src.* staging models) | New pass-through columns where the model selects src.* (rule 3) |
| ACCOUNT_DESC, DEPARTMENT_NAME, PARENT_CODE (STG_HHG_BUDGET_BY_CLUB, STG_HHG_TR12_DATA, STG_DAVIDSON_FULL_YEAR_PL, STG_DAVIDSON_HOTEL_MONTHLY_REPORT) | Filled from the join to the lane's accounts dictionary, whose literal now names the new table (Q-03 a); fill equals the pre-rename baselines (M3.md) |
| SCENARIO where D-45 uses the table name | Unchanged: equal to the view run on every lane (M6) |

Every other column has the same source column and expression as before; the M6 proof shows each object equal to the view run once the columns above are reversed.
