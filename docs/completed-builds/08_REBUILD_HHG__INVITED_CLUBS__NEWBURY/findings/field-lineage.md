# Field lineage - build 08 (HHG, INVITED_CLUBS, NEWBURY)

**Where does each column come from?** Earlier builds record every column's
lineage, and that record stands. Only the rows below changed in build 08.
Semantic passes them through by name.

| Lane | Column | Model | Lineage (build 08) |
|---|---|---|---|
| HHG | `ACCOUNT_DESC` | `SPROC_STG_HHG_TR12_DATA` | `CLN_HERITAGE_GOLF_ACCOUNTS.ACCOUNT_DESCRIPTION` on `FULL_ACCOUNT_STRING` (unique); null if unmatched |
| HHG | `DEPARTMENT_NAME` | same | `CLN_HERITAGE_GOLF_ACCOUNTS.DEPARTMENT_DESCRIPTION` verbatim (Q-09) |
| HHG | `PARENT_CODE` (staging only, unused) | same | `CLN_HERITAGE_GOLF_ACCOUNTS.PARENT_CODE` (Q-11) |
| INVITED_CLUBS | `IS_SUBTOTAL`, `SUBTOTAL_SOURCE` | `SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT` | also TRUE where `ACCOUNT` starts `Ind-Total` (Q-06) |
| INVITED_CLUBS | `H1`-`H2`, `P_L_SECTION`, `NORMAL_BALANCE`, `VALUE_SIGN` (A6) | seeder INVITED_CLUBS branch + one-time re-seed | A6 block mapping (`sources.md`) |
| INVITED_CLUBS | `UNKNOWN_REASON` | `SPROC_XFRM_INVITED_CLUBS` | `SOURCE_ROLLUP` / `PLANNING_INPUT` / `DUPLICATE_DETAIL` / `UNCLASSIFIED_ACCOUNT` (`M5.md`) |
| NEWBURY | `H2` and sign of 9 BU 9000 accounts | seeder NEWBURY branch + one-time re-seed | named accounts -> D&A / Income Taxes (Q-07) |

**Unchanged:** every key, measure, record-type, category and line-key
expression.
