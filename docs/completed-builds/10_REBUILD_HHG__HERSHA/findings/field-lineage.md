# Field lineage - build 10 (HHG, HERSHA)

**Where does each column come from?** Earlier builds' records stand. Only the
rows below changed.

| Lane | Column | Model | Lineage (build 10) |
|---|---|---|---|
| HHG | `ASSET_NAME`, `ASSET_NAME_SOURCE` (TR12) | `SPROC_STG_HHG_TR12_DATA` | `STG_HHG_ASSET_CODES.CLUB_NAME` on entity = `CLUB_NUMBER` (Q-02); null for 9055, 9056, 9099, 9102 |
| HHG | `H1`, `H2`, section, balance, sign (TR12 money) | seeder HHG branch + one-time re-seed | `STG_HHG_CHART_OF_ACCOUNTS.ACCOUNT_TYPE` on department + natural account, or natural account if single-typed (Q-03, Q-04, Q-09, stop 2 correction); else the digit |
| HHG | all columns of the 4 new STG tables | `SPROC_STG_HHG_{ASSET_CODES,CHART_OF_ACCOUNTS,DEPARTMENT_KEY,TR12_ACCOUNTS}` | source verbatim + RUN_ID, SOURCE_LANE, SOURCE_TABLE |
| HERSHA | every column of `STG_HERSHA_TB_ACTUAL` | `SPROC_STG_HERSHA_TB_ACTUAL` | as GL_ACTUAL's model (wide x 2, GL_CODE -> RECORD_TYPE); `FLAG_COL_1`, `FLAG_COL_2` staging only (Q-07) |
| HERSHA | `UNKNOWN_REASON` | `SPROC_XFRM_HERSHA` | `DUPLICATE_DETAIL` by the D-48 rule (source table x category x TB hotel set) |

**Unchanged:** every key, measure, record-type, category, scenario and
line-key expression. ROUNDS keys carry the file path (N-7).
