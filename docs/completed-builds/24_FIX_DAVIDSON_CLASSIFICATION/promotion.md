# Build 24 promotion (owner, 2026-11-16)

Build 24 rebuilds **DAVIDSON** (D-44) to fix its classification. The freeze held: 14 / 14 CLN_DAVIDSON tables were unchanged at every check, the last at 13:44.

- **A, monthly and budget detail:**
  - One-segment ACCOUNT strings take their natural account from segment 2 of their REF_ACCOUNTS alias (Q-01). 9xxx statistic-ledger aliases and strings with no alias stay Unclassified (Q-02, N-67).
  - 5990 goes to Expense / Operating Expenses. 6000, 7000, 7100-7400 and 7600 go to Below the Line / Other Income / (Expense) (Q-08). 7000 Management Fee: no category exists between GOP and EBITDA in the hierarchy or in any peer lane.
- **B, summary:**
  - The new D-48 rule: FIN_PL_MONTHLY beats FIN_PL_SUMMARY for every hotel-month, so every summary money line goes to UNKNOWN.
  - Classified summary lines carry DUPLICATE_DETAIL, per check 2(e); the subtotal flag marks the totals. This deviation from the Q-03 wording was accepted at stop 4.
  - Unclassified totals, roll-ups and repeats carry SOURCE_ROLLUP. All-capitals lines are subtotals (Q-04); total-named "| #n" lines are repeats (Q-05).
- **Re-seed:** 975 DAVIDSON keys (`scripts/reseed_build24.sql`): 363 six-segment keys at the Q-08 ledgers and 612 one-segment keys. Of the one-segment keys, 572 are newly classified and 40 have a changed seed note only.
- **Stop 4 approved:**
  - the D-48 entry in CLAUDE.md;
  - the merge expectation: 0 inserts and 976 updates, of which 936 change H1/H2, with 0 reviewed conflicts.

## Results reported by the owner (DEV1)
- **D-47 master merge:** DAVIDSON 0 inserted, 936 updated.
  - **Why 936, not 976:** the expected 976 counted every key whose seed differs from the master, including the 40 Q-02 one-segment strings. For those 40 the re-seed changed only SEED_SOURCE; their H1-H5 stay Unclassified.
  - The 936 updated keys are exactly the stop-4 count of keys changing H1/H2. They are the 975 re-seeded keys less those 40 (935), plus RINPKR / PNONO / PNONO-7300-XXXXX-XXXXX-TAXOT-XXXXX, which DEV1 had seeded that morning under the old 7300 rule.
- **CLN.UTIL.SPROC_PROMOTE:** 203 procedures, 16 classification-source swaps, 2 lanes with no classification.
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 18 lanes, 55 MAINs, 0 new keys.
- **DAVIDSON in DEV1:**
  - The income statement went from 449,376 to 431,604 lines.
  - UNKNOWN went from 466,128 to 483,900 lines.
  - The two moves are equal (17,772 lines), so the lane total is unchanged.
  - Both new figures equal this build's run C in DEV_G2M_AI (IS 431,604; UNKNOWN 483,900).
- **reconcile_DAVIDSON_DEV1:** 0 failures.

## Build figures (DEV_G2M_AI, after stop 4)
- **Keys:** 32,839 (32,424 existing keys reproduced, 0 dead, 415 new from the 11-16 reload).
- **Streams:** IS 431,604 (FIN_PL_MONTHLY 242,304; budget 189,300; summary 0), OM 133,260, UNKNOWN 483,900.
- **GOP tie-out against the summary:**

  | Category | Hotel-months | GOP ties | House Profit ties | Revenue ties |
  |---|---|---|---|---|
  | Actual | 150 | 104 | 104 | 139 |
  | Forecast | 47 | 33 | 33 | 43 |

- **Checks:**
  - parity 203/203;
  - check 2 all zero;
  - reconcile_DAVIDSON 27 checks, 0 failures;
  - check 5: the 17 other lanes, 332 objects, 0 differences; DAVIDSON identical between runs B and C;
  - check 6 passed twice.
- Detail: `findings/M6.md`.

## Open items
- **N-65:** GOP gaps in 46 actual and 14 forecast hotel-months.
- **N-66:** PINCEN Oct 2026, where monthly revenue is about 1.15M off the summary.
- **N-67:** the Q-02 strings left Unclassified.

All three are current in `docs/open-items.md` and none is in landed data.
