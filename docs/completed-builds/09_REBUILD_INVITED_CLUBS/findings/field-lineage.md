# Field lineage - build 09 (INVITED_CLUBS)

**Where does each column come from?** Earlier builds' records stand. Only the
rows below changed in build 09.

| Column | Model | Lineage (build 09) |
|---|---|---|
| `IS_SUBTOTAL`, `SUBTOTAL_SOURCE` | `SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT` | also TRUE where `ACCOUNT` is `Ind-Adjusted Cash EBITDA` or `Ind-Club Operating Profit` (Q-04) |
| `H1`, `H2`, section, balance, sign | seeder INVITED_CLUBS branch + one-time re-seed | `r_class` rules IND, ACE, PLAN, DUES, KPI, A5REV (`M4.md`) |
| `METRIC_UNIT` | same | `currency` for DUES / KPI keys (META `DATA_TYPE` currency) |
| `AGGREGATION_TYPE` | same | DUES / KPI: `STOCK` for `BegBase_*` / `EndBase_*` (owner override, Q-13), else `FLOW` from META `TIME_BALANCE` (primary instance, `STG_INVITED_CLUBS_META_ACCOUNT`) |
| `UNKNOWN_REASON` | `SPROC_XFRM_INVITED_CLUBS` | SOURCE_ROLLUP / PLANNING_INPUT extended (`M5.md`) |

**Unchanged:**
- every key, measure, record-type, category, scenario and line-key
  expression;
- ACCOUNT_DESC (Q-08: no source supplies more);
- ASSET_NAME.
