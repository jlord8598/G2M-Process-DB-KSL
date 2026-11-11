# Open questions - build 18

## Stop 1
- **Q-01. Shape (blocking).** (A, recommended) One row per labor line: hours stated by STAT_UNIT_FAMILY 'HOURS', the key's METRIC_UNIT CURRENCY (D-29; no key moves). Or (B) two rows per line: METRIC_UNIT HOURS on 10,045 new STATISTIC keys. That is as asked, but the new keys come from a changed derivation, which D-44 makes a stop. No shape can give one key two units (check 2(d)).
- **Q-02. Restage and freeze (blocking).** Both shapes change the labor staging model, and CLN.CLEAN was reloaded today (labor 793,934 / 366,164). Approve:
  - restaging only the two DAILY_LABOR models, on today's extract;
  - a load freeze (window?) on CUR_PROFITSWORD_KSL_DAILY_LABOR, CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR and CUR_PROFITSWORD_DEPARTMENTS;
  - every other KSL / PEREGRINE staging table left as staged on 11-04.
- **Q-03. Line key and personal data.** The unique key (site | business date | PERSON_ID | LABEL | LABOR_TYPE) puts an employee identifier in SOURCE_LINE_KEY in semantic. Use it, or leave SOURCE_LINE_KEY null for labor (reconcile at table level)? EMPLOYEE_NAME / EMPLOYEE_ID stay in staging either way.
- **Q-04. H2 and AGGREGATION_TYPE.** H2 'DAILY_LABOR' (the source's name)? AGGREGATION_TYPE UNRATIFIED (source states none) or FLOW?

**Stop 1 answers (owner):** Q-01 (A). Q-02 restage labor only, freeze to 22:00 MT. Q-03 line key null, person data staging-only (checked), N-44 logged. Q-04 DAILY_LABOR, FLOW.

## Before promotion
- **Q-05.** Approve build 18 for promotion. Expected master merge: 61 inserts, and 10,046 labor-key classification updates where unreviewed (M4).
- **Q-06.** `run_build.sql` calls the two labor staging models directly (not the STG MAINs). In DEV1 the full STG MAINs will restage every KSL / PEREGRINE table from the 11-11 reload. That is expected there, but it moves non-labor figures in DEV1 relative to DEV_G2M_AI.
