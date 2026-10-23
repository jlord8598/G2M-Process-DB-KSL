# Field lineage - build 04 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: where does each column come from?** Build 01's archived
`field-lineage.md` is the full map for both lanes. **This document lists only
what changed**; every column not listed here derives exactly as recorded
there.

## Changed in this build

| Column | Layer | Build 04 derivation | Procedure | Build 01 |
|---|---|---|---|---|
| `ASSET_NAME` | STG -> XFRM -> SEM | The fact's `SITE_NAME`; where that is null, `STG_{LANE}_SITES.SITE_NAME` joined on `SITE_TAG = SITE_TAG` (exact match; `SITES` is unique on `SITE_TAG`) (owner Q-13) | the 8 `SPROC_STG_{LANE}_{DAILY_EXTENDED, MONTHLY_EXTENDED, LEDGER_BATCHES, DAILY_LABOR}` | the fact's `SITE_NAME` |
| `ASSET_NAME_SOURCE` (new, staging only) | STG | `fact SITE_NAME`, or `STG_{LANE}_SITES.SITE_NAME on SITE_TAG (owner Q-13)` | same 8 | - |
| `DEPARTMENT_NAME` | STG -> XFRM -> SEM | `CLN.CLEAN.CUR_PROFITSWORD_{T}_COA.DEPARTMENT_NAME`, grouped by `ACCT_DEPT_SEGMENT`, where the code has exactly one distinct name, else null. Joined on the fact's `DEPARTMENT` (segment 1; labor: the `DEPARTMENT_LABEL` prefix) (owner Q-02) | same 8 | `CUR_PROFITSWORD_CHART_OF_ACCOUNTS.DEPARTMENT`, `min()` per (tenant, segment 1) |
| `IS_SUBTOTAL` | STG -> XFRM -> SEM | `ITEM_TAG` starts `TOT`, **or** the tag is a COA `IS_TOTAL_LINE` tag and no COA row of the tag carries an account or stat account (owner Q-05, Q-08) | daily and monthly models | `ITEM_TAG` starts `TOT` |
| `SUBTOTAL_SOURCE` | STG -> XFRM -> SEM | which of the rules applied; adds `COA IS_TOTAL_LINE, tag carries no account: source rollup (owner Q-05, Q-08)` and `COA IS_TOTAL_LINE on account-coded detail: unflagged (owner Q-08)` | daily and monthly models | build 01's texts |
| `RECORD_TYPE_SOURCE` | STG -> XFRM -> SEM | the same rule; its text now cites the chart evidence as build 01's (`build 01 rule; chart ACCOUNT_KIND ... at build 01 M1`), because the chart is gone | daily, monthly, ledger | `(chart ACCOUNT_KIND ..., M1)` |
| `CATEGORY` | XFRM -> SEM | build 01's rule, plus `Smart Forecast` -> `FORECAST` by exact `DATASETS` name (owner Q-03) | `SPROC_XFRM_{LANE}`, `cat` CTE | without Smart Forecast |
| `STG_{LANE}_COA` (new table) | STG | every column of `CLN.CLEAN.CUR_PROFITSWORD_{T}_COA` verbatim, plus `RUN_ID`, `SOURCE_LANE`, `SOURCE_TABLE` | `SPROC_STG_{LANE}_COA` | `STG_SHARED_CHART_OF_ACCOUNTS` (retired) |

## Coverage of the changed columns (queries `01c7e8f0-020a-3de2-0003-4ff21bbab44e`, `01c7e8b5-020a-3b31-0003-4ff21bb90bde`)

**`ASSET_NAME_SOURCE`, rows per fact table:**

| Lane | Table | `fact SITE_NAME` | `STG_{LANE}_SITES` | still null |
|---|---|---|---|---|
| KSL | DAILY_EXTENDED | 8,049,208 | 0 | 0 |
| KSL | MONTHLY_EXTENDED | 1,217,855 | 0 | 0 |
| KSL | LEDGER_BATCHES | 574,556 | 0 | 0 |
| KSL | DAILY_LABOR | 434,051 | 0 | 0 |
| PEREGRINE | DAILY_EXTENDED | 350,583 | 0 | 0 |
| PEREGRINE | MONTHLY_EXTENDED | 589,229 | 0 | 0 |
| PEREGRINE | LEDGER_BATCHES | 22,323 | **9,468** | 0 |
| PEREGRINE | DAILY_LABOR | 266,565 | 0 | 0 |

- **Where it applied.** The fill covers only the PEREGRINE ledger, the one
  table with the gap: 9,468 rows at CABRDOP, CASVROP, CAYRDOP and PABMROP,
  2026-06 to 2026-08 (M3).
- **Why every model has it.** It is applied to all 8 fact models, so a future
  gap fills the same way.
- **The fact's raw `SITE_NAME`** is still carried verbatim in staging.
- **Semantic.** `ASSET_NAME_SOURCE` is a staging column and does not reach
  SEMANTIC, whose shape is fixed (section 4). A semantic consumer sees the
  filled `ASSET_NAME`; staging says where it came from.

**`IS_SUBTOTAL`:**
- **KSL daily:** 3,559,388 (`TOT*` 3,501,949 + COA-flagged 57,439).
- **PEREGRINE daily:** 157,704 (157,381 + 323).
- **Unflagged account-coded detail (Q-08):** 13,601 KSL rows, daily 2,319 +
  monthly 11,282.

**`DEPARTMENT_NAME`:** see `classification-coverage.md`.

## Unchanged

- **The five-part key,** `ACCOUNT_KEY`, `SOURCE_ITEM_ID`, `RECORD_TYPE`,
  `STAT_UNIT_FAMILY`, `PERIOD_END`, `SCENARIO`, `SOURCE_AMOUNT`,
  `STAT_VALUE`, `SOURCE_LINE_KEY` and `SOURCE_TABLE`: as build 01, same
  expressions (M3, M4).
- **`H1`-`H5`, `P_L_SECTION`, `NORMAL_BALANCE`, `VALUE_SIGN`,
  `METRIC_UNIT`, `AGGREGATION_TYPE`:** from the classification table, read
  in `SPROC_XFRM_{LANE}`'s one marked CTE; `VALUE` =
  `SOURCE_AMOUNT x VALUE_SIGN`.
- **The semantic lane blocks** for both lanes are unchanged; the `sql/semantic/`
  diff is empty.
