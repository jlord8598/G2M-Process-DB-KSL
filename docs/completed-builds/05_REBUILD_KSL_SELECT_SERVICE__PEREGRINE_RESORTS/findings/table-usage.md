# Table usage - build 05 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: how were the tables wired?** All 27 `CLN.CLEAN` tables are
in scope. The 26 build 04 tables are wired exactly as in build 04's
`table-usage.md`. Changes:

| Source table | Role | Read by | Columns used | Staged as |
|---|---|---|---|---|
| `CUR_PROFITSWORD_DEPARTMENTS` (**new**, both tenants) | dictionary | `SPROC_STG_{LANE}_DEPARTMENTS` (verbatim); the 8 fact models join `STG_{LANE}_DEPARTMENTS` | `TENANT`, `SITE_TAG`, `DEPT_CODE`, `DEPARTMENT_GENERIC` (`DEPARTMENT_NAME`). `DEPARTMENT_OUTLET`, `OUTLET_SOURCE`, `OUTLET_SPELLINGS` and `ALL_SPELLINGS` are staged and not used. | `STG_KSL_SELECT_SERVICE_DEPARTMENTS`, `STG_PEREGRINE_RESORTS_DEPARTMENTS` (1,523 rows each) |
| `CUR_PROFITSWORD_{T}_COA` | dictionary | `SPROC_STG_{LANE}_COA` (verbatim); daily and monthly read `TAG`, `IS_TOTAL_LINE`, `ACCOUNT_NUMBER` and `STAT_ACCT_NUMBER` for the subtotal rule | **no longer read for `DEPARTMENT_NAME`** | `STG_{LANE}_COA` |
| `CUR_PROFITSWORD_{T}_DATASETS` | dictionary | `SPROC_XFRM_{LANE}`: `SCENARIO_NAME` now also maps `Budget 3` | `FCID`, `SCENARIO_NAME`, `IS_ACTUALS` | `STG_{LANE}_DATASETS` |

**Wiring.** `SPROC_STG_{LANE}_MAIN` makes 14 calls:
- dictionaries first: bookings, datasets, sites, site groups, account class,
  COA, **departments**;
- then the 4 facts and the 3 pace tables.

XREF, XFRM and SEM are wired as in build 04. 93 procedures are deployed,
parity clean.
