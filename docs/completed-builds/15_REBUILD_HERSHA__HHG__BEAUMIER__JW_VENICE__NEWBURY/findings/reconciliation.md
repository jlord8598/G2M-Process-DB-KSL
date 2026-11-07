# Reconciliation (build 15): does every record arrive?

Rows: CLN = STG on all 36 staged tables, long or with the stated unpivot multiplier (M3); fact STG = the four H1 streams per lane, pace STG = PACING (M5); four streams = six SEM tables per lane (M6). Measures: `reconcile_HERSHA.sql`, `reconcile_HHG.sql`, `reconcile_BEAUMIER.sql`, `reconcile_JW_VENICE.sql`, `reconcile_NEWBURY.sql`: rows and every numeric measure per source table, CLN / STG / XFRM / SEM, 0 failures each (outputs `reconcile_*_output.csv`). SOURCE_AMOUNT is reconciled; D-50 changes VALUE only.

Not staged (in the freeze, out of scope): CLN_JW_VENICE_CAPEX (N-9), CLN_JW_VENICE_DAILY_OTB, CLN_JW_VENICE_SEGMENT_PICK_UP (N-29), CLN_HERITAGE_GOLF_BUDGET_MEMBERSHIP (N-31).

Duplicates (D-48): HERSHA TB / GL, JW PL_DEPT / FCAST, HHG Anaplan older file (18,360 rows), BEAUMIER BP partial files (346 rows) in SEM_AI_UNKNOWN as DUPLICATE_DETAIL, 0 cells counted twice (2(m)). Subtotals: JW_VENICE SOURCE_ROLLUP rows in UNKNOWN; HHG Anaplan "+All Regions" (IS_SUBTOTAL, in the income statement, flagged).

Independent anchor: JW_VENICE EBITDA exact in the PL_DEPT months; the FCAST months do not tie (N-32). Other lanes have no stated total; GOP margin 32-40% after D-50 (M6).
