# Field lineage - build 02 (HHG, NEWBURY)

**The question: where does each column come from?** Every semantic column, per
lane, traced to the source column or the rule that sets it. Procedures:
staging `SPROC_STG_{LANE}_{SUBJECT}`, classification
`SPROC_XREF_ACCOUNT_CLASSIFICATION` (HHG and NEWBURY branches), transformation
`SPROC_XFRM_{LANE}`, semantic `SPROC_SEM_AI_*` (lane blocks HHG and NEWBURY).

Abbreviations: **TR12** `CLN_HERITAGE_GOLF_TR12_DATA`, **ANA**
`..._FORECAST_ANAPLAN`, **RND** `..._ROUNDS_DETAIL`, **TB**
`CLN_NEWBURY_BOSTON_TRIAL_BALANCE`, **BGT/PY** `..._OPERATING_STATS_BGT` and
`..._PYACT`. Dictionary joins are exact on a unique key, left joins.

## Common block

| Column | Set in | HHG | NEWBURY |
|---|---|---|---|
| `RUN_ID` | each layer's MAIN | the layer's own run stamp | same |
| `SOURCE_LANE` | staging | literal `HHG` | literal `NEWBURY` |
| `SOURCE_SITE_CODE` | staging | TR12: segment 1 of `ACCOUNT_CODE` (entity); ANA: `LOCATION`; RND: `CLUB_CODE`; each as written (owner Q-03) | TB: `BUSINESS_UNIT`; BGT/PY: `HOTEL_ID` (owner Q-11) |
| `ASSET_NAME` | staging | TR12: null (no exact link, Q-03); ANA: `LOCATION`; RND: `CLUB_LIST.CLUB_NAME` on `CLUB_CODE` | `PROPERTY_NAME` |
| `DEPARTMENT` | staging | TR12: segment 2 of `ACCOUNT_CODE`; ANA, RND: null | TB: segment 1 of `FULL_ACCOUNT_KEY`; BGT/PY: null |
| `DEPARTMENT_NAME` | staging | null (no dictionary names them, Q-02) | TB: `ACCOUNTS.DEPARTMENT_DESCRIPTION` on `FULL_ACCOUNT_STRING`; BGT/PY: null |
| `ACCOUNT_NUMBER` | staging | TR12: `ACCOUNT_CODE` raw; ANA, RND: null | TB: `FULL_ACCOUNT_KEY` raw; BGT/PY: null |
| `STAT_ACCOUNT` | staging | null (no column) | null (no column) |
| `ACCOUNT_KEY` | staging | D-06 coalesce. TR12: `ACCOUNT_CODE`; ANA: `LINE_ITEM` (`SOURCE_ITEM_ID`); RND: `~BLANK~` | TB: `FULL_ACCOUNT_KEY`; BGT/PY: `~BLANK~` |
| `RECORD_TYPE` | staging | TR12: `STATISTIC` where dept = 999 (owner Q-01), else `AMOUNT`; ANA: `AMOUNT`; RND: `STATISTIC` (owner Q-07) | TB: `VALUE_TYPE` Amount -> `AMOUNT`, STAT -> `STATISTIC`; BGT/PY: `AMOUNT` (D-29) |
| `RECORD_TYPE_SOURCE` | staging | the rule text per table | TB: `VALUE_TYPE <value> (stated by the source)`; BGT/PY: D-29 rule text |
| `STAT_UNIT_FAMILY` | staging | null | TB: `SUBACCOUNT` on STAT rows; BGT/PY: `'ROOMS'` (D-29) |
| `ACCOUNT_DESC` | staging | TR12: `ACCOUNTS.ACCOUNT_DESCRIPTION` on `FULL_ACCOUNT_STRING` (null on all rows, Q-02); ANA: `LINE_ITEM`; RND: null | TB: `ACCOUNTS.ACCOUNT_DESCRIPTION`; BGT/PY: null |
| `PERIOD_END` | staging | TR12, ANA: `PERIOD_DATE`; RND: `ROUND_DATE` (a day) | TB: `PERIOD_DATE`; BGT/PY: `STAY_DATE` (a day) |
| `CATEGORY` | transformation | TR12 `SCENARIO` ACT / PY ACT -> ACTUAL; ANA `KFCST FINAL` -> FORECAST; RND -> ACTUAL by `SOURCE_TABLE` | TB `MEASURE_COLUMN` -> ACTUAL / BUDGET / FORECAST; BGT `Budget` -> BUDGET; PY `Actual` -> ACTUAL |
| `SCENARIO` | staging | TR12, ANA: `SCENARIO` verbatim; RND: null | TB: `FORECAST_VERSION` on the forecast branch, null on actual and budget; BGT/PY: `SCENARIO` verbatim |
| `H1`-`H5`, `P_L_SECTION`, `NORMAL_BALANCE` | classification, joined in transformation | see `classification-coverage.md` | same |
| `IS_SUBTOTAL` | staging | ANA: `LOCATION = '+All Regions'`; others false | TB: `NODE_TYPE <> 'Leaf'`; BGT/PY: false |
| `SUBTOTAL_SOURCE` | staging | the rule text | the rule text |
| `SOURCE_AMOUNT` | staging | TR12: `AMOUNT` where dept <> 999, null where 999; ANA: `AMOUNT`; RND: null | TB: the branch's measure column on Amount rows, null on STAT rows; BGT/PY: `REVENUE` |
| `STAT_VALUE` | staging | TR12: `AMOUNT` where dept = 999; ANA: null; RND: `ROUNDS_COUNT` | TB: the branch's measure column on STAT rows; BGT/PY: `ROOMS` |
| `SOURCE_LINE_KEY` | staging | TR12, ANA: `SOURCE_FILE_PATH\|SOURCE_ROW_NUMBER\|PERIOD_DATE`; RND: `...\|CLUB_CODE` | TB: `FULL_ACCOUNT_KEY\|PERIOD_DATE\|VALUE_TYPE\|MEASURE_COLUMN`; BGT/PY: `SOURCE_FILE_PATH\|SOURCE_ROW_NUMBER` |
| `SOURCE_TABLE` | staging | literal fully qualified CLN table | same |

The key parts are unique on every fact table (M3, check 2): no
`SOURCE_LINE_KEY` repeats.

## Per-table additions

| Column | Set in | Rule |
|---|---|---|
| `VALUE_SIGN` | classification | from `NORMAL_BALANCE`: Credit +1, Debit -1, Mixed and null -> null (D-13) |
| `VALUE` | transformation | `SOURCE_AMOUNT * VALUE_SIGN`; null wherever either is null |
| `METRIC_UNIT` | classification | null on every key (D-38) |
| `AGGREGATION_TYPE` | classification | `UNRATIFIED` on every Statistic key; null otherwise |
| `UNKNOWN_REASON` | transformation | `UNCLASSIFIED_ACCOUNT` / `UNRESOLVED_CATEGORY` / `BOTH` |
| `UNRESOLVED_CATEGORY_VALUE` | transformation | HHG: the scenario (RND: the source table); NEWBURY: TB `MEASURE_COLUMN`, else the scenario; only where category is null (none this build) |

## Raw columns carried in staging, renamed

Two raw names collide with standard columns, so they are carried under new
names:
- TB `DEPARTMENT` as `SRC_DEPARTMENT`, and `ACCOUNT_KEY` as `SRC_ACCOUNT_KEY`.
- Both `ACCOUNTS` dictionaries' `SOURCE_TABLE` as `ACCOUNTS_SOURCE_TABLE`.

`SCENARIO` on TR12, ANA, BGT and PY is carried once, as the standard column.
Every other raw column is carried under its own name; the M3 hash test showed
the carried raw columns equal the CLN table on all 15 tables.

## Pacing (`XFRM_NEWBURY_PACING`)

- `RUN_ID`, `SOURCE_LANE`, `SOURCE_TABLE` come from the staging table.
- `AS_OF_DATE` is OTB `REPORT_DATE`, FCST `FILE_REPORT_DATE` or SHOPS
  `REPORTED_DATE`, and `AS_OF_SOURCE` names which.
- The other 28 columns are each source's own columns by name, cast to one type
  per name, and null where a source does not have the column.

`XFRM_HHG_PACING` has no rows (no source).
