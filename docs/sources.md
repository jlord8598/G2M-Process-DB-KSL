# Sources - build 07 (rebuild of BEAUMIER and NEWBURY, D-44)

**State: stop 1 of M1.** Written from queries run in this session against
`CLN.BOX_INVESTMENT_DATA`. Statements are marked *measured*, *decided*
(owner) or *proposed* (open in `findings/open-questions.md`).

**Scope (owner).**
- **BEAUMIER (rebuild, D-44):**
  - fill `ASSET_NAME` from `CLN_BEAUMIER_LOCATION_MAP` on an exact
    hotel-code join;
  - add `ASSET_NAME_SOURCE`, as for HHG in build 06;
  - BMR and CPH are corporate entities;
  - report any hotel code with no match.
- **NEWBURY (rebuild, D-44):** D-45, so that `SCENARIO` is never null.
- **No new lanes.** The keys must not move. Builds 03 (BEAUMIER) and 02
  (NEWBURY) are the record: their profiles stand, and only what the changes
  touch is re-measured.

---

## Archive check (CLAUDE.md section 2, measured)

- **The repo is archived:**
  - `docs/findings/` holds only `.gitkeep`;
  - `docs/sources.md` was the blank template (7,740 bytes);
  - `scripts/` holds `parity_check.py`, `check_line_endings.py` and
    `probes/SPROC_PROBE_FAULT.sql`;
  - builds 01-06 are in `docs/completed-builds/`;
  - parity of `sql/` against `DEV_G2M_AI` is 100 of 100, exit 0; line endings
    are clean.
- **Untracked files:**
  - `docs/client-requests/2026-10-26/beaumier_hotels.csv`, to be committed
    with the first commit (owner; see Q-05);
  - `Claude outputs/beaumier_hotels.csv`, not mentioned by the owner, left
    untouched. Its content differs from the first file.

## Source schema and freeze (D-43)

- **Source:** `CLN.BOX_INVESTMENT_DATA`, 33 tables visible.
- **Freeze:** the owner's start and end were not given (the request read
  `<start>` to `<end>`). The database clock at the first query was
  **2026-10-26 12:39:29.224 PDT** (query `01c7fe9b-010a-58cf-0003-4ff21bf4277a`).
  This is proposed as the start (Q-02).
- **Against earlier records (measured).** The 13 BEAUMIER and NEWBURY tables
  that builds 02 and 03 read carry the same `last_altered` (2026-10-19
  15:39-15:41) and row counts. `CLN_BEAUMIER_LOCATION_MAP` is new, loaded
  2026-10-26 12:03:38.633, before the first query.

**Baseline: every in-scope table's `last_altered`, row count and the sum of
every numeric column** (query `01c7fe9e-010a-58c4-0003-4ff21bf3e986`).

| Table | Rows | `last_altered` (PDT) | Sums |
|---|---|---|---|
| CLN_BEAUMIER_ACCOUNTS | 2,258 | 2026-10-19 15:39:28.345 | ROW_COUNT=53,144 |
| CLN_BEAUMIER_BP | 35,567 | 2026-10-19 15:39:22.897 | AMOUNT=38,868,453.531294; SOURCE_ROW_NUMBER=157,454,717 |
| CLN_BEAUMIER_BUDGET | 17,577 | 2026-10-19 15:39:24.788 | AMOUNT=19,866,830.779535; SOURCE_ROW_NUMBER=77,478,004 |
| CLN_BEAUMIER_CANCELLATIONS | 18,930 | 2026-10-19 15:39:26.608 | OCCUPANCY=4,266,661; ROOMS_REVENUE=2,436,169,569.154831; OCCUPANCY_N_1=4,781,975; ROOMS_REVENUE_N_1=2,586,921,064.715253; OCCUPANCY_N_2=3,671,700; ROOMS_REVENUE_N_2=1,920,085,936.360861; OCCUPANCY_N_3=2,654,606; ROOMS_REVENUE_N_3=1,538,100,952.392782; OCCUPANCY_N_4=2,057,179; ROOMS_REVENUE_N_4=1,202,425,868.0025; OCCUPANCY_N_5=379,237; ROOMS_REVENUE_N_5=190,546,505.63; SOURCE_ROW_NUMBER=61,184,330 |
| CLN_BEAUMIER_LOCATION_MAP | 13 | 2026-10-26 12:03:38.633 | no numeric column; content hash 3717277118938258010 |
| CLN_NEWBURY_BOSTON_ACCOUNTS | 770 | 2026-10-19 15:41:03.950 | ROW_COUNT=16,320 |
| CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT | 365 | 2026-10-19 15:40:46.853 | ROOMS=77,289; REVENUE=46,106,692.2701; SOURCE_ROW_NUMBER=67,160 |
| CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO | 426 | 2026-10-19 15:40:53.495 | OUT_OF_ORDER_ROOMS=54; OVERBOOK_ROOMS=null; SOURCE_ROW_NUMBER=98,817 |
| CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST | 2,190 | 2026-10-19 15:40:48.530 | ROOMS=444,759; REVENUE=291,599,340.6705; SOURCE_ROW_NUMBER=402,960 |
| CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT | 2,795 | 2026-10-19 15:40:49.844 | ROOMS=330,220; REVENUE=203,122,723.54; SOURCE_ROW_NUMBER=3,910,205 |
| CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS | 20,048 | 2026-10-19 15:40:51.796 | RATE_VALUE=17,106,633.3; SOURCE_ROW_NUMBER=51,280,888 |
| CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP | 75,264 | 2026-10-19 15:40:59.873 | ROOMS=1,364,830; REVENUE=823,772,430.0835; AVAILABLE_ROOMS=21,525,504; SOURCE_ROW_NUMBER=841,568,234 |
| CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP | 41,905 | 2026-10-19 15:41:01.771 | ROOMS=759,087; REVENUE=458,444,630.2943; AVAILABLE_ROOMS=11,984,830; SOURCE_ROW_NUMBER=493,118,815 |
| CLN_NEWBURY_BOSTON_TRIAL_BALANCE | 16,320 | 2026-10-19 15:40:57.687 | ACTUAL_AMOUNT=147,489,864.68; FORECAST_AMOUNT=75,743,308.957604; BUDGET_AMOUNT=208,458,076.386451; ACTUAL_SOURCE_ROW_NUMBER=5,076,458; FORECAST_SOURCE_ROW_NUMBER=1,087,770; BUDGET_SOURCE_ROW_NUMBER=1,902,420 |

---

## Tables and lanes (proposed, Q-01)

| Table | Lane | Role |
|---|---|---|
| CLN_BEAUMIER_BP, _BUDGET | **BEAUMIER** (rebuild) | facts (build 03) |
| CLN_BEAUMIER_CANCELLATIONS | **BEAUMIER** | pacing (build 03) |
| CLN_BEAUMIER_ACCOUNTS | **BEAUMIER** | dictionary (build 03) |
| CLN_BEAUMIER_LOCATION_MAP | **BEAUMIER** | **new** dictionary: `HOTEL_CODE`, `HOTEL_NAME`, `ENTITY_TYPE` (HOTEL / CORPORATE), 13 rows |
| CLN_NEWBURY_BOSTON_TRIAL_BALANCE, _OPERATING_STATS_BGT, _PYACT | **NEWBURY** (rebuild) | facts (build 02) |
| CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST, _OTB_1DAY_PICKUP, _OTB_3DAY_PICKUP, _OPERATING_STATS_SHOPS, _OPERATING_STATS_EVENTSANDOOO | **NEWBURY** | pacing / non-fact (build 02) |
| CLN_NEWBURY_BOSTON_ACCOUNTS | **NEWBURY** | dictionary (build 02) |
| CLN_DAVIDSON_* (3), CLN_HERITAGE_GOLF_* (6), CLN_HERSHA_* (3), CLN_INVITED_CLUBS_* (7) | out of scope | covered by the earlier-build baseline |

**Arithmetic:** 14 in scope (BEAUMIER 5, NEWBURY 9) + 19 out of scope = 33
visible.

## Lane names (D-32)

Both lanes are rebuilt under their existing names (D-44). No new name.

---

## BEAUMIER: `ASSET_NAME` from `LOCATION_MAP` (measured, queries `01c7fe9b-010a-58c4-0003-4ff21bf3e8c2`, `01c7fe9b-010a-58c5-0003-4ff21bf3baca`)

- **The map.**
  - 13 rows, unique on `HOTEL_CODE`;
  - 11 `HOTEL`, 2 `CORPORATE`: `BMR` "Beaumier Corporate", `CPH` "Beaumier
    Corporate - Exceptional Charges";
  - names are valid UTF-8 (`Les Trois Vallées` has `C3A9`; `L'Alpaga` has a
    plain apostrophe).
- **Every hotel code matches exactly.** BP: 13 of 13 codes, 35,567 rows.
  BUDGET: 13 of 13, 17,577 rows. ACCOUNTS: 13 of 13 entities.
  **No hotel code has no match**, and no code needed a case or space match.
- **Corporate rows.** BMR and CPH: BP 228 rows, BUDGET 120 rows (staged).
- **Today.** `STG_BEAUMIER_BP` and `_BUDGET` set `ASSET_NAME` null on every
  row (build 03).
- **`CANCELLATIONS` (pacing).** It carries `HOTEL_NAME` and no code. Its 11
  names equal the map's 11 hotel names exactly (query
  `01c7fe9f-010a-58c5-0003-4ff21bf3bbba`).
- **Proposed rule (Q-03).**
  - `ASSET_NAME = STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME` on `HOTEL_CODE`
    exactly, null otherwise. Corporate codes take their map names.
  - `ASSET_NAME_SOURCE` names the source and the `ENTITY_TYPE`.
  - The map is staged as `STG_BEAUMIER_LOCATION_MAP`, and the BEAUMIER MAIN
    calls dictionaries before facts.
  - CANCELLATIONS is unchanged.

## NEWBURY: D-45 (measured, queries `01c7fe9c-010a-58c4-0003-4ff21bf3e8f6`, `01c7fe9d-010a-58c5-0003-4ff21bf3baf6`, `01c7fe9d-010a-58d2-0003-4ff21bf3f8de`)

| Model | Category from | `SCENARIO` today | Null | D-45 rule | Value |
|---|---|---|---|---|---|
| `OPERATING_STATS_BGT` | source `SCENARIO` | `Budget` | 0 | source name | unchanged |
| `OPERATING_STATS_PYACT` | source `SCENARIO` | `Actual` | 0 | source name | unchanged |
| `TRIAL_BALANCE`, branch `ACTUAL_AMOUNT` | unpivoted measure column | null | 16,320 | measure column name | `ACTUAL_AMOUNT` |
| `TRIAL_BALANCE`, branch `BUDGET_AMOUNT` | unpivoted measure column | null | 16,320 | measure column name | `BUDGET_AMOUNT` |
| `TRIAL_BALANCE`, branch `FORECAST_AMOUNT` | unpivoted measure column; scenario `FORECAST_VERSION` | `Forecast9` 725, `Forecast10` 2,148, null 13,447 | 13,447 | **source name where given, else column name** (Q-04) | `Forecast9` / `Forecast10` / `FORECAST_AMOUNT` |

- **TB null total:** 16,320 + 16,320 + 13,447 = 46,087, the same as the
  NEWBURY semantic total of null `SCENARIO` today.
- **The 13,447 forecast rows with no version** are exactly the rows whose
  `FORECAST_AMOUNT` is null. They are empty cells dated 2025-01-31 to
  2026-09-30, before the forecast horizon. Every versioned row has an amount.
- **Not covered by D-45 (not fact rows):** FCST, OTB_1DAY, OTB_3DAY, SHOPS
  and EVENTSANDOOO are pacing or non-fact. They have no semantic table and,
  except FCST, no `SCENARIO` column. Unchanged.

## Keys

Neither change touches a key part (`ASSET_NAME` and `SCENARIO` are not in
the five-part key). The D-44 key report runs at M4 for both lanes.

## Corrections

None yet.
