# M3 re-run after the stop-3 answers, build 06

**Summary:** the Q-05 and Q-08 answers are applied to
`SPROC_STG_DAVIDSON_FULL_YEAR_PL`. No figure in `M3.md` moves. M4 is
**held**: Q-07 and Q-09 are with the source owner, and no classification
rows are written.

## D-43

- 12 tables, 0 changes (rows, `last_altered`, every sum) at 14:43:22 PDT
  (query `01c7ee37-020a-47a7-0003-4ff21bc9f226`), before the re-run.
- To be re-run again before M4 resumes (owner).

## What changed

Only `SPROC_STG_DAVIDSON_FULL_YEAR_PL` changed.

- **Q-05.** The key input `c_item` (`SOURCE_ITEM_ID`, and so `ACCOUNT_KEY`)
  is now `regexp_replace(trim(LINE_ITEM), ' {2,}', ' ')`, trim plus space
  collapse and nothing else. No line item on this extract contains repeated
  spaces (0 of 4,848, query `01c7ee36-020a-47a7-0003-4ff21bc9f1f2`), so every
  key still equals `LINE_ITEM`.
- **Q-08.** A new `SUBTOTAL_SOURCE` branch, `SUMMARY computed line (GOP /
  EBITDA): subtotal (owner Q-08)`:
  - it covers `Gross Operating Profit`, `EBITDA` and `EBITDA LESS
    REPLACEMENT RESERVE` on non-roll-up `SUMMARY` rows;
  - these were already `IS_SUBTOTAL` under the SUMMARY rule; only the stated
    reason changes;
  - on roll-up rows the roll-up reason still comes first;
  - these lines exist only on `SUMMARY`: the one `ALL_DEPARTMENT` "profit"
    line is `Post Street Ale House Profit`, 12 rows, not GOP;
  - `Total RevPar` is unchanged: a statistic, not a subtotal.

## Checks (query `01c7ee40-020a-47ae-0003-4ff21bca054a` and files below)

| Check | Result | Evidence |
|---|---|---|
| 1 | **PASS** | PL 474,312 = 237,156 x 2 |
| 3 | **PASS** | branch sums 8,260,056,979.34 / 2,241,894,573.66 = CLN |
| 4 | **PASS** | 99 of 99, exit 0; line endings clean |
| 5 | **PASS** | runs A = B on 43 objects (`check5_build06_hashes_M3r_A.csv`, `_B.csv`); earlier builds 108 of 108 equal the M2 baseline (`check5_earlier_hashes_M3r.csv`) |
| Profile | **unchanged** | `IS_SUBTOTAL` 185,880 staged rows (92,940 source), five-part keys 18,706, key = line text on every row. 1,080 staged rows (540 source) carry the new GOP/EBITDA reason. |

Against the M3 hashes, only `STG_DAVIDSON_FULL_YEAR_PL` differs (42 of 43
objects equal). The changed values were not snapshotted before the redeploy,
so the "only `SUBTOTAL_SOURCE` changed" claim rests on the profile figures
above, not on a before/after hash.

## Held

- **No XREF DDL, no seeder call.**
- **M4 resumes on the source owner's answers to Q-07 and Q-09**, after a
  fresh D-43 check.
