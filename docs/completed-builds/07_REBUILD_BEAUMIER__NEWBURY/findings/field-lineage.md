# Field lineage - build 07 (BEAUMIER, NEWBURY)

**Where does each column come from?** Builds 03 (BEAUMIER) and 02 (NEWBURY)
record every column's lineage, and that record stands. Only the rows below
changed in build 07. Transformation and semantic pass these columns through
by name, with no change to either procedure.

| Lane | Column | Model | Lineage (build 07) |
|---|---|---|---|
| BEAUMIER | `ASSET_NAME` | `SPROC_STG_BEAUMIER_BP`, `_BUDGET` | `STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME` on `HOTEL_CODE` exactly, corporate BMR/CPH included; null if unmatched (none on this extract) |
| BEAUMIER | `ASSET_NAME_SOURCE` (staging only) | same | `STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE; ENTITY_TYPE <HOTEL/CORPORATE> (build 07 Q-03)`, or null |
| BEAUMIER | all columns of `STG_BEAUMIER_LOCATION_MAP` | `SPROC_STG_BEAUMIER_LOCATION_MAP` | `CLN_BEAUMIER_LOCATION_MAP` verbatim (`HOTEL_CODE`, `HOTEL_NAME`, `ENTITY_TYPE`), plus `RUN_ID`, `SOURCE_LANE`, `SOURCE_TABLE` |
| NEWBURY | `SCENARIO` | `SPROC_STG_NEWBURY_TRIAL_BALANCE` | ACTUAL branch `'ACTUAL_AMOUNT'`; BUDGET branch `'BUDGET_AMOUNT'`; FORECAST branch `FORECAST_VERSION` verbatim, else `'FORECAST_AMOUNT'` (D-45, Q-04) |

**Unchanged:**
- BEAUMIER CANCELLATIONS (pacing), whose `HOTEL_NAME` is the source's own;
- NEWBURY BGT and PYACT `SCENARIO` (source `Budget` / `Actual`);
- every key, measure, record-type, subtotal and line-key expression.
