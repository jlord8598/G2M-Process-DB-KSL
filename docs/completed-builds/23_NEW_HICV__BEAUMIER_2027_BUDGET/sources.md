# Sources (build 23)

## Source schema
- `CLN.BOX_INVESTMENT_DATA`. Load freeze: Gary's, confirmed by the owner for the eight HICV tables at the 2026-11-16 loads (Q-01). The two Beaumier tables were added to the baseline after Gary's grant (Q-02).
- Baseline: Gary's latest loads. The whole schema was reloaded on 2026-11-16 (03:04-07:56 PST).
- `last_altered` of every in-scope table (D-43):

| Table | Rows | last_altered |
|---|---|---|
| CLN_HICV_FIN_PL_MONTHLY | 341,688 | 2026-11-16 07:56:52.901 |
| CLN_HICV_FIN_GL_MONTHLY | 15,257 | 2026-11-16 07:56:54.415 |
| CLN_HICV_REF_ACCOUNTS | 22,220 | 2026-11-16 07:56:55.725 |
| CLN_HICV_REF_PROPERTY_ROOM_KEYS | 304 | 2026-11-16 07:56:53.880 |
| CLN_HICV_OPS_KPI_WEEKLY | 1,318 | 2026-11-16 07:56:54.256 |
| CLN_HICV_OPS_TREND_WEEKLY | 6,849 | 2026-11-16 07:56:54.085 |
| CLN_HICV_PACE_RESERVATIONS_WEEKLY | 250 | 2026-11-16 07:56:53.095 |
| CLN_HICV_OPS_PRIORITIES_WEEKLY | 96 | 2026-11-16 07:56:53.283 |
| CLN_BEAUMIER_OPS_STATS_MONTHLY | 132 | 2026-11-16 03:04:25.338 (granted by Gary, Q-02) |
| CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI | 7,622 | 2026-11-16 03:04:24.626 (granted by Gary, Q-02) |

## Lane declaration (owner)
| Lane | Source tables | Notes |
|---|---|---|
| HICV | the 8 CLN_HICV_* tables | New lane. The name is unused: not in docs/completed-builds, DEV_G2M_AI or the master. |
| BEAUMIER | CLN_BEAUMIER_OPS_STATS_MONTHLY, CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI | Existing lane (1,181 keys in DEV_G2M_AI and in the master). Adding tables makes it a D-44 rebuild. Its other 8 CLN_BEAUMIER_* tables are staged by earlier builds. |

Every other table in the schema is out of scope (earlier builds' lanes and the CLN_UTIL_* control tables).

## HICV (measured)
- **FIN_PL_MONTHLY** (forecast-model P&L): long; 37 ledger tabs (legal entities), 134 locations, 559 accounts, 175 cost centers, 28 lines of business; Jan 2025 - Dec 2026, 14,237 lines per month.
  - Unique on ledger tab + account + cost center + LOB + location + LINE_ID + month (0 duplicates). No blank account, location, cost center or LOB.
  - Measures, wide x4:

| Measure | Populated | Months |
|---|---|---|
| ACTUAL_AMOUNT | 313,214 | Jan 2025 - Oct 2026 |
| FORECAST_AMOUNT | 28,474 | Nov - Dec 2026, version FORENOV |
| PREVIOUS_FORECAST_AMOUNT | 170,844 | 2026, version FOREOCT |
| BUDGET_AMOUNT | 170,844 | 2026, BUDGET_VERSION null |

  - SECTION is the workbook header above the line, 26 values. One account sits under several sections (204 of 559 accounts).
  - LINE_DESCRIPTION reads "account-cost center-P&L category-location-LOB". The third part is a stated P&L category, 26 values (e.g. Vacation ownership sales, Financing income - Interest Income, HOA, Provision). About 13% of descriptions (43,320 lines) carry hyphens inside names, so the split is not reliable on its own.
  - No total, subtotal or computed line was found. Section "Total" (1,589 lines in Sep 2026) is detail (club, HOA and management fees). "Check figure - all" is one line, zero in Sep 2026.
  - **Sign:** profit-signed (revenue positive, most costs negative), with exceptions: interest expense +3.46M and financing expense - mortgage servicing +4.33M in Sep 2026. Not yet proved as a whole-table convention (Q-06).
  - **Statistics:** no unit or count lines; every line is money.
- **FIN_GL_MONTHLY** (ledger actuals): Sep 2025 (7,544) and Sep 2026 (7,713) only; ACTUAL only (ACTUAL_SOURCE = CURRENT_YEAR); 32 ledgers, 121 locations, 505 accounts.
  - Unique on ledger + LOB + cost center + location + account + LINE_ID + month.
  - Carries the source P&L hierarchy: PL_MAJOR_CATEGORY (7) / PL_SUB_CATEGORY_1-3. It covers 498 of the P&L's 559 accounts (94.3% of absolute amount); 347 of those map to a single major / sub-category.
  - Profit-signed: revenue sub-categories positive, expense negative.
- **PL vs GL:** they overlap on Sep 2025 and Sep 2026 only, and they disagree.

| Sep 2026 (same 5-part cell) | Count |
|---|---|
| Cells in both | 7,512 |
| P&L only | 6,490 |
| GL only | 80 |
| Equal values | 372 |
| Opposite values | 223 |

  - Revenue (digit 3): P&L 231.7M vs GL 322.7M. Payroll (digit 5): -20.3M vs -138.2M. Total: 134.2M vs 80.4M.
  - The source comment says the P&L actuals are at forecast-model level and the GL is the ledger-level actual: "do not add the two together". A precedence rule is needed (Q-03).
- **Account structure:** 6 digits. The leading digit groups the chart:

| Digit | Group | Accounts (GL) |
|---|---|---|
| 3 | revenue | 157 |
| 4 | cost of vacation ownership / inventory | 33 |
| 5 | payroll | 51 |
| 7 | operating and financing | 174 |
| 8 | G&A, provision, taxes, D&A, license fees | 51 |
| 9 | allocations and other | 20 |

  - The P&L's accounts follow the same digits (3: 173, 4: 42, 5: 52, 7: 206, 8: 69, 9: 17).
- **Timeshare lines (Sep 2026 P&L, by stated category):**

| Category | Amount |
|---|---|
| Vacation ownership sales | 68.7M |
| Property management income | 30.9M |
| Club income | 21.0M |
| Financing income - Interest Income | 20.5M |
| Rental income | 12.5M |
| Fee for Service Revenue | 12.4M |
| Retail and resort income | 5.6M |
| HOA | 4.8M |
| Financing income - Other | 3.7M |
| Provision (loan loss) | -22.6M |
| Financing expense - provision | -2.7M |
| License fees | -5.6M |
| Cost reimbursement | 1.3M |

  - The GL shows Down Payment Forfeiture -11.3M and Cost Reimbursement Revenue / Expense +/-7.49M grossed up.
- **REF_ACCOUNTS:** derived dictionary. GL rows: 8,799 (121 entities, 505 accounts). P&L rows: 13,421 (134 entities, 559 accounts). PARENT_CODE is the GL sub-category 1 or the P&L section.
- **REF_PROPERTY_ROOM_KEYS:** reference data, 29 resorts x COUNT_YEAR 2008-2023, one file. ROOM_KEYS for 2024-2026 is not in landed data, so it cannot be the available-room base for the 2025-26 months. Proposed: staged as a dictionary, not a fact (Q-07).
- **OPS_KPI_WEEKLY / OPS_TREND_WEEKLY / PACE_RESERVATIONS_WEEKLY:** report snapshots, 2 SNAPSHOT_DATEs each (2026-11-02, 2026-11-09).
  - Windows WEEK / MTD / YTD; CY and PY (PY stored as ACTUAL dated one year earlier); IS_SUBTOTAL stated.
  - KPI: occupancy, arrivals, room revenue, ancillary, mortgage portfolio ($'000).
  - TREND: tours, conversion, packages, sales volume ($000's).
  - Reservations: new / cancelled / net.
  - The same period is measured in both snapshots (MTD, YTD), so this is pacing-shaped. Proposed: the PACING stream and SEM_AI_PACING (Q-08).
  - Overlap with the monthly P&L can't be determined: the snapshots cover November 2026, for which the P&L has no actual (actual ends Oct 2026). A partial month cannot be compared with a full one.
- **OPS_PRIORITIES_WEEKLY:** text. 96 lines of status notes (workstream, initiative, tier, update; average 397 characters, 0 numeric). Reference only; not staged (owner rule).
- **Currency:** no currency column. USD is assumed (Q-05).

## HICV build rules (owner, stop 2)
- **Precedence (Q-03, D-48):** CLN_HICV_FIN_PL_MONTHLY wins every month; the GL's Sep 2025 and Sep 2026 rows go to UNKNOWN as DUPLICATE_DETAIL.
- **Classification (Q-04):** H1 from the account's leading digit. H2 from the GL's PL_SUB_CATEGORY_1 where the GL covers the account; otherwise from the category stated in LINE_DESCRIPTION. The lines whose description does not split cleanly are listed at M3.
- **Currency (Q-05):** USD, an owner assumption; not in landed data.
- **Signs (Q-06):** as booked; nothing flipped. Measured by month, Jan 2025 - Oct 2026:
  - "Financing expense - mortgage servicing":
    - its expense accounts (digits 4-9) are negative (a cost) in 22 / 22 months;
    - its positive total comes from digit-3 revenue accounts labelled with that category, positive in 21 / 22 months.
  - "Interest expense" accounts (777805 Interest On Senior Notes, 777823 Amortization of Financing Cost, 799701) are positive in 21 / 22 months; December 2025 is -893,268, from a one-off -5,721,931 on 777850.
  - The GL books 777805 negative (-6,955,785.85 over its two months). So the P&L's positive interest expense is not a credit reducing expense: the same account is a cost in the ledger. The P&L carries it expense-positive, against its own profit-signed convention elsewhere.
- **Room keys (Q-07):** staged as a dictionary. A 2025-26 room base is not in landed data.
- **Weekly KPI / trend / reservations (Q-08):** to SEM_AI_PACING.
- **Key (Q-09):** site = LOCATION_CODE, department = COST_CENTER_CODE, account = ACCOUNT_CODE; ledger and LOB carried, not keyed.
- **Priorities (Q-10):** reference only, not staged.
- **P&L scope (Q-12):** the P&L wins every month (Q-03): it is the only continuous actual series (Jan 2025 - Oct 2026) and it aligns with the forecast and budget; the GL holds two months. Its cost scope is narrower than the GL's (Sep 2026 payroll -20.3M against -138.2M; sales commissions 0 against -30.7M). Sales and marketing costs are not in landed data at P&L level (N-59).
- **Interest On Senior Notes (Q-13):** positive in the P&L, negative in the GL; reported as booked (N-60).

## HICV scope of the P&L vs the GL (measured, Sep 2026)
| Digit | P&L | GL |
|---|---|---|
| 3 revenue | 231,680,872.00 | 322,691,520.82 |
| 4 cost of VOI / inventory | -14,859,729.00 | -47,745,039.00 |
| 5 payroll | -20,305,092.00 | -138,166,161.09 |
| 7 operating / financing | -16,027,569.00 | -32,190,263.47 |
| 8 G&A, provision, tax, D&A | -48,004,010.00 | -24,948,708.99 |
| 9 allocations | 1,675,583.00 | 714,906.35 |
| Total | 134,160,055.00 | 80,356,254.62 |

- The P&L carries less of the cost of selling vacation ownership. Commission - Sales Rep (569101) is 0.00 in the P&L against -30,744,291.40 in the GL. Salaries and Wages (500002) is -11,105,444.00 against -59,881,110.89; the GL puts -51,844,304.90 of it under Vacation Ownership Interest Sales.
- The GL's "Vacation Ownership Interest Sales" sub-category nets costs into the sale: digit 3 +271.3M, digits 4-9 -188.0M, net 83.3M.

## BEAUMIER 2027 budget (measured, after Gary's grant)
- **CLN_BEAUMIER_OPS_STATS_MONTHLY:** 132 lines = 11 hotels x 12 months (Jan - Dec 2027), BUDGET_YEAR 2027, one file; unique on hotel + month.
  - Wide x4 (BUDGET_OPENING_DAYS, BUDGET_KEYS, BUDGET_ROOMS_SOLD, BUDGET_ROOMS_AVAILABLE): 528 staged lines.
  - Zeros are seasonal closures: 56 hotel-months have 0 opening days and 0 rooms available. In 0 cases does opening days = 0 disagree with rooms available = 0, or rooms sold sit non-zero in a closed month.
  - H3V is zero in all 12 months.
  - Budget only; actual statistics are not in landed data.
- **CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI:** 7,622 lines; 10 hotels (no BMR, CPH, H3V); 113 line items; Jan - Dec 2027; one file; unique on hotel + line + month.
  - BUDGET_AMOUNT is already in units (= SOURCE_VALUE_THOUSANDS x 1000 on all 7,622 lines), so no D-49 scale.
  - All 113 line items match CLN_BEAUMIER_REF_HIERARCHY_PL_LINE and the existing budget's line names.
  - Signs as the existing Beaumier budget (PROFIT). The source gives no subtotal marker, as for the existing tables.
  - The table comment says currency EUR is assumed for every hotel, but the existing lane carries HGB and HSB as CHF (Q-11).
  - The comment also says "not to be added to the Budget tab of the same workbook" (held in RAW, CLN_UTIL_RAW_NOT_BUILT).
- **Overlap:** none.
  - The existing CLN_BEAUMIER_FIN_BUDGET_MONTHLY covers 2025 (Prior Year, 9,251 lines) and 2026 (Budget, 8,326 lines).
  - CLN_BEAUMIER_FIN_FORECAST_VERSIONS covers 2026 only.
  - 0 hotel-months are shared with the USALI budget, so no D-48 precedence rule is needed.

## BEAUMIER build rules (owner, stop 2)
- **Currency (Q-11):** the lane's existing per-hotel currency: HGB and HSB CHF, BMR and CPH UNCONFIRMED, the rest EUR. The USALI table comment's "EUR for all hotels" is logged as a conflict (N-58).
- **OPS_STATS_MONTHLY (Q-14):**
  - CATEGORY = BUDGET.
  - SCENARIO = the raw source label, the budget year (BUDGET_YEAR, 2027).
  - The measure (BUDGET_OPENING_DAYS, BUDGET_KEYS, BUDGET_ROOMS_SOLD, BUDGET_ROOMS_AVAILABLE) is the statistic account: STAT_ACCOUNT / ACCOUNT_KEY, RECORD_TYPE STATISTIC.
  - Keys STOCK; rooms sold, rooms available and opening days FLOW.
- **FIN_BUDGET_MONTHLY_USALI:** no overlap with the 2025-26 budget, so no D-48 rule. Staged as booked (units).

## Staging (M3, build 23)
| Model | Table | Source | Identity | Lines |
|---|---|---|---|---|
| SPROC_STG_HICV_ACCOUNTS | STG_HICV_ACCOUNTS | CLN_HICV_REF_ACCOUNTS | long | 22,220 |
| SPROC_STG_HICV_ROOM_KEYS | STG_HICV_ROOM_KEYS | CLN_HICV_REF_PROPERTY_ROOM_KEYS | long | 304 |
| SPROC_STG_HICV_PL | STG_HICV_PL | CLN_HICV_FIN_PL_MONTHLY | wide x4 | 1,366,752 |
| SPROC_STG_HICV_GL | STG_HICV_GL | CLN_HICV_FIN_GL_MONTHLY | long | 15,257 |
| SPROC_STG_HICV_KPI_WEEKLY | STG_HICV_KPI_WEEKLY | CLN_HICV_OPS_KPI_WEEKLY | long (pacing) | 1,318 |
| SPROC_STG_HICV_TREND_WEEKLY | STG_HICV_TREND_WEEKLY | CLN_HICV_OPS_TREND_WEEKLY | long (pacing) | 6,849 |
| SPROC_STG_HICV_RESERVATIONS_WEEKLY | STG_HICV_RESERVATIONS_WEEKLY | CLN_HICV_PACE_RESERVATIONS_WEEKLY | long (pacing) | 250 |
| SPROC_STG_BEAUMIER_BUDGET_USALI | STG_BEAUMIER_BUDGET_USALI | CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI | long | 7,622 |
| SPROC_STG_BEAUMIER_OPS_STATS | STG_BEAUMIER_OPS_STATS | CLN_BEAUMIER_OPS_STATS_MONTHLY | wide x4 | 528 |

- **HICV P&L (STG_HICV_PL):**
  - The 4 measures are unpivoted INCLUDE NULLS; SOURCE_MEASURE names the column.
  - SCENARIO (D-45): the named version (FORECAST_VERSION FORENOV, PREVIOUS_FORECAST_VERSION FOREOCT), else the measure column name. SCENARIO_SOURCE says which.
  - LINE_DESCRIPTION is split structurally: spaced hyphens are protected, then the text is split on bare hyphens. A 5-part split is CLEAN; anything else is AMBIGUOUS.

    | Split | Source lines | Note |
    |---|---|---|
    | CLEAN | 299,256 | the third part gives exactly the 26 stated categories |
    | AMBIGUOUS | 42,432 (12.4%) | 1,663 descriptions, 135 accounts; listed in docs/findings/hicv_ambiguous_descriptions.csv |

    M1's 43,320 came from a cruder count.
  - DESC_ACCOUNT_NAME, DEPARTMENT_NAME, DESC_PL_CATEGORY, ASSET_NAME and DESC_LOB_NAME come from the clean parts, and are null on AMBIGUOUS lines.
  - SOURCE_LINE_KEY = ledger tab | account | cost center | LOB | location | LINE_ID | month | measure (unique).
- **HICV GL (STG_HICV_GL):**
  - SCENARIO = CLN_HICV_FIN_GL_MONTHLY (D-45).
  - PL_MAJOR_CATEGORY and PL_SUB_CATEGORY_1-3 are carried for the seeder.
  - SOURCE_LINES_COMBINED > 1 on 9,084 lines (Q-19).
  - SOURCE_LINE_KEY = ledger | LOB | cost center | location | account | LINE_ID | month (unique).
- **HICV pacing (3 weekly tables):**
  - Long copies, SOURCE_IS_SUBTOTAL as stated.
  - SNAPSHOT_DATE on the row, which is the as-of.
  - SITE null: the reports are portfolio-level and the source names no site.
  - SOURCE_LINE_KEY = file | snapshot | tab | section | line | window | period (unique on the natural columns).
  - The D-51 mapping (VANTAGE, METRIC_UNIT, IS_ADDITIVE) is set at M5 / M6.
- **HICV dictionaries:**
  - STG_HICV_ACCOUNTS is not unique on FULL_ACCOUNT_STRING across the GL and P&L sources (1,064 distinct string + source pairs on 22,220 lines). The source's SOURCE_TABLE column is carried as REF_SOURCE_TABLE.
  - STG_HICV_ROOM_KEYS is reference only.
- **BEAUMIER USALI budget:**
  - Shaped as STG_BEAUMIER_BUDGET: SOURCE_ITEM_ID = LINE_ITEM, site = HOTEL_CODE, no department.
  - SCENARIO = BUDGET_YEAR (Q-17).
  - Currency per hotel: 5,867 lines EUR, 1,755 CHF.
  - Of its 850 site + line keys, 847 are already in the lane's classification. 3 are existing line names at a hotel for the first time: HVT Affiliation/Representation, HLG Branding, HPN Room service Food.
- **BEAUMIER OPS stats:**
  - STAT_ACCOUNT = ACCOUNT_KEY = the measure column, RECORD_TYPE STATISTIC.
  - SCENARIO = BUDGET_YEAR (Q-14).
  - 44 new keys (11 hotels x 4 measures).

## Stop-3 rules applied (M4-M6, build 23)
- **The P&L description parse (Q-15):** CLEAN, ANCHORED or AMBIGUOUS. The list is the 26 third parts of the CLEAN lines, derived in SPROC_STG_HICV_PL.

  | Status | Source lines |
  |---|---|
  | CLEAN | 299,256 |
  | ANCHORED | 35,880 |
  | AMBIGUOUS | 6,552 (N-62) |

- **HICV H2 mapping** (seeder branch HICV, owner Q-04, Q-15):
  - Digit 3 Revenue, 4 Cost of Goods Sold, 5 Payroll, 9 UNCLASSIFIED.
  - Digits 7 and 8 take the first single-valued category that maps, in this order: the key's GL PL_SUB_CATEGORY_1, the account's GL sub-category, the key's DESC_PL_CATEGORY, the account's DESC_PL_CATEGORY.

  | Stated category | H2 |
  |---|---|
  | Club / Rental / Property Mgmt. / Retail & Resort Ops. Expense; General & Administrative; License Fee Expense; Cost Reimbursement; and the P&L's Sales and marketing, Retail and resort expense, Property management expense, General and administrative, Rental expense, Cost reimbursement, Club expense, License fees | Operating Expenses |
  | Non-Recurring Items, Financing Expense, Financing expense - mortgage servicing, Interest expense, (Losses) gains, Foreign currency translation adjustment | Other Income / (Expense) |
  | Depreciation and amortization | Depreciation & Amortization |
  | Income taxes | Income Taxes |
  | Provision for Loan Loss, Provision, Financing expense - provision | Revenue |
  | any revenue, HOA or Other category | falls through to the next source |

- **HICV pacing (D-51):**
  - VANTAGE = ACTUAL_SOURCE (CY / PY) or BUDGET. SEGMENT = SECTION.
  - The unit comes from the section or line text, and the Sales-tab lines with no stated unit are null (Q-23).
  - k = 2 for KPI and TREND, 1 for RESERVATIONS.
- **BEAUMIER:**
  - USALI and OPS_STATS are categorised BUDGET from the source table.
  - OPS keys: BUDGET_KEYS STOCK, the rest FLOW, unit null.
  - CLN_BEAUMIER_PACE_PRODUCTION_MONTHLY and CLN_BEAUMIER_REF_ACCOUNT_MAPPING are read by no procedure (table-usage.md).

## Stop-4 rules (build 23)
- HICV provision categories are contra-revenue: H1 Revenue (Q-21).
- BEAUMIER keys with no PL_SECTION take it from STG_BEAUMIER_HIERARCHY.PL_GROUP (Q-24).
- HICV Sales-tab units are filled down from each block header (Q-23; N-64 for the rows with none).

## HICV forecast: two versions in one table (close-out note)
- SEM_AI_INCOME_STATEMENT_FORECAST holds both HICV forecast measures, told apart only by SCENARIO. Both carry CATEGORY FORECAST, and the table has no other column that separates them.

  | SCENARIO | Source measure | Populated lines | SOURCE_AMOUNT | Months |
  |---|---|---|---|---|
  | FORENOV | FORECAST_AMOUNT (current forecast) | 28,474 | 332,580,595 | Nov - Dec 2026 |
  | FOREOCT | PREVIOUS_FORECAST_AMOUNT (prior forecast) | 170,844 | 1,782,677,832 | Jan - Dec 2026 |
  | FORECAST_AMOUNT / PREVIOUS_FORECAST_AMOUNT | the empty cells of each measure (Q-18) | 0 | null | - |

- **A forecast total must filter on SCENARIO.**
  - FORENOV and FOREOCT overlap on Nov and Dec 2026, so summing the lane's forecast table double-counts those months.
  - FORENOV covers only Nov - Dec 2026. A full-year 2026 view is FOREOCT, or the ACTUAL months plus FORENOV, chosen by the consumer and never summed across versions (D-17).
