# Build 11 - promotion record (ALTERRA, ATLANTIC_AVIATION, JW_VENICE; new lanes)

Promotion is done by the owner, outside the build (CLAUDE.md section 7). The
results below are **as reported by the owner**. The build agent's role has no
access to DEV1 and could not verify them.

| Step | Result (owner) |
|---|---|
| D-47 guarded master merge | **2,675 inserted, 0 updated.** That equals the build's classification rows: ALTERRA 1,370 + ATLANTIC_AVIATION 1,149 + JW_VENICE 156. The master held 0 keys for these lanes (checked at stop 2 under the amended D-03). |
| `CLN.UTIL.SPROC_PROMOTE` | **128 procedures moved, 11 swaps.** That equals the 128 deployed in `DEV_G2M_AI` at M6. |
| `CLN.UTIL.SPROC_RUN_PIPELINE('DEV1')` | Ran clean: **11 lanes, 34 MAINs, 0 new keys.** |
| Reconcile in DEV1 | **0 failures**, ALTERRA, ATLANTIC_AVIATION and JW_VENICE. |

**State at promotion:**
- **Approvals:** stop 4 approved, including the process changes below.
  - **D-03 amended:** the build may read the master only to report the
    key-match rate and conflicts with reviewed rows; it never writes. Sections
    2, 7, 11 and D-47 are aligned with it. AGENTS.md line 44 matches.
  - **D-48:** the ALTERRA rule (resort Ski Butlers lines beat the Ski
    Butlers "Alterra Resorts" copy).
  - **D-13 / check 2(l):** the contra-line exception (Q-18; ALTERRA Revenue -
    Home Owners).
- **ALTERRA:**
  - Q-16 data test for Total lines; Q-17 contra sign.
  - EBITDA tie-out: every entity-month gap is the D-48 exclusion, the
    source's own GOP formula, the Q-07 OI/E lines (accepted, outside our
    EBITDA by design) or CMH Revenue - SG&A (N-14).
- **ATLANTIC_AVIATION:**
  - EBITDA tie-out 1,674 of 1,674 entity-months, to the cent.
  - Values carried as stored (N-13).
- **JW_VENICE:**
  - ACTUAL lacks departmental detail; MONTHLY_PL_DEPT is not landed (N-8).
  - CAPEX is out of scope (N-9).
- **Freeze (D-43):** clean at every stop through the final stop 4.

**Carried forward:** `docs/open-items.md`, N-8 to N-14 (with N-3 updated
after build 11 in commit `ba6ab41`).

**Commits:** the build, the CLAUDE.md and AGENTS.md changes and this archive
are committed together, in one commit.
