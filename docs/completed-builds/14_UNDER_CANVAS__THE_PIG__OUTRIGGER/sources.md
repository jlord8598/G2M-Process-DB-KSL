# Sources - build 14 (new lanes UNDER_CANVAS, THE_PIG, OUTRIGGER)

**State: stop 1.** Written from queries run in this session against `CLN.BOX_INVESTMENT_DATA`.

## Source schema and freeze (D-43)

- **Source:** `CLN.BOX_INVESTMENT_DATA`, the 12 tables below.
- **Freeze:** from **2026-11-06 07:55:14.618 PST** (first successful read). **End: 2026-11-07 06:00 America/Los_Angeles** (owner Q-01); past it, continue only while D-43 shows no change.
- **Extract:** all 12 tables created 2026-11-06 03:06:31 to 03:07:08 PST.

| Table | Rows | HASH_AGG(*) |
|---|---|---|
| CLN_OUTRIGGER_PACE | 13,256 | -926676262620762058 |
| CLN_PIG_HOTELS_PACE_NEXT_YEAR | 1,728 | -6626632639382259087 |
| CLN_PIG_HOTELS_PACE_THIS_YEAR | 1,728 | -6667705148816344511 |
| CLN_UNDER_CANVAS_ACCOUNTS | 2,623 | 8591774308905816307 |
| CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES | 27,505 | 546088064065887215 |
| CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES | 6,722 | 1586988466465073507 |
| CLN_UNDER_CANVAS_CANCELLATIONS | 408 | 6309105477389416414 |
| CLN_UNDER_CANVAS_CONSOLIDATED_PL | 102 | -7071390872765718498 |
| CLN_UNDER_CANVAS_DUETTO_DATA | 408 | 2065469859008614681 |
| CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS | 1,363 | -6911953387288909797 |
| CLN_UNDER_CANVAS_TOTAL_REVENUE | 56,663 | -192211268073281671 |
| CLN_UNDER_CANVAS_WEEKLY_PACE | 72,576 | -6837978762827795817 |

## Proposed lanes (owner names; scope confirmation pending)

| Lane | Tables | Proposed role |
|---|---|---|
| UNDER_CANVAS | TOTAL_REVENUE, CAMP_OPERATING_EXPENSES, CAMP_NON_OPERATING_EXPENSES, STATISTICAL_ACCOUNTS | facts (ACTUAL) |
| UNDER_CANVAS | CONSOLIDATED_PL | YTD summary; Q-04 |
| UNDER_CANVAS | ACCOUNTS | dictionary |
| UNDER_CANVAS | WEEKLY_PACE, DUETTO_DATA, CANCELLATIONS | pacing (D-24) |
| THE_PIG | PIG_HOTELS_PACE_THIS_YEAR, PIG_HOTELS_PACE_NEXT_YEAR | pacing only |
| OUTRIGGER | OUTRIGGER_PACE | pacing only |

Lane names free: no master, snapshot, semantic or archived-build rows (D-03, D-32).

## Decisions at stop 1 (owner)

- **CURRENCY_CODE:** UNDER_CANVAS USD, THE_PIG GBP (owner-confirmed); OUTRIGGER USD (stated). No D-49 scale (units, measured).
- **UNDER_CANVAS facts:** TOTAL_REVENUE, CAMP_OPERATING_EXPENSES, CAMP_NON_OPERATING_EXPENSES (income statement), STATISTICAL_ACCOUNTS (operating metrics). Key: LOCATION / DEPARTMENT / account code (leading code of ACCOUNT) / RECORD_TYPE. Category ACTUAL; SCENARIO `Actuals` verbatim.
- **H1 / H2 (D-46, account blocks):** 40xx-41xx Revenue; 50xx and 81xx COGS; 72xx, 77xx, 6300, 6512, 7920 Payroll; other 60xx-79xx Operating Expenses; 90xx Statistic (H2 = account text).
- **D-48 (UNDER_CANVAS):** the P&L detail beats CONSOLIDATED_PL; every CONSOLIDATED_PL row to UNKNOWN as DUPLICATE_DETAIL.
- **Pacing:** UNDER_CANVAS WEEKLY_PACE, DUETTO_DATA, CANCELLATIONS; THE_PIG both tables; OUTRIGGER_PACE (V1 and V2 as is). As-of = SNAPSHOT_DATE. THE_PIG and OUTRIGGER are pacing-only lanes.
- **Tie-out at stop 4:** Revenue - COGS - Payroll - OpEx = GOP 27,575,053.88, YTD and per department.

## Build 14 staging (M3)

12 models (M3.md). UNDER_CANVAS facts: long, one branch; key from structural code splits of LOCATION / DEPARTMENT / ACCOUNT. Pacing tables and the dictionary staged verbatim.
