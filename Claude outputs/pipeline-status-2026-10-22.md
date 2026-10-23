# G2M Process Pipeline: status and next steps (2026-10-22)

## Where things stand

- **7 portcos in DEV1** (`SEM_AI_*`): KSL_SELECT_SERVICE, PEREGRINE_RESORTS, HHG, NEWBURY, HERSHA, INVITED_CLUBS, BEAUMIER. Every build reconciles to source with 0 differences.
- **Builds archived** in `docs/completed-builds/`: 01 KSL/PEREGRINE, 02 HHG/NEWBURY, 03 HERSHA/INVITED_CLUBS/BEAUMIER, 04 rebuild KSL/PEREGRINE (new ProfitSword COA tables, history back to 2024, Smart Forecast = FORECAST).
- **Last DEV1 run:** 7 lanes, 22 MAINs, all streams match the builds. KSL 10,275,670 fact rows; PEREGRINE 1,238,168.
- **Master** `CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`: all 7 lanes present; `SPROC_RUN_PIPELINE` inserts new keys each run.
- **Utilities** (CLN.UTIL): `SPROC_PROMOTE(FROM, TO, DRY_RUN)` and `SPROC_RUN_PIPELINE(DB)`.
- **Process docs** (repo): CLAUDE.md now includes D-42 accumulation, D-43 held source (load freeze), D-44 lane rebuild, SEM_AI naming, master column list, 1-3 companies per build, snow sql rule.

## Promotion runbook

1. Insert the build's keys into the master (filtered to its lanes; checks existing keys).
2. `call CLN.UTIL.SPROC_PROMOTE('DEV_G2M_AI','DEV1',true);` then `false`; confirm "verified in target".
3. Drop any retired objects in DEV1 by hand (promotion never deletes).
4. `call CLN.UTIL.SPROC_RUN_PIPELINE('DEV1');`
5. Run each lane's reconcile script with `DEV_G2M_AI.` changed to `DEV1.`; expect 0 failures.
6. Archive the build in the repo; commit and push.

## Checklist for tomorrow

1. **Commit build 04's archive** (`git add -A`, commit, push).
2. **Send validator fixes** to the Streamlit owner (clears about half the red, no data change):
   - STAT_ACCOUNT: not applicable outside ProfitSword.
   - STAT_VALUE: check in operating metrics, not income statement.
   - SOURCE_AMOUNT: flag only when SOURCE_AMOUNT and STAT_VALUE are both null (unpivot placeholders are expected).
   - SCENARIO: null is fine where the lane has no scenario column.
   - Near-zero percentages: warning, not failure; add an "accepted: source has none" status.
3. **Run the BEAUMIER statistics check** (Rooms Sold / Occupancy booked as amounts?).
4. **Rebuild HHG** (D-44, under a BOX_INVESTMENT_DATA freeze): ASSET_NAME from REFERENCES via exact entity-code join; add BEAUMIER if step 3 finds statistics.
5. **When the colleague's department table lands:** rebuild KSL/PEREGRINE department names (OUTLET, fall back to GENERIC), under a CLN.CLEAN freeze.

## Open with the source owner (colleague)

- Department table: one row per TENANT + SITE_TAG + DEPT_CODE; fix 167/181 outlet "3"; confirm table name in CLN.CLEAN.
- BEAUMIER: hotel-code to name lookup.
- BEAUMIER and HHG Anaplan forecast: line-item to GL account (and department) map.
- HHG: account/department descriptions; 9 entity codes missing from REFERENCES.
- Minor: INVITED_CLUBS ~18 Essbase members and 8 roll-up entities without alias; BEAUMIER blank line items and budget cells.

## Open for the business (master H2)

- INVITED_CLUBS 460 A6 expense accounts (Expense/UNCLASSIFIED).
- NEWBURY 11 D&A / income-tax accounts sitting in Other Income/(Expense); 870215 credit (-206.4M).
- Allocations & Reserves and Mixed lines in every lane; KSL item-tag keys (~70% of KSL rows in SEM_AI_UNKNOWN).
- Setting H2 fills P_L_SECTION, NORMAL_BALANCE, VALUE_SIGN and VALUE on the next DEV1 run.

## Design decisions pending

- SCENARIO: validator change only, or design change (fill SCENARIO with the stating table/measure name).
- Sign convention for pre-signed sources (HHG Anaplan, HERSHA, BEAUMIER): consumers use SOURCE_AMOUNT for now.
