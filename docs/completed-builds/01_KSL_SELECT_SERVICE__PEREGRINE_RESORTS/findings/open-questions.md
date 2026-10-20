# Open questions - this build

Numbered within this build. Answered questions keep their number and record
the owner's answer. This is the state after the Q-04 re-run at stop 4: what
still needs a person.

## Answered at stop 2

| # | Question | Owner's answer (stop 2) |
|---|---|---|
| Q-01 | Paired rows (account and stat account both present) map to chart `ACCOUNT_KIND = STAT` but carry real P&L amounts. AMOUNT or STATISTIC? | `RECORD_TYPE = 'AMOUNT'`, with `STAT_UNIT_FAMILY` derived from the statistic account (D-29). |
| Q-02 | Blank-account rows (81.6% of KSL daily, 72.5% of PEREGRINE daily) all key to `~BLANK~`. | CLAUDE.md amended (D-06, sections 3 and 5): `ACCOUNT_KEY` falls back to the staging-only column `SOURCE_ITEM_ID` before `~BLANK~`. `SOURCE_ITEM_ID = ITEM_TAG` on `DAILY_EXTENDED`, `MONTHLY_EXTENDED` and `LEDGER_BATCHES`. See Q-14: `LEDGER_BATCHES` has no `ITEM_TAG`. |
| Q-03 | Department is on no fact row. | `DEPARTMENT` = segment 1 of the account code, a structural split in staging. `DEPARTMENT_NAME` from the chart of accounts. No account means `~BLANK~`. |
| Q-05 | Borderline subtotal groups. | `IS_SUBTOTAL = TRUE` for `TOT*` item tags only. `RF*`, `DVR*`, `CFL*` and `SEQ*` stay `FALSE`, with `SUBTOTAL_SOURCE` recording them as borderline and unflagged. |
| Q-06 | `DAILY_LABOR` role. | Fact table. `DEPARTMENT` from the numeric prefix of `DEPARTMENT_LABEL`; `SOURCE_ITEM_ID = LABEL`; `SOURCE_LINE_KEY` null. Employee IDs stay in staging only and never reach `SEMANTIC`. |
| Q-07 | `SALES_BOOKINGS` role. | A pacing-side dictionary, staged per lane in its own shape. It never feeds the seeder (D-37). |

## Answered at stop 3

| # | Question | Owner's answer (stop 3) | Applied |
|---|---|---|---|
| Q-09 | Ledger duplicates daily; daily equals monthly actuals on about 99.8% of keys. Guidance in the deliverable? | Yes. `reconciliation.md` states plainly that `DAILY_EXTENDED`, `MONTHLY_EXTENDED` and `LEDGER_BATCHES` overlap and that consumers must filter on `SOURCE_TABLE` rather than sum across them. | `reconciliation.md`, first section |
| Q-10 | Digit 2 = Intercompany in the chart. Follow section 5? | Seed per the CLAUDE.md section 5 digit table (digit 2 = `Balance Sheet` / `Liabilities`). Report the affected account counts. | KSL 28 accounts (62 keys), PEREGRINE 1 (1 key); M4.md |
| Q-11 | D&A inside section 8. Seed as `Other Income / (Expense)`? | Seed per the CLAUDE.md section 5 digit table (digit 8 = `Below the Line` / `Other Income / (Expense)`). Report the affected account counts. | Depreciation named on KSL 4 accounts (99 keys), PEREGRINE 1 (1 key); M4.md |
| Q-12 | Malformed codes carried raw; classify `Unclassified`. No special handling? | Confirmed. No special handling (invariant 3). | M4.md |
| Q-13 | KSL site group `ALL` = "Peregrine Hospitality". | Report only. | carried as-is |
| Q-14 | `LEDGER_BATCHES` has no `ITEM_TAG`. | Option (a). `SOURCE_ITEM_ID` is null on `LEDGER_BATCHES`; those rows key to `~BLANK~`. | as built |
| Q-15 | `RECORD_TYPE` for rows with no account and no stat account. | `AMOUNT` confirmed. | as built |
| Q-16 | Labor departments the chart cannot name (`DNU F&B`, KSL `605`, `898`). | Report only. | carried as-is |

## Answered at stop 4

| # | Question | Owner's answer (stop 4) | Applied |
|---|---|---|---|
| Q-04 | **Unmapped scenarios.** At M6 these routed to `SEM_UNKNOWN` as `UNRESOLVED_CATEGORY` (or `BOTH`): KSL `Flex` 82,988 rows, `5 Year Plan 2026 Final` 7,097, `RMS - OneYield` 182, `RMS - HiltonGRO/IDeaS` 31; PEREGRINE `Flex` 36,972. Which category, if any? | Map `Flex`, both RMS scenarios (exact names as they appear in `DATASETS`) and `5 Year Plan 2026 Final` to `CATEGORY = 'FORECAST'`, `SCENARIO` kept verbatim, in both lanes' `SPROC_XFRM_{LANE}`. | See below and `M6-q04-rerun.md`. |

**How Q-04 was applied.**
- **Code.** One branch added to the `cat` CTE of `SPROC_XFRM_KSL_SELECT_SERVICE`
  and `SPROC_XFRM_PEREGRINE_RESORTS`, listing the four names exactly as staged
  from `DATASETS`: `Flex`, `RMS - OneYield`, `RMS - HiltonGRO/IDeaS`,
  `5 Year Plan 2026 Final`. Both files rewritten in full and redeployed; new
  MD5s `b2898a41897829a62fc1ed0c5a8198fc` and
  `331f44d03f9e41cdfc5fb081885acfb0`; parity 41 OK.
- **Where the rows went** (each by its `H1`):
  - KSL: 87,303 to `SEM_INCOME_STATEMENT_FORECAST`, 1,658 to
    `SEM_BALANCE_SHEET`, 631 to `SEM_OPERATING_METRICS`; 706 stay in
    `SEM_UNKNOWN`, now `UNCLASSIFIED_ACCOUNT` (their account has no
    classification) with `CATEGORY = 'FORECAST'`. Total 90,298.
  - PEREGRINE: 36,735 to `SEM_INCOME_STATEMENT_FORECAST`, 217 to
    `SEM_OPERATING_METRICS`; 20 stay in `SEM_UNKNOWN` as
    `UNCLASSIFIED_ACCOUNT`. Total 36,972.
- **Result.** No row on either lane now awaits a category. All six checks
  pass; both reconcile scripts report 0 failures; ACTUAL and BUDGET hash
  exactly as at M6.
- **Two PEREGRINE `DATASETS` names were not mapped**, because the answer did
  not name them: `5 Year Plan 2026` (FCID 16; KSL's is `... Final`) and `RMS`
  (FCID 11). Both have 0 fact rows in this extract. If either gains rows they
  will route to `SEM_UNKNOWN` as `UNRESOLVED_CATEGORY` until mapped.
- **The 5 Year Plan is a blend.** It carries actuals-like values for elapsed
  months (evidence below), so `FORECAST` here means "not actuals", not a pure
  projection. Consumers should filter on `SCENARIO` within the forecast
  table (`reconciliation.md`).

## Open

| # | Question | Blocks | Until answered |
|---|---|---|---|
| Q-08 | **Pace window.** At M6, every pace row on both lanes has its period before its as-of date: a trailing window (`DAYS_OUT` equals period minus as-of on every row). KSL holds 21 snapshots, 27 Sep - 19 Oct. PEREGRINE pace tables arrived in the 07:39 reload with 1 snapshot, 19 Oct (8,898 rows). The as-of date exists, so pacing is derivable. What the source would need to supply for a forward booking position is rows with periods on or after the as-of date. Is the forward position missing from the extract? | no | built as-is |
| Q-17 | **The source reloads during a build.** All 25 `CLN.CLEAN` tables were recreated three times: (1) 2026-10-16 15:26:36 - 15:27:06, during M2; (2) 2026-10-19 02:18:09 - 02:18:41, after M3; (3) 07:39:27 - 07:39:56, during M5 run 2; there was no reload during M6 or the Q-04 re-run (`max(last_altered)` still 07:39:56.040 after the final build). Each reload grew the facts: KSL daily went 2,014,289 (M3), 2,046,893 (M4/M5), 2,050,067 (M6). Reload 3 also populated PEREGRINE's pace tables and two of its dictionaries for the first time. Time Travel is unavailable, so the changed rows cannot be identified. Every milestone reconciles to the extract it ran on; M6's figures are for the 07:39 extract, and M3-M5 figures differ from them for that reason. The reloads look scheduled. Confirm, and say whether builds should run against a frozen copy. | no | figures reported against the live source |
| Q-18 | **Ledger stat-only rows equal daily stat-only rows** to the cent: KSL `AMT` 135,500,997.99 over 9,059 non-zero rows in each, PEREGRINE 163,454,410.62 over 235 (measured at M5 against `CLN`). This is more evidence of the Q-09 overlap, and it also means `SEM_OPERATING_METRICS` carries real `SOURCE_AMOUNT` on stat-only rows. Report only, unless the owner wants it treated differently. | no | carried as booked |
| Q-19 | **Sign outliers to check in the master** (`classification-coverage.md`). The largest income-statement outlier is one KSL `Below the Line` account at -4,736,537.42, on both daily and monthly. Revenue and expense outliers are small and look like contra accounts. None was reclassified. After Q-04, only the KSL monthly balance sheet line moved (6,139 outlier rows, -171,040,436.10; same 134 accounts). | no | report only |

## Q-04 evidence: KSL `5 Year Plan 2026 Final` against Actuals, rooms revenue

Read-only check at stop 4, run **before** Q-04 was answered, against the
deployed M6 tables (queries `01c7d6a0-020a-2e85-0003-4ff21b860676`,
`01c7d6a0-020a-2696-0003-4ff21b8624e2`, `01c7d6a0-020a-2979-0003-4ff21b866186`).
At that time the plan rows were in `SEM_UNKNOWN`; since the re-run they are
in `SEM_INCOME_STATEMENT_FORECAST` with the same `SOURCE_AMOUNT`, so the
figures below are unaffected.

**Method.**
- **Plan:** `SEM_UNKNOWN` (now `SEM_INCOME_STATEMENT_FORECAST`), `SOURCE_LANE = 'KSL_SELECT_SERVICE'`, `SCENARIO = '5 Year Plan 2026 Final'`, `ACCOUNT_NUMBER = '100-4004-000'` (ROOM REV - BAR), `SOURCE_AMOUNT` summed per site and month.
- **Actuals:** `SEM_INCOME_STATEMENT_ACTUAL`, the same lane, `DEPARTMENT = '100'`, section digit (character 5) `= '4'`, `SOURCE_AMOUNT` summed per site and month.
  - Restricted to `SOURCE_TABLE = CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED`, the plan's own table, per the Q-09 rule against summing across overlapping extracts. Every row selected has `SCENARIO = 'Actuals'` and `IS_SUBTOTAL = FALSE`.
- **Ratio:** plan / actuals, rounded to 4 places.

**Does the plan carry any other rooms revenue account?**
- **Department 100, section 4: no.** `100-4004-000` is the only one, and it holds 418 rows (38 sites x 11 months, 2026-06 to 2027-04). Actuals spread rooms revenue over 6 to 19 section-4 accounts per site-month.
- **Department 100, outside section 4:** the plan has one other account, `100-7700-000` SUPPLIES - GUEST SUPPLIES, which is an expense.
- **Section 4, outside department 100:** `770-4036-000` GUEST ROOM CANCELLATION (418 rows) is rooms-related revenue under department 770. It is not in the comparison.
- **In total the plan carries 20 accounts.** It is one line per P&L area, not a full chart.

**Summary per month (sites with both a plan and an actual).**

| Month | Site pairs | Plan equals Actuals to the dollar | Within 0.5% | Off by more than 5% | Plan total | Actuals total |
|---|---|---|---|---|---|---|
| 2026-06 | 38 | 24 | 33 | 4 | 21,689,842 | 22,263,088.57 |
| 2026-07 | 38 | 0 | 0 | 13 | 23,423,303 | 24,606,635.50 |

**Reading.**
- **June 2026:** the plan's single BAR line equals the actual total of all department-100 section-4 accounts, rounded to the dollar, at 24 of 38 sites, and is within 0.5% at 33. June looks like actuals loaded into the plan as total rooms revenue under one account. That is a closed month carried as fact, not a forecast.
- **July 2026:** the plan never matches. Ratios run from 0.585 to 1.1986, which reads as a genuine projection.
- **The scenario is therefore mixed:** actuals for elapsed months and plan for later ones. The source carries no column that says where the switch happens.
- **Five sites carry the same plan figure in June and July:** CAALSOP 404,070, CAPRIOP 644,798, CATIBOP 476,559, CATOLOP 450,122 and CAVPBOP 1,148,701. Four of them are the June sites off by more than 5%.
- **CASCHOP has actuals in both months and no plan row.**
- **The owner's answer** (above): map it to `FORECAST`, scenario verbatim.

**Per site-month.** Plan BAR and the Actuals rooms total are `SOURCE_AMOUNT`.

| Month | Site | Plan BAR | Actuals rooms (accounts) | Ratio |
|---|---|---|---|---|
| 2026-06 | 167 | 661,918 | 663,823.17 (8) | 0.9971 |
| 2026-06 | 168 | 580,509 | 580,509.34 (8) | 1.0000 |
| 2026-06 | 170 | 743,032 | 743,031.85 (10) | 1.0000 |
| 2026-06 | 171 | 451,395 | 451,574.96 (10) | 0.9996 |
| 2026-06 | 177 | 653,324 | 653,324.27 (10) | 1.0000 |
| 2026-06 | 183 | 474,453 | 474,453.26 (8) | 1.0000 |
| 2026-06 | 190 | 119,094 | 119,093.99 (6) | 1.0000 |
| 2026-06 | 193 | 289,259 | 289,686.73 (8) | 0.9985 |
| 2026-06 | 194 | 334,453 | 334,453.35 (10) | 1.0000 |
| 2026-06 | 195 | 1,742,898 | 1,743,248.17 (11) | 0.9998 |
| 2026-06 | 197 | 342,558 | 343,533.62 (12) | 0.9972 |
| 2026-06 | 198 | 462,716 | 464,065.72 (11) | 0.9971 |
| 2026-06 | 201 | 420,017 | 420,166.93 (13) | 0.9996 |
| 2026-06 | 203 | 510,907 | 510,906.74 (10) | 1.0000 |
| 2026-06 | 306 | 477,225 | 477,325.49 (19) | 0.9998 |
| 2026-06 | 307 | 388,385 | 388,384.77 (10) | 1.0000 |
| 2026-06 | 308 | 413,708 | 413,708.38 (9) | 1.0000 |
| 2026-06 | 309 | 1,608,129 | 1,608,129.34 (10) | 1.0000 |
| 2026-06 | 310 | 461,146 | 461,281.28 (10) | 0.9997 |
| 2026-06 | 311 | 579,021 | 579,020.75 (10) | 1.0000 |
| 2026-06 | 312 | 650,505 | 650,504.79 (11) | 1.0000 |
| 2026-06 | CAALSOP | 404,070 | 382,354.58 (7) | 1.0568 |
| 2026-06 | CAPRIOP | 644,798 | 640,030.28 (12) | 1.0074 |
| 2026-06 | CASCHOP | no plan row | 817,645.58 (9) | - |
| 2026-06 | CASTCOP | 793,722 | 793,722.16 (10) | 1.0000 |
| 2026-06 | CATIBOP | 476,559 | 589,468.73 (12) | 0.8085 |
| 2026-06 | CATOLOP | 450,122 | 530,085.43 (8) | 0.8491 |
| 2026-06 | CAVPBOP | 1,148,701 | 1,549,983.14 (9) | 0.7411 |
| 2026-06 | FLINTOP | 163,628 | 163,628.25 (10) | 1.0000 |
| 2026-06 | MACLEOP | 528,572 | 528,571.90 (8) | 1.0000 |
| 2026-06 | MAFBWOP | 507,417 | 507,416.53 (8) | 1.0000 |
| 2026-06 | MAFCCOP | 638,353 | 638,353.30 (10) | 1.0000 |
| 2026-06 | MAHLEOP | 313,822 | 313,821.76 (9) | 1.0000 |
| 2026-06 | MARBWOP | 555,592 | 555,591.79 (9) | 1.0000 |
| 2026-06 | NHCHLOP | 817,196 | 817,195.82 (8) | 1.0000 |
| 2026-06 | NYRIKOP | 555,928 | 555,927.79 (7) | 1.0000 |
| 2026-06 | TXHTXOP | 483,583 | 483,582.79 (12) | 1.0000 |
| 2026-06 | VARNAOP | 621,018 | 621,018.41 (9) | 1.0000 |
| 2026-06 | VTKMLOP | 222,109 | 222,109.01 (11) | 1.0000 |
| 2026-07 | 167 | 606,947 | 613,433.91 (10) | 0.9894 |
| 2026-07 | 168 | 518,588 | 508,903.25 (9) | 1.0190 |
| 2026-07 | 170 | 648,056 | 656,552.45 (9) | 0.9871 |
| 2026-07 | 171 | 435,013 | 475,593.21 (11) | 0.9147 |
| 2026-07 | 177 | 654,669 | 669,704.14 (11) | 0.9775 |
| 2026-07 | 183 | 513,292 | 468,801.71 (9) | 1.0949 |
| 2026-07 | 190 | 143,354 | 119,601.01 (7) | 1.1986 |
| 2026-07 | 193 | 296,155 | 313,651.65 (8) | 0.9442 |
| 2026-07 | 194 | 319,339 | 309,115.39 (9) | 1.0331 |
| 2026-07 | 195 | 2,292,171 | 2,250,156.15 (11) | 1.0187 |
| 2026-07 | 197 | 362,732 | 372,063.78 (11) | 0.9749 |
| 2026-07 | 198 | 479,041 | 489,143.36 (10) | 0.9793 |
| 2026-07 | 201 | 598,284 | 576,158.76 (11) | 1.0384 |
| 2026-07 | 203 | 847,262 | 851,914.94 (8) | 0.9945 |
| 2026-07 | 306 | 428,649 | 421,238.44 (16) | 1.0176 |
| 2026-07 | 307 | 355,059 | 368,620.40 (9) | 0.9632 |
| 2026-07 | 308 | 367,817 | 372,482.25 (10) | 0.9875 |
| 2026-07 | 309 | 1,690,524 | 1,852,046.93 (9) | 0.9128 |
| 2026-07 | 310 | 517,985 | 460,312.21 (11) | 1.1253 |
| 2026-07 | 311 | 611,142 | 569,003.89 (10) | 1.0741 |
| 2026-07 | 312 | 737,065 | 742,562.66 (10) | 0.9926 |
| 2026-07 | CAALSOP | 404,070 | 690,705.44 (6) | 0.5850 |
| 2026-07 | CAPRIOP | 644,798 | 753,458.36 (10) | 0.8558 |
| 2026-07 | CASCHOP | no plan row | 1,490,415.25 (9) | - |
| 2026-07 | CASTCOP | 1,025,210 | 1,007,741.37 (10) | 1.0173 |
| 2026-07 | CATIBOP | 476,559 | 557,179.07 (11) | 0.8553 |
| 2026-07 | CATOLOP | 450,122 | 376,264.86 (9) | 1.1963 |
| 2026-07 | CAVPBOP | 1,148,701 | 1,876,025.08 (13) | 0.6123 |
| 2026-07 | FLINTOP | 178,515 | 181,533.56 (9) | 0.9834 |
| 2026-07 | MACLEOP | 774,440 | 797,375.96 (9) | 0.9712 |
| 2026-07 | MAFBWOP | 471,706 | 486,978.66 (9) | 0.9686 |
| 2026-07 | MAFCCOP | 915,384 | 860,108.04 (10) | 1.0643 |
| 2026-07 | MAHLEOP | 546,216 | 542,615.14 (11) | 1.0066 |
| 2026-07 | MARBWOP | 492,480 | 511,026.93 (7) | 0.9637 |
| 2026-07 | NHCHLOP | 618,794 | 602,945.41 (9) | 1.0263 |
| 2026-07 | NYRIKOP | 618,877 | 635,200.22 (7) | 0.9743 |
| 2026-07 | TXHTXOP | 423,994 | 436,522.23 (11) | 0.9713 |
| 2026-07 | VARNAOP | 606,390 | 615,511.96 (9) | 0.9852 |
| 2026-07 | VTKMLOP | 203,903 | 214,382.72 (9) | 0.9511 |

**Ratio rounding:** "1.0000" means the ratio rounds to 1.0000 at 4 decimal places. The exact "to the dollar" count is in the summary table.
