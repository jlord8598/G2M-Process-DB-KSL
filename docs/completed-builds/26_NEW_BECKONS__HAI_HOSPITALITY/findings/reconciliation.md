# Build 26 reconciliation
- reconcile_BECKONS.sql and reconcile_HAI_HOSPITALITY.sql: row count and every numeric sum, CLN -> STG -> XFRM -> SEM. 0 failures each (`reconcile_build26_output.txt`).
- BECKONS: ROWS 58,556 / 68,477 at every layer. BASE 13,710,254.6085 / 236,077,058.2993 at every layer (a cross-currency checksum; business totals are per CURRENCY_CODE, M6.md). AUD 14,804,426.6356 / 254,405,970.9263, CLN = STG (staged only).
- HAI: ROWS 339,232 at every layer; ACTUAL 1,172,016,406.01; BUDGET 1,222,446,430.17.
- Partitions: BECKONS 127,033 = 126,237 IS + 794 OM + 2 UNKNOWN (after the stop-4 re-seed; 125,910 / 329 before); HAI 339,232 = 339,232 IS. Both reconciles rerun after the re-seed: 0 failures.
- **Summing caveats:**
  - BECKONS: never sum across CURRENCY_CODE.
  - HAI: sum by PERIOD_END (fiscal period); a period's lines are split by calendar month and add up.
  - BECKONS SAN / PAT 7777777 FX revaluation (+/-2.06B) offsets within the lane (N-73); filter it for lodge-level P&L.
