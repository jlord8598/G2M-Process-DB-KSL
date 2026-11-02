# Reconciliation - build 09 (INVITED_CLUBS)

**Does every record arrive?** Yes. Every source row reaches staging, its
stream and semantic. Every numeric sum is equal within 0.005.

## Reconcile script (run at M6)

`scripts/reconcile_INVITED_CLUBS.sql` (build 03 text, unchanged): **15 rows
compared, 0 failures.**

| Table | Rows | Measures (CLN = STG = XFRM = SEM) |
|---|---|---|
| ESSBASE_EXTRACT | 17,296,157 x 3 = 51,888,471 | AMT 452,143,631,494.71; STAT 539,676,405.36 |
| ACCOUNTS | 288,714 | ROW_COUNT 17,268,114 (CLN = STG) |
| META_ACCOUNT / DEPARTMENT / ENTITY / LOCATION / SUBACCOUNT | 9,244 / 799 / 5,472 / 1,507 / 1,198 | SOURCE_ROW_NUMBER equal (CLN = STG) |

## Count identity (queries `01c826bc-...-9752`, `01c826c5-030a-6ed8-0003-4ff21c5ad712`)

| Fact staged | XFRM (IS + BS + OM + UNKNOWN) | SEM (ACTUAL + BUDGET + FORECAST + BS + OM + UNKNOWN) |
|---|---|---|
| 51,888,471 | 10,145,931 + 10,072,524 + 22,494,201 + 9,175,815 | 3,381,977 x 3 + 10,072,524 + 22,494,201 + 9,175,815 = 51,888,471 |

## Subtotals

- **IS_SUBTOTAL is TRUE on 375,747 staged rows:**
  - `REPORT_LEVEL EBITDA_SUMMARY` (Adjusted Cash EBITDA);
  - the 7 `Ind-Total*` members;
  - `Ind-Adjusted Cash EBITDA` and `Ind-Club Operating Profit` (new, Q-04,
    by structure).
- **All are in UNKNOWN as SOURCE_ROLLUP.** After build 09, no subtotal row
  remains in a classified stream.
