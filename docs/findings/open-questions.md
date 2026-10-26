# Open questions - build 07 (rebuild of BEAUMIER and NEWBURY)

Numbered within this build. The decisions of builds 02 (NEWBURY) and 03
(BEAUMIER) carry over unchanged, except the changes declared for this build.

## Answered at stop 1 (owner, 2026-10-26)

| # | Answer |
|---|---|
| Q-01 | **Approved.** BEAUMIER and NEWBURY are rebuilt; all other lanes are out of scope. |
| Q-02 | **Freeze 2026-10-26 12:39:29 PDT to 2026-10-28 12:39 PDT.** If M6 will not finish before then, stop and report. |
| Q-03 | **Approved.** BMR and CPH take their map names; `ASSET_NAME_SOURCE` records the source and the corporate flag. The map is staged as a BEAUMIER dictionary, called before the facts. CANCELLATIONS unchanged. |
| Q-04 | **Approved.** TB ACTUAL and BUDGET get `ACTUAL_AMOUNT` / `BUDGET_AMOUNT`; FORECAST keeps `FORECAST_VERSION` where present, `FORECAST_AMOUNT` where empty. |
| Q-05 | **Regenerate** `beaumier_hotels.csv` from `CLN_BEAUMIER_LOCATION_MAP`, UTF-8 with BOM, and commit the fix. Leave the untracked outputs file alone. |

DDL is approved through M6 for BEAUMIER and NEWBURY objects only.

## Raised at stop 1

| # | Lane | Question | Blocks | Proposal |
|---|---|---|---|---|
| Q-01 | all | **Table assignment.** BEAUMIER: its 4 build 03 tables plus the new `CLN_BEAUMIER_LOCATION_MAP` (dictionary). NEWBURY: its 9 build 02 tables. The other 19 visible tables (DAVIDSON, HHG, HERSHA, INVITED_CLUBS) are out of scope. | yes | As listed in `sources.md`. |
| Q-02 | process | **Freeze window.** The request gave `<start>` and `<end>` without values. | yes (D-43) | Start = 2026-10-26 12:39:29.224 PDT, the database clock at the first query; the owner to state the end. |
| Q-03 | BEAUMIER | **`ASSET_NAME` rule.** `LOCATION_MAP.HOTEL_NAME` on an exact `HOTEL_CODE` join: 13 of 13 codes match in BP, BUDGET and ACCOUNTS, so none is unmatched. (a) Do BMR and CPH take their map names (`Beaumier Corporate`, `Beaumier Corporate - Exceptional Charges`) or stay null? (b) Stage the map as `STG_BEAUMIER_LOCATION_MAP` (D-26) and call dictionaries before facts? (c) `CANCELLATIONS` (pacing) is unchanged? | M3 | (a) Map names, with `ASSET_NAME_SOURCE` naming the source and `ENTITY_TYPE` (`... (CORPORATE)`). (b) Yes. (c) Yes. |
| Q-04 | NEWBURY | **D-45 for `TRIAL_BALANCE`.** ACTUAL and BUDGET branches name no scenario: `ACTUAL_AMOUNT` and `BUDGET_AMOUNT`. The FORECAST branch names `FORECAST_VERSION` on 2,873 rows (`Forecast9` 725, `Forecast10` 2,148) and nothing on 13,447 rows, exactly the rows whose forecast amount is null. | M3 | Keep the version verbatim where the source gives one; `FORECAST_AMOUNT` where it gives none. The branch then carries three values. |
| Q-05 | process | **`docs/client-requests/2026-10-26/beaumier_hotels.csv`** contains U+FFFD replacement characters for two names (`Les Trois Vall?es`, `L?Alpaga`). The source map holds `Les Trois Vallées` and `L'Alpaga` correctly. | no | Commit as given, or regenerate from `CLN_BEAUMIER_LOCATION_MAP` (UTF-8) first. The owner to choose. |

## Open at stop 4

| # | Item | Blocks | Note |
|---|---|---|---|
| Q-06 | **Stream-level rebuild diff not available.** No hash of `XFRM_BEAUMIER_*` / `XFRM_NEWBURY_*` without `ASSET_NAME` / `SCENARIO` was taken before M3, which rebuilt them. The evidence that only those columns moved is the staging diff (M3), the unchanged transformation procedures (equal MD5, M5) and checks 1, 3 and 5. | no | Recorded. Future rebuilds: take stream and semantic rest hashes at M2, before the first staging run. |
| - | **No owner question blocks approval.** No hotel code is unmatched; no H2 needs adding; 0 keys moved. | | |
