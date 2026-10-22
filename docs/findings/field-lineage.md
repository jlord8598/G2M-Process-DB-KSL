# Field lineage - build 03 (HERSHA, INVITED_CLUBS, BEAUMIER)

**The question: where does each column come from?** Every semantic column, per
lane.
- Staging `SPROC_STG_{LANE}_{SUBJECT}`.
- Classification `SPROC_XREF_ACCOUNT_CLASSIFICATION` (build 03 branches).
- Transformation `SPROC_XFRM_{LANE}`.
- Semantic `SPROC_SEM_AI_*` (lane blocks).

Abbreviations: **GA** HERSHA `GL_ACTUAL`, **GS** `GL_STAT`, **ES**
INVITED_CLUBS `ESSBASE_EXTRACT`, **BP / BU** BEAUMIER `BP` / `BUDGET`.

## Common block

| Column | Set in | HERSHA | INVITED_CLUBS | BEAUMIER |
|---|---|---|---|---|
| `RUN_ID` | each MAIN | layer run stamp | same | same |
| `SOURCE_LANE` | staging | literal | literal | literal |
| `SOURCE_SITE_CODE` | staging | `COMPANY_ID` | `ENTITY` | `HOTEL_CODE` |
| `ASSET_NAME` | staging | `COMPANY_NAME` | `META_ENTITY.ALIAS_DEFAULT` on `ENTITY` (MIN per member) | null |
| `DEPARTMENT` | staging | `DEPARTMENT_CODE` | `DEPARTMENT` (raw, carried once) | null |
| `DEPARTMENT_NAME` | staging | `DEPARTMENT_DESCRIPTION` | `META_DEPARTMENT.ALIAS_DEFAULT` | null |
| `ACCOUNT_NUMBER` | staging | `ACCOUNT_CODE` | `ACCOUNT` (member name) | null |
| `STAT_ACCOUNT` | staging | null | null | null |
| `ACCOUNT_KEY` | staging | `ACCOUNT_CODE` | `ACCOUNT` | `LINE_ITEM` (`SOURCE_ITEM_ID`) |
| `RECORD_TYPE` | staging | GA: `GL_CODE` Stat -> STATISTIC else AMOUNT; GS: STATISTIC (Q-02) | `META_ACCOUNT.DATA_TYPE` non-currency -> STATISTIC (Q-05) | AMOUNT |
| `RECORD_TYPE_SOURCE` | staging | rule text per table | `META_ACCOUNT.DATA_TYPE <value>` or "not in META" | rule text |
| `STAT_UNIT_FAMILY` | staging | null (no unit stated) | null | null |
| `ACCOUNT_DESC` | staging | `ACCOUNT_DESCRIPTION` | `META_ACCOUNT.ALIAS_DEFAULT` | `LINE_ITEM` |
| `PERIOD_END` | staging | `PERIOD_DATE` | `PERIOD_DATE` (`DAY_OF_MONTH` carried raw) | `PERIOD_DATE` |
| `CATEGORY` | XFRM | branch ACTUAL / FORECAST | `MEASURE_COLUMN` | table + scenario (Q-07) |
| `SCENARIO` | staging | null | `VERSION_NAME`, + ` \| FORECAST_VERSION` on the forecast branch | `SCENARIO` verbatim |
| `H1`-`H5`, `P_L_SECTION`, `NORMAL_BALANCE` | XREF, joined in XFRM | see `classification-coverage.md` | | |
| `IS_SUBTOTAL` / `SUBTOTAL_SOURCE` | staging | false / "source gives no way to tell" | `EBITDA_SUMMARY` true; `TotalDOMEnter` false, labelled borderline (Q-01) | false |
| `SOURCE_AMOUNT` | staging | GA: branch `_AMOUNT` (AMOUNT rows); GS: null | branch measure on AMOUNT rows | `AMOUNT` |
| `STAT_VALUE` | staging | GA: branch `_STAT`; GS: branch `_AMOUNT` (Q-02) | branch measure on STATISTIC rows | null |
| `SOURCE_LINE_KEY` | staging | 7 key dims + branch | 9 key dims + measure | path\|row\|period\|scenario |
| `SOURCE_TABLE` | staging | literal FQN | literal FQN | literal FQN |

`SOURCE_LINE_KEY` is unique on every fact table (M3).

## Per-table additions

| Column | Set in | Rule |
|---|---|---|
| `VALUE_SIGN` | XREF | `NORMAL_BALANCE`: Credit +1, Debit -1, else null (D-13) |
| `VALUE` | XFRM | `SOURCE_AMOUNT * VALUE_SIGN` |
| `METRIC_UNIT` / `AGGREGATION_TYPE` | XREF | null / `UNRATIFIED` on Statistic keys |
| `UNKNOWN_REASON` / `UNRESOLVED_CATEGORY_VALUE` | XFRM | INVITED_CLUBS `UNCLASSIFIED_ACCOUNT` only; no category value unresolved |

## Staging columns beyond the common block

- **GA, GS:** `MEASURE_COLUMN` (the branch).
- **ES:** `MEASURE_COLUMN`, plus `META_ACCOUNT_TYPE` and `META_DATA_TYPE` (read
  by the seeder).
- **Raw columns:** every one is carried under its own name, except:
  - BEAUMIER `SCENARIO` and ES `DEPARTMENT`, carried once as the standard
    column;
  - the three `ACCOUNTS` dictionaries' `SOURCE_TABLE`, carried as
    `ACCOUNTS_SOURCE_TABLE`.
- **Losslessness:** the M3 hash test showed the raw columns equal CLN on 15 of
  15 comparisons.

## Pacing (`XFRM_BEAUMIER_PACING`)

`RUN_ID`, `SOURCE_LANE`, `SOURCE_TABLE`; `AS_OF_DATE` = `BUSINESS_DATE`, with
`AS_OF_SOURCE` = `'BUSINESS_DATE'`; then all 22 CANCELLATIONS columns by name.
`XFRM_HERSHA_PACING` and `XFRM_INVITED_CLUBS_PACING` have no rows (no source).
