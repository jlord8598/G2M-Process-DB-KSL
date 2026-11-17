# Build 26 promotion (owner, 2026-11-17)

Build 26 adds two lanes from the new source schema **CLN.DATA_SHARE**, landed copies of a data share owned by G2M_SYSADMIN:
- **BECKONS:** luxury lodges in AU, NZ, CA and CL, plus Beckons corporate (Sydney, the management company). ACTUALS and BUDGET tables.
- **HAI_HOSPITALITY:** UCHI / LORO restaurants. One table with actual and budget columns.

The freeze was proved by last_altered plus HASH_AGG before every milestone (owner Q-01): 3 / 3 unchanged throughout.

## Rules
- **BECKONS measure:** the local base amount, with a per-lodge CURRENCY_CODE (AUD, NZD, CAD, USD); the AUD-converted figure is staged only (Q-02).
- **D-50 per table and entity (Q-03):** ACTUALS PROFIT, except location UNKNOWN DEBIT; BUDGET PROFIT, except ATA, PAT and SAN PRESENTED. HAI PRESENTED. The entry is in CLAUDE.md.
- **BECKONS classification:**
  - the iLevel mapping per key first, then the account range proven from account names for blank mappings (Q-08, Q-09, addendum A);
  - build rule: depreciation and amortisation by title go to Below the Line / Other Income / (Expense) on both charts, overriding the mapping (stop 4 and pre-promotion);
  - 1 key Unclassified: suspense 99999.
- **HAI classification:** HIERARCHY_LEVEL_1 as stated; AMOUNT_BUDGET is the BUDGET (Q-05); USD confirmed by market (Q-07).
- **Not eliminated:** Sydney's intercompany management fees (N-75) and the Chilean FX revaluation 7777777 (N-73) are logged.

## Results reported by the owner (DEV1)
- **D-47 master merge:** 9,092 inserted (BECKONS 4,342, HAI_HOSPITALITY 4,750), 0 updated. Equal to the stop-4 expectation.
- **CLN.UTIL.SPROC_PROMOTE:** 214 procedures (203 + 11 new), 18 classification-source swaps (16 + the 2 new lanes), 2 lanes with no classification.
- **Grant:** the pipeline role reads CLN.DATA_SHARE (58,556 Beckons actual lines). This equals CLN and this build's staging.
- **CLN.UTIL.SPROC_RUN_PIPELINE:** 20 lanes, 61 MAINs (55 + 6 new), 28 new keys (KSL_SELECT_SERVICE 21, PEREGRINE_RESORTS 7, daily). These come from those lanes' sources, not from this build; the new lanes added none, as expected after the merge.
- **reconcile_BECKONS_DEV1 and reconcile_HAI_HOSPITALITY_DEV1:** 0 failures each.

## Build figures (DEV_G2M_AI)
- **Lines:** BECKONS 127,033 (IS 126,237, OM 794, UNKNOWN 2); HAI 339,232 (all IS).
- **Checks:**
  - parity 214 / 214;
  - check 2 all 0; (m) N/A (no D-48 rule);
  - reconciles 0 failures;
  - check 5: 18 existing lanes, 356 objects, unchanged after every re-run; new lanes identical run to run;
  - check 6 passed twice.
- **Income statement by lane, currency and year:** findings/M6.md. Beckons figures are per currency, never summed across.

## Open items
- N-69 to N-76: current in docs/open-items.md. N-71 updated at stop 4 (only suspense 99999 remains unclassified); N-74 carries the stop-4 per-account measurement.
- N-77 (new, process): a lane reloaded by calling its MAINs directly skips the master insert, so its new keys land in UNKNOWN with a blank reason.
