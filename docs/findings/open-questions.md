# Open questions - build 08 (D-44 rebuild of HHG, INVITED_CLUBS, NEWBURY)

Numbered within this build. Figures are in `M1.md`.

## Open at stop 1

| # | Lane | Question | Blocks |
|---|---|---|---|
| Q-01 | HHG | **The HHG sources are not granted.** None of the six `CLN_HERITAGE_GOLF_*` tables is visible: `SHOW TABLES` returns 0 rows and a direct read fails. No visible table carries HHG account, department or entity descriptions. Grant the six tables and the new description table, and name it? Or drop HHG from build 08? | All HHG work (scope item 1) |
| Q-02 | all | **Table assignment.** 27 tables are visible: 7 INVITED_CLUBS, 9 NEWBURY, and 11 out of scope (BEAUMIER, DAVIDSON, HERSHA), as listed in `M1.md` section 3. Confirm? | Staging redeploys |
| Q-03 | INVITED_CLUBS | **H2 names the standard vocabulary lacks.** Each needs a standard H2, or a CLAUDE.md change to add one. Defaults are proposed in `M1.md`. (a) "Payroll Related" (605-606): proposed Payroll. (b) "Utilities" (629): proposed Operating Expenses. (c) "Fixed Charges" (626, 630-633: property tax, insurance, lease, rent): no standard H2; Operating Expenses is the nearest. (d) "Management Fees" (63504): no standard H2; Operating Expenses is the nearest. (e) Impairment (62824) and minority interest (62839, 62849): proposed Other Income / (Expense). | The INVITED_CLUBS mapping |
| Q-04 | INVITED_CLUBS, NEWBURY | **H1 for the Below-the-Line moves.** INVITED_CLUBS interest, D&A, impairment, minority interest and income taxes go from H1 Expense to Below the Line, as the owner's text says. NEWBURY's 11 accounts stay H1 Below the Line, with only H2 changing. **Consequence:** under the standard hierarchy, D&A carries P_L_SECTION `Operating`, so a consumer computing operating profit from P_L_SECTION includes D&A whatever H1 says. Confirm? | No (default as stated) |
| Q-05 | INVITED_CLUBS | **Accounts the blocks do not cover, or cover twice.** Block 602 (8 "COGS:" accounts): proposed COGS. Block 638 (A63804 Web Hosting): proposed Operating Expenses. Block 626: in both 607-628 and Fixed Charges. A62838 Capitalized Interest: interest or Operating? A63004 Foreign Taxes: parent TAXEX, like the six income tax accounts, but not listed. A63506 and A63551 (debt-cost amortisation): proposed interest. A63699 Life / TAM Dues Clearing: parent AMORT, but not D&A by its description. | The INVITED_CLUBS mapping |
| Q-06 | INVITED_CLUBS | **`UNKNOWN_REASON` values outside CLAUDE.md.** Section 4 allows only `UNCLASSIFIED_ACCOUNT`, `UNRESOLVED_CATEGORY` and `BOTH`, and check 2(j) is written against them. `SOURCE_ROLLUP`, `PLANNING_INPUT` and `DUPLICATE_DETAIL` need a CLAUDE.md change, which is the owner's to make. Also: should the `Ind-Total` rows be marked `IS_SUBTOTAL` in staging (D-25), in addition to or instead of the reason value? And should the 53 unmatched keys (dues-movement members, `EB_*_ADJEBITDA`, the two `Plan ... Adjustment` members, the 3 `[Total Base Dues]` accounts) stay `UNCLASSIFIED_ACCOUNT`? | Scope item 3 |
| Q-07 | NEWBURY | **880420 Amort Expense-Loan Fees and 880440 Amort Expense-Interest Rate Cap** are financing costs. D&A (proposed, by block and description) or Other Income / (Expense) (interest-like)? | No (default D&A) |
| Q-08 | INVITED_CLUBS, NEWBURY | **How the D-44 re-seed runs.** Proposed: (1) the lane's seeder branch gets the new mapping, so new keys seed under it; (2) a one-time UPDATE of the lane's existing snapshot rows sets H1-H5, section, balance, sign and seed source from that same branch logic, keyed on the five-part key, with no insert and no delete. It is idempotent, and its row count is reported against the pre-change hash. The seeder header comment (line 23, "insert-only") is updated to cite the D-44 exception. | M4 |

## HHG, after re-grant

| # | Lane | Question | Blocks |
|---|---|---|---|
| Q-01 | HHG | **Answered:** re-granted by the owner; all six tables are readable. Measured: recreated 2026-10-27 17:23-17:24 PDT, before the freeze. Data identical except three ACCOUNTS columns. See `M1.md` section 9. | - |
| Q-09 | HHG | **`DEPARTMENT_DESCRIPTION` on department 950 has four values** across accounts ("Fixed G&A Expenses", "Administrative Expenses", "BELOW EBITDA", "Other Income & Expenses"); 903 has two. Carried verbatim per row (the join is per account, so no conflict), `DEPARTMENT_NAME` would show a P&L section heading on 950 rows. Use it as `DEPARTMENT_NAME` as supplied, or carry it under another name and leave 950's `DEPARTMENT_NAME` as it is? | HHG `DEPARTMENT_NAME` |
| Q-10 | HHG | **No entity names for 9050-9056, 9099, 9102 in any HHG table.** Supply them (as source data, such as REFERENCES rows), or leave those entities' `ASSET_NAME` as built? | No (default: unchanged) |
| Q-11 | HHG | **`PARENT_CODE` is newly filled** (13,128 rows: Green Fees, Cart Fees, ...). It is out of this build's scope. Carry it through staging as an attribute only, or leave it unstaged? It would be the lane's H2 evidence at a later rebuild (D-46). | No (default: staged as an attribute, not used) |

## Answered by the owner (stop 1)

- **Q-01:** HHG is back in scope, for item 1 only. The recreated ACCOUNTS table
  is baselined as found.
- **Q-02:** table assignment approved.
- **Q-03:** approved as proposed, with no new H2 names:
  - Payroll Related -> Payroll;
  - Utilities, Fixed Charges and Management Fees -> Operating Expenses;
  - impairment and minority interest -> Other Income / (Expense).
- **Q-04:** the standard hierarchy is accepted as it is; noted in `sources.md`.
- **Q-05:**
  - 602 -> Cost of Goods Sold; 638 -> Operating Expenses; 626 -> Operating
    Expenses.
  - A62838 -> as the 635xx interest accounts.
  - A63004 -> Income Taxes.
  - A63699 -> UNCLASSIFIED, listed for the business.
  - Where block and META parent disagree, list at stop 3 rather than choose
    (`M1.md` section 10: 14 accounts).
- **Q-06:** approved, after the `CLAUDE.md` section 4 / check 2(j) change
  (diff shown).
  - `Ind-Total` rows: `IS_SUBTOTAL = TRUE` and reason `SOURCE_ROLLUP`.
  - The 53 unmatched keys stay `UNCLASSIFIED_ACCOUNT`.
- **Q-07:** 880420 and 880440 -> Other Income / (Expense), i.e. unchanged.
  The other 9 as proposed.
- **Q-08:** approved.
- **Q-09:** `DEPARTMENT_NAME` = `DEPARTMENT_DESCRIPTION` as supplied, per
  account. No repair or normalising.
- **Q-10:** the nine entities' `ASSET_NAME` stays as built (an open client
  request). No crosswalk.
- **Q-11:** `PARENT_CODE` is carried through staging as an unused attribute.

## Open at stop 3

| # | Lane | Question | Blocks |
|---|---|---|---|
| Q-12 | INVITED_CLUBS | **14 A6 accounts whose block and META `ACCTS-*` parent disagree** (Q-05: list, don't choose). Listed in `M1.md` section 10. The block applies unless the owner says otherwise. 12 are block COGS or Payroll with an Operating-majority parent: A60005, A60201-A60208, A60211, A60203 (COGS), and A60517, A60518, A60528 (Payroll, parent OTINS). 2 are block Operating with a Payroll-majority parent: A62424, A62431 (parent EMREL). | M4 seeding of these 14 |
| Q-13 | INVITED_CLUBS | **`Ind-Total Revenue` and `Ind-Total Golf Revenue` (53,982 rows)** are classified Revenue and in the INCOME_STATEMENT stream, not UNKNOWN. Under the `Ind-Total` rule they are now `IS_SUBTOTAL = TRUE` in staging. They stay in the income statement (routing is on `H1`), flagged. Confirm. | No (default: flagged as built) |
| Q-14 | INVITED_CLUBS | **Wages ratio.** Against their own five non-exempt GL accounts, the `*_Wages_*_Dollars` members are 103.9% of GL (GL = 96.3%), ranging 103% to 122% by account. Against all of A603 they are 64.2%. Keep `DUPLICATE_DETAIL` for all five at M5? | M5 reason value |

## Answered by the owner (stop 3)

- **Q-06:** the `CLAUDE.md` wording is approved; the new values are used at M5.
- **Q-12:** the block mapping applies to all 14 accounts. They are listed in
  `sources.md`, and at stop 4 as accounts for the business to spot-check.
- **Q-13:** confirmed. `Ind-Total Revenue` and `Ind-Total Golf Revenue` stay
  flagged `IS_SUBTOTAL`.
- **Q-14:** `DUPLICATE_DETAIL` is kept for all five wage members. **Measured
  figure: 103.9%** (wages members / GL, all entities, matched to
  A60351-A60355; `M3.md`). The owner's 98% was one entity-month.
