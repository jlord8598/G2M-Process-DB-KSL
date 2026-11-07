# Open questions - build 15

## Stop 1

**Q-01. Scope of the five tables new since their lanes were built.** None is read by a deployed staging model or named in any earlier build record (see `docs/sources.md`). Proposal:
- CLN_BEAUMIER_HIERARCHY: in scope, staged as a BEAUMIER dictionary (a P&L line hierarchy; likely evidence for item 1's sign rule).
- CLN_HERITAGE_GOLF_BUDGET_BY_CLUB, CLN_HERITAGE_GOLF_BUDGET_MEMBERSHIP: in scope as HHG budget facts, if you want HHG budget in this build; this widens the HHG rebuild beyond the validation fixes. Otherwise out of scope, logged for a later build.
- CLN_JW_VENICE_DAILY_OTB, CLN_JW_VENICE_SEGMENT_PICK_UP: in scope as JW_VENICE pacing (PACING stream, D-24), or out of scope for a later build.
- CLN_JW_VENICE_CAPEX stays out of scope (N-9).

**Q-02. Confirm the other 34 assignments** in `docs/sources.md` (every table each lane's deployed staging reads today).

**Answered (owner, stop 1):** Q-01: BEAUMIER_HIERARCHY in scope (dictionary, sign-rule evidence); HHG BUDGET_BY_CLUB and BUDGET_MEMBERSHIP in scope under the existing HHG chart rules (report at stop 2 if new mapping decisions are needed, and propose deferring); JW_VENICE DAILY_OTB and SEGMENT_PICK_UP deferred (N-29). Q-02: yes, all 34; CAPEX out. Also: identify the 3 extra BEAUMIER master keys at M1.

## Stop 2

**Q-03. Sign rule per source table (new decision D-50).** Stage `SOURCE_SIGN_CONVENTION` (DEBIT / PROFIT / PRESENTED) with `SOURCE_SIGN_CONVENTION_SOURCE`, apply in transformation: DEBIT VALUE = -SOURCE_AMOUNT (HERSHA GL_ACTUAL, TB_ACTUAL); PROFIT VALUE = SOURCE_AMOUNT (BEAUMIER BP, BUDGET; HHG FORECAST_ANAPLAN); PRESENTED VALUE = SOURCE_AMOUNT x VALUE_SIGN (all other tables, including HHG BUDGET_BY_CLUB). VALUE stays null where VALUE_SIGN is null. SOURCE_AMOUNT unchanged. No classification row changes (sign is per table, not per key), so no master update from this.

**Q-04. Prior-year rule.** Measured: in this build's lanes, prior-year rows never overlap a genuine ACTUAL except JW_VENICE 2025-08. Proposal: prior-year fills where ACTUAL is missing (BEAUMIER 2025, HHG 2025-09..12; already CATEGORY ACTUAL, scenario kept verbatim; no row moves). JW_VENICE 2025-08: keep PL_DEPT LAST YEAR (account detail) as the actual under the existing D-48 rule, since its revenue equals FCAST_BY_PERIOD's actual TOTAL SALES exactly; the alternative (FCAST actual beats LAST YEAR) loses the account detail. GOP gap 239,557.35 investigated at M4.

**Q-05. NEWBURY 870215 FF&E Reserve.** Proposal: re-seed key `9000 | 9000 | 9000-870215-0000-000000-0000 | AMOUNT` from Depreciation & Amortization to H1 Allocations & Reserves / H2 UNCLASSIFIED (reserve funding, not depreciation; D-44 re-seed, 1 key; VALUE null, so it leaves every total), and log the 2025-03 -208,849,849.38 to the source owner. NEWBURY D&A 2025-03 becomes 923,535.04 and 2025-11 becomes 0. The row stays, as booked.

**Q-06. BEAUMIER CURRENCY_CODE per hotel** via LOCATION_MAP -> CANCELLATIONS: 9 hotels EUR, HGB and HSB CHF, BMR and CPH UNCONFIRMED (as you said). Confirm.

**Q-07. HHG BUDGET_MEMBERSHIP blank-account rows.** 1,656 "Ending Member Count" rows have no ACCOUNT_CODE. Either declare SOURCE_ITEM_ID = MEMBER_LINE_KEY for this table (new key decision), or carry them on '~BLANK~' and let them route Unclassified, or defer the table (your stop-1 rule). Proposal: defer BUDGET_MEMBERSHIP (statistics, not the missing budget) and build BUDGET_BY_CLUB.

**Q-08. Overlapping extracts (new D-48 rules).** HHG FORECAST_ANAPLAN holds KFCST FINAL twice for 2026 (files 2026-10-09, 19,080 rows; 2026-11-05, 18,360). BEAUMIER BP holds Forecast and Last Fcst from 2026-09-29 and 2026-10-13 partial files besides the full 2026-10-26 file. Proposal: per table and scenario, the latest FILE_DATE beats earlier ones; losers to UNKNOWN as DUPLICATE_DETAIL. Also: BEAUMIER "Other F&B" runs negative on 203 / 209 rows: list as a D-13 contra line, or leave for the business review?

**Answered (owner, stop 2):** Q-03 D-50 approved (CLAUDE.md text at stop 4). Q-04 no build change; JW 2025-08 under existing D-48, resolve the 19,705.39 GOP gap at M4. Q-05 re-seed 870215 to Allocations & Reserves, logged (N-30). Q-06 confirmed. Q-07 BUDGET_MEMBERSHIP deferred (N-31). Q-08 latest file wins per entity / account / month / scenario, older files fill cells no later file has; report the count. Other F&B: no contra rule; business review.

**Refined (owner, stop 3):** Q-08: the latest file wins per entity + month + scenario; an older file counts only for entity-months the latest file lacks entirely. Measured: HHG Anaplan keeps 24 club-months (Independence Country Club and Old Natchez Country Club, 2026-01..12, 720 rows) from the 2026-10-09 file; BEAUMIER BP keeps 0 (346 rows lose).

## Stop 4 (build 15)

- For approval: D-50, its section 5 paragraph, the check 2(h) rewording, and the build 15 D-48 rules (`claude-md-diff.md`).
- For promotion: expected master merge 219 inserts (HHG), 1 update (NEWBURY 870215), 0 attribute-only, 0 reviewed.
- **Q-09 (new). JW_VENICE FCAST classification (N-32).** In FCAST_BY_PERIOD / FCAST_ACT_FORECAST, "EBITDA EXCLUDING OWNER EXPENSES" and "GOP MARGIN" are classified Operating Expenses, REPLACEMENT RESERVE is in OpEx, and departmental expenses are absent, so the FCAST months do not tie to EBITDA or GOP (ACTUAL 12.0M, FORECAST 4.5M in total). Proposal for a later JW_VENICE build: re-seed those lines (subtotal / ratio -> SOURCE_ROLLUP or Statistic; reserve -> Below the Line) and decide how department profit lines enter. Not done here (outside the validation fixes; needs your mapping decision).

**Answered (owner, stop 4):** approved, including D-50, its section 5 text, the 2(h) rewording and the build 15 D-48 rules. Q-09: before promotion, apply the existing rules to the JW_VENICE FCAST lines (subtotals -> SOURCE_ROLLUP + IS_SUBTOTAL under the Q-16 tie test; ratios -> Statistic); departmental expenses inside department profit are not in landed data. Re-run JW_VENICE M4-M6 only. Anaplan clubs logged (N-34).

**Q-09 done (M6 addendum).** 2 keys re-seeded (EBITDA EXCLUDING OWNER EXPENSES, GOP MARGIN); merge now 219 inserts, 3 updates. Raised: N-35 (FCAST_BY_PERIOD non-op spelling; reserve and credit card outside the source's EBITDA).
