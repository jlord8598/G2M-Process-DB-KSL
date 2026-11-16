# M1 addendum - the summary in the P&L (build 24, owner's M1 follow-up)

**Report only. Stopped for decisions on Q-03, Q-04, Q-06 and Q-07.** Everything here is from today's CLN with the deployed logic:
- the seeder's summary section map;
- the staging IS_SUBTOTAL rule;
- XFRM_DAVIDSON, where category = the measure column and DAVIDSON has no D-48 rule.

Q-01, Q-02 and Q-05 are approved; see open-questions.md.

## 1. Is Davidson double counted today? Yes, on revenue.
- **The base:** the 36,912 staged summary lines in the income statement, reproduced exactly. 20,129 of them carry an amount.
- **By hotel-month:**

| Category | Summary hotel-months with amounts | Also with MR lines in the P&L | Summary only |
|---|---|---|---|
| ACTUAL | 160 | 149 | 11 |
| FORECAST | 50 | 47 | 3 |

- **Amounts in the overlapping hotel-months**, all summary lines as they sit in the P&L. GOP = revenue - expense, PRESENTED.

| Category | Hotel-months | Summary revenue | Summary expense | Summary GOP | MR revenue | MR expense | MR GOP |
|---|---|---|---|---|---|---|---|
| ACTUAL | 149 | 899,350,395 | 1,041,343,698 | -141,993,303 | 396,306,039 | 420,573,870 | -24,267,831 |
| FORECAST | 47 | 201,190,132 | 231,225,608 | -30,035,476 | 89,729,035 | 118,575,566 | -28,846,531 |

**The anchor: the summary's "Total Operating Revenue" against MR revenue (natural 4xxx).**

- **ACTUAL:** equal to within 1 in 118 of 149 hotel-months, and within 0.5% in 125. Totals: 395,046,419 against 396,306,039.
- **FORECAST:** 36 of 47 equal, 43 within 0.5%. Totals: 89,622,851 against 89,729,035.
- Example: PMIHST, Mar 2026, 2,157,855 against 2,157,854.51.
- **The summary's four revenue lines sum to that total** in 148 / 149 and 47 / 47 hotel-months. So the summary SUMMARY sheet puts each hotel-month's revenue into the P&L twice (lines + total), and the MR puts it in a third time.
  - Of the summary's 899.4M actual revenue in overlap months, 790.1M is the SUMMARY sheet (2 x 395.0M).
  - The rest is ALL_DEPARTMENT MISCELLANEOUS INCOME: 27.5M detail, 27.2M unflagged all-capitals lines, and 54.6M flagged subtotals.
- The SUMMARY sheet's lines are all IS_SUBTOTAL today (build 15 / 19 rule). A consumer who excludes IS_SUBTOTAL removes them; a plain sum does not.

**Expense does not tie.**

- The SUMMARY sheet's Total Departmental + Total Undistributed Expenses is 249.9M (actual, 149 hotel-months), against 420.6M of MR expense: 0 hotel-months within 2%.
- The MR's own GOP, by the lane's natural-account map, is negative (-24.3M actual), so the MR expense set is not a clean GOP anchor either. A natural-account-to-USALI-line bridge is not in landed data.
- **Material:** the SUMMARY sheet's expense sections carry profit lines (Departmental Profit, Gross Operating Profit, House Profit: 532.7M actual, 89.9M forecast). Section-level classification gives them H1 Expense, so profits sit in the P&L as expense (flagged IS_SUBTOTAL).
- Non-Operating Income and Expenses on the SUMMARY sheet likewise carries EBITDA and EBITDA LESS REPLACEMENT RESERVE.

## 2. Subtotal-style lines in the P&L now

| Sheet | Group | Kind | Staged lines | With amount | Actual | Forecast |
|---|---|---|---|---|---|---|
| SUMMARY | Revenue | flagged IS_SUBTOTAL (whole sheet) | 2,112 | 1,154 | 1,075,006,571 | 254,357,814 |
| SUMMARY | Expense | flagged IS_SUBTOTAL | 6,000 | 3,278 | 1,413,842,459 | 327,987,942 |
| SUMMARY | Below the Line | flagged IS_SUBTOTAL | 3,648 | 1,990 | 367,508,077 | 55,093,510 |
| ALL_DEPARTMENT | Revenue (MISC INCOME) | flagged, all-capitals | 4,080 | 2,227 | 81,123,586 | 17,477,914 |
| ALL_DEPARTMENT | Revenue | flagged, not all-capitals | 864 | 468 | 8,515,576 | 2,060,817 |
| ALL_DEPARTMENT | Revenue | **all-capitals, NOT flagged (Q-04 pattern)** | **864** | **474** | **27,328,540** | **5,304,787** |
| ALL_DEPARTMENT | Revenue | detail | 6,048 | 3,307 | 27,550,284 | 5,441,324 |
| ALL_DEPARTMENT | Below the Line (NON-OP) | flagged, all-capitals | 4,296 | 2,337 | 543,368,844 | 156,416,219 |
| ALL_DEPARTMENT | Below the Line | flagged, not all-capitals | 1,320 | 715 | 65,043,209 | 18,706,546 |
| ALL_DEPARTMENT | Below the Line | detail | 7,680 | 4,179 | 165,903,303 | 47,470,941 |

- **Flagged subtotals in the P&L:** 22,320 staged lines. They are next to their own detail, distinguishable only by IS_SUBTOTAL.
- **Unflagged subtotals in the P&L:** 864 staged lines (MISCELLANEOUS INCOME all-capitals totals, 27.3M actual / 5.3M forecast). These double count even for a consumer who excludes IS_SUBTOTAL; the actual amount is almost equal to the 27.6M of detail they total.
- The SUMMARY sheet's Below the Line lines (Other Income / (Expense), Mixed) carry no VALUE, so they move no signed total. Revenue and expense lines do.

## 3. Hotel-months whose only P&L source is the summary

| Hotel | Category | Months | Revenue | Expense |
|---|---|---|---|---|
| Davenport Collection (roll-up, no HOTEL_CODE) | ACTUAL | Jan - Oct 2026 (10) | 194,374,090 | 233,880,725 |
| Davenport Collection (roll-up) | FORECAST | Oct - Dec 2026 (3) | 53,247,531 | 64,324,353 |
| Islamorada (roll-up) | ACTUAL | Jan - Oct 2026 (10) | 117,089,706 | 127,364,836 |
| Islamorada (roll-up) | FORECAST | Oct - Dec 2026 (3) | 29,756,559 | 31,922,579 |
| Mackinac Island Bike Shop (roll-up) | ACTUAL | Jan - Oct 2026 (10) | 6,051,890 | 8,296,927 |
| Mackinac Island Bike Shop (roll-up) | FORECAST | Oct - Dec 2026 (3) | 448,434 | 515,402 |
| PINCEN The Centennial Hotel | ACTUAL | Oct 2026 (1) | 2,658,476 | 2,956,273 |

- **The three roll-ups (IS_ROLLUP, no HOTEL_CODE) are group lines by name:** Davenport Collection; Islamorada; Mackinac Island Bike Shop, which by name matches the MR's RINGMIBIKE.
  - Which hotels each one totals is not in landed data: there is no group-to-hotel map, so I have not proved that they double count their hotels.
  - If they are group totals, they are a second count of hotels already in the P&L. Today their 13 + 13 + 13 roll-up hotel-months reach the P&L in full.
- **PINCEN, October 2026** is the one genuine summary-only hotel-month: the MR has no PINCEN actual for October. It is not in landed data in the MR.
- **The reverse:**
  - The MR alone carries FORECAST Aug - Sep 2026 for 12 hotels (the summary forecast starts in Oct).
  - RINGMIBIKE (10 actual, 5 forecast hotel-months) has no summary counterpart under its own code; the summary shows it only as the Bike Shop roll-up.

## What this means for the held questions
- **Q-03:** today the P&L counts revenue three times (MR + summary lines + summary total) for 149 actual and 47 forecast hotel-months. It also books profit lines as expense, and adds the three roll-ups (whose member hotels are not in landed data). Taking the summary out of the P&L (D-48, MR wins) removes all of that. Kept out of the P&L, the summary would lose only PINCEN October 2026 (2.66M revenue).
- **Q-04:** the all-capitals rule would flag the 864 unflagged MISCELLANEOUS INCOME totals now in the P&L.
- **Q-06 / Q-07:** revenue gives the anchor (118 / 149 exact, 125 within 0.5%). Expense needs a crosswalk that is not in landed data.
