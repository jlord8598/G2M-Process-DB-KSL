# Open questions - build 06 (DAVIDSON new; HHG and HERSHA rebuilt)

Numbered within this build. Builds 02 and 03's decisions for HHG and HERSHA
carry over unchanged, except the changes declared for this build.

## Answered at stop 1 (owner, 2026-10-23)

| # | Lane | Question | Answer |
|---|---|---|---|
| Q-01 | all | Table assignment and lane names | **Approved.** DAVIDSON (new) with its 3 tables, HHG and HERSHA rebuilt under D-44. BEAUMIER, INVITED_CLUBS and NEWBURY are out of scope and must not change. |
| Q-02 | HHG | `ASSET_NAME` for actuals | **Approved.** `REFERENCES.CLUB_NAME` on an exact entity = `CLUB_NUMBER` join; the new `ASSET_NAME_SOURCE` records the source. Forecast and rounds keep their own names. The 9 unmatched codes (`9050`-`9056`, `9099`, `9102`) stay null: a client item. |
| Q-03 | HHG, HERSHA | D-45 values | **Approved.** HHG keeps the source scenario names; `ROUNDS_DETAIL` gets `CLN_HERITAGE_GOLF_ROUNDS_DETAIL`. HERSHA `GL_ACTUAL` and `GL_STAT` get `ACTUAL_AMOUNT` / `FORECAST_AMOUNT`. |
| Q-04 | process | Freeze end | **2026-10-25 13:21 PDT.** If M3 cannot finish before then, stop and report. |

## Answered at stop 3 (owner, 2026-10-23)

| # | Answer |
|---|---|
| Q-05 | **Approved.** PL key = the line text (D-06 fallback). Trim and collapse repeated spaces only, no other cleanup. Built; it changes no key on this extract. |
| Q-06 | **Approved as proposed.** |
| Q-08 | **Approved.** Roll-ups, `SUMMARY` amount lines and `Total` amount lines are subtotals; GOP and EBITDA are subtotals too, now with their own `SUBTOTAL_SOURCE` text. `Total RevPar` stays a non-subtotal statistic. |
| Q-10 | **Noted.** Consumers separate the PL from the monthly report by `SOURCE_TABLE` (in `sources.md`). |
| HHG MAIN order | **Approved:** dictionaries before facts. |
| Q-07, Q-09 | **With the source owner. M4 is held:** no classification rows are written until the answer arrives, and the D-43 baseline is re-run before resuming. |

## Answered before M4 (owner, 2026-10-23): decided by owner from data; source owner to confirm

| # | Answer |
|---|---|
| Q-07 | **MR naturals 9000-9990 are STATISTICS.** 9000-9114 and 9400: room, cover and attendee counts. 9102 (`LHMGT`/`LHNMT`/`LHCON`): labor hours by position. 9300 (`UT*`, `ELECT`, `GAS`, `WATER`, `SEWER`): utility usage. 9990 `LAOFF`/`STOFF`: stat-ledger offsets, STATISTIC and adding to no total, with that reason stated. Built at M4; the segment values were checked against the data (M4). 9201 (`LHNMT`/`LNCOK`, 12 rows) falls in the range. |
| Q-09 | **MR hierarchy by natural account, not the 5xxx digit.** 4xxx Revenue. 5000-5006 Payroll. 5100 COGS. 5110 the nearest existing cost-of-sales H2 (`Cost of Goods Sold`). 5200, 5201, 5900 Operating Expenses. 5202-5204 utilities: no `Utilities` H2 exists, so `Operating Expenses` now, listed at stop 4. 5990 Allocations & Reserves. 6xxx-8xxx as proposed. The PL mapping stays as proposed: worded sections only. Built at M4. |

## Open at stop 4

| # | Item | Blocks | Proposal |
|---|---|---|---|
| Q-11 | **`Utilities` H2.** It is not in the standard vocabulary (CLAUDE.md section 5) or in any `DEV_G2M_AI` lane. The master was not read (D-03). DAVIDSON MR 5202-5204: 99 keys, 1,188 source rows, now seeded `Operating Expenses`. | no | The owner checks the master, and adds `Utilities` there and to the standard vocabulary if wanted; the master rows are re-pointed after promotion. |
| Q-12 | **Q-07 and Q-09 await the source owner's confirmation.** | no | If he disagrees, the DAVIDSON staging model (Q-07) or the seeder branch (Q-09) changes. DAVIDSON's classification rows are seeded, so a Q-09 change after promotion is a master correction, not a re-seed (D-14). |
| Q-13 | **Report only.** DAVIDSON PL department sections stay `Unclassified`: 17,182 keys and 435,840 staged rows, the bulk of `SEM_AI_UNKNOWN` for the lane. | no | Classified in the master by people. |

## Resume steps (M4 on hold since 2026-10-23, end of day)

M4 resumes only when the source owner has answered Q-07 and Q-09. Then, in
order:

1. **Re-run the D-43 baseline.** For all 12 in-scope tables, compare
   `last_altered`, row count and every numeric sum with the baseline table in
   `docs/sources.md` (the query is in this session's record; the last clean
   check was 14:43:22 PDT, query `01c7ee37-020a-47a7-0003-4ff21bc9f226`). Any
   change is a stop. Also confirm that the freeze is still open: it ends
   2026-10-25 13:21 PDT.
2. **Snapshot every object that will be redeployed, before redeploying it.**
   Hash (`hash_agg`, `RUN_ID` excluded) the tables each changed procedure
   builds, and save the result under `docs/findings/`. The M3 re-run lacked
   this snapshot for `STG_DAVIDSON_FULL_YEAR_PL`. If Q-07 makes 9xxx
   STATISTIC, that covers `STG_DAVIDSON_HOTEL_MONTHLY_REPORT` before its model
   changes. Always cover:
   - the HHG and HERSHA classification rows (baseline
     `check5_rebuilt_xref_baseline.csv`);
   - the earlier-build baseline (`check5_earlier_hashes_M2_baseline.csv`).
3. **Start M4.**
   - Add the DAVIDSON branch to `SPROC_XREF_ACCOUNT_CLASSIFICATION`, built on
     the Q-07 and Q-09 answers.
   - Restore the HHG and HERSHA XREF MAINs from build 02 and 03 text, and
     write the DAVIDSON XREF MAIN.
   - Run the checks: 2(a)-(d), (f), (k), (l); checks 4 and 5; the D-44 key
     report for HHG and HERSHA; and the review report.

## Raised at M1 (DAVIDSON; the stop-3 answers are above)

| # | Question | Blocks | Proposal |
|---|---|---|---|
| Q-05 | **Key composition.** MR: site `HOTEL_CODE`, department = segment 1 of a 6-segment `ACCOUNT` (null on the 156 one-segment `x...` strings and on `ADR`/`Rooms`), `ACCOUNT_KEY = ACCOUNT`, else `LINE_CLASS`. PL: site `HOTEL_CODE`, department `SECTION`, `ACCOUNT_KEY = LINE_ITEM` (`SOURCE_ITEM_ID`). PL roll-ups have a null hotel code, so their site is `~BLANK~` and the two groups share keys; `ASSET_NAME` (`Islamorada` / `Davenport Collection`) still tells them apart. | M4 | As stated. The alternative, roll-up site = `HOTEL_NAME`, would separate the two groups' keys but uses a name column as a code. |
| Q-06 | **`RECORD_TYPE`.** MR: `LINE_CLASS` `ADR` / `Rooms` are STATISTIC (180 rows each, no account), `Item` is AMOUNT. PL: the seven lines in `SUMMARY`'s hotel-heading sections (`ADR`, `Available Rooms`, `Comp Rooms`, `Occupancy`, `Rooms RevPar`, `Rooms Sold`, `Total RevPar`; 1,428 rows) are STATISTIC, everything else AMOUNT. Neither table has a type column; the MR class is stated by the source, the PL block is a rule. | M4 | As stated. |
| Q-07 | **MR natural accounts 9000-9990** (27 naturals, 36,480 rows). They look like statistics: 9000 on `PROOM` is whole numbers to 22,196, 9001 sits on restaurants, 9102 on 51 departments. But 9300 on `PENER` sums 68.1M and 9990 on `PSTAT` sums -71.9M, and nothing in the source states a type. | M4 | **AMOUNT** until the owner says otherwise. The digit table then seeds them `Allocations & Reserves`, unsigned, so they add to no total. If they are statistics, `RECORD_TYPE` becomes STATISTIC on digit 9 (as HHG department 999). |
| Q-08 | **PL subtotals.** Flag (a) `IS_ROLLUP` (40,824 rows; source flag); (b) every `SUMMARY` amount line (5,616 rows; verified on one line pair, 204 of 204 exact); (c) **amount** line items whose first word is `Total` (case-insensitive; 47,172 non-roll-up rows; structure only; built at M3 to exclude the statistic `Total RevPar`, a rate). **Borderline, not flagged:** `ALL_DEPARTMENT` lines with no `Total` word that may still be totals, for example lines beginning `NET` or `GROSS`; and on `SUMMARY`, the computed lines `Departmental Profit`, `Gross Operating Profit`, `House Profit`, `EBITDA`, `EBITDA LESS REPLACEMENT RESERVE` are flagged by (b) but are computed measures rather than totals. MR has no way to tell: unflagged. | M4 | (a)+(b)+(c) as stated; the owner to rule on the borderline groups. |
| Q-09 | **Hierarchy.** MR: the leading digit of the natural account (segment 2) on the standard table. Digit 5 (89,844 rows, 227.5M actual) seeds `Cost of Goods Sold`, but with no descriptions it may hold departmental payroll; one-segment `x...` strings are `Unclassified`. PL: no code, so `Unclassified`, except sections that state their section in words: `Operating Revenues` gives Revenue; `Departmental Expenses` and `Undistributed Operating Expenses` give Expense / `Operating Expenses`; `Non-Operating Income and Expenses` and `NON-OPERATING INCOME & EXPENSE` give Below the Line; `MISCELLANEOUS INCOME` gives Revenue. Department sections (`ROOMS`, `SPA` ...) mix revenue and expense, so they are not mapped. | M4 | As stated. |
| Q-10 | **Report only.** (a) MR and PL cover the same 15 hotels and 12 months, so summing both counts money twice; `SOURCE_TABLE` separates them. (b) `ACCOUNTS` is not unique on entity + string + source table: 2,043 extra rows differing only in `DEPARTMENT_DESCRIPTION` and `FIRST_SEEN_DATE`. It is staged losslessly; the facts read only `ACCOUNT_DESCRIPTION`, which has one value per string. (c) 12,684 PL rows repeat a line's dimensions; they are distinct source rows and are kept. | no | Recorded. |

## Answered at stop 4 (owner, 2026-10-23)

| # | Answer |
|---|---|
| Q-11 | **Closed.** `Utilities` (MR 5202-5204) stays under `Operating Expenses`. No new H2. |
| 9201 | **Approved** as STATISTIC (labor hours, `LHNMT`/`LNCOK`). |
| Stop 4 | **Build approved.** Promotion is done by the owner. |

## For the business (master H2)

| Item | Detail |
|---|---|
| DAVIDSON PL department sections | **17,182 keys are left `Unclassified` by design** (Q-09, Q-13). They are the `FULL_YEAR_PL` `ALL_DEPARTMENT` sections (`ROOMS`, `SPA`, `RESTAURANT 1` ...), whose lines mix revenue and expense: 435,840 staged rows, 164,040 of them subtotals. They land in `SEM_AI_UNKNOWN` (`UNCLASSIFIED_ACCOUNT`) until H1/H2 are assigned in the master. |
