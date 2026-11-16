# M6 - stop 4 decisions applied (build 23)

**Result: PASS.** Checks 2, 3 and 5 were rerun after the changes and pass. The 315 other-lane objects are unchanged. **Stopped for promotion.** This memo adds to `M6.md` and does not replace it.

## Changes

- **Q-20, CLAUDE.md register:**
  - D-48: HICV, the P&L beats the GL in every month it carries.
  - D-50: HICV FIN_PL_MONTHLY and FIN_GL_MONTHLY PROFIT, with the Interest On Senior Notes exception reported as booked (N-60); BEAUMIER FIN_BUDGET_MONTHLY_USALI PROFIT.
- **Q-21, seeder branch HICV:**
  - A provision category (H2 Revenue) on a digit 7 / 8 account now seeds H1 Revenue, as contra-revenue.
  - VALUE_SIGN stays +1, from Credit. The lane is PROFIT, so the booked negative already reduces revenue; no D-13 opposite-sign entry was added, because it would change no VALUE.
  - Re-seeded by `scripts/reseed_build23.sql`: **297 rows** (2 accounts), Below the Line / Revenue -> Revenue / Revenue. No sign or unit change.
- **Q-24, seeder branch BEAUMIER:**
  - A key with no stated PL_SECTION reads it from STG_BEAUMIER_HIERARCHY.PL_GROUP on LINE_ITEM (Revenue -> Total Operating Revenue, COGS, Payroll -> * Payroll Expenses, Expenses -> Other Expenses).
  - Below the Line comes from LEVEL_2 = Non-Operating Income and Expenses.
  - Keys with a stated PL_SECTION are untouched. A dry run of the new branch against every stored key differed on exactly these 3 keys and no others.
  - Re-seeded: **3 rows**.

  | Site | Line item | Hierarchy | H1 / H2 | Section / balance / sign |
  |---|---|---|---|---|
  | HLG | Branding | PL_GROUP Expenses; LEVEL_2 Total Undistributed Operating Expenses | Expense / Operating Expenses | Operating / Debit / -1 |
  | HVT | Affiliation/Representation | PL_GROUP Expenses; LEVEL_2 Total Undistributed Operating Expenses | Expense / Operating Expenses | Operating / Debit / -1 |
  | HPN | Room service Food | PL_GROUP Revenue; LEVEL_2 Total Operating Revenue | Revenue / Revenue | Gross Profit / Credit / +1 |

  Their 20 lines (-2,919.50) moved from SEM_AI_UNKNOWN to SEM_AI_INCOME_STATEMENT_BUDGET.

  | BEAUMIER | Before | After |
  |---|---|---|
  | IS | 60,726 | 60,746 |
  | UNKNOWN | 366 | 346 |
  | SEM budget lines | 24,416 | 24,436 |

- **Q-23, Sales-tab units:**
  - SPROC_XFRM_HICV adds BLOCK_HEADER to XFRM_HICV_PACING: the last header at or above each line, where a header follows a gap of two or more blank lines.
  - The block is unambiguous: one line item per LINE_ORDER in all 36 snapshot / window / vantage / period groups, and the same 5 headers on the tab (37 Close Rate, 66 Sales, 95 ASP ($'s), 124 Gross Volume ($000's), 153 VPG ($'s)).
  - The HICV lane block of SPROC_SEM_AI_PACING reads the unit from the block header on the Sales tab, and from the section or line elsewhere. On the other tabs the gaps separate sections whose first line states no unit, so they are not unit headers.

  **The proof: Sales-tab SEM_AI_PACING rows by unit after the fill-down.**

  | Block header | METRIC_UNIT | Rows |
  |---|---|---|
  | Close Rate | PERCENT | 1,490 |
  | ASP ($'s) | CURRENCY_PER_UNIT | 1,486 |
  | VPG ($'s) | CURRENCY_PER_UNIT | 1,490 |
  | Gross Volume ($000's) | CURRENCY_THOUSANDS | 1,656 |
  | Sales | null (states no unit) | 1,656 |
  | (above the first header) | null | 1,584 |
  | **Total** | | **9,362** |

  - Before, 4,358 TREND rows were unitless. Now 3,240 are, all logged as N-64.
  - HICV SEM_AI_PACING by unit:

    | Unit | Rows |
    |---|---|
    | COUNT | 3,658 |
    | CURRENCY | 1,176 |
    | CURRENCY_PER_UNIT | 3,456 |
    | CURRENCY_THOUSANDS | 1,740 |
    | PERCENT | 3,314 |
    | null | 3,240 |
    | **Total** | **16,584** (unchanged) |

- **Q-22:** no reclassification. Logged as N-63.

## Checks rerun

| Check | Result |
|---|---|
| 1 | XFRM = SEM: HICV 1,382,009 = 1,382,009; BEAUMIER 61,620 = 61,620 (IS 60,746 + OM 528 + UNKNOWN 346). Pacing unchanged (16,584 HICV rows). |
| 2 | XREF (a) (b) (d) (f) (k) (l) 0 for HICV (13,215 keys) and BEAUMIER (1,228). (c) 0 of 1,382,009 and 0 of 61,620. XFRM (e) (f) (h) and RECORD_TYPE / H1 0. SEM (g) (h) (i) (j) (k) 0. (m) 0. |
| 3 | `reconcile_HICV.sql` 0 failures; `reconcile_BEAUMIER.sql` 0 failures. |
| 4 | Parity 203 / 203 live MD5s, exit 0. Line endings: 960 files clean. Freeze: 18 / 18 unchanged at 11:38. |
| 5 | Harness run 1 at 11:22 and run 2 at 11:26. The 41 lane objects are identical across the runs (`check5_build23_stop4_lanes.csv`). Classification inserted 0 on both runs. XREF HICV hash -1018535922063883395, BEAUMIER 702262950109130012. The 1,181 pre-existing BEAUMIER keys still hash 8409854223578525169. **315 other-lane objects: 0 differences** against the M2 baseline (`check5_build23_stop4.csv`). |
| 6 | Unchanged since M6. The models changed here (SPROC_XFRM_HICV, the seeder, SPROC_SEM_AI_PACING) sit in the same call path that check 6 faulted. |

## Expected merge counts (D-47; master read-only, D-03)

| Lane | Snapshot keys | Insert (new to master) | Already in master | Update (unreviewed, seed changed) | Reviewed (listed only) | Reviewed conflicts |
|---|---|---|---|---|---|---|
| HICV | 13,215 | 13,215 | 0 | 0 | 0 | 0 |
| BEAUMIER | 1,228 | 47 | 1,181 | 0 | 0 | 0 |
| **Total** | **14,443** | **13,262** | **1,181** | **0** | **0** | **0** |

- The master holds 1,181 BEAUMIER keys, none reviewed, and every one identical to the snapshot.
- It holds 0 HICV keys, and 0 master keys are missing from the snapshot.
- The re-seeded keys (297 HICV, 3 BEAUMIER) are all inserts.

## For promotion (owner)

- **Code to promote:**
  - the 9 new staging models plus SPROC_STG_HICV_MAIN and SPROC_STG_BEAUMIER_MAIN;
  - SPROC_XREF_HICV_MAIN and the seeder;
  - SPROC_XFRM_HICV, SPROC_XFRM_HICV_MAIN and SPROC_XFRM_BEAUMIER;
  - the 7 SEM_AI models.
- **The classification CTE to point at the master:** SPROC_XFRM_HICV and SPROC_XFRM_BEAUMIER.
- **The merge:** `Claude outputs/MASTER_MERGE_D47.sql` for HICV and BEAUMIER.
- **Not done, by rule:** promotion, the merge, git and archiving.
