# Table usage - how were the tables wired?

All 25 granted `CLN.CLEAN` tables are in scope (stop 1), and every one is
read. One row per table below; procedure and column are named for every use.
Row counts are `COUNT(*)` from the live re-run of
`scripts/reconcile_KSL_SELECT_SERVICE.sql` (query
`01c7d6ba-020a-2bbb-0003-4ff21b86a2f6`) and
`scripts/reconcile_PEREGRINE_RESORTS.sql` (query
`01c7d6bb-020a-2b54-0003-4ff21b85ea6a`), after the Q-04 re-run, on the 07:39
extract. Every staged count equals its source count (0 failures in both).

**Changed from M6:** nothing in the wiring. Q-04 changed only the scenario
list `SPROC_XFRM_{LANE}` applies to the `DATASETS` columns it already read
(rows 6 and 18); no table gained or lost a reader, and every row count is
unchanged.

## Source tables (`CLN.CLEAN`)

| # | `CLN.CLEAN` table | Lane | Rows | Read by (staging) | Downstream use (procedure: columns), or why unused |
|---|---|---|---|---|---|
| 1 | `CUR_PROFITSWORD_CHART_OF_ACCOUNTS` | shared (both) | 5,845 | `SPROC_STG_SHARED_CHART_OF_ACCOUNTS` (all columns) to `STG_SHARED_CHART_OF_ACCOUNTS`; also the eight fact staging models (rows 2-5, 14-17): `TENANT`, `ACCOUNT_NUMBER`, `DEPARTMENT`, for `DEPARTMENT_NAME` | The staged copy is read by no later procedure. The seeder derives `H1`/`H2` from the account number; the chart's `PL_SECTION`/`ACCOUNT_TYPE` restate Level 1 only (M1). Staged for the seed (D-26), kept for review. |
| 2 | `CUR_PROFITSWORD_KSL_DAILY_EXTENDED` | KSL_SELECT_SERVICE | 2,050,067 | `SPROC_STG_KSL_SELECT_SERVICE_DAILY_EXTENDED` to `STG_KSL_SELECT_SERVICE_DAILY_EXTENDED` | `SPROC_XREF_ACCOUNT_CLASSIFICATION`: `SOURCE_SITE_CODE`, `DEPARTMENT`, `ACCOUNT_KEY`, `RECORD_TYPE`, `MIN()` of `ASSET_NAME`, `DEPARTMENT_NAME`, `ACCOUNT_NUMBER`, `STAT_ACCOUNT`, `ACCOUNT_DESC`. `SPROC_XFRM_KSL_SELECT_SERVICE`: every common-block column; `SOURCE_TABLE` for category (ACTUAL). |
| 3 | `CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED` | KSL_SELECT_SERVICE | 328,292 | `SPROC_STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED` to `STG_KSL_SELECT_SERVICE_MONTHLY_EXTENDED` | As row 2, plus `SPROC_XFRM_KSL_SELECT_SERVICE`: `FCID` joined to the datasets dictionary (row 6) for category; `SCENARIO` carried verbatim. |
| 4 | `CUR_PROFITSWORD_KSL_LEDGER_BATCHES` | KSL_SELECT_SERVICE | 174,751 | `SPROC_STG_KSL_SELECT_SERVICE_LEDGER_BATCHES` to `STG_KSL_SELECT_SERVICE_LEDGER_BATCHES` | As row 2 (category ACTUAL by `SOURCE_TABLE`). |
| 5 | `CUR_PROFITSWORD_KSL_DAILY_LABOR` | KSL_SELECT_SERVICE | 142,919 | `SPROC_STG_KSL_SELECT_SERVICE_DAILY_LABOR` to `STG_KSL_SELECT_SERVICE_DAILY_LABOR` | As row 2 (category ACTUAL by `SOURCE_TABLE`). Employee columns (`PERSON_ID`, `EFFECTIVE_RATE`) stop at staging. |
| 6 | `CUR_PROFITSWORD_KSL_DATASETS` | KSL_SELECT_SERVICE | 24 | `SPROC_STG_KSL_SELECT_SERVICE_DATASETS` to `STG_KSL_SELECT_SERVICE_DATASETS` | `SPROC_XFRM_KSL_SELECT_SERVICE`, CTE `ds`: `FCID`, `SCENARIO_NAME`, `IS_ACTUALS` (category). Since Q-04, 10 of its 24 scenario names map to a category (Actuals, Budget, Budget 2, Primary Forecast, Forecast 2, Forecast 3, Flex, RMS - OneYield, RMS - HiltonGRO/IDeaS, 5 Year Plan 2026 Final); the other 14 have no fact rows. |
| 7 | `CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS` | KSL_SELECT_SERVICE | 17,637 | `SPROC_STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS` to `STG_KSL_SELECT_SERVICE_SALES_PACE_ROOMS` | `SPROC_XFRM_KSL_SELECT_SERVICE` to `XFRM_KSL_SELECT_SERVICE_PACING`, every column. Never seeded (D-37). |
| 8 | `CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT` | KSL_SELECT_SERVICE | 215,710 | `SPROC_STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT` to `STG_KSL_SELECT_SERVICE_SALES_PACE_TRANSIENT` | As row 7. |
| 9 | `CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS` | KSL_SELECT_SERVICE | 11,091 | `SPROC_STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS` to `STG_KSL_SELECT_SERVICE_SALES_PACE_EVENTS` | As row 7, with the event columns and `AMT_FOOD`, `AMT_BEV`, `AMT_RENT`, `AMT_RSRC`, `AMT_MISC`, `AMT_TOTAL`. |
| 10 | `CUR_PROFITSWORD_KSL_SALES_BOOKINGS` | KSL_SELECT_SERVICE | 4,229 | `SPROC_STG_KSL_SELECT_SERVICE_SALES_BOOKINGS` to `STG_KSL_SELECT_SERVICE_SALES_BOOKINGS` | Unused after staging. Pacing-side dictionary (Q-07): pace `BOOKING_CODE` links to its `SALE_SYS_CODE`. Kept for consumers. |
| 11 | `CUR_PROFITSWORD_KSL_SITES` | KSL_SELECT_SERVICE | 41 | `SPROC_STG_KSL_SELECT_SERVICE_SITES` to `STG_KSL_SELECT_SERVICE_SITES` | Unused after staging. `ASSET_NAME` comes from the fact rows' own `SITE_NAME`. |
| 12 | `CUR_PROFITSWORD_KSL_SITE_GROUPS` | KSL_SELECT_SERVICE | 137 | `SPROC_STG_KSL_SELECT_SERVICE_SITE_GROUPS` to `STG_KSL_SELECT_SERVICE_SITE_GROUPS` | Unused after staging. Region membership, many-to-many; no fact column carries a group. |
| 13 | `CUR_PROFITSWORD_KSL_ACCOUNT_CLASS` | KSL_SELECT_SERVICE | 54 | `SPROC_STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS` to `STG_KSL_SELECT_SERVICE_ACCOUNT_CLASS` | Unused after staging. No fact column carries `DEPARTMENT_CLASS` (M1). |
| 14 | `CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED` | PEREGRINE_RESORTS | 335,161 | `SPROC_STG_PEREGRINE_RESORTS_DAILY_EXTENDED` to `STG_PEREGRINE_RESORTS_DAILY_EXTENDED` | `SPROC_XREF_ACCOUNT_CLASSIFICATION`: `SOURCE_SITE_CODE`, `DEPARTMENT`, `ACCOUNT_KEY`, `RECORD_TYPE`, `MIN()` of `ASSET_NAME`, `DEPARTMENT_NAME`, `ACCOUNT_NUMBER`, `STAT_ACCOUNT`, `ACCOUNT_DESC`. `SPROC_XFRM_PEREGRINE_RESORTS`: every common-block column; `SOURCE_TABLE` for category (ACTUAL). |
| 15 | `CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED` | PEREGRINE_RESORTS | 122,070 | `SPROC_STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED` to `STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED` | As row 14, plus `SPROC_XFRM_PEREGRINE_RESORTS`: `FCID` joined to the datasets dictionary (row 18) for category; `SCENARIO` carried verbatim. |
| 16 | `CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES` | PEREGRINE_RESORTS | 30,889 | `SPROC_STG_PEREGRINE_RESORTS_LEDGER_BATCHES` to `STG_PEREGRINE_RESORTS_LEDGER_BATCHES` | As row 14 (category ACTUAL by `SOURCE_TABLE`). |
| 17 | `CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR` | PEREGRINE_RESORTS | 260,735 | `SPROC_STG_PEREGRINE_RESORTS_DAILY_LABOR` to `STG_PEREGRINE_RESORTS_DAILY_LABOR` | As row 14 (category ACTUAL by `SOURCE_TABLE`). Employee columns (`PERSON_ID`, `EFFECTIVE_RATE`) stop at staging. |
| 18 | `CUR_PROFITSWORD_PEREGRINE_DATASETS` | PEREGRINE_RESORTS | 12 | `SPROC_STG_PEREGRINE_RESORTS_DATASETS` to `STG_PEREGRINE_RESORTS_DATASETS` | `SPROC_XFRM_PEREGRINE_RESORTS`, CTE `ds`: `FCID`, `SCENARIO_NAME`, `IS_ACTUALS` (category). Since Q-04, 6 of its 12 names map (Actuals, Budget, Budget 2, Primary Forecast, Forecast 2, Flex); the other 6, including `5 Year Plan 2026` and `RMS`, have no fact rows. |
| 19 | `CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS` | PEREGRINE_RESORTS | 1,122 | `SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS` to `STG_PEREGRINE_RESORTS_SALES_PACE_ROOMS` | `SPROC_XFRM_PEREGRINE_RESORTS` to `XFRM_PEREGRINE_RESORTS_PACING`, every column. Never seeded (D-37). |
| 20 | `CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT` | PEREGRINE_RESORTS | 2,405 | `SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT` to `STG_PEREGRINE_RESORTS_SALES_PACE_TRANSIENT` | As row 19. |
| 21 | `CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS` | PEREGRINE_RESORTS | 5,371 | `SPROC_STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS` to `STG_PEREGRINE_RESORTS_SALES_PACE_EVENTS` | As row 19, with the event columns and `AMT_FOOD`, `AMT_BEV`, `AMT_RENT`, `AMT_RSRC`, `AMT_MISC`, `AMT_TOTAL`. |
| 22 | `CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS` | PEREGRINE_RESORTS | 4,899 | `SPROC_STG_PEREGRINE_RESORTS_SALES_BOOKINGS` to `STG_PEREGRINE_RESORTS_SALES_BOOKINGS` | Unused after staging. Pacing-side dictionary (Q-07). Kept for consumers. |
| 23 | `CUR_PROFITSWORD_PEREGRINE_SITES` | PEREGRINE_RESORTS | 6 | `SPROC_STG_PEREGRINE_RESORTS_SITES` to `STG_PEREGRINE_RESORTS_SITES` | Unused after staging. `ASSET_NAME` comes from the fact rows' own `SITE_NAME`. |
| 24 | `CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS` | PEREGRINE_RESORTS | 13 | `SPROC_STG_PEREGRINE_RESORTS_SITE_GROUPS` to `STG_PEREGRINE_RESORTS_SITE_GROUPS` | Unused after staging. Region membership; no fact column carries a group. Empty until the 07:39 reload. |
| 25 | `CUR_PROFITSWORD_PEREGRINE_ACCOUNT_CLASS` | PEREGRINE_RESORTS | 123 | `SPROC_STG_PEREGRINE_RESORTS_ACCOUNT_CLASS` to `STG_PEREGRINE_RESORTS_ACCOUNT_CLASS` | Unused after staging. No fact column carries `DEPARTMENT_CLASS` (M1). Empty until the 07:39 reload. |

**25 rows, 25 tables:** 1 shared, 12 KSL_SELECT_SERVICE, 12 PEREGRINE_RESORTS.
No table is empty on the current extract.

## Build objects

`{L}` below is `KSL_SELECT_SERVICE` or `PEREGRINE_RESORTS`.

| Object | Built by | Read by |
|---|---|---|
| `XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION` | `SPROC_XREF_ACCOUNT_CLASSIFICATION`, called by each `SPROC_XREF_{L}_MAIN` | `SPROC_XFRM_{L}`, CTE `cls` only: the five key parts, `H1`-`H5`, `P_L_SECTION`, `NORMAL_BALANCE`, `VALUE_SIGN`, `METRIC_UNIT`, `AGGREGATION_TYPE`. Also the three review views. |
| `VW_XREF_NEW_THIS_RUN`, `VW_XREF_UNCLASSIFIED`, `VW_XREF_AWAITING_SIGN` | each `SPROC_XREF_{L}_MAIN` | the review report only; no procedure |
| `XFRM_{L}_INCOME_STATEMENT` | `SPROC_XFRM_{L}` | `SPROC_SEM_INCOME_STATEMENT_{ACTUAL,BUDGET,FORECAST}`, split on `CATEGORY` |
| `XFRM_{L}_BALANCE_SHEET` | `SPROC_XFRM_{L}` | `SPROC_SEM_BALANCE_SHEET` |
| `XFRM_{L}_OPERATING_METRICS` | `SPROC_XFRM_{L}` | `SPROC_SEM_OPERATING_METRICS` |
| `XFRM_{L}_UNKNOWN` | `SPROC_XFRM_{L}` | `SPROC_SEM_UNKNOWN` |
| `XFRM_{L}_PACING` | `SPROC_XFRM_{L}` | none: it ends at transformation (D-21) |
| `SEM_*` x6 | `SPROC_SEM_*`, called by `SPROC_SEM_MAIN` | consumers |

## Orchestration

| MAIN | Calls |
|---|---|
| `SPROC_STG_{L}_MAIN` | `SPROC_STG_SHARED_CHART_OF_ACCOUNTS` and the lane's 12 staging models (`models=13`) |
| `SPROC_XREF_{L}_MAIN` | `SPROC_XREF_ACCOUNT_CLASSIFICATION(run_id, '{L}')`, then the three views |
| `SPROC_XFRM_{L}_MAIN` | `SPROC_XFRM_{L}` |
| `SPROC_SEM_MAIN` | the six `SPROC_SEM_*` |

**41 procedures are deployed, each with exactly one file under `sql/`**
(parity after the Q-04 re-run, `M6-q04-rerun.md`: 41 OK). No procedure
exists outside a MAIN's call list. Test harnesses outside the pipeline,
never deployed: `scripts/run_build.sql` and `scripts/reconcile_{L}.sql`.

## Not read

- `CLN.XREF` is not read (D-03).
- Nothing outside `CLN.CLEAN` and `DEV_G2M_AI` is read.
