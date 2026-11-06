# Reconciliation (build 14): does every record arrive?

Rows: CLN = STG on all 12 tables (M2/M3); fact STG = five streams (M5: 92,355); four H1 streams = SEM (90,890 + 1,363 + 102); pace STG = PACING per lane (73,392 / 3,456 / 13,256). Measures: `reconcile_UNDER_CANVAS.sql`, `reconcile_THE_PIG.sql`, `reconcile_OUTRIGGER.sql`: row count and the sum of every numeric column per source table, CLN / STG / XFRM (/ SEM for facts), 0 failures each (outputs `reconcile_*_output.csv`).

Independent anchor: the GOP tie-out (M6) is exact at every line, YTD and per department (Sales 52,992,340.16; GOP 27,575,053.88).

Subtotals vs detail: CONSOLIDATED_PL (the YTD summary) is entirely in SEM_AI_UNKNOWN as DUPLICATE_DETAIL (102 rows, D-48); the detail tables carry no subtotal row.
