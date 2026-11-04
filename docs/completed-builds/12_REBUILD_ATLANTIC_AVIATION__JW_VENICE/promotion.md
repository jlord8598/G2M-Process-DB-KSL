# Build 12 promotion (owner, 2026-11-04)

Build 12: D-44 rebuild of JW_VENICE (MONTHLY_PL_DEPT staged; D-48 rules Q-02, Q-03, Q-09, Q-11) and ATLANTIC_AVIATION (x1000 unit scale, D-49); CURRENCY_CODE on all six semantic tables, every lane. Stop 4 approved, including the CLAUDE.md diff (section 4 CURRENCY_CODE and unit scale, D-49, the JW_VENICE D-48 rules).

## Results reported by the owner

- **D-47 master merge:** 2,164 inserted, 0 updated (JW_VENICE MONTHLY_PL_DEPT keys; no existing key's seed changed, as reported at stop 4).
- **CLN.UTIL.SPROC_PROMOTE:** 129 procedures moved; 11 classification-source swaps (one per lane).
- **CLN.UTIL.SPROC_RUN_PIPELINE('DEV1'):** 11 lanes, 34 MAINs; 85 new keys inserted (KSL_SELECT_SERVICE 18, PEREGRINE_RESORTS 67).
- **DEV1 reconcile:** 0 failures for JW_VENICE and ATLANTIC_AVIATION.

## Build figures (from the stop-4 memos)

- JW_VENICE EBITDA tie-out vs the owner P&L: 2026-08 1,303,456.44 and 2025-08 1,518,519.50, exact.
- ATLANTIC_AVIATION EBITDA tie-out after scaling: 1,674 of 1,674 site-months.
- Open items raised: N-17, N-18, N-19, N-20 (docs/open-items.md); N-8 and N-15 resolved.
