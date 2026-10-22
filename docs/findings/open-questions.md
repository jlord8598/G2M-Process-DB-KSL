# Open questions - build 03 (HERSHA, INVITED_CLUBS, BEAUMIER)

Numbered within this build. Figures are from queries run on 2026-10-21 against
`CLN.BOX_INVESTMENT_DATA`; detail is in `docs/sources.md`.

## Answered at stop 1

| # | Question | Owner's answer (stop 1) |
|---|---|---|
| - | Lanes and scope | `HERSHA` (3 tables), `INVITED_CLUBS` (7), `BEAUMIER` (4), as proposed. Build 02's 15 tables out of scope. None of the three names is in the master. |
| - | Freeze window | 48 hours from the answer, from the database clock: 2026-10-21 11:43:21 PDT to 2026-10-23 11:43:21 PDT. |

## Answered at stop 2 (M1 approved)

| # | Lane | Question | Owner's answer (stop 2) | Applied in |
|---|---|---|---|---|
| Q-01 | INVITED_CLUBS | Subtotals | **`EBITDA_SUMMARY` -> `IS_SUBTOTAL = TRUE`.** **`TotalDOMEnter` stays `FALSE`**, with `SUBTOTAL_SOURCE` recording it as borderline (76% match: 82,758 of 108,850 groups). | ESSBASE staging model |
| Q-02 | HERSHA | `GL_STAT` values in `ACTUAL_AMOUNT` | **Approved:** `RECORD_TYPE = 'STATISTIC'`, value in `STAT_VALUE`; rule recorded per table in `RECORD_TYPE_SOURCE`. | GL_STAT staging model |
| Q-03 | HERSHA | 25-account map | **Map only where `CLN_HERSHA_ACCOUNTS` states the entry; where it rests on description wording, use the ?5 digit table and list the accounts for correction in the master.** `ACCOUNTS` states only `ACCOUNT_DESCRIPTION`; `ALIAS`, `PARENT_CODE` and `SUBACCOUNT_*` are null on all 30 accounts (query `01c7e24f-020a-3b2d-0003-4ff21baa2dba`). Every departure from the digit would rest on wording, so **all HERSHA money accounts take the digit table** (first digit of `ACCOUNT_CODE`). **Listed for correction in the master** (the digit disagrees with the description): `610000 Operating Expenses` and `630000 Management Fees` (digit 6 -> Payroll; description says operating expense / fee); `700000 Non-Operating Income` and `714000 Non-Operating Expenses` (digit 7 -> Operating Expenses; description says non-operating). `999999` and the `ST*` accounts are STATISTIC by record type, which is read before any digit. | HERSHA seeder branch (M4) |
| Q-05 | INVITED_CLUBS | Section and record type from `META_ACCOUNT` | **Approved as proposed.** | ESSBASE staging (record type); seeder (M4) |
| Q-06 | BEAUMIER | Section map | **Approved as proposed.** | seeder (M4) |
| Q-07 | all | Category and scenario | **BEAUMIER `BP` -> BUDGET; `Prior Year` -> ACTUAL.** Each scenario kept verbatim. Others as proposed. | XFRM (M5) |
| Q-04 | HERSHA, BEAUMIER | Sign conventions | **Default:** `VALUE` unchanged; consumers use `SOURCE_AMOUNT`, stated in `reconciliation.md`. | M6 |
| Q-08 to Q-12 | - | Non-blocking | **Defaults** as listed below. | as listed |

## As proposed at M1 (kept for the record)

### Formerly blocking

| # | Lane | Question | Proposal |
|---|---|---|---|
| Q-01 | INVITED_CLUBS | **Subtotals.** (a) `REPORT_LEVEL = 'EBITDA_SUMMARY'`: 28,043 rows of one account, `Adjusted Cash EBITDA`, at `Total Operating Departments / Total Subaccount / Total Location`. (b) `DAY_OF_MONTH = 'TotalDOMEnter'`: 112,934 groups; of the 108,850 with daily rows, 82,758 (76%) equal the sum of Day01-31. | (a) `IS_SUBTOTAL = TRUE`, structure only (a computed measure stated by the source). (b) **Borderline**: flag `TRUE` (it reads as a month total by name) or `FALSE` (it fails to tie in 24% of groups)? Your call. |
| Q-02 | HERSHA | **`GL_STAT`'s values sit in `ACTUAL_AMOUNT`**. The 5 `ST` accounts are rooms sold, covers and hours; `ACTUAL_STAT` is 0 on every row. | `RECORD_TYPE = STATISTIC` by table and `ST` prefix; value to `STAT_VALUE`, `SOURCE_AMOUNT` null (the HHG dept 999 precedent). Rule recorded in `RECORD_TYPE_SOURCE`. |
| Q-03 | HERSHA | **Section.** The digit does not follow the §5 table below 5: 610000 Operating Expenses and 630000 Management Fees are digit 6, and 700000/714000 are non-operating. | The 25-account map in `sources.md` (hierarchy table): 60xxxx Payroll; 610000 and 630000 Operating Expenses; 7xxxxx Below the Line; 999999 and `ST*` Statistic with `H2` = the code. |
| Q-05 | INVITED_CLUBS | **Section and record type from `META_ACCOUNT`.** `ACCOUNT_TYPE` gives the statement; `DATA_TYPE` currency/non-currency gives the record type. Open: (a) `expense` named members with no A-digit (114 currency), which have no Level 1; (b) `saved assumption` (14 currency, 114 non-currency; 1.21M rows); (c) the 3 `[Total Base Dues].[...]` accounts not in meta (24,647 rows); (d) A-digit 5 accounts typed `revenue` (36). | `ACCOUNT_TYPE` wins over the digit (stated). (a) Unclassified. (b) Non-currency -> Statistic (by `DATA_TYPE`); currency -> Unclassified. (c) AMOUNT, Unclassified. (d) Revenue, per the stated type. |
| Q-06 | BEAUMIER | **Section map** from `PL_SECTION` / `PL_LINE` / `EBITDA_GROUP`. | As in `sources.md`. `Non-Operating Income & Expenses` and every `NOI` item (Cluster Services, Exceptional, FF&E, Owners / Holdings) -> Below the Line; the rest of `Other Expenses` -> Operating Expenses. |
| Q-07 | all | **Category and scenario.** | HERSHA: measure column (actual Jan-Feb, forecast Mar-Dec). INVITED_CLUBS: measure column; scenario = `VERSION_NAME` (+ `FORECAST_VERSION` `Fcst6_6` on forecast). BEAUMIER: `BP` -> BUDGET; `Forecast`, `Last Fcst`, `Downgraded Fcst` -> FORECAST; `Budget` -> BUDGET; **`Prior Year` -> ACTUAL**. Unmapped values route to UNKNOWN. |

### Non-blocking (defaults taken)

| # | Lane | Question | Default |
|---|---|---|---|
| Q-04 | HERSHA, BEAUMIER | **Sign conventions.** HERSHA books revenue negative; BEAUMIER books expense negative. `VALUE = SOURCE_AMOUNT x VALUE_SIGN` will therefore not net for either: HERSHA revenue turns negative, and BEAUMIER expense turns positive (the build 02 Q-22 pattern). | `VALUE` signing unchanged. Consumers use `SOURCE_AMOUNT`, stated in `reconciliation.md`. |
| Q-08 | BEAUMIER | **Currency.** CANCELLATIONS states CHF and EUR per hotel; the P&L tables state none. | Carried as is; no conversion. |
| Q-09 | INVITED_CLUBS | **`Proforma Adj` and `Operations Adj`** look like adjustment layers on `Load` and `Input` (3,428 and 1,376 detail rows). | Kept, distinguished by scenario. |
| Q-10 | INVITED_CLUBS | **Key grain.** `LOCATION` and `SUBACCOUNT` are carried but not in the key. The key is entity x department x account (225,833 combinations). | As stated. |
| Q-11 | INVITED_CLUBS | **Daily and monthly overlap.** 6 accounts appear both as `Day00` and as daily rows; summing both may double count. | Kept; reported at M3. |
| Q-12 | process | **Freeze window**: 2026-10-21 11:43 to 2026-10-23 11:43 PDT. | See M1.md: the build fits if each stop is answered within a few hours. |

## New at M4-M6 (Q-13 answered after stop 4; Q-14 to Q-16 left for the master)

| # | Lane | Question | State |
|---|---|---|---|
| Q-13 | INVITED_CLUBS | **All 460 A6 expense accounts seed Payroll** under the approved digit rule (Q-05): the lane has no A7 or A8 expense account. 351 carry no labour word, and many are `COGS:` lines (A60001 onward); `A63009 Federal Income Tax` is among them. Does the A6 range need a finer rule (the 4-digit prefix, or META `PARENT`), or a bulk correction in the master? | As seeded; listed in `classification-coverage.md`. **Answered after stop 4:** the A6 range is not Payroll; it seeds H1 `Expense`, H2 `UNCLASSIFIED` (section, balance, sign null). Applied and rerun; see `M6-q13-rerun.md`. |
| Q-14 | INVITED_CLUBS | **7,432 revenue keys run negative** (-4,203,724,393.61, sign anomaly test). Stated contra lines account for some; the population is large. | Reported. **Owner, at build 03 approval:** open for the master; no build change. |
| Q-15 | BEAUMIER | **`Owners Expenses` and `Holdings`** carry both `EBITDA_GROUP` EBITDA and NOI rows for some hotels. They are seeded Below the Line where any row of the key is NOI (Q-06's "every NOI item"). | As seeded. **Owner, at build 03 approval:** open for the master; no build change. |
| Q-16 | INVITED_CLUBS | **`A40250-52 Payroll: Service Charge Distribution`** is typed revenue in META. | Revenue, as stated. **Owner, at build 03 approval:** open for the master; no build change. |
