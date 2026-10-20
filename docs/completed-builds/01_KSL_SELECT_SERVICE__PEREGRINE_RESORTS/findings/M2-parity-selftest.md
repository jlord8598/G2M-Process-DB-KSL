# M2 addendum - parity self-test, per-fault evidence

Written after stop 3, before M4. M2.md recorded the six-fault self-test as a
single overall exit code with `PASS` per fault, which is pass by assertion.
This file supplies the per-fault evidence. M2.md is not modified.

## Method

- **Deployed side.** A live query run immediately before the test:
  `select procedure_schema||','||procedure_name||','||md5(procedure_definition)
  from DEV_G2M_AI.INFORMATION_SCHEMA.PROCEDURES` (query id
  `01c7d5f3-010a-2b08-0003-4ff21b82658a`). It returned 32 rows. They were
  written to a temporary CSV outside the repo and deleted after the test.
- **Each fault was staged by hand.** Each run was the real CLI,
  `python scripts/parity_check.py <sql_dir> <csv>`. The exit code is the
  process exit code (`$LASTEXITCODE`), not the `--self-test` summary, which
  reports only PASS/FAIL per fault.
- **Fixtures.**
  - The probe is `scripts/probes/SPROC_PROBE_FAULT.sql`, with `$$` body MD5
    `da4e5d333aaf9957378e91459f581da2`.
  - Each fault's CSV is a copy of the live CSV with one row appended.
  - Probe files were removed in a `finally` block.
- **Exit codes** (`parity_check.py`): 0 pass, 1 fault detected, 2 check
  broken.

## Results

| # | Fault | Setup | Expected | Actual exit | Output (the 32 `OK:` lines are omitted) |
|---|---|---|---|---|---|
| 1 | Clean baseline | live tree, live CSV | 0 | **0** | 32 `OK:` lines, no faults |
| 2 | Wrong hash | probe in `sql/staging/`; CSV row `STAGING,SPROC_PROBE_FAULT,deadbeef00000000deadbeef00000000` | 1, hash mismatch | **1** | `FAULT: hash mismatch on STAGING.SPROC_PROBE_FAULT (file=da4e5d333aaf9957378e91459f581da2, deployed=deadbeef00000000deadbeef00000000)` |
| 3 | Stray `.sql` deployed nowhere | probe in `sql/staging/`; live CSV | 1, stray file | **1** | `FAULT: stray file sql\staging\SPROC_PROBE_FAULT.sql - deployed nowhere` |
| 4 | Deployed object with no file | no probe; CSV row `STAGING,SPROC_PHANTOM_PROC,<probe md5>` | 1, no file | **1** | `FAULT: STAGING.SPROC_PHANTOM_PROC is deployed but has no file` |
| 5 | File in the wrong folder | probe in `sql/staging/`; CSV row `XREF_SNAPSHOT,SPROC_PROBE_FAULT,<probe md5>`, the correct hash under another schema | 1, folder fault, no hash fault | **1** | `FAULT: sql\staging\SPROC_PROBE_FAULT.sql is in folder staging/ (schema STAGING) but deployed in XREF_SNAPSHOT`. No `hash mismatch` line: **fails on folder, not hash.** |
| 6 | Recursion finds nothing | empty temporary tree holding the four layer folders; live CSV | 2, check broken | **2** | `BROKEN: no .sql files found under C:\Users\JoeLord\AppData\Local\Temp\g2m_empty` |

All six faults gave the expected exit code and the expected message. **PASS.**

## Tree clean afterwards

- Probe or phantom files remaining under `sql/`: **0**.
- `.sql` files under `sql/`: **32**, the same as the 32 deployed procedures.
- Clean baseline re-run after cleanup: exit **0**, 32 `OK:`.
- `python scripts/check_line_endings.py`: exit **0**,
  `OK: 42 file(s) scanned, all LF, all .sql ASCII`.
