# Table usage - build 04 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: how were the tables wired?** Every table visible in
`CLN.CLEAN` (26), with the procedure and columns that read it. Every one is in
scope (owner Q-01).

## Source tables

`{T}` = `KSL` for KSL_SELECT_SERVICE and `PEREGRINE` for PEREGRINE_RESORTS.
Each row holds for both lanes.

| Source table | Role | Read by | Columns used for derivation | Staged as |
|---|---|---|---|---|
| CUR_PROFITSWORD_{T}_DAILY_EXTENDED | fact | `SPROC_STG_{LANE}_DAILY_EXTENDED` | `SITE_TAG`, `SITE_NAME`, `ACCOUNT_NUMBER`, `STAT_ACCOUNT`, `ITEM_TAG`, `DESCRIPTION`, `BUSINESS_DATE`, `AMT`, `STAT`; all others verbatim | `STG_{LANE}_DAILY_EXTENDED` |
| CUR_PROFITSWORD_{T}_MONTHLY_EXTENDED | fact | `SPROC_STG_{LANE}_MONTHLY_EXTENDED` | as daily, plus `FCID`, `SCENARIO_NAME`, `PERIOD_DATE` | `STG_{LANE}_MONTHLY_EXTENDED` |
| CUR_PROFITSWORD_{T}_LEDGER_BATCHES | fact | `SPROC_STG_{LANE}_LEDGER_BATCHES` | `SITE_TAG`, `SITE_NAME`, `GL_ACCT`, `STAT_ACCT`, `ITEM_DESCRIPTION`, `FISCAL_PERIOD_DATE`, `AMT`, `QTY`, `BATCH_ID`, `LINE_SEQ` | `STG_{LANE}_LEDGER_BATCHES` |
| CUR_PROFITSWORD_{T}_DAILY_LABOR | fact | `SPROC_STG_{LANE}_DAILY_LABOR` | `SITE_TAG`, `SITE_NAME`, `LABEL`, `DEPARTMENT_LABEL`, `BUSINESS_DATE`, `AMOUNTS`, `HOURS` | `STG_{LANE}_DAILY_LABOR` |
| CUR_PROFITSWORD_{T}_SALES_PACE_EVENTS / _ROOMS / _TRANSIENT | pacing | `SPROC_STG_{LANE}_SALES_PACE_*` (verbatim); then `SPROC_XFRM_{LANE}` -> `XFRM_{LANE}_PACING` | all columns, own shape; `AS_OF_DATE` carried | `STG_{LANE}_SALES_PACE_*` |
| CUR_PROFITSWORD_{T}_SALES_BOOKINGS | pacing-side dictionary | `SPROC_STG_{LANE}_SALES_BOOKINGS` (verbatim) | none downstream | `STG_{LANE}_SALES_BOOKINGS` |
| CUR_PROFITSWORD_{T}_DATASETS | dictionary | `SPROC_STG_{LANE}_DATASETS`; `SPROC_XFRM_{LANE}` joins `STG_{LANE}_DATASETS` on `FCID` | `FCID`, `SCENARIO_NAME`, `IS_ACTUALS` (category) | `STG_{LANE}_DATASETS` |
| CUR_PROFITSWORD_{T}_SITES | dictionary | `SPROC_STG_{LANE}_SITES`; the 4 fact models join `STG_{LANE}_SITES` on `SITE_TAG` | `SITE_TAG`, `SITE_NAME` (the `ASSET_NAME` fill, Q-13) | `STG_{LANE}_SITES` |
| CUR_PROFITSWORD_{T}_COA | dictionary (**new**) | `SPROC_STG_{LANE}_COA` (verbatim); the 4 fact models read it directly (as build 01's models read the chart) | `ACCT_DEPT_SEGMENT`, `DEPARTMENT_NAME` (Q-02); `TAG`, `IS_TOTAL_LINE`, `ACCOUNT_NUMBER`, `STAT_ACCT_NUMBER` (daily and monthly, Q-05/Q-08) | `STG_{LANE}_COA` |
| CUR_PROFITSWORD_{T}_SITE_GROUPS | dictionary | `SPROC_STG_{LANE}_SITE_GROUPS` (verbatim) | none downstream | `STG_{LANE}_SITE_GROUPS` |
| CUR_PROFITSWORD_{T}_ACCOUNT_CLASS | dictionary | `SPROC_STG_{LANE}_ACCOUNT_CLASS` (verbatim) | none downstream; no fact column carries `DEPARTMENT_CLASS` | `STG_{LANE}_ACCOUNT_CLASS` |

- **Staged but unused downstream.** `SALES_BOOKINGS`, `SITE_GROUPS` and
  `ACCOUNT_CLASS` are staged for consumers and read by nothing after
  staging, as at build 01.
- **The seeder** reads only the 4 fact staging tables per lane (D-37); pacing
  and the dictionaries never feed it.

## Retired

| Object | Was | Now |
|---|---|---|
| `CLN.CLEAN.CUR_PROFITSWORD_CHART_OF_ACCOUNTS` | read by 8 fact models (department names) and by `SPROC_STG_SHARED_CHART_OF_ACCOUNTS` | **no longer visible to this role**; read by nothing |
| `SPROC_STG_SHARED_CHART_OF_ACCOUNTS`, `STG_SHARED_CHART_OF_ACCOUNTS` | built by both staging MAINs; read by nothing | **dropped** in `DEV_G2M_AI`, file removed (owner Q-06). Drop by hand in promoted environments. |

## Wiring

```
SPROC_STG_{LANE}_MAIN (13 calls)
    dictionaries first: SALES_BOOKINGS, DATASETS, SITES, SITE_GROUPS, ACCOUNT_CLASS, COA
    facts: DAILY_EXTENDED, MONTHLY_EXTENDED, LEDGER_BATCHES, DAILY_LABOR
    pacing: SALES_PACE_ROOMS, SALES_PACE_TRANSIENT, SALES_PACE_EVENTS
SPROC_XREF_{LANE}_MAIN -> SPROC_XREF_ACCOUNT_CLASSIFICATION(run, lane), three review views
SPROC_XFRM_{LANE}_MAIN -> SPROC_XFRM_{LANE} (five streams)
SPROC_SEM_AI_MAIN       -> six SPROC_SEM_AI_* (lane blocks unchanged)
```

- **Harness.** `scripts/run_build.sql` calls the six lane MAINs, then
  `SPROC_SEM_AI_MAIN`. It calls no MAIN of a lane not rebuilt.
- **Deployed:** 91 procedures, parity clean.
