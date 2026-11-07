# Build 15 promotion (owner, 2026-11-06)

Build 15: D-44 rebuild of HERSHA, HHG, BEAUMIER, JW_VENICE and NEWBURY to fix issues found by the Streamlit income-statement validation, on the 2026-11-06 03:03-03:06 extract (freeze from 13:09:00 PST). Changes: D-50 source sign convention (HERSHA GL / TB DEBIT; BEAUMIER BP / BUDGET and HHG Anaplan PROFIT; the rest PRESENTED); BEAUMIER CURRENCY_CODE per hotel (9 EUR, HGB / HSB CHF, BMR / CPH UNCONFIRMED; N-19 closed); NEWBURY 870215 FF&E Reserve re-seeded to Allocations & Reserves (N-30); HHG BUDGET_BY_CLUB staged (budget was missing), BUDGET_MEMBERSHIP deferred (N-31); BEAUMIER HIERARCHY staged as a dictionary; HHG ACCOUNTS joined per SOURCE_TABLE slice; D-48 latest-file rules for HHG Anaplan and BEAUMIER BP (per entity + month + scenario); Q-09 JW_VENICE FCAST lines (EBITDA EXCLUDING OWNER EXPENSES -> SOURCE_ROLLUP, GOP MARGIN -> Statistic). Stop 4 and the Q-09 fix approved.

## Results reported by the owner

- **D-47 master merge:** 219 inserted, 3 updated (= stop 4 / Q-09 expectation: HHG 219 new BUDGET_BY_CLUB keys; NEWBURY 870215, JW_VENICE EBITDA EXCLUDING OWNER EXPENSES and GOP MARGIN).
- **CLN.UTIL.SPROC_PROMOTE:** 155 procedures moved; 12 classification-source swaps; 2 lanes with no classification.
- **CLN.UTIL.SPROC_RUN_PIPELINE('DEV1'):** 14 lanes, 43 MAINs, 0 new keys.
- **DEV1 reconcile:** 0 failures for HERSHA, HHG, BEAUMIER, JW_VENICE and NEWBURY.

## Build figures (stop-4 memos)

- Wrong-sign investment-months 4,291 -> 149 (HERSHA Revenue 264 -> 0; HHG Anaplan COGS / Payroll / OpEx 1,822 -> 0; BEAUMIER OpEx / Payroll 1,582 -> 13).
- NEWBURY D&A 2025-03 -207,926,314.34 -> 923,535.04.
- GOP margins after D-50: HERSHA 32.2 / 34.1%, BEAUMIER 33.4 / 40.0 / 37.9%, HHG 33.6 / 35.2 / 36.3%.
- JW_VENICE: EBITDA exact in the PL_DEPT months; FCAST-month differences fully explained (departmental expenses not in landed data, replacement reserve, credit card, non-op; N-32, N-35).
- Keys: every existing key reproduced, 0 dead; HHG +219, BEAUMIER +3 (already in the master).

## Scripts archived with this build

`run_build.sql` (five lanes), `run_build_jw.sql` (Q-09 JW_VENICE-only harness), `reconcile_{HERSHA,HHG,BEAUMIER,JW_VENICE,NEWBURY}.sql`, `d43_check.sql`, `build15_hashes.sql`, `earlier_build_hashes.sql`, `build15_q09_jw_hashes.sql`, `build15_q09_other4_hashes.sql`.

## CLAUDE.md changes applied

D-50 (new decision), the section 5 paragraph on VALUE and D-50, the check 2(h) rewording, and the HHG / BEAUMIER latest-file rules in D-48.

## Open items raised

N-29 (JW_VENICE pacing tables deferred), N-30 (NEWBURY 870215), N-31 (HHG BUDGET_MEMBERSHIP deferred), N-32 (JW FCAST tie-out, partly resolved), N-33 (sign test, business review), N-34 (HHG clubs missing from the 2026-11-05 Anaplan file), N-35 (JW FCAST non-op spelling; reserve and credit card treatment). N-19 closed.
