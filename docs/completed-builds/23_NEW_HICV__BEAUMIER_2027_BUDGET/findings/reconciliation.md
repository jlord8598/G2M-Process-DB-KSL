# Reconciliation (build 23: HICV new; BEAUMIER rebuilt)

**Does every record arrive?** Yes. Both reconcile scripts return 0 failures, and every count identity holds per lane. All figures are from live queries on 2026-11-16 (scripts run at 10:5x-11:0x after harness run 2).

## Scripts

- `scripts/reconcile_HICV.sql`: 29 checks, **0 failures**.
- `scripts/reconcile_BEAUMIER.sql`: 29 checks, **0 failures**. This is the build-16 script plus FIN_BUDGET_MONTHLY_USALI and OPS_STATS_MONTHLY.
- Each compares CLN, STG, XFRM and SEM per source table, on row count and the sum of every numeric column, with a tolerance of 0.005.

## Counts (check 1)

| Lane | Source lines | Staged | XFRM (IS + BS + OM + UNKNOWN) | SEM (six tables) | PACING staged = XFRM | SEM_AI_PACING |
|---|---|---|---|---|---|---|
| HICV | PL 341,688 x4 + GL 15,257 | 1,382,009 | 1,366,752 + 0 + 0 + 15,257 = 1,382,009 | 1,382,009 | 8,417 | 16,584 = 1,318 x2 + 6,849 x2 + 250 x1 |
| BEAUMIER | BP 35,893 + BUDGET 17,577 + USALI 7,622 + OPS 132 x4 | 61,620 | 60,726 + 0 + 528 + 366 = 61,620 | 61,620 | 16,995 | 203,940 (unchanged) |

**HICV semantic distribution:**

| Table | Lines | Note |
|---|---|---|
| SEM_AI_INCOME_STATEMENT_ACTUAL | 341,688 | |
| SEM_AI_INCOME_STATEMENT_BUDGET | 341,688 | |
| SEM_AI_INCOME_STATEMENT_FORECAST | 683,376 | FORENOV / FORECAST_AMOUNT and FOREOCT / PREVIOUS_FORECAST_AMOUNT |
| SEM_AI_UNKNOWN | 15,257 | GL, DUPLICATE_DETAIL |

**BEAUMIER semantic distribution:**

| Table | Lines | Note |
|---|---|---|
| SEM_AI_INCOME_STATEMENT_ACTUAL | 9,251 | |
| SEM_AI_INCOME_STATEMENT_BUDGET | 24,416 | 16,814 + 7,602 USALI |
| SEM_AI_INCOME_STATEMENT_FORECAST | 27,059 | |
| SEM_AI_OPERATING_METRICS | 528 | |
| SEM_AI_UNKNOWN | 366 | 346 DUPLICATE_DETAIL + 20 UNCLASSIFIED_ACCOUNT |

**Change in the semantic totals from before this build's blocks to after:**

| Table | Change | Explanation |
|---|---|---|
| SEM_AI_INCOME_STATEMENT_ACTUAL | +341,688 | HICV |
| SEM_AI_INCOME_STATEMENT_BUDGET | +349,290 | HICV + USALI |
| SEM_AI_INCOME_STATEMENT_FORECAST | +683,376 | HICV |
| SEM_AI_OPERATING_METRICS | +528 | BEAUMIER OPS |
| SEM_AI_UNKNOWN | +15,277 | HICV GL + USALI |
| SEM_AI_PACING | +16,584 | HICV |
| SEM_AI_BALANCE_SHEET | 0 | |

## Amounts (check 3), CLN = STG = XFRM = SEM

| Lane / table | Measure | Value |
|---|---|---|
| HICV FIN_PL_MONTHLY | ACTUAL | 2,500,007,132 |
| | FORECAST | 332,580,595 |
| | PREVIOUS_FORECAST | 1,782,677,832 |
| | BUDGET | 1,950,596,652 |
| HICV FIN_GL_MONTHLY | ACTUAL (all in UNKNOWN, D-48) | 146,831,311.54 |
| | SOURCE_LINES_COMBINED (CLN = STG) | 46,044 |
| HICV OPS_KPI_WEEKLY | ACTUAL_AMOUNT (1,308 non-null) | 1,876,639,094.5675 |
| | BUDGET_AMOUNT (654 non-null) | 974,968,766.120049 |
| HICV OPS_TREND_WEEKLY | ACTUAL_AMOUNT (6,664 non-null) | 11,840,994,151.0394 |
| | BUDGET_AMOUNT (1,115 non-null) | 4,510,207,773.57358 |
| HICV PACE_RESERVATIONS_WEEKLY | ACTUAL_AMOUNT (250 non-null) | 8,276,556 |
| HICV REF_ACCOUNTS / ROOM_KEYS | rows and numeric columns, CLN = STG | 22,220 / 304 rows |
| BEAUMIER FIN_FORECAST_VERSIONS | AMT | 38,515,055.066075 |
| BEAUMIER FIN_BUDGET_MONTHLY | AMT | 19,866,830.779535 |
| BEAUMIER FIN_BUDGET_MONTHLY_USALI | AMT | 22,925,892.688046 |
| BEAUMIER OPS_STATS_MONTHLY | STAT (sum of the 4 columns) | 196,602 |
| BEAUMIER PACE_CANCELLATIONS_MONTHLY | 13 numeric columns, CLN = STG = XFRM | 16,995 rows |

**Subtotals:** HICV states none in its facts (IS_SUBTOTAL false on every line). Its weekly reports flag their own (SOURCE_IS_SUBTOTAL, carried in ATTRIBUTES). BEAUMIER states none.

**Empty cells:** 683,376 of HICV's 1,366,752 staged P&L cells are empty. They are kept (invariant 1, as in the peer lanes) and add 0 to every sum.

## After stop 4
- **BEAUMIER:** IS 60,746, OM 528, UNKNOWN 346; SEM budget 24,436 lines; SEM_AI_UNKNOWN 346 (all DUPLICATE_DETAIL). The 20 USALI lines moved with their re-seeded keys.
- **HICV:** counts unchanged.
- Both reconcile scripts were rerun with 0 failures.
