# Open questions - build 05 (rebuild of KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

Numbered within this build. Figures are from queries run on 2026-10-23
against `CLN.CLEAN`; detail is in `docs/sources.md`.

**Build 04's decisions carry over unchanged,** except the two this build
replaces:
- `DEPARTMENT_NAME` (build 04 Q-02);
- `SCENARIO` on rows whose source names none (D-45).

Build 04's still-open items, unchanged:
- **Q-02:** a department list. `CUR_PROFITSWORD_DEPARTMENTS` is the answer
  this build tests.
- **Q-14:** KSL monthly expense outliers, for the master.
- **Q-15:** `100-9036-000` `AMOUNT` keys, for the master.

## Raised at stop 1 (answered below)

| # | Lane | Question | Blocks | Proposal |
|---|---|---|---|---|
| Q-01 | both | **The source was reloaded after build 04.** All 26 tables build 04 used, plus the new `CUR_PROFITSWORD_DEPARTMENTS`, were last altered 2026-10-23 06:49:58-06:50:43 PDT, before this freeze began (08:23:25.583 PDT). The extract gained about one day: KSL daily 8,049,208 to 8,063,150, PEREGRINE monthly 589,229 to 593,686, and the ledger and labor tables also grew. Build 04's `last_altered` values therefore do not match; this build's are recorded in `sources.md`. | yes (stop 1) | Build on today's extract. The M4 key report will show the new keys as new data. |
| Q-02 | PEREGRINE | **New scenario `Budget 3`** (FCID 17, 4,369 monthly rows, 2027-01 to 2027-04). No build 04 category rule maps it, so it would route to UNKNOWN as `UNRESOLVED_CATEGORY`. | no | `CATEGORY = BUDGET`, scenario verbatim, by exact name in both lanes (as `Budget 2`). |
| Q-03 | both | **`DEPARTMENT_OUTLET` from `LABOR` often holds a labor position label, not an outlet.** Where `OUTLET_SOURCE = 'COA'` (KSL 1,484 rows, PEREGRINE 608), the outlet always equals `DEPARTMENT_GENERIC`. Where `OUTLET_SOURCE = 'LABOR'` (KSL 329, PEREGRINE 226), it always differs, and many values carry a position or a code: `Housekeeping-Room Attendant`, `Pequin-181. Server`, `Accounting & Finance-805`, `Laundry-Contract Laundry Attendant 1`. **167/181 is `3-Meal Restaurant`** in full; the "3" seen in DEV1 is that value cut at its hyphen. The instructed rule (outlet, else generic) puts these labels in `DEPARTMENT_NAME` on KSL 1,807,390 and PEREGRINE 859,921 fact rows. | **M3** | Your call: **(a)** as instructed, outlet then generic; **(b)** generic only, which names the same rows with the stated department; **(c)** outlet only where `OUTLET_SOURCE = 'COA'`, otherwise generic, which in this extract is identical to (b). |
| Q-04 | KSL | **Rows with no department match.** 284,617 KSL fact rows have a department code but no `DEPARTMENTS` row for (tenant, site, code): 225,393 at four sites absent from the table (`CAPLSOP`, `CASCHOP`, `MAFBWOP`, `CAPICOP`), and 59,224 on 79 codes absent at present sites (mostly the malformed codes of build 04 Q-12, plus `605` and `900`). PEREGRINE: 0. | no | Null `DEPARTMENT_NAME` (exact join, no fallback). Report. |
| Q-05 | both | **D-45 rule per model.** Monthly carries the source's `SCENARIO_NAME` (0 null). Daily, ledger and labor take the table name without schema. **No KSL/PEREGRINE model unpivots a measure column,** so the column-name rule applies to none. Pacing has no `SCENARIO` column and stays in its own shape. | no | As listed. |

## Answered at stop 1

| # | Owner's answer (stop 1) |
|---|---|
| Q-01 | Build on today's extract (reloaded 06:50 PDT, before the freeze). |
| Q-02 | `Budget 3` is `BUDGET`, scenario kept verbatim. |
| Q-03 | Option **(b)**: `DEPARTMENT_NAME = DEPARTMENT_GENERIC` on the exact tenant + site + department-code join. `DEPARTMENT_OUTLET` is not used, because `LABOR`-sourced outlets hold job titles (for example `Housekeeping-Room Attendant`, `Pequin-181. Server`), and `COA`-sourced outlets equal the generic name. |
| Q-04 | Rows still unmatched keep a null `DEPARTMENT_NAME`, reported by site and code. |
| Q-05 | D-45 approved as laid out: monthly = `SCENARIO_NAME`; daily, ledger and labor = table name without schema; no model uses a measure column name. |
| Freeze | Ends 2026-10-25 08:23 PDT. |
| `DEPARTMENTS` | The owner may have updated it (four KSL sites added). Re-measure uniqueness and per-lane coverage, record `last_altered`, report before and after; if uniqueness fails, stop. |

## Raised after stop 1: D-43 stop (answered below)

| # | Lane | Question | Blocks |
|---|---|---|---|
| Q-06 | both | **The whole source was recreated during the freeze, and `DEPARTMENTS` changed by more than the four sites.** See the details below. Please confirm the reload was intended, and that the reloaded `DEPARTMENTS` is the version to build on. On confirmation I take 09:14:32.938 as the new baseline for all 27 tables and proceed with M1-M3 as answered. | **yes** |

**Q-06 details.**
- **Every table was recreated.** All 27 `CLN.CLEAN` tables were last altered
  between 2026-10-23 **09:13:52.206** and **09:14:32.938** PDT, after the
  freeze began (08:23:25.583) (query `01c7ecf1-020a-3bc3-0003-4ff21bc3f11a`).
- **The other 26 kept their row counts exactly.** Their content cannot be
  proven unchanged: M1 recorded counts, not sums or hashes, and Time Travel is
  unavailable because the tables were recreated.
- **`DEPARTMENTS`, before and after:**

| | M1 (06:50:43) | Now (09:14:32.938) |
|---|---|---|
| Rows | 2,647 | **1,523** |
| Unique on (tenant, site, code) | yes, 2,647 keys | **yes, 1,523 keys**; no null key parts |
| KSL: rows / sites / codes | 1,813 / 37 / 49 | 1,147 / **41** / 47 |
| PEREGRINE: rows / sites / codes | 834 / 6 / 139 | **376** / 6 / **128** |
| The four KSL sites (`CAPLSOP`, `CASCHOP`, `MAFBWOP`, `CAPICOP`) | absent | **present, 98 rows** |
| Columns | 7 | 8 (**`OUTLET_SPELLINGS` added**) |
| Blank `DEPARTMENT_GENERIC` | 0 | 0 |

- **Coverage under rule (b)** (query `01c7ecf1-020a-3b2d-0003-4ff21bc2ef4e`):

| Lane | Table | Rows with a department | Matched at M1 | Matched now | Unmatched now |
|---|---|---|---|---|---|
| KSL | daily | 1,280,934 | 1,152,083 (89.94%) | 1,246,864 (97.34%) | 34,070 |
| KSL | monthly | 1,180,332 | 1,071,445 (90.77%) | 1,166,580 (98.83%) | 13,752 |
| KSL | ledger | 448,006 | 422,788 (94.37%) | 436,451 (97.42%) | 11,555 |
| KSL | labor | 322,307 | 300,646 (93.28%) | 321,804 (99.84%) | 503 |
| PEREGRINE | daily | 95,830 | 95,830 (100%) | 95,830 (100%) | 0 |
| PEREGRINE | monthly | 583,866 | 583,866 (100%) | 583,866 (100%) | 0 |
| PEREGRINE | ledger | 31,257 | 31,257 (100%) | 31,256 | **1** |
| PEREGRINE | labor | 268,321 | 268,321 (100%) | 268,321 (100%) | 0 |

- **Rows were removed, not only added.** PEREGRINE lost 458 rows and 11
  codes. KSL fell by 666 rows net; with 98 rows added at the four new
  sites, at least 764 KSL rows were removed. At least one combination
  that matched at M1 no longer does: PEREGRINE `CAYRDOP/616`, 1 ledger row.
  Some KSL well-formed codes are now unmatched at present sites (for
  example `291` at `167` and `MARBWOP`, 184 rows; `832` at `203`, 70 rows).
  Which of those matched at M1 cannot be established without the M1
  version.
- **Unmatched now, by site and code** (query
  `01c7ecf2-020a-3b2d-0003-4ff21bc2ef66`, 96 codes): KSL 59,880 rows,
  PEREGRINE 1.
  - Malformed codes (build 04 Q-12): 58,748 KSL rows, led by
    `xD0202` 10,472, `xD0101` 9,427 and `x10110` 7,346.
  - Well-formed codes, 1,132 KSL rows: `900` 456 (6 sites), `605` 209, `291` 184,
    `832` 70, `194` 44, `898` 41, `181` 36, `187` 22, `183` 20, `270` 12,
    and smaller ones; PEREGRINE `616` 1.
  - The full list is in the query output and goes into M3.

## Answered after stop 1

| # | Owner's answer |
|---|---|
| Q-06 | Confirmed by the source owner: the 09:14 reload is intended, and this `DEPARTMENTS` version is the one to build on. 09:14:32.938 is the new baseline for all 27 tables; counts, `last_altered` and fact sums are recorded in `sources.md`. |

## Status at stop 3

- **Q-04:** 59,880 KSL rows and 1 PEREGRINE row keep a null `DEPARTMENT_NAME`;
  by site in M3.md, by code in Q-06 above. Report only.
- **Carried for the master from build 04:** Q-14 and Q-15.

## Status at stop 4

- **Applied:** Q-02 (`Budget 3` -> BUDGET, 4,369 rows), Q-03 (b), Q-04
  (nulls reported), Q-05 (D-45), Q-06 (baseline 09:14).
- **Open for the owner:**

| # | Lane | Question | State |
|---|---|---|---|
| Q-07 | KSL, PEREGRINE | **Well-formed department codes absent from `DEPARTMENTS` at their site:** KSL 1,132 rows (`900` 456, `605` 209, `291` 184, `832` 70, ...) and PEREGRINE `CAYRDOP/616` (1). The source owner could add them. | null `DEPARTMENT_NAME`, as decided |
| Q-08 | HERSHA, HHG, NEWBURY | **D-45 not yet applied.** `SCENARIO` is null in SEMANTIC on HERSHA 106,350, HHG 91,300 and NEWBURY 46,087 rows. D-45 applies at each lane's next build. | report |
| Q-14, Q-15 | KSL | From build 04, for the master. | open |

## Answered at stop 4 (build 05 approved)

| # | Owner's answer (stop 4) |
|---|---|
| Q-07 | Goes to the source owner: well-formed department codes missing from `DEPARTMENTS` at their site (KSL 1,132 rows, PEREGRINE 1). No build change; `DEPARTMENT_NAME` stays null until the table lists them. |
| Q-08 | D-45 is applied to HERSHA, HHG and NEWBURY at their next rebuild. No change in this build. |
| Q-14, Q-15 | Stay open for the master; no build change. |

