# Sources - this build (18: labor as operating metrics)

Rebuilt lanes (D-44, owner): KSL_SELECT_SERVICE and PEREGRINE_RESORTS, labor only. Source schema CLN.CLEAN. Archived records read:
- build 13: the latest rebuild of both lanes; its key rule, and its Q-03 decision that labor stays in UNKNOWN;
- build 05: the labor department join;
- builds 09 / 11: B09-D4.

## Labor staging today (STG_<LANE>_DAILY_LABOR, staged 2026-11-04)
|  | KSL_SELECT_SERVICE | PEREGRINE_RESORTS |
|---|---|---|
| Rows | 787,419 | 354,052 |
| Business dates | 2024-01-01 .. 2026-11-02 | 2026-04-23 .. 2026-11-02 |
| Sites | 40 | 6 |
| Departments | 30 | 92 |
| Positions | 289 | 276 |
| Persons (PERSON_ID) | 4,640 | 3,744 |
| Labels | 2,433 | 3,631 |
| LABOR_TYPE values | 56 | 37 |
| Wages, sum of AMOUNTS (= SOURCE_AMOUNT) | 115,229,029.51 | 52,862,457.88 |
| Hours, sum of HOURS (= STAT_VALUE) | 4,973,408.28 | 1,989,648.28 |
| EFFECTIVE_RATE populated | 785,635 | 350,896 |

One row per site x business date x person x LABEL x LABOR_TYPE. LABEL = "<dept no>. <department>-<position>-<labor type>".
- SOURCE_AMOUNT = AMOUNTS and STAT_VALUE = HOURS on every row (0 differ). RECORD_TYPE AMOUNT on every row (build 13 assumption); STAT_UNIT_FAMILY null.
- EFFECTIVE_RATE = AMOUNTS / HOURS where HOURS <> 0 (0 rows off by more than 0.01): a rate, not additive.
- No FTE or headcount column.
- SOURCE_LINE_KEY is null on every labor row.
- Staged person identifiers: PERSON_ID, EMPLOYEE_ID, EMPLOYEE_NAME. No semantic table carries them today.

## Source state (CLN.CLEAN)
All 27 CUR_PROFITSWORD tables of both lanes were reloaded 2026-11-11 01:17, after staging. DAILY_LABOR now has KSL 793,934 and PEREGRINE 366,164 rows, against 787,419 / 354,052 staged.
