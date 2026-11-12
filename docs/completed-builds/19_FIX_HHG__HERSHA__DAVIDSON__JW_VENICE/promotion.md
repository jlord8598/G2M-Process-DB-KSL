# Build 19 promotion (owner, 2026-11-12)

Build 19: D-44 fix / extension of HHG, HERSHA, DAVIDSON and JW_VENICE, all four restaged on the 2026-11-12 03:03 extract. Gary's freeze held: 32 / 32 tables unchanged at every check.
- HHG: OPS_MEMBERSHIP_MONTHLY staged (budget accounts win under D-48; Ending Member Count in operating metrics); account descriptions filled by natural account wherever the chart gives exactly one (TR12 24 rows, budget 12 rows).
- HERSHA: budget branch staged, both build-16 WHEREs removed; preferred stat row wins (D-48); DAVIDSON is the source for 149 / 230 in 2026 across actual, forecast and budget (cross-lane D-48).
- DAVIDSON: FIN_BUDGET_MONTHLY staged (2026 and 2027, 245,676 rows).
- JW_VENICE: FIN_CAPEX in operating metrics (Statistic / FIN_CAPEX / CURRENCY / FLOW); PACE_OTB_DAILY and PACE_SEGMENT_MONTHLY through XFRM_JW_VENICE_PACING to SEM_AI_PACING.

Stop 4 approved with Q-14 and Q-15 applied.

## Results reported by the owner

- **D-47 master merge (HHG, HERSHA, DAVIDSON, JW_VENICE):** 916 inserted, 0 updated. This equals the stop-4 expectation (582 + 51 + 195 + 88; 0 updates; 0 reviewed conflicts).
- **CLN.UTIL.SPROC_PROMOTE:** 161 procedures; 12 of 12 classification-source swaps; 2 lanes with no classification.
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 14 lanes, 43 MAINs, 10 new keys (the usual daily pickup: KSL 6, PEREGRINE 4), SEM models=7.
- **DEV1 reconciles (`reconcile_<LANE>_DEV1.sql`):** TOTAL FAILURES 0 for HHG, HERSHA, DAVIDSON and JW_VENICE.
  - JW pacing (OTB and segment) and CAPEX tie from CLN to semantic.
  - Every check-2 assertion (b-m) returns 0 in DEV1, including HERSHA_X_DAVIDSON.
  - reconcile_PACING_DEV1.sql was not re-run; JW pacing coverage passed in check 1.

## Build figures (stop-4 memos, DEV_G2M_AI)

- Rows newly staged: +322,527, then -10,611 / -24 / +10,635 from Q-15 (M6).
- Final SEM: ACTUAL 6,950,742; BUDGET 4,204,079; FORECAST 4,522,843; BALANCE_SHEET 11,319,585; OPERATING_METRICS 24,358,847; UNKNOWN 22,613,248; PACING 8,421,372.
- Proof: 197 objects of the 10 other lanes identical to the baseline; the 4 lanes' 81 objects identical across runs; 916 new keys, none changed, none dead.
- Davidson 15-key difference vs M1: M1's key ignored the LINE_CLASS fallback; no row lost.

## Scripts archived with this build

`run_build.sql`, `build19_hashes.sql`, `build19_rebuilt_hashes.sql`, `build19_check2.sql`, `d43_check.sql`, `reconcile_HHG.sql`, `reconcile_HERSHA.sql`, `reconcile_DAVIDSON.sql`, `reconcile_JW_VENICE.sql` and their `_DEV1` copies.

## CLAUDE.md changes applied

- D-48: HERSHA (preferred row; cross-lane 149 / 230 for actual, forecast and budget), HHG (membership), and the cross-lane sentence.
- D-50: HERSHA budget DEBIT; HHG OPS_MEMBERSHIP_MONTHLY and JW FIN_CAPEX PRESENTED.
- D-52 added: attribute precedence (HHG acquisition date from REF_PROPERTY_STATUS).

## Open items

Closed N-1, N-5, N-10; updated N-11, N-31; added N-45 to N-51 (N-49 updated at close: Davidson statistical COA located, awaiting a CLN table from Gary).
