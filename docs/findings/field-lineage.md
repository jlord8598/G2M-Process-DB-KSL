# Field lineage - build 05 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: where does each column come from?** Builds 01 and 04's
archived `field-lineage.md` cover every column. This lists what build 05
changed.

| Column | Build 05 derivation | Procedure | Build 04 |
|---|---|---|---|
| `DEPARTMENT_NAME` | `STG_{LANE}_DEPARTMENTS.DEPARTMENT_GENERIC`, left-joined on `TENANT = '{T}'`, `SITE_TAG = fact SITE_TAG`, `DEPT_CODE = DEPARTMENT` (segment 1 of the account; labor: the `DEPARTMENT_LABEL` prefix). The key is unique, so the join cannot fan out; null where no row matches. `DEPARTMENT_OUTLET` is not used (owner Q-03 (b)). | the 8 `SPROC_STG_{LANE}_{DAILY_EXTENDED, MONTHLY_EXTENDED, LEDGER_BATCHES, DAILY_LABOR}` | COA `DEPARTMENT_NAME`, only where the code had one name |
| `SCENARIO` | Monthly: `SCENARIO_NAME`, verbatim. Daily, ledger, labor: the literal source table name without schema, e.g. `CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES` (D-45). Never null. | same 8 | null on daily, ledger, labor |
| `CATEGORY` | Build 04's rule plus `Budget 3` -> `BUDGET`, exact `DATASETS` name (owner Q-02) | `SPROC_XFRM_{LANE}` | without `Budget 3` |
| `STG_{LANE}_DEPARTMENTS` (new table) | Every row and column of `CLN.CLEAN.CUR_PROFITSWORD_DEPARTMENTS` (both tenants), plus `RUN_ID`, `SOURCE_LANE`, `SOURCE_TABLE` | `SPROC_STG_{LANE}_DEPARTMENTS` | - |

**Coverage:** `DEPARTMENT_NAME` is named on 3,171,699 KSL and 979,273
PEREGRINE semantic rows. `SCENARIO` is null on 0 rows of either lane
(M3, M6).

**Unchanged:** the five-part key, measures, line key, subtotal and site-name
rules, classification columns, `VALUE`, and the semantic lane blocks.
