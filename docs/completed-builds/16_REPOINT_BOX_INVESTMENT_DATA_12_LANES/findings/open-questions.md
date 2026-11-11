# Open questions - build 16

## Stop 1

**Q-01. SOURCE_TABLE values (blocking).** Every staging model stamps SOURCE_TABLE with its CLN table name, and 6 transformation procedures (24 literals) and the seeder (21) key on those names: category (e.g. HHG BUDGET_BY_CLUB -> BUDGET), the D-48 rules (HERSHA TB vs GL, JW PL_DEPT vs FCAST, HHG Anaplan / BEAUMIER BP latest file, UNDER_CANVAS CONSOLIDATED_PL), and the HHG seeder's COA routing. CLAUDE.md D-48 / D-49 / D-50 name the old tables 16 times. Options:
- (a) keep SOURCE_TABLE = the old name the row has always carried (a lineage label; downstream code, D-48 text and the master unchanged; semantic identical to the view run on every column);
- (b) stamp the new name: 45 downstream literals and the CLAUDE.md rule text change with it, and the semantic proof excludes SOURCE_TABLE.
Recommendation: (b) for traceability once the views are dropped, but it is a wider change than "repoint staging".

**Q-02. HERSHA filters vs invariant 1.** Rule 1 puts the views' WHERE in staging. JW and PIG filters only split a merged table between two models (nothing unread). The HERSHA filters leave rows unread: 3,056 budget-only rows (FIN_PL_MONTHLY) and 1,798 non-preferred forecast-stat rows (OPS_STATS_MONTHLY). None was in the old tables, so the output is unchanged; but a staging WHERE that excludes source rows is what invariant 1 forbids. Confirm the filters as an approved exception for this build (both sets logged as new source content for a later HERSHA build), or stage the full tables (changes HERSHA output: new budget rows; stat duplicates would need a D-48 rule).

**Answered (owner, stop 1):** Q-01 (b) with the merge-column rule (PIG: PACE_YEAR; STAY_YEAR_SCOPE does not exist). Q-02 approved as a one-build exception; N-36, N-37 logged.

**Stop 2 (owner):** approved, PACE_YEAR as PIG's merge column. MIN(source_table) tie-break logged (N-38), unchanged here.

## Q-03 (stop 3): rule 2 and "fill rates unchanged" conflict
The accounts tables now stamp new names in SOURCE_TABLE, so the 4 old join literals match 0 rows. Today's view run has ACCOUNT_DESC, DEPARTMENT_NAME and PARENT_CODE 0% filled in STG_HHG_BUDGET_BY_CLUB, STG_HHG_TR12_DATA, STG_DAVIDSON_FULL_YEAR_PL and STG_DAVIDSON_HOTEL_MONTHLY_REPORT. With rule 2's literals they fill (figures in M3.md). Rows, keys and classification inputs are unaffected.
- (a) Keep rule 2 (built): the descriptions return. The semantic proof at M6 then expects these three columns to differ from the view run, and only these.
- (b) Keep today's fill: leave the 4 literals as they are. This contradicts rule 2.

**Q-03 answer (owner):** (a). The intent was fill unchanged from before the rename: compare the four models' ACCOUNT_DESC, DEPARTMENT_NAME, PARENT_CODE fill with the build 15 (HHG) and last DAVIDSON baselines. At M6 only these three columns may differ from today's view run.

## Stop 4
- **Q-04. M3.md lost its main content.** It holds only the Q-03 (a) addendum; the staging memo was overwritten in the previous session and was never committed. The supporting files (`M3_proof.csv`, `check5_build16_M3.csv`) are intact, and M3's checks are re-evidenced at M6 (check 1, 3 and the view-run proof). Should I reconstruct the M3 memo from those files and live queries, or leave it as is with this note?
- **Q-05. CLAUDE.md D-48 / D-50 table names.** Proposed text: `claude-md-diff.md`. Approve, edit or reject.
- **Q-06. Expected master merge is 58 inserts, not 0 (M1 corrected).** DAVIDSON 57 and HHG 1, all first seen in this morning's pre-repoint view run: new source content. Confirm before promotion step 1.

**Stop 4 answers (owner):** approved.
- Q-06: confirmed; the 58 inserts (DAVIDSON 57, HHG 1) are new source data.
- Q-05: approved and applied to CLAUDE.md D-48 / D-50. JW rule: "for `ACTUAL`, `CLN_JW_VENICE_FIN_PL_DEPARTMENT` beats `CLN_JW_VENICE_FIN_PL_SUMMARY` for the `CLN_JW_VENICE_FIN_PL_DEPARTMENT` months (2025-08 and 2026-08)".
- Q-04: M3.md rebuilt (header states its sources).
- Combined DEV1 reconcile: `scripts/reconcile_ALL_DEV1.sql`, tested against DEV_G2M_AI: 278 metric rows, each equal to the per-lane outputs; TOTAL FAILURES 0.
