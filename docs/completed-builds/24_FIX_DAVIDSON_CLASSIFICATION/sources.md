# Sources (build 24: FIX_DAVIDSON_CLASSIFICATION)

## Source schema and freeze
- **Source:** `CLN.BOX_INVESTMENT_DATA`. Gary's freeze is confirmed by the owner; the baseline is the current Davidson loads. `scripts/d43_check.sql` checks it.
- **Tables:** all 14 `CLN_DAVIDSON_*` tables, with `last_altered` at M1:

| Table | Lines | last_altered |
|---|---|---|
| CLN_DAVIDSON_FIN_BUDGET_MONTHLY | 245,676 | 2026-11-16 03:04:52.512 |
| CLN_DAVIDSON_FIN_BUDGET_SUMMARY | 239,616 | 2026-11-16 03:04:53.992 |
| CLN_DAVIDSON_FIN_PL_MONTHLY | 158,760 | 2026-11-16 03:04:51.900 |
| CLN_DAVIDSON_FIN_PL_SUMMARY | 242,784 | 2026-11-16 03:04:51.707 |
| CLN_DAVIDSON_PACE_GROUP_ANNUAL | 2,856 | 2026-11-16 03:04:53.370 |
| CLN_DAVIDSON_REF_ACCOUNTS | 45,304 | 2026-11-16 03:04:55.543 |
| CLN_DAVIDSON_REF_ACCOUNT_LOOKUP | 5,504 | 2026-11-12 11:07:13.297 |
| CLN_DAVIDSON_REF_ACCOUNT_MAPPING | 5,504 | 2026-11-16 03:04:52.942 |
| CLN_DAVIDSON_REF_CHART_OF_ACCOUNTS | 220 | 2026-11-16 03:04:52.718 |
| CLN_DAVIDSON_REF_DEPARTMENTS | 66 | 2026-11-16 03:04:53.567 |
| CLN_DAVIDSON_REF_LABOR_TYPES | 293 | 2026-11-16 03:04:53.768 |
| CLN_DAVIDSON_REF_REVENUE_CATEGORIES | 83 | 2026-11-16 03:04:51.483 |
| CLN_DAVIDSON_REF_SALES_ITEMS | 341 | 2026-11-16 03:04:52.105 |
| CLN_DAVIDSON_REF_SPEND_CATEGORIES | 323 | 2026-11-16 03:04:53.153 |

## Lane declaration (owner)
| Lane | Status | Why |
|---|---|---|
| DAVIDSON | rebuilt (D-44) | Classify the unclassified monthly and budget detail keys, and label the FIN_PL_SUMMARY lines that sit in UNKNOWN. The key rule is unchanged. |

- **No other lane is touched:** the other 17 lanes in DEV_G2M_AI are covered by the check 5 baseline at M2.
- **The archived records read first** (D-44): builds 06, 19, 20 and 21. The key is built as in build 21:
  - MR and budget: site = HOTEL_CODE, department = segment 1 of a six-segment ACCOUNT, ACCOUNT_KEY = ACCOUNT, else LINE_CLASS.
  - Summary: department = SECTION, ACCOUNT_KEY = LINE_ITEM with repeated spaces collapsed.
- **DEV_G2M_AI's Davidson objects predate the 11-16 reload.**
  - Its MR unknown is 1,983,068.79, against 1,988,322.85 computed from today's CLN.
  - The 415 keys the DEV1 pipeline found are not yet in DEV_G2M_AI's snapshot; the rebuild's first run will insert them (D-44, new data).
  - Every M1 figure below is computed read-only from today's CLN with the deployed staging derivations.

## A. Monthly report (FIN_PL_MONTHLY) and budget (FIN_BUDGET_MONTHLY): unclassified detail
- **The unclassified keys are not mixed department sections.** Every one is a one-segment ACCOUNT, so the staged NATURAL_ACCOUNT is null and the branch has nothing to read.

  | Table | One-segment strings | Keys (site + string) | Source lines | Amount |
  |---|---|---|---|---|
  | MONTHLY | 156 | 550 | 6,600 (13,200 staged, x2 branches) | 1,988,322.85 |
  | BUDGET | 164 | 568 | 7,128 | 7,040,086.67 |

  - The strings: `x...` codes (MONTHLY 156, BUDGET 159), `NEW 02`, `NEW 02b`, `NEW 03`, `NEW 03b` (budget) and `957399100` (budget, RMIHKK).
  - The "department section mixes revenue and expense" rule belongs to FIN_PL_SUMMARY, not to these tables. The monthly rule maps every six-segment account already, including 5200-5204 (Operating Expenses).
- **The source states their ledger account.**
  - CLN_DAVIDSON_REF_ACCOUNTS.ALIAS gives each `x...` code its six-segment string, e.g. `x402053410` -> `PROOM-4101-TRNDS-TDOTH-XXXXX-XXXXX` ("Transient - Discount - Other - Reward Redemption").
  - There is at most one alias per code, and none of these strings is in REF_ACCOUNT_MAPPING.
- **Proposed rule:** a one-segment ACCOUNT takes its natural account from segment 2 of its REF_ACCOUNTS.ALIAS, and that natural account goes through the lane's existing map (4xxx Revenue; 5000-5006, 6xxx Payroll; 5100/5110 COGS; 5200-5204, 5900, 7xxx Operating Expenses; 5990 Allocations & Reserves; 8xxx Other Income / (Expense)).
  - This is a staged dictionary lookup. The key is unchanged (ACCOUNT_KEY stays the `x...` string), and RECORD_TYPE is unchanged.

  | Proposed | MONTHLY strings / lines / amount | BUDGET strings / lines / amount |
  |---|---|---|
  | Expense / Payroll | 95 / 4,620 / 884,682.76 | 95 / 4,944 / 2,686,755.48 |
  | Expense / Operating Expenses | 34 / 1,296 / 587,103.57 | 41 / 1,392 / 3,192,367.41 |
  | Revenue / Revenue | 7 / 168 / 636,366.97 | 4 / 132 / 949,532.00 |
  | Allocations & Reserves | 4 / 144 / -146,324.52 | 4 / 216 / -600,926.43 |
  | **The alias cannot settle:** natural 9xxx, a statistic ledger | 15 / 360 / 19,774.07 | 14 / 372 / 61,247.19 |
  | **The alias cannot settle:** no alias, or alias with a DNU segment and no number | 1 / 12 / 6,720.00 | 6 / 72 / 751,111.02 |

  Settled: MONTHLY 140 of 156 strings, BUDGET 144 of 164.
- **The P&L effect** (PRESENTED: VALUE = SOURCE_AMOUNT x VALUE_SIGN):
  - MONTHLY actual, Jan - Mar 2026: revenue +671,360.98 / -68,408.54 / +33,404.53; expense +344,345.77 / +284,638.30 / +380,158.12; GOP +327,015.21 / -353,046.84 / -346,753.59.
  - MONTHLY forecast, Aug - Dec 2026: expense 149,565.82 / 164,875.76 / 58,898.41 / 44,466.84 / 44,837.31; revenue 10.00 in Aug only.
  - BUDGET 2026, monthly: revenue 2,386 to 227,783; expense 285,304 to 813,385; GOP -210,107 to -657,268. 2027 adds expense of 8,453 to 12,395 a month.
  - Before the change, all of these are in UNKNOWN and add 0 to the P&L. Full table in `findings/M1.md`.

## B. FIN_PL_SUMMARY
- **Today:**
  - 3,895 section + line keys (11,546 with site) of summary detail sit in UNKNOWN as UNCLASSIFIED_ACCOUNT, with 2,953 subtotal keys (5,596 with site) and 79 "| #n" keys (420 with site).
  - **Summary lines already reach the P&L:** 36,912 staged lines, from MISCELLANEOUS INCOME and NON-OPERATING INCOME & EXPENSE on ALL_DEPARTMENT and the four SUMMARY-sheet sections. 22,320 of them are flagged IS_SUBTOTAL.
- **B1, totals:**
  - The current IS_SUBTOTAL rule (IS_ROLLUP; a SUMMARY amount line; a line starting "Total") misses upper-case group lines that do not start with TOTAL: 19,896 source lines, e.g. "SUBTOTAL A&G SALARIES AND WAGES", "GOVERNMENT MANDATED PAYROLL TAXES - A&G", "EMPLOYEE BENEFITS - A&G", "ROOMS PROFIT". They count as detail, so the totals above them do not tie.
  - Tie-out (actual file, ALL_DEPARTMENT): a total ties when it equals the detail summed from the section start, or from some earlier total, down to it.

    | Rule | Total lines | Tie |
    |---|---|---|
    | Current rule ("Total" first word) | 36,367 | 20,371 (56.0%) |
    | Upper-case rule (every all-capitals line is a subtotal) | 46,089 | 31,595 (68.6%) |

  - Most of the untied lines are differences, not sums: "... PROFIT", "GROSS ... PROFIT", "LESS: ALLOWANCES", "TOTAL NET ALLOCATION". Restaurant revenue and cost totals also often do not tie.
- **B2, "| #n" lines:** 5,280 lines (64 names).

  | Kind | Lines | With a first line | Equal on both measures | Differ | No first line |
  |---|---|---|---|---|---|
  | Total-named | 4,440 | 4,428 | 4,409 (99.6%) | 19 | 12 |
  | Detail-named | 840 | 826 | 258 | 568 (6,010,671 absolute) | 14 |

  The detail-named "| #n" lines are distinct lines that share a name (e.g. two Supplemental Pay lines in RECREATION), not repeats.
- **B3, overlap with the monthly report:**
  - The summary covers actuals to Sep / Oct 2026 (files as of 2026-09-01) and 15 hotels plus a roll-up. The MR covers actuals to Oct 2026 (report month 2026-07-01 to 2026-10-01), forecasts Aug - Dec, and 16 hotels.
  - **By line name** (mapping department + most specific segment name vs SECTION + LINE_ITEM): 17,652 of 134,088 summary detail cells match (13.2%). Of the matched actual cells, 12,646 are equal and 2,060 differ; matched totals are 289,780,971 (summary) against 290,651,711 (MR).
  - **By hotel + month + section:** 1,932 of 3,948 cells have an MR section of the same name. 491 are equal and 761 are within 1%; the matched totals are 678,239,471 against 461,113,721.
  - The 2,016 summary-only cells (443,087,702 absolute) are mostly sections the mapping names differently: ADMINISTRATIVE & GENERAL / ADMINISTRATION & GENERAL, IT / INFORMATION TECHNOLOGY, UTILITIES / "ENERGY, WATER, AND WASTE", BANQUETS / BANQUETS & CATERING, SALES & MARKETING / "SALES, MARKETING & REVENUE MANAGEMENT", NON-OPERATING / NONOPERATING.
  - The roll-up hotel (no HOTEL_CODE: 108 cells over 12 months) has no MR counterpart.
  - **A line-level match between the two tables is not in landed data:** the summary carries no account code, and the only bridge is names.

## Rules unchanged
SCENARIO, category, sign (PRESENTED; DAVIDSON is not in D-50), the HERSHA D-48 rule for RMICAD / RINPKR, and the RECORD_TYPE rules.

#### Build 24 rules (owner stop 2, Q-01 to Q-08)
- Q-01: a one-segment FIN_PL_MONTHLY / FIN_BUDGET_MONTHLY ACCOUNT takes its natural account from segment 2 of its REF_ACCOUNTS.ALIAS (one alias per string). Key unchanged.
- Q-02: 9xxx statistic-ledger aliases (15 monthly / 14 budget strings) and the strings with no usable alias (NEW 02, 02b, 03, 03b; 957399100; x405993010, alias a DNU string) stay Unclassified: not in landed data.
- Q-03 / Q-06 / Q-07 (D-48): FIN_PL_MONTHLY beats FIN_PL_SUMMARY for every DAVIDSON hotel-month; every summary money line is in UNKNOWN (classified: DUPLICATE_DETAIL; unclassified totals / profit / EBITDA / the 3 group roll-ups / total repeats: SOURCE_ROLLUP; other unclassified: DUPLICATE_DETAIL). Evidence: summary Total Operating Revenue = monthly revenue in 118 of 149 actual hotel-months at M1 (139 of 150 after build 24).
- Q-04: all-capitals summary lines are subtotals. Q-05: total-named "| #n" lines are repeats; detail-named "| #n" lines are distinct detail.
- Q-08: 5990 -> Expense / Operating Expenses (inside GOP); 6000, 7000, 7100-7400, 7600 -> Below the Line / Other Income / (Expense). 7000: no category between GOP and EBITDA in the hierarchy or a peer lane. 7600 stays combined (interest / D&A split not in landed data).
- PINCEN Oct 2026 (actual): monthly-level revenue differs from the summary by 1.15M; the cause is not in landed data.
- Stop 4 (owner): classified FIN_PL_SUMMARY lines carry UNKNOWN_REASON DUPLICATE_DETAIL (check 2(e)), not SOURCE_ROLLUP; IS_SUBTOTAL / SUBTOTAL_SOURCE mark the totals among them (36,912 lines). Unclassified totals, roll-ups and repeats carry SOURCE_ROLLUP.
