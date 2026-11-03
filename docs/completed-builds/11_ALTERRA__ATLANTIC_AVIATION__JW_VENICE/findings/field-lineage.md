# Field lineage - build 11 (ALTERRA, ATLANTIC_AVIATION, JW_VENICE)

**Where does each column come from?** Every column is carried through
STG -> XFRM -> SEM unchanged, except where a row below says otherwise. The
classification columns come only from `XREF_ACCOUNT_CLASSIFICATION` (via the
one marked CTE).

| Column | ALTERRA (MONTHLY_FINANCIALS) | ATLANTIC_AVIATION (OC_DATA) | JW_VENICE (FCAST x2; FTE, HEADCOUNT) |
|---|---|---|---|
| `SOURCE_SITE_CODE` | ENTITY | ENTITY | PROPERTY_NAME |
| `ASSET_NAME` | ENTITY | ENTITY | PROPERTY_NAME |
| `DEPARTMENT` | SECTION (null kept; key `~BLANK~`) | SECTION as stored | SECTION; FTE / HEADCOUNT: DEPARTMENT_LABEL (Q-04) |
| `DEPARTMENT_NAME` | SECTION | null | SECTION; FTE / HEADCOUNT: source DEPARTMENT_NAME |
| `ACCOUNT_NUMBER`, `STAT_ACCOUNT` | null (no account in the source) | null | null |
| `ACCOUNT_KEY` | LINE_ITEM as `SOURCE_ITEM_ID` (D-06) | LINE_ITEM | LINE_ITEM; FTE / HEADCOUNT: the table subject `FTE` / `HEADCOUNT` (Q-04) |
| `ACCOUNT_DESC` | LINE_ITEM | LINE_ITEM | LINE_ITEM; DEPARTMENT_LABEL |
| `RECORD_TYPE` (derived, D-07) | SECTION Skier Visits / KPIs -> STATISTIC | LINE_ITEM Landings, Trips, Gallons, MPG -> STATISTIC (Fuel Margin AMOUNT, Q-13) | KEY STATISTICS except CREDIT CARD EXPENSE -> STATISTIC; FTE / HEADCOUNT all STATISTIC |
| `PERIOD_END` | PERIOD_DATE | PERIOD_DATE | PERIOD_DATE |
| `CATEGORY` (XFRM) | the unpivoted measure column | same | same; PREVIOUS_FORECAST -> FORECAST |
| `SCENARIO` | the measure column name (D-45) | same | same |
| `SOURCE_AMOUNT` / `STAT_VALUE` | the branch's measure, by `RECORD_TYPE` | same | same |
| `IS_SUBTOTAL`, `SUBTOTAL_SOURCE` | M1 rule + Q-15 (`sources.md`) | source IS_SUBTOTAL + computed / bridge lines + Total Company rollup rows (Q-02) | M1 rule; FTE / HEADCOUNT source IS_SUBTOTAL |
| `SOURCE_LINE_KEY` | ENTITY, SECTION, LINE_ITEM, PERIOD_DATE, branch | same | SECTION or DEPARTMENT_LABEL, PERIOD_DATE, branch |
| `UNKNOWN_REASON` (XFRM) | D-48 -> DUPLICATE_DETAIL; IS_SUBTOTAL on an Unclassified key -> SOURCE_ROLLUP | SOURCE_ROLLUP; UNCLASSIFIED_ACCOUNT | SOURCE_ROLLUP |
| `METRIC_UNIT`, `AGGREGATION_TYPE` | null; UNRATIFIED | Fuel Margin currency / FLOW (Q-13); else null; UNRATIFIED | null; UNRATIFIED |

**Staging-only columns** (carried, not used downstream):
- `MEASURE_COLUMN`, `MEASURE_SOURCE_FILE_PATH`, `MEASURE_SOURCE_ROW`;
- every raw source column, including OC `SRC_IS_SUBTOTAL`, `IS_ROLLUP`,
  `IS_HIDDEN_ROW` and the `*_TEXT` columns.

**Pacing:** `XFRM_ALTERRA_PACING` = every staged column, plus `AS_OF_DATE`
(= SNAPSHOT_DATE) and `AS_OF_SOURCE`.
