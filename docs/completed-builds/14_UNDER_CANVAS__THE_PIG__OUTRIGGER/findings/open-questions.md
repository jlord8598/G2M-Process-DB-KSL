# Open questions - build 14

## Stop 1

| # | Lane | Question | Evidence | Proposal |
|---|---|---|---|---|
| Q-01 | all | Freeze end: the kickoff said `<END TIME>`. What is it? | - | Give a time; until then D-43 reports minutes since baseline. |
| Q-02 | UNDER_CANVAS | REPORT_CELLS is not visible to this role (possible missing grant). Grant it, or confirm the 5 CLN tabs are the whole actuals file? | M1 section 1 | Confirm or grant; the 5 tabs tie through GOP. |
| Q-03 | UNDER_CANVAS, THE_PIG | CURRENCY_CODE: neither source states one. USD for UNDER_CANVAS, GBP for THE_PIG? | M1 section 3 | USD / GBP if you confirm; else UNCONFIRMED. OUTRIGGER USD (stated). |
| Q-04 | UNDER_CANVAS | CONSOLIDATED_PL (102 YTD rows): its total lines are SOURCE_ROLLUP; its department lines restate the detail (D-48: detail beats CONSOLIDATED_PL, DUPLICATE_DETAIL); corporate OH (lines 111-127), D&A (139), interest / other (141-147) exist only here, YTD. Route those to UNKNOWN (UNCLASSIFIED_ACCOUNT) or classify them as YTD rows? | M1 sections 5-6 | D-48 rule as stated; corporate / below-GOP lines to UNKNOWN until a monthly source exists (a YTD row in a monthly income statement double-counts against months). |
| Q-05 | UNDER_CANVAS | CONSOLIDATED_PL lines 139-153 look mis-parsed (Total Other Expenses does not tie; NET INCOME > EBITDA; section labels shifted). Source owner? | M1 section 6 | Log for the source owner; carry as booked. |
| Q-06 | THE_PIG, OUTRIGGER | Build both as pacing-only lanes (staging + PACING, no seeder keys, no semantic rows)? | M1 sections 4, 8 | Yes; OUTRIGGER V1 / V2 kept side by side with REPORT_FILTERS. |
| Q-07 | UNDER_CANVAS | Approve the D-46 block mapping (M1 section 6), payroll = 72xx, 77xx, 6300, 6512, 7920? | ties to source Labor exactly | Approve. |
| Q-08 | UNDER_CANVAS | Stop-4 tie-out: detail Revenue - COGS - Payroll - OpEx = GOP 27,575,053.88 (YTD, and per department). | M1 section 7 | Approve. |

## Owner answers, stop 1

| # | Answer |
|---|---|
| Q-01 | Freeze ends 2026-11-07 06:00 America/Los_Angeles; past it, continue only while D-43 shows no change. |
| Q-02 | No grant: the five CLN tabs reconcile through GOP; REPORT_CELLS is raw and not read by the build. |
| Q-03 | CURRENCY_CODE: UNDER_CANVAS USD, THE_PIG GBP (owner-confirmed); OUTRIGGER USD (stated). |
| Q-04 | D-48: the P&L detail beats CONSOLIDATED_PL. Every CONSOLIDATED_PL row goes to UNKNOWN as DUPLICATE_DETAIL (single YTD snapshot). Below-GOP lines (corporate OH, D&A, interest, tax) have no monthly detail: logged as not in landed data (N-25). |
| Q-05 | Lines 139-153 mis-parse logged for the source owner (N-26); not blocking (already UNKNOWN under Q-04). |
| Q-06 | Yes: THE_PIG and OUTRIGGER pacing-only. OUTRIGGER V1 / V2 carried as is; name-to-code map logged (N-27). |
| Q-07 | Yes: mapping as proposed. |
| Q-08 | Yes: tie to GOP, YTD and per department. |

**For stop 4:** the D-48 rule (UNDER_CANVAS: CONSOLIDATED_PL loses to the P&L detail, every row) is to be listed in CLAUDE.md D-48, as earlier rules were.

## Stop 4 (build 14)

- Stop 3 answers applied: THE_PIG / OUTRIGGER XREF MAINs refresh the views only, no seeder call; the 126 dictionary-gap keys are classified by block (4100 Revenue, 7650-00x Operating Expenses), in the GOP tie-out, and listed as not in landed data (descriptions present from the fact text).
- For approval: the D-48 UNDER_CANVAS rule text (`claude-md-diff.md`).
- For promotion: expected master merge 2,725 inserts (UNDER_CANVAS), 0 updates, 0 for THE_PIG / OUTRIGGER.
- No new question.

