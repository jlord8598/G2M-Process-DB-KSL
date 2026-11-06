# Proposed CLAUDE.md change (build 14, for owner approval at stop 4)

Not applied: CLAUDE.md is the owner's to edit. The build already implements the rule; the text brings D-48 in line with it.

## D-48: UNDER_CANVAS rule (owner Q-04)

```diff
-... and the first 98xxxx hours block beats its repeat (`<code> \| <text> \| #n`). |
+... and the first 98xxxx hours block beats its repeat (`<code> \| <text> \| #n`). UNDER_CANVAS (build 14): the P&L detail (`CLN_UNDER_CANVAS_TOTAL_REVENUE`, `CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES`, `CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES`, `CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS`) beats `CLN_UNDER_CANVAS_CONSOLIDATED_PL` for every row; all 102 CONSOLIDATED_PL rows go to `UNKNOWN` as `DUPLICATE_DETAIL`, including its below-GOP lines (N-25). |
```

No other CLAUDE.md change in this build.
