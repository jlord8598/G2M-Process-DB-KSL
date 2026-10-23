# Classification coverage - build 05 (KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**The question: which accounts are classified, and correctly?**
- **Classification is unchanged from build 04:** same seeder branches,
  insert-only, existing rows hash identically (M4). Build 04's coverage
  analysis, keyword test and sign-anomaly test stand.
- **New keys:** 13 KSL and 40 PEREGRINE, all from the added day, seeded by the
  same rules (M4).
- **Keys now:** KSL 59,123 (34,903 unclassified on staged rows), PEREGRINE
  24,100 (12,850).

## `DEPARTMENT_NAME`: build 05 against build 04 (queries `01c7ecf1-020a-3b2d-0003-4ff21bc2ef4e`, `01c7ed11-020a-44e6-0003-4ff21bc3c826`, `01c7ed47-020a-3b2d-0003-4ff21bc40f06`)

The comparison is on this extract, over fact rows that carry a department
code.

| Lane | Rows with a department | Named, build 04's rule (one COA name per code) | Named, build 05 (`DEPARTMENTS.DEPARTMENT_GENERIC`, exact tenant + site + code) | Unnamed now |
|---|---|---|---|---|
| KSL | 3,231,579 | 64,431 (2.0%) | **3,171,699 (98.15%)** | 59,880 |
| PEREGRINE | 979,274 | 486,213 (49.7%) | **979,273 (100.00%)** | 1 |

- **Why the outlet is not used (owner, Q-03 (b)).** `LABOR`-sourced
  `DEPARTMENT_OUTLET` values are job titles (`Housekeeping-Room Attendant`,
  `Pequin-181. Server`); `COA`-sourced values equal the generic name.
- **Unnamed (Q-04).** KSL 58,748 rows are on malformed codes (build 04 Q-12);
  1,132 KSL rows and 1 PEREGRINE row are on well-formed codes absent at their
  site. By site in `M3.md`, by code in `open-questions.md` Q-06.
- **Classification rows** keep the `DEPARTMENT_NAME` stored at their first
  insert (insert-only). Only the 53 new keys carry build 05 names. Semantic
  rows carry the build 05 value.

## Owner attention in the master

Unchanged from build 04 (Q-14, Q-15), plus the unnamed well-formed codes
above.
