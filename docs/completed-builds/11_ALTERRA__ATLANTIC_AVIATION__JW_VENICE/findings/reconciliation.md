# Reconciliation - build 11 (ALTERRA, ATLANTIC_AVIATION, JW_VENICE)

**Does every record arrive?** Yes. Every source row reaches staging, exactly
one stream and semantic, and every numeric sum is equal within 0.005.

## Reconcile scripts (run at M6, after run B)

| Script | Rows compared | Failures |
|---|---|---|
| `scripts/reconcile_ALTERRA.sql` | 12 | **0** |
| `scripts/reconcile_ATLANTIC_AVIATION.sql` | 5 | **0** |
| `scripts/reconcile_JW_VENICE.sql` | 14 | **0** |

| Lane | Table | Rows CLN -> STG | Measures (CLN = STG = XFRM = SEM) |
|---|---|---|---|
| ALTERRA | MONTHLY_FINANCIALS | 38,781 x 3 = 116,343 | AMT 29,128,373,809.3266; STAT 46,657,078.455442 |
| ALTERRA | PACE_BY_STAY_MONTH (pacing) | 10,320 = 10,320 = XFRM_ALTERRA_PACING | TODAY 3,944,253 rooms / 1,191,674,525.59112; STLY 3,887,986 / 1,261,333,093.22567; ST2Y 3,443,850 / 1,108,209,921.0893 |
| ALTERRA | ACCOUNTS | 1,370 | ROW_COUNT 38,781 |
| ATLANTIC_AVIATION | OC_DATA | 109,995 x 3 = 329,985 | AMT 1,998,865,553.78796; STAT 3,651,404.822482 |
| ATLANTIC_AVIATION | ACCOUNTS | 1,149 | ROW_COUNT 109,995 |
| JW_VENICE | FCAST_ACT_FORECAST | 808 x 2 = 1,616 | AMT 229,398,511.701456; STAT 468,263.64869 |
| JW_VENICE | FCAST_BY_PERIOD | 761 x 2 = 1,522 | AMT 178,359,075.105516; STAT 401,192.686825 |
| JW_VENICE | FTE | 1,044 x 4 = 4,176 | STAT 16,112.69 |
| JW_VENICE | HEADCOUNT | 1,080 x 4 = 4,320 | STAT 18,558 |
| JW_VENICE | ACCOUNTS | 2,360 | ROW_COUNT 12,349 |

**Not reconciled:**
- `CLN_JW_VENICE_CAPEX`: out of scope (Q-05, N-9), not staged.

## Count identities (per lane)

| Lane | Staged facts | XFRM: IS + BS + OM + UNKNOWN | SEM: six tables |
|---|---|---|---|
| ALTERRA | 116,343 | 71,223 + 0 + 10,338 + 34,782 | 116,343 |
| ATLANTIC_AVIATION | 329,985 | 155,520 + 12,348 + 25,920 + 136,197 | 329,985 |
| JW_VENICE | 11,634 | 1,386 + 0 + 7,872 + 2,376 | 11,634 |

**Pacing:** ALTERRA 10,320 = `XFRM_ALTERRA_PACING`. It has no semantic table
(D-21).

## Source subtotals and duplicates

**`SOURCE_ROLLUP`, kept in UNKNOWN and excluded from the income statement:**
- ALTERRA 34,212 rows (21,436,442,912.04);
- ATLANTIC 136,194 (1,387,298,230.45);
- JW 2,376 (297,291,563.84).

**Detail and subtotal totals are stated separately by these figures** (M5).

**D-48, ALTERRA:**
- **Moved:** 570 Ski Butlers "Alterra Resorts" rows to UNKNOWN as
  `DUPLICATE_DETAIL` (ACTUAL 37,128,676.06, equal to the resorts' own Ski
  Butlers lines).
- **Check 2(m):** 0 cells counted twice.
