# Build 13 promotion (owner, 2026-11-04)

Build 13: D-44 rebuild of KSL_SELECT_SERVICE and PEREGRINE_RESORTS on the 2026-11-04 01:20 extract. D-46 account-block mapping (2x due-from -> Assets; 30-38 and 3900-3955 -> Liabilities; 8704-8720 -> Depreciation & Amortization; PEREGRINE block 86 -> Operating Expenses) with a D-44 re-seed; COA calculated lines as SOURCE_ROLLUP + IS_SUBTOTAL (Q-16 tie test, `=TOT` and untestable lines on IS_CALCULATED_LINE; 28 failing lines unflagged). Stop 4 approved.

## Results reported by the owner

- **D-47 master merge:** 9,691 updated, 0 inserted. 1,795 reclassifications (= stop 4: KSL 1,445 + PEREGRINE 350) and 7,896 department-name and description refreshes. All section and sign changes sit inside the approved reclassifications.
- **CLN.UTIL.SPROC_PROMOTE:** 129 procedures moved; 11 classification-source swaps.
- **CLN.UTIL.SPROC_RUN_PIPELINE('DEV1'):** 11 lanes, 34 MAINs, 0 new keys.
- **DEV1 reconcile:** 0 failures for KSL_SELECT_SERVICE and PEREGRINE_RESORTS.

## Build figures (stop-4 memos)

- EBITDA tie-out: KSL 937 / 1,360 site-months (68.9%); PEREGRINE 124 / 180 (68.9%).
- Open items raised: N-21 (PEREGRINE Budget 4 / 5), N-22 (KSL block 86 in EBITDA), N-23 (KSL malformed codes and account-less ledger rows), N-24 (PEREGRINE Land Lease sign).
