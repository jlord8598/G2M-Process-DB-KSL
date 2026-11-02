# Open questions - build 09

| # | Item | Question | Blocks |
|---|---|---|---|
| Q-01 | access | **Resolved:** SELECT on `CLN_INVITED_CLUBS_*` granted; freeze restarted at the first successful read (12:57:35.498). | - |
| Q-02 | 1 | **Indicated rule:** match on the member name prefix `Ind` (all 35 revenue members, about 31.9B), not on parent `Indicated*`, which catches 9 and misses 26 under `Ind-...` parents (9.31B)? Rule reads the **primary** META instance only (47 members are Indicated only through a shared copy, none with data)? | M4 seeder |
| Q-03 | 1 | **Shared copies:** drop `DUPLICATE_DETAIL` for shared instances? They produce no duplicate rows (line key unique, 17,296,157 of 17,296,157), and the rule would move 1,099 classified members (about 392B) to UNKNOWN. | M4 / M5 |
| Q-04 | 1 | **Calculated members:** `Adjusted Cash EBITDA` -> H1 Unclassified, SOURCE_ROLLUP (IS_SUBTOTAL already TRUE via REPORT_LEVEL). `Ind-Adjusted Cash EBITDA` and `Ind-Club Operating Profit` (stored, under Indicated Calculations) -> PLANNING_INPUT as Ind members, or SOURCE_ROLLUP as calculations? | M5 reason |
| Q-05 | 2 | **Plan entities:** treat as planning inputs? Seed H1 Unclassified for keys at the 8 Plan entities with data (225 keys), reason PLANNING_INPUT. Their 64 ACTUAL amounts net to 0.00; the rest is budget and forecast. | M4 / M5 |
| Q-06 | 3 | **Dues list:** route the expense dues members to OM via H1 `Statistic` (RECORD_TYPE stays AMOUNT; METRIC_UNIT `currency`, AGGREGATION_TYPE `FLOW` as stated by META; H2 = member name). Confirm: (a) `AMBase_*`, all 4 saved assumption: PLANNING_INPUT, not OM? (b) DMBase split: 3 expense -> OM, 5 saved assumption -> PLANNING_INPUT? (c) add `AALost_Golf` (2,936 cells, 598,762.00) to OM? | M4 seeder |
| Q-07 | 4 | **Ind- revenue:** item 4 holds only for expense. 35 revenue Ind members are in the P&L today. Under Q-02 they become PLANNING_INPUT / SOURCE_ROLLUP, which also moves `Ind-Total Revenue` and `Ind-Total Golf Revenue` out of the IS. That reverses build 08 Q-13. Approve? | M4 |
| Q-08 | 5 | **ACCOUNT_DESC:** no gain available (dictionary = ALIAS_DEFAULT; DESCRIPTION empty). Leave the code unchanged, and take the 38-member list (not in landed data) to the source owner? | M3 |
| Q-09 | - | Out of scope, noted: `*_Covers` members are META revenue; their DATA_TYPE was not checked here. Look at it in a later build? | no |
| Q-10 | - | **A62825 and other GL accounts at Plan entities** (budget 7,500,000.00) would also become PLANNING_INPUT under Q-05. They are named GL accounts posted to a planning entity. Confirm they follow the entity. | M4 |

## Answered by the owner (stop 1)

- **Q-02:** yes. Match on the `Ind` name prefix, primary instance only.
  The member list is in `M1.md`: 94 members, none a false match.
- **Q-03:** yes. No DUPLICATE_DETAIL for shared copies.
- **Q-04:** SOURCE_ROLLUP with IS_SUBTOTAL, as for Ind-Total in build 08.
  This covers Adjusted Cash EBITDA, Ind-Adjusted Cash EBITDA and Ind-Club
  Operating Profit.
- **Q-05, Q-10:** yes. The Plan entities are PLANNING_INPUT by entity rule,
  and GL accounts posted at them follow the entity.
- **Q-06:** route by META:
  - AMBase and the 5 saved-assumption DMBase members: PLANNING_INPUT;
  - the 3 expense DMBase members and AALost_Golf: dues roll-forward, in
    operating metrics.
- **Q-07:** yes. Build 08 Q-13 is reversed; all Ind revenue members leave
  the income statement.
- **Q-08:** yes. No code change; the not-in-landed-data list is kept.
- **Q-09:** a later build.

## Build decisions (this build)

- **B09-D1 (owner, Q-07):** every `Ind*` revenue member is H1 Unclassified
  and leaves the income statement. That includes `Ind-Total Revenue` and
  `Ind-Total Golf Revenue`, which build 08 Q-13 kept there as IS_SUBTOTAL.
  This reverses build 08 Q-13.
- **B09-D2 (owner, Q-03):** shared META instances are not duplicate detail.
  The line key is unique, and Essbase extracts a member's data once.
- **B09-D3 (owner, Q-06):** the dues roll-forward is routed to operating
  metrics by the classifier (H1 Statistic). RECORD_TYPE stays AMOUNT, so no
  key part changes.

| # | Item | Question | Blocks |
|---|---|---|---|
| Q-11 | 1 | **Anchor test failed:** Ind-Total Revenue is within 1% of the remaining A4 GL revenue in 551 of 970 ACTUAL entity-years (56.8%; 95% required). Aggregate is +4.3% (5,894,058,094.75 vs 5,649,438,582.37). There are 154 entity-years with no A4 GL; E01694 is the largest difference every year. Proceed with the removal anyway? Re-test against a wider GL definition (for example all remaining H1 Revenue, not only A4 codes)? Or change the rule? | M2 |
| Q-12 | 1 | **Non-A4 revenue left in ACTUAL** after the rules is 10.26B (182 members) against 5.65B of A4 GL. None of the 10 largest restates total A4 GL (0 entity-years within 1% each; they run at 4-43% of GL), so no rule is proposed. The largest are the base dues balances (`BegBase_*` / `EndBase_*`, 5.30B together for golf, social and tennis), Core Member Spend, time-of-day food, initiation fees and curve values. Owner: keep them as Revenue, route the base dues balances with the dues roll-forward (OM, as Q-06), or test them against specific GL accounts (which needs a member-to-account mapping the landed data does not state)? | M2 (owner's call) |

- **Q-11 (owner):** proceed with the removal. Aggregate Ind-Total Revenue is within 4.3% of A4 GL, so it restates the GL.
| Q-13 | B09-D4 | **AGGREGATION_TYPE for BegBase_* / EndBase_*:** the owner asked for `BALANCE`. META states `TIME_BALANCE flow` for every one of the 182 members (all 14 BegBase and 21 EndBase included), and CLAUDE.md allows `FLOW` / `STOCK` / `UNRATIFIED`, taken from the source where stated (D-30). Seed `FLOW` as stated, or `STOCK` by owner instruction (recorded as an override of the source)? | M4 seeder |

- **Q-12 (owner):** route all 182 non-A4 revenue members to operating metrics (B09-D4).
- **B09-D4 (owner, Q-12):** for INVITED_CLUBS, H2 Revenue holds only A4 GL accounts; every other revenue-tree member gets H1 Statistic, with RECORD_TYPE AMOUNT, METRIC_UNIT currency and AGGREGATION_TYPE from META (see Q-13).
| Q-14 | D-43 | **Source reloaded inside the freeze.** All 7 `CLN_INVITED_CLUBS_*` tables were recreated 2026-11-02 13:22-13:23 -0800 (freeze 12:57:35-17:57:35). Row counts are unchanged; ESSBASE_EXTRACT and ACCOUNTS differ in bytes. Options: (a) re-baseline at the reload and re-run the M1 measurements that the stop-1/2/Q-11/Q-12 decisions rest on; (b) the source owner confirms the content is identical, and M1 stands; (c) restart the build with a new freeze. Raise with the source owner. | M2 onward |

- **Q-13 (owner):** STOCK on `BegBase_*` / `EndBase_*` as an override of META `flow` (opening and closing balances are not summable over time). All other non-A4 members get FLOW from META.
- **Q-14 (owner):** (a) re-baseline at the reload with HASH_AGG(*) per table, re-checked at every stop. Freeze end unchanged. Every M1 figure re-ran identically (`M2.md`).
| Q-15 | staging | **Build 08 rows changed value in this extract.** Of 51,301,512 build 08 lines, all present today, 54,384 have a different SOURCE_AMOUNT, 6,677 a different STAT_VALUE, and 1 a different SCENARIO. Every key and attribute is identical. All are 2026: mostly ACTUAL Sep (38,178) and Oct (9,441, of which 8,637 null -> value); net +657.9M. Looks like month-end postings and forecast revisions after build 08's extract (unverified). Accept as new source data and proceed to M4? | M4 |

- **Q-15 (owner):** accepted as new source data; build 08 was extracted 2026-10-28.

## Notes for the source owner (not blocking)

- **N-1, future-period ACTUAL values changed.** 490 ACTUAL rows in Nov-Dec
  2026 changed value between build 08 and this extract (net -3,562,114.35).
  The 5 largest (query `01c82699-030a-6ed8-0003-4ff21c59a862`):

  | Entity | Account | Department | Period | Scenario | Build 08 | Now | Change |
  |---|---|---|---|---|---|---|---|
  | E00268 | PER_Wedding_CP_Curve_Value | D0220 | 2026-11 | Load | 2,734,050.00 | 39,700.00 | -2,694,350.00 |
  | E00763 | PER_Business_CP_Curve_Value | D0220 | 2026-12 | Load | 358,250.00 | 263,360.00 | -94,890.00 |
  | E00648 | PER_Business_CP_Curve_Value | D0220 | 2026-11 | Load | 212,113.00 | 156,312.50 | -55,800.50 |
  | E02889 | PER_Social_CP_Curve_Value | D0220 | 2026-12 | Load | 230,206.00 | 176,915.58 | -53,290.42 |
  | E00674 | PER_Social_CP_Curve_Value | D0220 | 2026-12 | Load | 138,496.00 | 89,828.75 | -48,667.25 |

  All five are private-event curve values (`PER_*_CP_Curve_Value`) at
  department D0220. These are B09-D4 members, routed to operating metrics,
  not GL.
- **N-2, ACCOUNTS not unique on entity + account.** 42,332 `ENTITY_CODE` +
  `ACCOUNT_CODE` pairs occur more than once in the rebuilt
  `CLN_INVITED_CLUBS_ACCOUNTS` (288,714 rows). Nothing in the build joins it
  today.
| Q-16 | B09-D4 | **36 A5 GL revenue accounts** (A50013 Consulting & Management fees 110.0M, A50615 Misc Income 42.4M, A50502/04/07/08 interest income, ...) are among the 182 "non-A4" members. They are booked GL, not KPI. Route them (a) H1 Revenue, (b) Below the Line / Other Income / (Expense) [recommended], or (c) Statistic as written? | M4 seeder |
| Q-17 | D-44 | **Re-seeding METRIC_UNIT / AGGREGATION_TYPE** on existing keys is outside D-44's column list (H1-H5, section, balance, sign, seed source). Amend D-44 and AGENTS.md to include them [recommended], or re-seed without them (existing keys get no currency / FLOW / STOCK)? | M4 re-seed |

- **Stop 4 (owner):** build approved, including the D-44 amendment to CLAUDE.md and AGENTS.md (METRIC_UNIT and AGGREGATION_TYPE are re-seedable). Not committed: the archive and commit follow the owner's DEV1 reconcile.
