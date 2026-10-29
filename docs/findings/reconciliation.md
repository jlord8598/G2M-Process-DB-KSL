# Reconciliation - build 08 (HHG, INVITED_CLUBS, NEWBURY)

**Does every record arrive?** Yes. Every source row of the three lanes
reaches staging, its stream and semantic (facts), or PACING (pacing). Every
numeric sum is equal within 0.005.

## Reconcile scripts (run at M6)

| Script | Rows compared | Failures |
|---|---|---|
| `scripts/reconcile_HHG.sql` (build 06 text) | 16 | **0** |
| `scripts/reconcile_INVITED_CLUBS.sql` (build 03 text) | 15 | **0** |
| `scripts/reconcile_NEWBURY.sql` (build 07 text) | 33 | **0** |

| Lane | Table | Rows | Amount (CLN = STG = XFRM = SEM) |
|---|---|---|---|
| HHG | TR12_DATA | 164,760 | 826,163,401.59 |
| HHG | FORECAST_ANAPLAN | 19,080 | 325,117,641.875673 |
| HHG | ROUNDS_DETAIL | 91,300 | (statistic) |
| HHG | ACCOUNTS / CLUB_LIST / REFERENCES | 13,759 / 50 / 45 | CLN = STG |
| INVITED_CLUBS | ESSBASE_EXTRACT | 51,301,512 | 442,516,489,057.67 |
| INVITED_CLUBS | ACCOUNTS, META_* (5) | 13,314; 9,244 / 799 / 5,472 / 1,507 / 1,198 | CLN = STG |
| NEWBURY | TRIAL_BALANCE | 48,960 | 408,072,850.883742 |
| NEWBURY | OPERATING_STATS_BGT / _PYACT | 365 / 2,795 | 46,106,692.2701 / 203,122,723.54 |
| NEWBURY | pacing FCST, SHOPS, OTB_1DAY, OTB_3DAY | 2,190 / 20,048 / 75,264 / 41,905 | CLN = STG = PACING |

## Count identities (query `01c80aa3-010a-66f0-0003-4ff21c1a7a96`)

| Lane | Fact staged | SEM (ACTUAL + BUDGET + FORECAST + BS + OM + UNKNOWN) |
|---|---|---|
| HHG | 275,140 | 157,344 + 0 + 19,080 + 0 + 98,716 + 0 |
| INVITED_CLUBS | 51,301,512 | 6,795,958 x 3 + 9,857,187 + 12,443,505 + 8,612,946 |
| NEWBURY | 52,120 | 12,924 x 3 + 0 + 10,188 + 3,160 |

## Subtotals

- **INVITED_CLUBS:** `IS_SUBTOTAL` is now also TRUE for the 7 `Ind-Total*`
  members (Q-06/Q-13).
  - 5 are in UNKNOWN as `SOURCE_ROLLUP` (154,269 rows).
  - 2 revenue members are in the income statement: `Ind-Total Revenue` 32,076
    rows and `Ind-Total Golf Revenue` 21,906, all flagged.
- **HHG, NEWBURY:** rules unchanged.
