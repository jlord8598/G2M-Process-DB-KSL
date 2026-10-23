# Field lineage - build 06 (DAVIDSON, HHG, HERSHA)

**Where does each column come from?** Staging derives every column below.
Transformation adds classification columns from the one classification CTE,
plus `CATEGORY`, `VALUE` and `UNKNOWN_REASON`. Semantic selects by name.
HHG and HERSHA columns are as builds 02 and 03 recorded, except the rows
marked "build 06".

## DAVIDSON

| Column | `HOTEL_MONTHLY_REPORT` (`SPROC_STG_DAVIDSON_HOTEL_MONTHLY_REPORT`) | `FULL_YEAR_PL` (`SPROC_STG_DAVIDSON_FULL_YEAR_PL`) |
|---|---|---|
| `SOURCE_LANE` | `'DAVIDSON'` | `'DAVIDSON'` |
| `SOURCE_SITE_CODE` | `nullif(trim(HOTEL_CODE),'')` | `nullif(trim(HOTEL_CODE),'')`; null on `IS_ROLLUP` rows |
| `ASSET_NAME` | `HOTEL_NAME` | `HOTEL_NAME` (`Islamorada` / `Davenport Collection` on roll-ups) |
| `DEPARTMENT` | `split_part(ACCOUNT,'-',1)` on a 6-segment `ACCOUNT`, else null | `nullif(trim(SECTION),'')` |
| `DEPARTMENT_NAME` | null | null |
| `ACCOUNT_NUMBER` | `ACCOUNT`, raw | null |
| `STAT_ACCOUNT` | null | null |
| `ACCOUNT_KEY` | `coalesce(nullif(trim(ACCOUNT),''), nullif(trim(LINE_CLASS),''), '~BLANK~')` | `coalesce(nullif(regexp_replace(trim(LINE_ITEM),' {2,}',' '),''), '~BLANK~')` (Q-05) |
| `RECORD_TYPE` / `_SOURCE` | STATISTIC on `LINE_CLASS` ADR/Rooms (Q-06) or natural 9000-9990 (Q-07; 9990 stated as an offset), else AMOUNT | STATISTIC on the SUMMARY hotel-heading sections (Q-06), else AMOUNT |
| `STAT_UNIT_FAMILY` | null | null |
| `ACCOUNT_DESC` | `STG_DAVIDSON_ACCOUNTS`, `MIN(ACCOUNT_DESCRIPTION)` on entity = `HOTEL_CODE`, string = `ACCOUNT`, else `LINE_CLASS` | same dictionary on entity = `coalesce(HOTEL_CODE, HOTEL_NAME)`, string = `LINE_ITEM` |
| `PERIOD_END` | `PERIOD_DATE` | `PERIOD_DATE` |
| `SCENARIO` | `'ACTUAL_AMOUNT'` / `'FORECAST_AMOUNT'`: the branch's measure column (D-45) | same |
| `CATEGORY` | `SPROC_XFRM_DAVIDSON`, from `MEASURE_COLUMN` ACTUAL / FORECAST | same |
| `SOURCE_AMOUNT` / `STAT_VALUE` | the branch's `*_AMOUNT`, to one or the other by `RECORD_TYPE` | same |
| `IS_SUBTOTAL` / `SUBTOTAL_SOURCE` | `FALSE` / `source gives no way to tell` | `IS_ROLLUP`; SUMMARY amount line (GOP / EBITDA named); amount line with first word `Total` (Q-08) |
| `SOURCE_LINE_KEY` | hotel, class, account, period, branch | hotel, hotel name, sheet, section, line, period, four file/row pointers, branch |
| `SOURCE_TABLE` | the CLN table, fully qualified | same |
| `H1`-`H5`, `P_L_SECTION`, `NORMAL_BALANCE`, `VALUE_SIGN`, `METRIC_UNIT`, `AGGREGATION_TYPE` | `XREF_ACCOUNT_CLASSIFICATION`, DAVIDSON branch of the seeder (`M4.md`) | same |
| `VALUE` | `SOURCE_AMOUNT * VALUE_SIGN` (`SPROC_XFRM_DAVIDSON`) | same |
| Staging only | `MEASURE_COLUMN`, `NATURAL_ACCOUNT` (segment 2), every raw column | `MEASURE_COLUMN`, every raw column |

## HHG (build 06 changes)

| Column | Model | Lineage |
|---|---|---|
| `ASSET_NAME` | `SPROC_STG_HHG_TR12_DATA` | `STG_HHG_REFERENCES.CLUB_NAME` on `CLUB_NUMBER` = the entity segment; null otherwise (Q-02) |
| `ASSET_NAME_SOURCE` | `SPROC_STG_HHG_TR12_DATA` (staging only) | the source used, or null |
| `SCENARIO` | `SPROC_STG_HHG_ROUNDS_DETAIL` | `'CLN_HERITAGE_GOLF_ROUNDS_DETAIL'` (D-45, Q-03) |

## HERSHA (build 06 change)

| Column | Model | Lineage |
|---|---|---|
| `SCENARIO` | `SPROC_STG_HERSHA_GL_ACTUAL`, `_GL_STAT` | `'ACTUAL_AMOUNT'` / `'FORECAST_AMOUNT'`, the branch's defining measure column (D-45, Q-03) |
