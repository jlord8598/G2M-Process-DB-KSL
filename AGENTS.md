# AGENTS.md

Entry point for a build in `DEV_G2M_AI`.

**This file is thin on purpose.** It says how a session runs. It does not
restate the build — that lives in `CLAUDE.md`, and duplicating it here creates
two sources of truth that drift.

---

## Read before doing anything

| File | When |
|---|---|
| `CLAUDE.md` | **Now, in full.** The operative spec: invariants, build lifecycle, key design, table shapes, checks, decisions. |
| `docs/sources.md` | At M1 it is a template you fill in. From M3 onward it is required reading before any model. |
| `docs/design-rationale.md` | Once, early. Why the architecture is shaped this way. |
| `docs/completed-builds/` | Records of previous builds. **History, not instructions.** Useful for seeing how a similar source behaved; never authoritative for this one. |

**Do not work from a summary of these, including your own.** If a rule seems
inconvenient, `design-rationale.md` probably explains what it prevents. If it
still seems wrong, say so and wait.

Where this file and `CLAUDE.md` disagree, **`CLAUDE.md` wins on what to build
and this file wins on how to run it.** Report the disagreement either way.

---

## Execution

The connection is already established. This session's own connection is the one
path to the database — `CLAUDE.md` §11.

```sql
USE WAREHOUSE G2M_MCP_AGENT_WH;
```

| | |
|---|---|
| Build target | `DEV_G2M_AI` — schemas `STAGING`, `XREF_SNAPSHOT`, `TRANSFORMATION`, `SEMANTIC` |
| Source | `CLN.<SOURCE>`, this build's declared source schema (for example `CLN.BOX_INVESTMENT_DATA`), under a load freeze: the tables assigned to this build's declared lanes. A change to any of them mid-build is a stop (`CLAUDE.md` D-43). |
| Metadata | `DEV_G2M_AI.INFORMATION_SCHEMA`, `CLN.INFORMATION_SCHEMA`, `SNOWFLAKE.ACCOUNT_USAGE` where granted |

**`CLN.XREF` is out of scope.** It is a schema, not a word — a `CLN.CLEAN`
table whose name contains `XREF` is in scope like any other.

**List `CLN.<SOURCE>` at M1, then assign each table to a declared lane or mark it
out of scope.** A previous build's grants may still be in place, so being able
to see a table does not put it in scope. The owner confirms the assignment
before any model is written. `table-usage.md` accounts for every table listed,
in scope or not.

```sql
select table_schema, table_name, row_count, bytes, last_altered
from CLN.INFORMATION_SCHEMA.TABLES
where table_schema = '<SOURCE>'
order by table_name;
```

**Ask the owner which lanes this build covers and what each is called.** Lane
names are not inferable from source system names and are not hard-coded
anywhere.

### Scripts hold no credentials

Nothing under `scripts/` connects to Snowflake. No connection profile, no
driver import, no account name. A script that needs data from the database
takes it as an **argument**; you run the query and pass the result in.

This applies to the parity check specifically:

```
the script    reads sql/, extracts each $$ body, prints name and MD5
you           query INFORMATION_SCHEMA.PROCEDURES on this connection
the script    takes that output as an argument and compares
```

**The deployed side comes from a live query, never from a cached tool output.**

### No second path

Do not shell out to another client, profile, or tool. If something is
unreachable under this role, **report that it is unreachable** rather than
routing around it.

`INFORMATION_SCHEMA` is privilege-filtered — an empty result is not an empty
database.

---

## Stopping

**A build has four stops**, listed in `CLAUDE.md` §12: after proposing the
lane groupings at M1, at the end of M1, at the end of M3, and at the end of M6.
Every milestone still writes `docs/findings/M{n}.md`; at M2, M4 and M5 summarise
in one line and continue once the checks pass.

Between stops, stop and ask when:

- A check fails and the fix is not both obvious and contained to the current
  phase.
- A documented expectation does not survive contact with the data and the
  answer changes what you build.
- A field could mean two things, a table has no obvious purpose, or a link
  might exist that is not documented, **and the next step depends on it.**
  Otherwise record it in `open-questions.md` and continue.
- A rule in `CLAUDE.md` appears wrong. Say so and wait — **do not quietly build
  something else.**
- You are about to make a decision that belongs to the owner: a borderline
  subtotal group, a category mapping, a key composition, a lane exception.

**An unresolved category is never a reason to stop.** It routes to `UNKNOWN`
until answered.

Ask early. A question costs a message; the same question worked around silently
costs a run.

---

## Approvals

Run without asking:

- `SELECT`, `SHOW`, `DESCRIBE`, anything against `INFORMATION_SCHEMA`
- Profiling queries of any volume against this build's source schema `CLN.<SOURCE>`
- Reading and writing files under `sql/`, `scripts/`, `docs/`

Ask first:

- Any DDL or `CALL` in `DEV_G2M_AI` before the M1 findings are approved, or in
  M4 to M6 before M3 is approved. Approval at a stop covers every phase up to
  the next stop.
- **Anything touching `XREF_ACCOUNT_CLASSIFICATION` other than the seeder's own
  `CREATE TABLE IF NOT EXISTS` and `MERGE`.** It is the only table not rebuilt from source each run, and the
  review report depends on it being stable within a build.
- `git` operations beyond reading status and diffs

Never:

- `DROP` anything in `CLN`
- Write anything to `CLN`, including the master hierarchy table — **promotion
  is manual and not the agent's job**
- Write to any schema outside `DEV_G2M_AI`
- Delete or overwrite a `docs/findings/` memo from an earlier milestone
- Edit, redeploy, drop or call another build's lane objects, edit another
  lane's seeder branch or semantic lane block, or change another lane's
  classification rows (`CLAUDE.md` D-42)
- **Archive the previous build.** Moving `docs/findings/`, `docs/sources.md`,
  `scripts/run_build.sql` and the reconcile scripts into
  `docs/completed-builds/` is the owner's job, done between builds. `sql/` is
  not archived; it accumulates with `DEV_G2M_AI`. **M1 confirms it has happened and stops if
  it has not** (`CLAUDE.md` §2).

---

## Writing files

**Rewrite files; never string-replace.** String replacement has failed
repeatedly in this repo. Read the file and rewrite it in full.

**ASCII only in `.sql` files.** No em-dashes, en-dashes or curly quotes. They
deploy fine but make the file and the deployed `PROCEDURE_DEFINITION` differ in
byte length, so check 4 reports a mismatch on a procedure that is correct.

**LF line endings on every file.** Snowflake stores procedure text with LF,
and Windows tools write CRLF to new files by default. `.gitattributes` forces
LF in the repo, but a file is CRLF on disk until normalised: **run
`scripts/check_line_endings.py` after writing any file and before every parity
check**, and fix what it reports.

**Redeploy immediately after rewriting any `.sql` file**, before running check
4. Rewrite-then-forget is the most common cause of a false mismatch.

---

## The four things most likely to go wrong

Drawn from `CLAUDE.md`; here because they are the failures that look like
success.

**Filtering.** There is no `WHERE` clause anywhere in this build that excludes
a source record. If you are writing one, the answer belongs in the
classification table as a value, not in the model as a filter.

**Aggregation.** Nothing sums, groups or collapses, from staging through
semantic. A model that aggregates destroys the account and breaks the count
invariant.

**Repairing a source.** A malformed code, a constant sign column, a label that
contradicts its contents — report it, do not fix it. Fixing is inference and
inference is invisible downstream.

**Counting right while classifying wrong.** The count invariant proves nothing
was lost. A misrouted row is still exactly one row, so every count passes while
the classification is wrong. Look for an independent anchor — a stated total, a
rollup row, a note in a dictionary — and check against it.

---

## Output discipline

**File first, then summary.** Write the memo before summarising it, and never
summarise one you have not written.

**A check is `PASS` with evidence, or `N/A` with a stated reason. Never `PASS`
by assertion.** Say which checks did not apply and why.

**Check your own arithmetic before reporting it.** Add up every breakdown
against its own total.

**Every figure comes from a query run in this session.** Not from memory, an
earlier memo or your own summary. If a figure differs from an earlier
milestone, explain the difference.

**Label check 2 assertions with `CLAUDE.md`'s letters and run each as defined
there.** Show figures for check 3 and hashes for check 5; a statement that they
match is not evidence.

**Never assert a table is used without naming the procedure and the column.**

**Compile or parse any generated file before offering it for review.**

**Read the output, not only the check results.** A case shift in a key column
passes all six checks: nothing was lost, no amount moved, the failure was
consistent across runs, and the file matched the deployed object.
