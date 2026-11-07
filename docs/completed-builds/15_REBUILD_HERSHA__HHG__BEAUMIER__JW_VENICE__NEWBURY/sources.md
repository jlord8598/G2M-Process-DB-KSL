# Sources - build 15 (D-44 rebuild: HERSHA, HHG, BEAUMIER, JW_VENICE, NEWBURY)

## Source schema and freeze (D-43)

- Source schema: `CLN.BOX_INVESTMENT_DATA` (every deployed staging model of the five lanes reads it; one schema, as D-43 requires).
- Freeze: the five lanes' 40 source tables only, from the first successful read, 2026-11-06 13:09:00.854 PST, until 2026-11-07 06:00 America/Los_Angeles (owner). Past 06:00 the build continues only while the D-43 check shows no change.
- Check: `scripts/d43_check.sql` (row count and `HASH_AGG(*)` per table against the baseline below), run at every stop.

## Lanes (owner-declared, D-44 rebuild)

HERSHA, HHG, BEAUMIER, JW_VENICE, NEWBURY: existing lanes, rebuilt under their existing names to fix issues found by the Streamlit income-statement validation (sign conventions, prior-year rows, NEWBURY D&A, BEAUMIER per-hotel currency N-19). No new lane name, so no name check is needed (D-32).

D-03, master key match (snapshot keys found in `CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY` on the five-part key): BEAUMIER 1,178 / 1,178, HERSHA 1,377 / 1,377, HHG 15,369 / 15,369, JW_VENICE 2,320 / 2,320, NEWBURY 782 / 782 (100% each). Reviewed rows in the master for these lanes: 0, so 0 conflicts. The master holds 3 BEAUMIER keys the snapshot lacks (1,181 vs 1,178), to be identified at M1.

## Table assignment and baseline (stop 1, owner to confirm)

| Lane | Table | Rows | HASH_AGG(*) | Read by (deployed staging) |
|---|---|---|---|---|
| BEAUMIER | CLN_BEAUMIER_ACCOUNTS | 3,282 | 6207409818506280668 | SPROC_STG_BEAUMIER_ACCOUNTS |
| BEAUMIER | CLN_BEAUMIER_BP | 35,893 | 5280581650166000017 | SPROC_STG_BEAUMIER_BP |
| BEAUMIER | CLN_BEAUMIER_BUDGET | 17,577 | -7675988773965074675 | SPROC_STG_BEAUMIER_BUDGET |
| BEAUMIER | CLN_BEAUMIER_CANCELLATIONS | 38,311 | -798790072126979833 | SPROC_STG_BEAUMIER_CANCELLATIONS |
| BEAUMIER | CLN_BEAUMIER_HIERARCHY | 147 | -2561288222712526144 | **not read** - new since the lane was built; scope to confirm (Q-01) |
| BEAUMIER | CLN_BEAUMIER_LOCATION_MAP | 13 | 3717277118938258010 | SPROC_STG_BEAUMIER_LOCATION_MAP |
| HHG | CLN_HERITAGE_GOLF_ACCOUNTS | 23,372 | 1771299207645600806 | SPROC_STG_HHG_ACCOUNTS, SPROC_STG_HHG_TR12_DATA |
| HHG | CLN_HERITAGE_GOLF_ASSET_CODES | 50 | 3018675477003782727 | SPROC_STG_HHG_ASSET_CODES |
| HHG | CLN_HERITAGE_GOLF_BUDGET_BY_CLUB | 115,356 | -5495382573461328954 | **not read** - new since the lane was built; scope to confirm (Q-01) |
| HHG | CLN_HERITAGE_GOLF_BUDGET_MEMBERSHIP | 9,936 | 2069045493696574511 | **not read** - new since the lane was built; scope to confirm (Q-01) |
| HHG | CLN_HERITAGE_GOLF_CHART_OF_ACCOUNTS | 623 | 1862171034088220365 | SPROC_STG_HHG_CHART_OF_ACCOUNTS |
| HHG | CLN_HERITAGE_GOLF_CLUB_LIST | 51 | -1092025536874094413 | SPROC_STG_HHG_CLUB_LIST, SPROC_STG_HHG_ROUNDS_DETAIL |
| HHG | CLN_HERITAGE_GOLF_DEPARTMENT_KEY | 11 | -195453728121409663 | SPROC_STG_HHG_DEPARTMENT_KEY |
| HHG | CLN_HERITAGE_GOLF_FORECAST_ANAPLAN | 37,440 | 4359511544370693853 | SPROC_STG_HHG_FORECAST_ANAPLAN |
| HHG | CLN_HERITAGE_GOLF_REFERENCES | 45 | -5652368222656237762 | SPROC_STG_HHG_REFERENCES |
| HHG | CLN_HERITAGE_GOLF_ROUNDS_DETAIL | 91,300 | -5936324666508679822 | SPROC_STG_HHG_ROUNDS_DETAIL |
| HHG | CLN_HERITAGE_GOLF_TR12_ACCOUNTS | 50,940 | -7367486876974984871 | SPROC_STG_HHG_TR12_ACCOUNTS |
| HHG | CLN_HERITAGE_GOLF_TR12_DATA | 164,760 | 743238683865840193 | SPROC_STG_HHG_TR12_DATA |
| HERSHA | CLN_HERSHA_ACCOUNTS | 2,187 | 3515371143495636202 | SPROC_STG_HERSHA_ACCOUNTS |
| HERSHA | CLN_HERSHA_GL_ACTUAL | 50,903 | -2225945427342163908 | SPROC_STG_HERSHA_GL_ACTUAL |
| HERSHA | CLN_HERSHA_GL_STAT | 9,424 | 2123432595447915137 | SPROC_STG_HERSHA_GL_STAT |
| HERSHA | CLN_HERSHA_TB_ACTUAL | 52,827 | -3464323821827476744 | SPROC_STG_HERSHA_TB_ACTUAL |
| JW_VENICE | CLN_JW_VENICE_ACCOUNTS | 2,360 | -4474948644677297740 | SPROC_STG_JW_VENICE_ACCOUNTS |
| JW_VENICE | CLN_JW_VENICE_CAPEX | 200 | -2398897289528261542 | **not read** - out of scope (owner, builds 11/12 Q-05/Q-08; N-9) |
| JW_VENICE | CLN_JW_VENICE_DAILY_OTB | 730 | -230625250588822865 | **not read** - new since the lane was built; scope to confirm (Q-01) |
| JW_VENICE | CLN_JW_VENICE_FCAST_ACT_FORECAST | 808 | -8506196185378544053 | SPROC_STG_JW_VENICE_FCAST_ACT_FORECAST |
| JW_VENICE | CLN_JW_VENICE_FCAST_BY_PERIOD | 761 | 3848384668570664544 | SPROC_STG_JW_VENICE_FCAST_BY_PERIOD |
| JW_VENICE | CLN_JW_VENICE_FTE | 1,044 | -5503771762041690548 | SPROC_STG_JW_VENICE_FTE |
| JW_VENICE | CLN_JW_VENICE_HEADCOUNT | 1,080 | -4105530968933583267 | SPROC_STG_JW_VENICE_HEADCOUNT |
| JW_VENICE | CLN_JW_VENICE_MONTHLY_PL_DEPT | 8,656 | -7754782521118946605 | SPROC_STG_JW_VENICE_MONTHLY_PL_DEPT |
| JW_VENICE | CLN_JW_VENICE_SEGMENT_PICK_UP | 1,200 | -7065732017023796045 | **not read** - new since the lane was built; scope to confirm (Q-01) |
| NEWBURY | CLN_NEWBURY_BOSTON_ACCOUNTS | 770 | 11581097365948119 | SPROC_STG_NEWBURY_ACCOUNTS, SPROC_STG_NEWBURY_TRIAL_BALANCE |
| NEWBURY | CLN_NEWBURY_BOSTON_OPERATING_STATS_BGT | 730 | 4848103911405594033 | SPROC_STG_NEWBURY_OPERATING_STATS_BGT |
| NEWBURY | CLN_NEWBURY_BOSTON_OPERATING_STATS_EVENTSANDOOO | 426 | -195031753587469519 | SPROC_STG_NEWBURY_OPERATING_STATS_EVENTSANDOOO |
| NEWBURY | CLN_NEWBURY_BOSTON_OPERATING_STATS_FCST | 3,285 | -8849721257839530074 | SPROC_STG_NEWBURY_OPERATING_STATS_FCST |
| NEWBURY | CLN_NEWBURY_BOSTON_OPERATING_STATS_PYACT | 2,862 | 4524608924983505793 | SPROC_STG_NEWBURY_OPERATING_STATS_PYACT |
| NEWBURY | CLN_NEWBURY_BOSTON_OPERATING_STATS_SHOPS | 33,024 | -3712663510212793872 | SPROC_STG_NEWBURY_OPERATING_STATS_SHOPS |
| NEWBURY | CLN_NEWBURY_BOSTON_OTB_1DAY_PICKUP | 149,838 | 1054961629945306573 | SPROC_STG_NEWBURY_OTB_1DAY_PICKUP |
| NEWBURY | CLN_NEWBURY_BOSTON_OTB_3DAY_PICKUP | 41,905 | -617558403330406244 | SPROC_STG_NEWBURY_OTB_3DAY_PICKUP |
| NEWBURY | CLN_NEWBURY_BOSTON_TRIAL_BALANCE | 16,320 | 4470988549401615549 | SPROC_STG_NEWBURY_TRIAL_BALANCE |

The other 27 tables in the schema belong to other lanes (ALTERRA, ATLANTIC_AVIATION, DAVIDSON, INVITED_CLUBS, OUTRIGGER, THE_PIG, UNDER_CANVAS) and are out of scope for this build. Item 2 of the brief (prior-year rows across all 14 lanes) reads the deployed `DEV_G2M_AI` semantic and staging tables for the other lanes, not their CLN tables, and reports only.

New since the lanes were built (columns only; not profiled before scope is confirmed):

| Table | Shape (from its columns) |
|---|---|
| CLN_BEAUMIER_HIERARCHY | 147 rows; LINE_ITEM with LEVEL_0-4, PL_GROUP, LINE_TYPE, PROJECTION_GROUP, INDEX_*: a P&L line hierarchy (dictionary). Possible evidence for the sign rule and H2 mapping. |
| CLN_HERITAGE_GOLF_BUDGET_BY_CLUB | 115,356 rows; CLUB_NUMBER, ACCOUNT_CODE, DEPARTMENT_CODE, PERIOD_DATE, BUDGET_AMOUNT, BUDGET_VERSION: a budget fact. |
| CLN_HERITAGE_GOLF_BUDGET_MEMBERSHIP | 9,936 rows; MEMBER_CATEGORY, MOVEMENT_TYPE, ACCOUNT_CODE, PERIOD_DATE, BUDGET_AMOUNT: membership budget (counts or dues). |
| CLN_JW_VENICE_DAILY_OTB | 730 rows; SNAPSHOT_DATE, STAY_DATE, ROOMS_*: on-the-books pacing. |
| CLN_JW_VENICE_SEGMENT_PICK_UP | 1,200 rows; SNAPSHOT_DATE, MARKET_SEGMENT, STAY_MONTH, ROOM_NIGHTS, ROOM_REVENUE: pickup pacing. |

## Decisions at stop 1 (owner)

- Q-02: all 34 tables read today stay in scope; CLN_JW_VENICE_CAPEX stays out (N-9).
- CLN_BEAUMIER_HIERARCHY: in scope as a BEAUMIER dictionary, evidence for the sign rule.
- CLN_HERITAGE_GOLF_BUDGET_BY_CLUB, CLN_HERITAGE_GOLF_BUDGET_MEMBERSHIP: in scope (validation found HHG has no budget), mapped with the existing HHG chart-of-accounts rules; any table needing new mapping decisions is reported at stop 2 with a proposal to defer it.
- CLN_JW_VENICE_DAILY_OTB, CLN_JW_VENICE_SEGMENT_PICK_UP: deferred to a later build (pacing, not validation fixes; N-29).
- In scope: 37 tables (BEAUMIER 6, HHG 12, HERSHA 4, JW_VENICE 6, NEWBURY 9). The D-43 freeze still covers all 40.

## Decisions at stop 2 (owner)

- Q-03: D-50 approved. `SOURCE_SIGN_CONVENTION` staged per table (with `SOURCE_SIGN_CONVENTION_SOURCE`), applied in transformation: DEBIT (HERSHA GL_ACTUAL, TB_ACTUAL) VALUE = -SOURCE_AMOUNT; PROFIT (BEAUMIER BP, BUDGET; HHG FORECAST_ANAPLAN) VALUE = SOURCE_AMOUNT; PRESENTED (every other table, incl. HHG BUDGET_BY_CLUB) VALUE = SOURCE_AMOUNT x VALUE_SIGN. VALUE null wherever VALUE_SIGN is null. CLAUDE.md text shown at stop 4.
- Q-04: no build change; prior-year rows are already ACTUAL. JW_VENICE 2025-08 stays under the existing D-48 rule; the 19,705.39 GOP difference is resolved at M4.
- Q-05: NEWBURY key 9000 | 9000 | 9000-870215-0000-000000-0000 | AMOUNT re-seeded (D-44) to Allocations & Reserves; logged for the source owner (N-30).
- Q-06: BEAUMIER CURRENCY_CODE per hotel: 9 EUR, HGB and HSB CHF, BMR and CPH UNCONFIRMED (closes N-19).
- Q-07: CLN_HERITAGE_GOLF_BUDGET_MEMBERSHIP deferred (N-31). In scope: 36 tables.
- Q-08: new D-48 rules, per cell: within HHG FORECAST_ANAPLAN and BEAUMIER BP, the latest FILE_DATE wins for each entity / account / month / scenario; an older file counts only for cells no later file has. Losers to UNKNOWN as DUPLICATE_DETAIL. Cells from older files reported. "Other F&B" needs no contra rule (D-50 keeps it as booked); it stays on the business-review list.

## Build 15 staging (M3)

- SOURCE_SIGN_CONVENTION (D-50) on every fact model: DEBIT HERSHA GL_ACTUAL, TB_ACTUAL; PROFIT BEAUMIER BP, BUDGET, HHG FORECAST_ANAPLAN; PRESENTED HERSHA GL_STAT, HHG TR12_DATA, ROUNDS_DETAIL, BUDGET_BY_CLUB, all JW_VENICE, NEWBURY TRIAL_BALANCE, OPERATING_STATS_BGT, OPERATING_STATS_PYACT. Evidence in SOURCE_SIGN_CONVENTION_SOURCE.
- BEAUMIER CURRENCY_CODE per hotel (CANCELLATIONS via LOCATION_MAP.HOTEL_NAME): EUR 41,811, CHF 11,311, UNCONFIRMED 348 rows.
- CLN_HERITAGE_GOLF_ACCOUNTS now holds one slice per fact table (SOURCE_TABLE); each fact model joins its own slice (TR12_DATA, BUDGET_BY_CLUB), unique within the slice.
- New: STG_HHG_BUDGET_BY_CLUB (fact, SCENARIO = BUDGET_VERSION, long identity), STG_BEAUMIER_HIERARCHY (dictionary).
- SCENARIO rule (D-45): HHG BUDGET_BY_CLUB names its scenario (BUDGET_VERSION, verbatim); the others unchanged.

