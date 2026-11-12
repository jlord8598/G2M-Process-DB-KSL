# Open questions - build 20

## Stop 1 / 2
- **Q-01.** CLN_DAVIDSON_REF_ACCOUNT_LOOKUP landed 11:07 today, after the build-19 baseline. Confirm a freeze (Gary) on it and the Davidson fact tables for this build.
- **Q-02.** The classification's ACCOUNT_DESC for existing Davidson keys stays null (insert-only merge). Accept, with semantic carrying the filled description; or do you want a D-44 re-seed of the attribute?
- **Q-03.** Fill by exact string only (8,878 AMOUNT + 756 STATISTIC keys), or also build descriptions from segment names for strings the lookup lacks (+576 keys)? Proposed: exact string only.
- **Q-04.** Labor type RESMN has two names (Restaurant Manager / zDNU - FB Department Manager); MIN picks one for 2 strings. Accept, or a rule?
- **Q-05.** Format: ledger | cost center | revenue category | sales item | spend category | labor type (M1 section 4). Approve, or prefer the lookup's ACCOUNT_NAME (varies across the 513 duplicate strings)?
- **Q-06.** N-49 stays partly open: 2,412 statistic keys (labor hours, utilities) and 1,591 amount keys have no lookup line. Update N-49 at close with what remains?

## Owner answers
- Q-01: freeze (Gary) to 22:00 MT covering the lookup and fact tables; baseline the 11:07 load.
- Q-02: no re-seed; semantic reads the staging fill (confirmed, M2).
- Q-03: also build from segment names, tagged SEGMENT_BUILT.
- Q-04: retired line last (RETIRED, DO NOT USE, zDNU), then first alphabetically; in the build rule.
- Q-05: format approved.
- Q-06: N-49 updated with what stays blank as "not in landed data".

