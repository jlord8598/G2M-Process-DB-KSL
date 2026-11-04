# Open questions - build 12

| # | Lane | Question | Proposal | Blocks |
|---|---|---|---|---|
| Q-01 | both | **Freeze end time:** the brief says `<END TIME>`. | You give it. Until then, no "minutes remaining" can be reported. | every stop |
| Q-02 | JW_VENICE | **D-48:** MONTHLY_PL_DEPT restates FCAST's August ACTUAL exactly (2026-08 18 of 18; 2025-08 18 of 18). Which wins? | MONTHLY_PL_DEPT (MONTH) beats FCAST_ACT_FORECAST / FCAST_BY_PERIOD for ACTUAL at the months it carries; the FCAST rows for those months go to `UNKNOWN` `DUPLICATE_DETAIL`. | M4 |
| Q-03 | JW_VENICE | **YTD rows are cumulative** (August YTD = January-August, exact). How are they kept from adding to MONTH? | Stage all rows with `PERIOD_TYPE`; D-48 rule "MONTH beats YTD"; YTD rows go to `UNKNOWN` `DUPLICATE_DETAIL`. | M3 |
| Q-04 | JW_VENICE | **`H1` / `H2` by account block** (M1 section 2a). Is 7xxxxx (investment factors: fees, reserve 701110, insurance, owner items) Below the Line / OI/E? | As in M1 section 2a. | M4 |
| Q-05 | JW_VENICE | **CB duplicates TOT F&B** (its accounts sit inside TOT F&B). **TOT_HTL holds 12 Minor Operated account cells** (86,948.61) that no sheet carries. | CB: `DUPLICATE_DETAIL` (D-48, TOT F&B beats CB). TOT_HTL: `SOURCE_ROLLUP`, **except those 12 cells, kept as detail** (lone figures) so departmental EBITDA rebuilds the owner's 1,303,456.44. | M3 |
| Q-06 | all | **CURRENCY_CODE:** add to every money-bearing semantic table? The source states BEAUMIER as EUR / CHF and INVITED_CLUBS as USD, so "USD for all other lanes" is not right for BEAUMIER. | Add the column; JW_VENICE EUR; INVITED_CLUBS USD (stated); BEAUMIER from its CURRENCY column where present, else ask; others confirmed by you. Needs a CLAUDE.md section 4 change (semantic shape) and touches every lane's semantic block. | M6 |
| Q-07 | ATLANTIC_AVIATION | **Scaling:** dollars are x1000, but Gallons are evidently in thousands too (5.11 per gallon as stored). Scale Gallons? Landings and Trips? | Scale in transformation from a staged `SOURCE_UNIT_SCALE`; dollars and Gallons x1000; MPG and ratios x1; Landings / Trips after your confirmation. Reconcile: CLN x scale = XFRM = SEM. | M5 |
| Q-08 | JW_VENICE | **CAPEX** is in the freeze baseline as a lane table. Still out of scope (build 11 Q-05)? | Yes, out of scope. | M3 |

## Owner answers, stop 1

| # | Answer | Done / measured |
|---|---|---|
| Q-01 | Freeze ends 2026-11-05 06:00 America/Los_Angeles. | `scripts/d43_check.sql` reports minutes left |
| Q-02 | D-48: MONTHLY_PL_DEPT beats FCAST for ACTUAL in 2025-08 and 2026-08; every other FCAST month stays. | For M5 |
| Q-03 | D-48: MONTH beats YTD; YTD rows go to UNKNOWN as DUPLICATE_DETAIL. | For M5 |
| Q-04 | Map 7xxxxx by the owner P&L: management fees, fixed expenses, insurance and property taxes are above EBITDA (Operating Expenses); the replacement reserve and anything below EBITDA is OI/E. Test: Revenue - COGS - Payroll - OpEx for 2026-08 = 1,303,456.44; list any line that cannot be placed. | **Placement passes:** every 7xxxxx account in OpEx except 701110 (OI/E); 0 unplaced. On TOT_HTL's account rows: 2026-08 = **1,303,456.44 exact**; 2025-08 = 1,518,519.50 = FCAST's 2025 figure. See Q-09 for the detail set. |
| Q-05 | TOT_HTL rollup except the 12 Minor Operated cells (classified); CB loses to TOT F&B as DUPLICATE_DETAIL (D-48). | **Short by 2,848.38 in 2026-08** (1,300,608.06): Q-09 |
| Q-06 | Add CURRENCY_CODE to every money semantic table, per lane from source evidence: JW_VENICE EUR; BEAUMIER by the currency each row states; list lanes with no stated currency. Prove earlier lanes with the excluding-changed-columns hash. Show the section 4 diff at stop 4. | See Q-10 |
| Q-07 | Scale x1000 only what the data proves: dollar measures, Gallons and Fuel Margin. MPG, Landings and Trips stay as booked; log Landings and Trips. Design approved. | N-17 |
| Q-08 | CAPEX stays out of scope. | |

**The 7xxxxx placement** (2026-08, from the owner P&L lines; query
`01c83123-030a-840c-0003-4ff21c7b71ae`):

| Owner P&L line | Amount | Accounts | `H2` |
|---|---|---|---|
| BASE MGMT FEE | 133,745.62 | 706001 122,600.16 + 701120 11,145.46 | Operating Expenses |
| NON-OP INC/EXP EXCL. OWNER EXP. (fixed expenses, insurance, property taxes; above EBITDA) | 101,443.12 | 701025, 701727, 720901, 720910, 730108, 740002 | Operating Expenses |
| REPLACEMENT RESERVE (below EBITDA) | 222,909.39 | 701110 | Other Income / (Expense) |
| inside A&G and S&M (their sheets' DEPT NET = the owner lines) | | 76xxxx, 77xxxx, 79xxxx on ADMIN / S&M | Operating Expenses |
| allocation credit inside RSV and OTHERS | -290,819.42 | 759101 | Operating Expenses |

## New at stop 2

| # | Lane | Question | Proposal | Blocks |
|---|---|---|---|---|
| Q-09 | JW_VENICE | **The Q-05 detail set misses part of Minor Operated.** Department sheets (excluding TOT_HTL, CB) + the 12 sheet-less TOT_HTL cells give 1,300,608.06 for 2026-08, 2,848.38 short (2025-08 ties exactly). Minor Operated also posts to accounts other departments use: TOT_HTL exceeds the sheets on 314001 by 7,924.53 (revenue) and on 424019 / 414001 / 490001 by 2,410.87 / 1,996.98 / 668.30 (COGS). 7,924.53 - 5,076.15 = 2,848.38 exactly. With the 12 cells (324019 8,228.18, 350002 6,610.89), Minor Operated revenue is 22,763.60 and dept profit 17,687.45 = FCAST's MINOR OPERATED lines. That share exists only inside TOT_HTL's shared-account figures; no landed row carries it, and creating a residual row would be invention. | **(a)** TOT_HTL's GL-account rows are the detail (they tie: 1,303,456.44 and 1,518,519.50, 0 unplaced). The 15 department sheets are `DUPLICATE_DETAIL` under a D-48 rule (TOT_HTL beats the department sheets), and the named lines on every sheet are `SOURCE_ROLLUP`. Department split is then lost from the classified streams but kept in UNKNOWN. **(b)** Keep Q-05; record Minor Operated's shared-account share (2,848.38 in 2026-08) as not in landed data; the tie-out is short by it. | M3 |
| Q-10 | BEAUMIER (and every lane) | **Currency per lane, from source evidence** (queries `01c83103-030a-7f66-0003-4ff21c7a2dc2`, `01c83126-030a-83f8-0003-4ff21c7b51ae`). **States a currency:** INVITED_CLUBS META_ENTITY.BASE_CURRENCY USD (every entity). BEAUMIER: only the pacing table CANCELLATIONS (no semantic table) states one, per HOTEL_NAME: CHF for GH Belvedere and Hotel & Spa Silberhorn; EUR for the other 9 hotels. BP / BUDGET rows state none, but LOCATION_MAP links HOTEL_CODE to the same HOTEL_NAME, so each BP / BUDGET row reaches a stated currency through two source tables. **The corporate codes BMR and CPH have no stated currency.** **States none:** KSL_SELECT_SERVICE, PEREGRINE_RESORTS, HHG, NEWBURY, HERSHA, DAVIDSON, ALTERRA, ATLANTIC_AVIATION; JW_VENICE (EUR per the owner, not in landed data). | BEAUMIER rows via HOTEL_CODE -> LOCATION_MAP -> CANCELLATIONS currency; you confirm BMR / CPH and every "states none" lane (USD?). | M6 |

## Owner answers, stop 2

| # | Answer |
|---|---|
| Q-09 | (a): TOT_HTL's GL-account rows are the detail. The 15 department sheets lose to TOT_HTL under D-48 and stay in UNKNOWN as DUPLICATE_DETAIL. This replaces the Q-05 CB rule. |
| Q-10 | CURRENCY_CODE: JW_VENICE EUR (the source report header states "Currency Code: EUR"; AUG - PL.xlsm, not landed). INVITED_CLUBS USD (stated). BEAUMIER by hotel through LOCATION_MAP; BMR and CPH 'UNCONFIRMED'. KSL_SELECT_SERVICE, PEREGRINE_RESORTS, HHG, NEWBURY, HERSHA, DAVIDSON, ATLANTIC_AVIATION USD (owner-confirmed). ALTERRA 'UNCONFIRMED' (Canadian entities Tremblant, Blue Mountain, CMH). BMR / CPH and ALTERRA logged as N-18. |

**For M6 (raised early):** BEAUMIER's currency reaches its fact rows only through LOCATION_MAP and CANCELLATIONS, which are staging tables. Semantic reads transformation only (section 3), so the hotel currency must be carried on `XFRM_BEAUMIER_*`. That touches BEAUMIER's transformation procedure, an earlier lane's code. The proposal will be put at M6 before any change.

## Stop 3

| # | Question | Evidence | Proposal |
|---|---|---|---|
| Q-11 | MONTHLY_PL_DEPT repeats each sheet's 98xxxx hours accounts as a second block (under "HOURS (incl. NE Mgrs)"). Which copy is the detail? | Second block = first in 96 / 96 account-cells (actual and budget). 20 staged rows on TOT_HTL MONTH would double the lane's hours; the other 172 already lose to D-48 rules. | D-48: the first block (line_order before "HOURS & HRS POR") wins; the repeat block goes to UNKNOWN as DUPLICATE_DETAIL. |

## Owner answers, stop 3

| # | Answer |
|---|---|
| Q-11 | Yes: the first hours block wins; the repeat block goes to UNKNOWN as DUPLICATE_DETAIL under D-48. |
| BEAUMIER currency | Do not touch BEAUMIER's transformation in this build. CURRENCY_CODE = 'MIXED' at lane level in semantic; logged as N-19 (per-hotel EUR / CHF via LOCATION_MAP in a later BEAUMIER rebuild). |

## Stop 4: what still needs a person

| Item | For | Where |
|---|---|---|
| Approve the CLAUDE.md text (CURRENCY_CODE, unit scale / D-49, JW D-48 rules) | owner | claude-md-diff.md |
| 20 JW sign-anomaly candidates | master review | classification-coverage.md |
| N-17 Landings / Trips units; N-18 BMR / CPH and ALTERRA currency; N-19 BEAUMIER per-hotel currency | source owner / later build | docs/open-items.md |
| Q-01 to Q-11 | answered | above |
