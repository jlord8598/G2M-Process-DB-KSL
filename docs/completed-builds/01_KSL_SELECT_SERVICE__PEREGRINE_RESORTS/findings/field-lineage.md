# Field lineage - where does each column come from?

Every `SEMANTIC` column, traced to its origin. Every semantic model selects
from `XFRM_{LANE}_{STREAM}` by name, cast to type. Every transformation
procedure takes the staged value, or the classification CTE, as stated here.
The staging mapping per source table is in `docs/sources.md`, "Mapping per
fact table". It is restated below by column.

Regenerated after the Q-04 re-run (`M6-q04-rerun.md`). **Changed from M6:**
the `CATEGORY` rule (four more scenario names map to `FORECAST`) and the
populated values of `UNKNOWN_REASON` and `UNRESOLVED_CATEGORY_VALUE`. Every
other row is as at M6; the staging and classification code did not change
(parity, 41 OK).

**Read as:** CLN column -> STG derivation -> XFRM -> SEM.
- "staging" means set in `SPROC_STG_{LANE}_{TABLE}`.
- "classification" means `XREF_ACCOUNT_CLASSIFICATION`, read in the marked
  CTE of `SPROC_XFRM_{LANE}` and joined on the five-part key.
- `DAILY`, `MONTHLY`, `LEDGER`, `LABOR` are the four fact tables.

## Common block

| SEM column | Origin | Rule |
|---|---|---|
| `RUN_ID` | `SPROC_SEM_MAIN` | The semantic MAIN's own stamp; each layer has its own (D-27). |
| `SOURCE_LANE` | staging | Literal lane name in each staging model. |
| `SOURCE_SITE_CODE` | staging | `nullif(trim(SITE_TAG),'')`, all four tables. |
| `ASSET_NAME` | staging | `SITE_NAME`, all four tables. |
| `DEPARTMENT` | staging | Text before the first `-` of the trimmed account (`ACCOUNT_NUMBER` daily/monthly, `GL_ACCT` ledger). Labor: digits before the first `.` of `DEPARTMENT_LABEL`. Null where blank; the key part is `~BLANK~` (Q-03, Q-06). |
| `DEPARTMENT_NAME` | staging | Chart `DEPARTMENT` for (tenant, department code), grouped to one row per code. Never the classification copy. |
| `ACCOUNT_NUMBER` | staging | Raw `ACCOUNT_NUMBER` (daily, monthly) or `GL_ACCT` (ledger); null on labor. Malformed values included. |
| `STAT_ACCOUNT` | staging | Raw `STAT_ACCOUNT` (daily, monthly) or `STAT_ACCT` (ledger); null on labor. |
| `ACCOUNT_KEY` | staging | `coalesce(nullif(trim(account),''), nullif(trim(stat),''), nullif(trim(SOURCE_ITEM_ID),''), '~BLANK~')`. `SOURCE_ITEM_ID` is `ITEM_TAG` (daily, monthly), `LABEL` (labor), null on the ledger (Q-14). |
| `RECORD_TYPE` | staging | `STATISTIC` where the stat account is present and the account blank; otherwise `AMOUNT` (Q-01, Q-15). |
| `RECORD_TYPE_SOURCE` | staging | Text naming which of the four row shapes applied. |
| `STAT_UNIT_FAMILY` | staging | First two characters of segment 2 of the trimmed stat account; null where blank (D-29). |
| `ACCOUNT_DESC` | staging | `DESCRIPTION` (daily, monthly), `ITEM_DESCRIPTION` (ledger), `LABEL` (labor). Never the classification copy. |
| `PERIOD_END` | staging | `BUSINESS_DATE` (daily, labor), `last_day(PERIOD_DATE)` (monthly), `last_day(FISCAL_PERIOD_DATE)` (ledger). |
| `CATEGORY` | `SPROC_XFRM_{LANE}`, CTE `cat` | Daily, ledger, labor: `ACTUAL` by `SOURCE_TABLE`. Monthly: `FCID` joined to `STG_{LANE}_DATASETS`. `IS_ACTUALS` gives `ACTUAL`; otherwise the exact `SCENARIO_NAME` gives `BUDGET` (`Budget`, `Budget 2`) or `FORECAST` (`Primary Forecast`, `Forecast 2`, `Forecast 3`, and since Q-04 `Flex`, `RMS - OneYield`, `RMS - HiltonGRO/IDeaS`, `5 Year Plan 2026 Final`); any other name is null. The same list is in both lanes' code. In this extract every monthly row resolves on both lanes. |
| `SCENARIO` | staging | Monthly `SCENARIO_NAME` verbatim; null elsewhere. Never replaced by the category (D-17). |
| `H1`-`H5` | classification | Seeded once per key by `SPROC_XREF_ACCOUNT_CLASSIFICATION` (M4.md, derivation rules). In `SEM_UNKNOWN` they are nulled where `H1 = Unclassified`. |
| `P_L_SECTION`, `NORMAL_BALANCE` | classification | Fixed function of `H2` (D-12). |
| `IS_SUBTOTAL` | staging | `TRUE` where `ITEM_TAG` starts `TOT` (daily, monthly); `FALSE` otherwise and on ledger and labor (Q-05). |
| `SUBTOTAL_SOURCE` | staging | The rule that applied, including the `RF`/`DVR`/`CFL`/`SEQ` borderline note. |
| `SOURCE_AMOUNT` | staging | `AMT` (daily, monthly, ledger) or `AMOUNTS` (labor), cast to `FLOAT`, as booked. |
| `STAT_VALUE` | staging | `STAT` (daily, monthly), `QTY` (ledger), `HOURS` (labor), cast to `FLOAT`. |
| `SOURCE_LINE_KEY` | staging | Daily: `SITE_TAG|BUSINESS_DATE|ITEM_TAG`. Monthly: `FCID|SITE_TAG|PERIOD_DATE|ITEM_TAG`. Ledger: `SITE_TAG|BATCH_ID|GL_ACCT|STAT_ACCT|ITEM_DESCRIPTION|LINE_SEQ`. Each part is `~BLANK~`-coalesced. Labor: null (Q-06). |
| `SOURCE_TABLE` | staging | Literal fully qualified `CLN.CLEAN` table name. Never null (check 2(i)). |

## Per-table additions

| SEM table | Column | Origin | Rule |
|---|---|---|---|
| income statement x3, balance sheet | `VALUE_SIGN` | classification | `+1` Credit, `-1` Debit, null for Mixed and wherever `NORMAL_BALANCE` is null. On balance sheet rows it is always null. |
| income statement x3, balance sheet | `VALUE` | `SPROC_XFRM_{LANE}` | `SOURCE_AMOUNT * VALUE_SIGN`; null where either is null. |
| operating metrics, unknown | `METRIC_UNIT` | classification | Always null: the source states no unit (D-38). |
| operating metrics, unknown | `AGGREGATION_TYPE` | classification | `UNRATIFIED` on `Statistic` keys; null otherwise (D-30). |
| unknown | `UNKNOWN_REASON` | `SPROC_XFRM_{LANE}` | `BOTH` if `H1 = Unclassified` and `CATEGORY` is null; else `UNCLASSIFIED_ACCOUNT` or `UNRESOLVED_CATEGORY`. **Populated now:** `UNCLASSIFIED_ACCOUNT` only (KSL 1,831,009, PEREGRINE 504,666). M6 also had `UNRESOLVED_CATEGORY` (KSL 89,592, PEREGRINE 36,952) and `BOTH` (706, 20); Q-04 resolved them. The rule is unchanged and still applies to any future unmapped scenario. |
| unknown | `UNRESOLVED_CATEGORY_VALUE` | `SPROC_XFRM_{LANE}` | Where `CATEGORY` is null: monthly gives the scenario name (or `FCID n` if not in `DATASETS`); other tables give `SOURCE_TABLE`. Null otherwise. **Null on every row now** (2(j) holds). |

## Not carried to SEMANTIC

- **Staging only:** labor's `PERSON_ID`, `EMPLOYEE_ID` and `EMPLOYEE_NAME`
  (Q-06), and every other raw column carried verbatim in staging.
  `SOURCE_LINE_KEY` reaches them.
- **Transformation only:** pacing columns (`XFRM_{LANE}_PACING`), which has
  no semantic table (D-21).
