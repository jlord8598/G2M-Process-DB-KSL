# Open questions - build 19

## Stop 1
- **Q-01 (HHG item 1).** D&A is already Below the Line / D&A / Operating in every lane (D-12). Confirm no change, or change the standard hierarchy for all lanes?
- **Q-02 (item 2).** Fill ACCOUNT_DESC for 9102-950 keys from the chart of accounts by natural account where it states exactly one description (66100, 66900; 77850 stays null, not in landed data)?
- **Q-03 (item 5).** Approve the D-48 rule: FIN_BUDGET_MONTHLY beats OPS_MEMBERSHIP_MONTHLY per club + month + account (UNKNOWN +7,068; OPERATING_METRICS +2,868). The alternative is that membership wins. Also approve SOURCE_ITEM_ID = MEMBER_LINE_KEY | CLUB_SEGMENT for the 1,656 "Ending Member Count" rows, and H2 for membership (the budget member accounts are STAT_9 today).
- **Q-04 (item 4).** Approve the acquisition-date precedence text as D-52 (or as a line in D-48).
- **Q-05 (item 6).** Totals do not tie line by line (Cadillac 1.6%, Parrot Key under 0.1%; Rooms ties within 0.1%). Approve the cross-lane rule (Davidson wins 149 / 230 for 2026, all categories; Hersha UNKNOWN +20,478) and the CLAUDE.md sentence.
- **Q-06 (item 8).** Stage Hersha budget from FIN_PL_MONTHLY's BUDGET columns (x3 unpivot, no WHERE; DEBIT, D-50)?
- **Q-07 (item 8).** Approve the D-48 rule: PREFERRED_ROW beats non-preferred within OPS_STATS_MONTHLY (+3,596 UNKNOWN).
- **Q-08 (item 8).** CLN_HERSHA_FIN_BUDGET_MONTHLY is an exact copy of FIN_PL_MONTHLY's budget. Leave it unstaged, or stage it under a D-48 rule?
- **Q-09 (item 9).** FIN_PL_OWNER and OPS_STATS_MONTHLY (same workbook as PL_DEPARTMENT): leave out of this build?
- **Q-10 (items 10, 11).** CAPEX option (a) with ACCOUNT_KEY = VENDOR_NAME? JW pacing blocks as laid out, with segment SOURCE_LINE_KEY = SNAPSHOT_DATE | REPORT_BLOCK | MARKET_SEGMENT | STAY_MONTH?
- **Q-11 (item 14).** Stage CLN_DAVIDSON_FIN_BUDGET_MONTHLY (2026 + 2027, 245,676 rows) as STG_DAVIDSON_HOTEL_BUDGET, category BUDGET, PRESENTED? Group pace (CLN_DAVIDSON_PACE_GROUP_ANNUAL, 2,856) is reported only, not built.
- **Q-13 (item 13).** No fill rule (not in landed data); log N-49 asking for the Davidson statistical chart of accounts (segments 1, 2, 5, 6)?
- **Q-12.** All four lanes restage on today's 03:03 extract. Confirm.

## Owner answers (stop 1, build 19)
- **Q-01:** no change; D&A stays as D-12 places it.
- **Q-02:** approved, only where the chart gives exactly one description. 77850 stays "not in landed data" and is on the source-owner list (N-48). Applied in TR12 (M3).
- **Item 3 (49992):** keep both lines (invariant 1); N-48.
- **Item 4 (D-52):** approved; acquisition date from REF_PROPERTY_STATUS. N-4 stays open; Palisades N-46.
- **Q-03:** approved. The budget accounts beat membership per club, month and account; Ending Member Count stays in operating metrics. The transfer difference (+1 against 3,036) is reported in M6.
- **Q-05:** approved, actual and forecast, applied in Hersha's transformation by site and year, with the drafted CLAUDE.md sentence.
- **Item 7:** N-5 closed.
- **Q-06:** approved; actual, forecast and budget with no WHERE.
- **Q-07:** approved; the preferred row wins.
- **Q-08:** approved; Hersha FIN_BUDGET_MONTHLY unstaged (sources.md).
- **Q-09:** approved; JW FIN_PL_OWNER and OPS_STATS_MONTHLY unstaged (N-50).
- **Q-10:** approved; JW CAPEX Statistic / FIN_CAPEX / CURRENCY / FLOW, keyed by vendor.
- **Item 11:** approved; JW pacing with both SEM blocks; occupancy and ADR not additive; JW included in the coverage check.
- **Q-11:** approved; Davidson budget for 2026 and 2027, line key file + row + period. Group pace not in this build (N-51).
- **Q-12:** accepted; restaged on today's extract.
- **Q-13:** approved; no fill rule (N-49).

## Raised at M6 (for stop 4)
- **Q-14.** The Q-02 rule would also fill one HHG budget account (9108-905, 12 rows) in BUDGET_BY_CLUB. Apply it there too, or leave it (as now)?
- **Q-15.** Hersha's 149 / 230 2026 BUDGET rows stay (the rule covers actual and forecast), and Davidson also has a 2026 budget for RMICAD / RINPKR, so both lanes count a 2026 budget for these two hotels. Extend the cross-lane rule to BUDGET, or keep it as approved?

## Owner answers (stop 4)
- **Q-14:** yes; the rule applies wherever it gives exactly one description (BUDGET_BY_CLUB 9108-905-52100, 12 rows).
- **Q-15:** yes; the cross-lane rule covers actual, forecast and budget; CLAUDE.md updated.

