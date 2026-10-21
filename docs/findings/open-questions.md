# Open questions - build 02 (HHG, NEWBURY)

Numbered within this build. Every figure is from a query run on 2026-10-20
against `CLN.BOX_INVESTMENT_DATA`; detail is in `docs/sources.md`.

## Answered at stop 1

| # | Question | Owner's answer (stop 1) |
|---|---|---|
| - | Lane names and scope | `HHG` = Heritage Golf, the six `CLN_HERITAGE_GOLF_*` tables; `NEWBURY` = the nine `CLN_NEWBURY_BOSTON_*` tables; nothing out of scope; neither name is in the master. |
| - | Freeze window | Starts 2026-10-20 14:34 PDT. End 2026-10-22 14:34 PDT until the owner confirms an extension. |

## Answered at stop 2 (M1 approved)

| # | Lane | Question | Owner's answer (stop 2) | Applied in |
|---|---|---|---|---|
| Q-01 | HHG | Department 999 statistics or money? | **`RECORD_TYPE = 'STATISTIC'`** where department = 999. Rule recorded in `RECORD_TYPE_SOURCE` (dept 999, section 9, all whole numbers; owner Q-01). The master's classifier can override it. | `SPROC_STG_HHG_TR12_DATA` |
| Q-02 | HHG | No account or department descriptions | Default: `ACCOUNT_DESC` and `DEPARTMENT_NAME` null on TR12 rows. | as built |
| Q-03 | HHG | Site key differs by table | **Each table's own value as written; no name matching.** Report the three unmapped identifier sets as a finding for the business (below). | HHG staging models |
| Q-04 | HHG | Anaplan line items to the hierarchy | Proposed at stop 2, **approved at stop 3** (below). | HHG seeder branch |
| Q-05 | HHG | `+All Regions` subtotal | Default: `IS_SUBTOTAL = TRUE` where `LOCATION = '+All Regions'`. | `SPROC_STG_HHG_FORECAST_ANAPLAN` |
| Q-06 | HHG | TR12 `ACT` / `PY ACT` | Default: both `ACTUAL`, scenario verbatim. | `SPROC_XFRM_HHG` |
| Q-07 | HHG | `ROUNDS_DETAIL` role | **A statistics fact, `CATEGORY = ACTUAL` on every row, the zero future-dated rows included.** Report them (M3.md). | `SPROC_STG_HHG_ROUNDS_DETAIL`; `SPROC_XFRM_HHG` |
| Q-08 | HHG | Two source lines for `9102-950-49992` | Default: both kept. | as built |
| Q-09 | HHG | `REFERENCES.WORKSHEET_CODE` shifted | Default: report only; carried verbatim. | as built |
| Q-10 | NEWBURY | Trial balance wide by measure | Default: unpivot 3 columns, nulls kept, `count x 3` identity. | `SPROC_STG_NEWBURY_TRIAL_BALANCE` |
| Q-11 | NEWBURY | Site key differs by table | **Each table's own value as written** (`KANRZZ` and `3338`). Same rule as Q-03. | NEWBURY staging models |
| Q-12 | NEWBURY | `OPERATING_STATS_*` roles | **FCST is pacing.** BGT and PYACT are facts (one row: rooms and room revenue, D-29); EVENTSANDOOO is a dictionary. **PYACT keeps its scenario verbatim.** | NEWBURY staging models |
| Q-13 | NEWBURY | `OPERATING_STATS_SHOPS` | **Its own pacing stream, in its own shape.** See Q-20. | `SPROC_STG_NEWBURY_OPERATING_STATS_SHOPS`; `SPROC_XFRM_NEWBURY` |
| Q-14 | NEWBURY | D&A and income tax in section 8; the -206.4M line | Default: digit rule only (`Other Income / (Expense)`); the -206,407,739.14 line reported, not repaired. | NEWBURY seeder branch |
| Q-15 | NEWBURY | Forecast versions overlap | Default: scenario verbatim; consumers filter. | as built |
| Q-16 | NEWBURY | OTB tables share 16,908 identical rows | Default: both kept, tagged by `SOURCE_TABLE`. | as built |
| Q-17 | both | Freeze window | Default: treat 2026-10-22 14:34 PDT as the end. Confirmed again at stop 3. | D-43 checks |
| Q-18 | process | `AGENTS.md` approvals line | **Corrected by the owner** (line 125 now names `CLN.<SOURCE>`). Re-read at M2. | closed |

## Answered at stop 3 (M3 approved)

| # | Question | Owner's answer (stop 3) | Applied in |
|---|---|---|---|
| Q-04 | Anaplan line items to `H1`/`H2` | **Approved as proposed** (table below). Fees and dues are Revenue. `Other F&B Income` is Revenue; `Other Income` is Below the Line. | HHG branch of `SPROC_XREF_ACCOUNT_CLASSIFICATION` |
| Q-17 | Freeze window | Still ends 2026-10-22 14:34 PDT unless the owner says otherwise; `last_altered` checked before each milestone's checks. | D-43 checks |
| - | `snow sql -f` deploy path | Show that it runs on the same connection and role as this session before any DDL; stop if it does not, and record it in M4.md if it does. **It matched** (M4.md). | M4.md |

## Open - new at M4 (non-blocking; default applied)

| # | Lane | Question | Default applied until answered |
|---|---|---|---|
| Q-19 | NEWBURY | `OPERATING_STATS_BGT` and `_PYACT` rows carry no account, stat account or line item (`ACCOUNT_KEY` `~BLANK~`). Should their `REVENUE` (room revenue) seed an income-statement class? | **`Unclassified`**: nothing in the source states an account, and classing room revenue as `Revenue` would double-count against the trial balance's 41xxxx room-revenue accounts in the income statement. The rows route to `UNKNOWN` as `UNCLASSIFIED_ACCOUNT`, with category resolved. |
| Q-20 | NEWBURY | Owner Q-13 says SHOPS is "its own pacing stream, in its own shape". CLAUDE.md fixes five streams per lane, so a sixth `XFRM_` table is not allowed. | SHOPS rows go into `XFRM_NEWBURY_PACING` alongside FCST and the two OTB tables. The table carries the union of their columns, so each source keeps its own columns (null where another source's apply), and `SOURCE_TABLE` separates them. If you want a separate table, say so and the lane gets a named exception. |
| Q-21 | process | `AGENTS.md` "No second path" says not to shell out to another client. Deploys use `snow sql -f` so the deployed text is the file text, and the identity check at M4 shows it is the same connection, role, user and account. | Kept, per the owner's stop-3 instruction. Recorded here because it conflicts with `AGENTS.md` as written; the owner may want that file updated. |

### Finding for the business (Q-03): HHG club identifiers that do not map

The owner ruled no name matching. These identifier sets carry no exact link to
another table's club identifier, measured at M1:

| Table | Identifier | Values with no exact match | Rows |
|---|---|---|---|
| `TR12_DATA` | GL entity (account segment 1) | 9 entities not in `REFERENCES.CLUB_NUMBER`: 9050, 9051, 9052, 9053, 9054, 9055, 9056, 9099, 9102 | 17,124 |
| `REFERENCES` | `CLUB_CODE` | 5 `CLUB_LIST` clubs absent: `PLS` Palisades, `OCA` Ocala, `PLN` Palencia, `PLA` Plantation, `SOU` Southern Hills | - |
| `FORECAST_ANAPLAN` | `LOCATION` (a name) | 14 of 53 do not equal a `CLUB_LIST.CLUB_NAME`: `+All Regions` (the subtotal), `Cape Fear National Golf Club`, `Country Club of Ocala`, `Independence Country Club`, `Magnolia Greens Golf Course`, `Old Natchez Country Club`, `Palencia Golf Club`, `Plantation Golf and Country Club`, `Savannah Quarters Country Club`, `Southern Hills Plantation`, `Stanton Ridge Golf & County Club`, `The Club at Cheval`, `The Club at Grandezza`, `The Oasis Golf Club` | 5,040 |

`ROUNDS_DETAIL.CLUB_CODE` maps to `CLUB_LIST` on all 50 clubs. A consumer
joining across these tables needs a cross-reference the source does not supply.

### Q-04: Anaplan line items to `H1` / `H2` (approved at stop 3)

Source: `CLN_HERITAGE_GOLF_FORECAST_ANAPLAN.LINE_ITEM`, 30 values, read as the
section the source states in words. `H3`, `H4`, `H5` = `UNCLASSIFIED`.
`P_L_SECTION` and `NORMAL_BALANCE` follow from `H2` (D-12).

| `LINE_ITEM` | Stated by | `H1` | `H2` |
|---|---|---|---|
| Ala Carte Revenue | "Revenue" | Revenue | Revenue |
| Banquet F&B Revenue | "Revenue" | Revenue | Revenue |
| Lodging/Pool Revenue | "Revenue" | Revenue | Revenue |
| Other Golf Revenue | "Revenue" | Revenue | Revenue |
| Tennis/Fitness/Spa Revenue | "Revenue" | Revenue | Revenue |
| Merchandise Sales | "Sales" | Revenue | Revenue |
| Cart Fees | "Fees" (charged to members and guests) | Revenue | Revenue |
| Green Fees | "Fees" | Revenue | Revenue |
| Initiation Fees | "Fees" | Revenue | Revenue |
| Membership Dues | "Dues" | Revenue | Revenue |
| Timeshare Dues | "Dues" | Revenue | Revenue |
| Other F&B Income | "Income", inside the F&B operation | Revenue | Revenue |
| Food & Beverage Cost of Sales | "Cost of Sales" | Expense | Cost of Goods Sold |
| Merchandise Cost of Sales | "Cost of Sales" | Expense | Cost of Goods Sold |
| Administrative Labor | "Labor" | Expense | Payroll |
| Course Maintenance Labor | "Labor" | Expense | Payroll |
| Food & Beverage Labor | "Labor" | Expense | Payroll |
| Golf Operations Labor | "Labor" | Expense | Payroll |
| Lodging/Pool Labor | "Labor" | Expense | Payroll |
| Membership & Marketing Labor | "Labor" | Expense | Payroll |
| Tennis/Fitness/Spa Labor | "Labor" | Expense | Payroll |
| Administrative Expense | "Expense" | Expense | Operating Expenses |
| Course Maintenance Expense | "Expense" | Expense | Operating Expenses |
| Fixed G&A Expense | "Expense" | Expense | Operating Expenses |
| Food & Beverage Expense | "Expense" | Expense | Operating Expenses |
| Golf Operations Expense | "Expense" | Expense | Operating Expenses |
| Lodging/Pool Expense | "Expense" | Expense | Operating Expenses |
| Membership & Marketing Expense | "Expense" | Expense | Operating Expenses |
| Tennis/Fitness/Spa Expense | "Expense" | Expense | Operating Expenses |
| Other Income | "Income", not tied to an operation | Below the Line | Other Income / (Expense) |

Revenue 12, Cost of Goods Sold 2, Payroll 7, Operating Expenses 8, Below the
Line 1: 30 in all. Approved at stop 3 with both calls as proposed: fees and dues
are Revenue; `Other F&B Income` is Revenue and `Other Income` is Below the Line.

## Open - new at M6 (non-blocking; reported, not repaired)

| # | Lane | Question | State |
|---|---|---|---|
| Q-22 | HHG | Anaplan books expenses negative; the build signs by `NORMAL_BALANCE` (Debit -1), so `VALUE` turns them positive. HHG forecast `VALUE` totals 1,428,944,200.12 against `SOURCE_AMOUNT` 325,117,641.88 (`classification-coverage.md`). TR12 books expense positive and signs correctly. A per-lane sign rule for Anaplan, or a correction in the master? | `SOURCE_AMOUNT` as booked; `VALUE` as the rule gives it. Owner decision. |
| Q-23 | NEWBURY | `870215-Depr Expense-FF&E Reserve` carries -206,407,739.14 of actuals over 12 rows, a credit on a depreciation line (sign anomaly test). Reversal, or source error? | Reported (also Q-14). |

## Answered at stop 4 (build 02 approved)

| # | Question | Owner's answer (stop 4) |
|---|---|---|
| Q-19 | BGT/PYACT room revenue | **Stays unclassified**, to avoid double-counting the trial balance. Rows remain in `UNKNOWN` as `UNCLASSIFIED_ACCOUNT`. |
| Q-20 | SHOPS as its own stream | **Stays in `XFRM_NEWBURY_PACING`**; no exception. |
| Q-21 | `snow sql` deploy path | **Accepted** as the deploy path when it is shown to use the same connection and role as the session. The owner will update `AGENTS.md` and `CLAUDE.md` section 11. |
| Q-22 | HHG Anaplan `VALUE` signing | **Unchanged for this build.** Consumers use `SOURCE_AMOUNT` for the HHG Anaplan forecast; stated in `reconciliation.md`. |
| Q-23 | NEWBURY `870215` credit | **Open with the business**; no build change. |
