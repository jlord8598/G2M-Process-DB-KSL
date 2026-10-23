# Sources - build 06 (DAVIDSON new; HHG and HERSHA rebuilt)

**State: end of M1 (stop-1 answers applied).** Written from queries run in this
session against `CLN.BOX_INVESTMENT_DATA`. Statements are marked *measured*,
*decided* (owner) or *proposed* (open in `findings/open-questions.md`). The
DAVIDSON profile is in `findings/M1.md`.

**Scope (owner).**
- **DAVIDSON:** a new lane with a full M1 profile, after stop 1.
- **HHG (rebuild, D-44):** `ASSET_NAME` for actuals from `STG_HHG_REFERENCES`
  on an exact GL entity-code match, recording the source used; plus
  `SCENARIO` never null (D-45).
- **HERSHA (rebuild, D-44):** `SCENARIO` never null (D-45) only.
- **Builds 02 and 03's profiles stand for HHG and HERSHA**
  (`docs/completed-builds/02_HHG__NEWBURY/`,
  `docs/completed-builds/03_HERSHA__INVITED_CLUBS__BEAUMIER/`). Only what
  the changes touch is re-measured.

---

## Source schema and freeze (D-43)

- **Source:** `CLN.BOX_INVESTMENT_DATA`.
- **Freeze:** from **2026-10-23 13:21:34.322 PDT** (database clock at the
  first query, query `01c7ede5-020a-44d4-0003-4ff21bc743ae`) **to 2026-10-25
  13:21 PDT** (decided, Q-04).
- **Against earlier records (measured).**
  - The 9 HHG and HERSHA tables carry the same `last_altered` as builds 02
    and 03 recorded (2026-10-19 15:39), with unchanged row counts.
  - The DAVIDSON tables were loaded **2026-10-23 08:36:47-08:36:53 PDT**,
    before the freeze.

**Baseline: every in-scope table's `last_altered`, row count and the sum of
every numeric column (measured).** Every later milestone is checked against
this table.

| Table | Rows | `last_altered` (PDT) | Sums |
|---|---|---|---|
| CLN_DAVIDSON_ACCOUNTS | 32,842 | 2026-10-23 08:36:53.170 | ROW_COUNT=394,104 |
| CLN_DAVIDSON_FULL_YEAR_PL | 237,156 | 2026-10-23 08:36:51.092 | ACTUAL_AMOUNT=8,260,056,979.34; FORECAST_AMOUNT=2,241,894,573.66; ACTUAL_SOURCE_ROW_NUMBER=124,681,335; FORECAST_SOURCE_ROW_NUMBER=42,380,894 |
| CLN_DAVIDSON_HOTEL_MONTHLY_REPORT | 156,948 | 2026-10-23 08:36:47.581 | ACTUAL_AMOUNT=750,402,952.70; FORECAST_AMOUNT=367,041,063.22; ACTUAL_SOURCE_ROW_NUMBER=61,544,955; FORECAST_SOURCE_ROW_NUMBER=32,611,053 |
| CLN_HERITAGE_GOLF_ACCOUNTS | 13,759 | 2026-10-19 15:39:44.169 | ROW_COUNT=183,840 |
| CLN_HERITAGE_GOLF_CLUB_LIST | 50 | 2026-10-19 15:39:34.465 | SOURCE_ROW_NUMBER=1,375 |
| CLN_HERITAGE_GOLF_FORECAST_ANAPLAN | 19,080 | 2026-10-19 15:39:40.072 | AMOUNT=325,117,641.88; SOURCE_ROW_NUMBER=15,292,620 |
| CLN_HERITAGE_GOLF_REFERENCES | 45 | 2026-10-19 15:39:35.764 | SOURCE_ROW_NUMBER=1,080 |
| CLN_HERITAGE_GOLF_ROUNDS_DETAIL | 91,300 | 2026-10-19 15:39:42.542 | ROUNDS_COUNT=6,959,463.04; SOURCE_ROW_NUMBER=84,132,950 |
| CLN_HERITAGE_GOLF_TR12_DATA | 164,760 | 2026-10-19 15:39:38.096 | AMOUNT=828,930,067.59; SOURCE_ROW_NUMBER=1,131,818,820 |
| CLN_HERSHA_ACCOUNTS | 1,196 | 2026-10-19 15:39:49.871 | ROW_COUNT=53,175 |
| CLN_HERSHA_GL_ACTUAL | 50,903 | 2026-10-19 15:39:46.615 | ACTUAL_AMOUNT=-7,680,004.63; FORECAST_AMOUNT=-96,108,648.44; ACTUAL_STAT=833,864.11; FORECAST_STAT=8,643,928.44; ACTUAL_SOURCE_ROW_NUMBER=40,495,490; FORECAST_SOURCE_ROW_NUMBER=1,255,138,569 |
| CLN_HERSHA_GL_STAT | 2,272 | 2026-10-19 15:39:48.593 | ACTUAL_AMOUNT=686,105.65; FORECAST_AMOUNT=null; ACTUAL_STAT=0.00; FORECAST_STAT=null; ACTUAL_SOURCE_ROW_NUMBER=2,586,672; FORECAST_SOURCE_ROW_NUMBER=null |

---

## Tables and lanes (decided, Q-01)

32 tables are visible in `CLN.BOX_INVESTMENT_DATA`.

| Table | Lane | Proposed role |
|---|---|---|
| CLN_DAVIDSON_ACCOUNTS | **DAVIDSON** (new) | dictionary: account, department and subaccount strings per entity |
| CLN_DAVIDSON_FULL_YEAR_PL | **DAVIDSON** | fact: wide by category (`ACTUAL_AMOUNT`, `FORECAST_AMOUNT`), with `IS_ROLLUP`, `SECTION` and `LINE_ITEM` |
| CLN_DAVIDSON_HOTEL_MONTHLY_REPORT | **DAVIDSON** | fact: wide by category (`ACTUAL_AMOUNT`, `FORECAST_AMOUNT`), with `LINE_CLASS`, `LINE_TYPE` and `ACCOUNT` |
| CLN_HERITAGE_GOLF_* (6) | **HHG** (rebuild) | build 02 roles: TR12 fact (actuals), ANAPLAN fact (forecast), ROUNDS fact (statistics), ACCOUNTS, CLUB_LIST and REFERENCES dictionaries |
| CLN_HERSHA_* (3) | **HERSHA** (rebuild) | build 03 roles: GL_ACTUAL and GL_STAT facts, ACCOUNTS dictionary |
| CLN_BEAUMIER_* (4), CLN_INVITED_CLUBS_* (7), CLN_NEWBURY_BOSTON_* (9) | out of scope | other lanes; covered by the earlier-build baseline |

- **Arithmetic.** 12 in scope (DAVIDSON 3, HHG 6, HERSHA 3) + 20 out of scope
  (BEAUMIER 4, INVITED_CLUBS 7, NEWBURY 9) = 32 visible.
- **The DAVIDSON roles are confirmed by the M1 profile.**

## Lane-name check (D-32, measured)

- **`DAVIDSON`** appears nowhere in `docs/completed-builds/` and in no
  `SOURCE_LANE` in `DEV_G2M_AI`. The classification table and the six
  semantic tables hold BEAUMIER, HERSHA, HHG, INVITED_CLUBS,
  KSL_SELECT_SERVICE, NEWBURY and PEREGRINE_RESORTS, all archived.
- **Checking the master is the owner's job.**
- **HHG and HERSHA** are rebuilt under their existing names (D-44).

---

## HHG: `ASSET_NAME` from `REFERENCES` (measured, query `01c7ede5-020a-4652-0003-4ff21bc75376`)

- **Today.** `STG_HHG_TR12_DATA` (actuals) sets `ASSET_NAME` null. The site
  is the GL entity, segment 1 of `ACCOUNT_CODE` (build 02 Q-03).
- **`CLN_HERITAGE_GOLF_REFERENCES`:** 45 rows, unique on `CLUB_NUMBER` (45
  numbers), no blank `CLUB_NAME`.

| | Entity codes | TR12 rows |
|---|---|---|
| In TR12 | 54 | 164,760 |
| Matched exactly to `REFERENCES.CLUB_NUMBER` | **45** | **147,636** |
| Not matched | 9: `9050`-`9056`, `9099`, `9102` | 17,124 |

- **This matches build 02** (45 of 54 codes; the same 9 unmatched on 17,124
  rows).
- **Rule (decided, Q-02).** `ASSET_NAME = STG_HHG_REFERENCES.CLUB_NAME` where
  the entity code equals `CLUB_NUMBER` exactly; null otherwise (a client
  item). A new staging column, `ASSET_NAME_SOURCE`, names the source, as KSL
  and PEREGRINE did in build 04. `FORECAST_ANAPLAN` and `ROUNDS_DETAIL` keep
  their own names. Because TR12 now reads `STG_HHG_REFERENCES`,
  `SPROC_STG_HHG_MAIN` calls the dictionaries before the facts.

## D-45: `SCENARIO` per model (measured, query `01c7ede5-020a-4689-0003-4ff21bc7728e`, and `sql/`)

| Lane | Model | Today | Category from | D-45 rule | Value |
|---|---|---|---|---|---|
| HHG | `TR12_DATA` | source `SCENARIO` | `SCENARIO` | **source name** | `ACT`, `PY ACT` (0 null) |
| HHG | `FORECAST_ANAPLAN` | source `SCENARIO` | `SCENARIO` | **source name** | `KFCST FINAL` (0 null) |
| HHG | `ROUNDS_DETAIL` | null (91,300 rows) | source table | **table name** | `CLN_HERITAGE_GOLF_ROUNDS_DETAIL` |
| HERSHA | `GL_ACTUAL` | null (101,806 staged rows) | unpivoted measure column (`MEASURE_COLUMN` = ACTUAL / FORECAST) | **measure column name** | `ACTUAL_AMOUNT` / `FORECAST_AMOUNT` (decided, Q-03) |
| HERSHA | `GL_STAT` | null (4,544 staged rows) | unpivoted measure column | **measure column name** | `ACTUAL_AMOUNT` / `FORECAST_AMOUNT` (decided, Q-03) |
| DAVIDSON | `HOTEL_MONTHLY_REPORT` | new | unpivoted measure column | **measure column name** | `ACTUAL_AMOUNT` / `FORECAST_AMOUNT` |
| DAVIDSON | `FULL_YEAR_PL` | new | unpivoted measure column | **measure column name** | `ACTUAL_AMOUNT` / `FORECAST_AMOUNT` |

- **Why HERSHA needs a decision.** HERSHA's branches each read a column
  *pair*: `ACTUAL_AMOUNT` with `ACTUAL_STAT`, and `FORECAST_AMOUNT` with
  `FORECAST_STAT`. D-45 asks for "that column's name". The pair's amount
  column is the one that defines the branch: on GL_STAT the count sits in
  `*_AMOUNT` (build 03 Q-02). Hence the proposal.
- **Not a candidate.** The build's own branch label (`ACTUAL`/`FORECAST` in
  `MEASURE_COLUMN`) is not a source name.
- **Category does not change.** `SCENARIO` does not route.

---

## DAVIDSON (new lane; proposed rules Q-05 to Q-09, measured profile in `findings/M1.md`)

| Rule | `HOTEL_MONTHLY_REPORT` | `FULL_YEAR_PL` |
|---|---|---|
| Identity | wide, 2 branches (`ACTUAL_AMOUNT`, `FORECAST_AMOUNT`), nulls kept: x 2 | wide, 2 branches, nulls kept: x 2 |
| Site / asset name | `HOTEL_CODE` / `HOTEL_NAME` | `HOTEL_CODE` (null on `IS_ROLLUP` rows) / `HOTEL_NAME` |
| Department | segment 1 of a 6-segment `ACCOUNT`, else null | `SECTION` |
| `SOURCE_ITEM_ID` | `LINE_CLASS` | `LINE_ITEM` |
| `ACCOUNT_KEY` | `ACCOUNT`, else `LINE_CLASS` | `LINE_ITEM` |
| `RECORD_TYPE` | `LINE_CLASS` `ADR`/`Rooms` STATISTIC, `Item` AMOUNT | `SUMMARY` hotel-heading section STATISTIC, else AMOUNT |
| Section digit | leading digit of segment 2 (natural account) | none; section words where stated (Q-09) |
| Statistic units | none stated (`STAT_UNIT_FAMILY` null) | none stated |
| Category | measure column (at M5) | measure column |
| `SOURCE_LINE_KEY` | hotel, class, account, period, branch (unique, M1) | hotel or roll-up name, sheet, section, line, period, four pointers, branch (unique, M1) |
| Period | `PERIOD_DATE` (month-end) | `PERIOD_DATE` (month-end) |
| Subtotals | none stated: `FALSE` | `IS_ROLLUP`; `SUMMARY` amount lines; `Total` first word (Q-08) |
| Pacing | none: one as-of per line | none |

**Decided at stop 3 (owner).**
- **Q-05:** the PL `ACCOUNT_KEY` is the line text (D-06 fallback through
  `SOURCE_ITEM_ID`). The only cleanup is trimming and collapsing repeated
  spaces, so the key stays deterministic. No line on this extract has
  repeated spaces, so the key equals `LINE_ITEM` on every row.
- **Q-06:** `RECORD_TYPE` as above.
- **Q-08:** subtotals as above, with `Gross Operating Profit`, `EBITDA` and
  `EBITDA LESS REPLACEMENT RESERVE` named in their own `SUBTOTAL_SOURCE`
  text. `Total RevPar` stays a non-subtotal statistic.
- **Q-10, for consumers:** `FULL_YEAR_PL` and `HOTEL_MONTHLY_REPORT` cover
  the same hotels and months. **Separate them by `SOURCE_TABLE`**; summing
  both counts the money twice.
- **Pending with the source owner (M4 held):** Q-07 (MR 9000-9990: statistics
  or amounts) and Q-09 (hierarchy, including 5xxx).

`STG_DAVIDSON_ACCOUNTS` stages the dictionary losslessly. The facts take
`ACCOUNT_DESC` from it: `MIN(ACCOUNT_DESCRIPTION)` per entity + string +
source table, one value per string (M1).

## Keys

None of the HHG and HERSHA changes touches a key part (`ASSET_NAME` and `SCENARIO`
are not in the five-part key). The D-44 key report runs at M4 for HHG and
HERSHA.

## Corrections

None yet.
