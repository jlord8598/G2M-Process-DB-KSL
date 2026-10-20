# CLAUDE.md — DEV_G2M_AI

**Take every record in the granted source tables and land all of it at
source-line grain, where any record can be traced from source to
destination:** every fact record classified into the semantic detail layer,
every pacing record in its own transformation stream (pacing has no semantic
model, D-21).

This document describes a **repeatable process**, not a one-time build. It
names no company, no lane and no table count. Those are declared per build.

Two companion documents. **Read them; do not summarise from this file.**

| | |
|---|---|
| `docs/sources.md` | This build's lanes and what M1 measured about them. Written during M1, not before. |
| `docs/design-rationale.md` | Why the architecture is shaped this way. Read once; consult when a rule looks arbitrary. |

Records of previous builds are in `docs/completed-builds/`. They are history,
not instructions: useful for seeing how a similar source was handled, never
authoritative for this one.

---

## 1. Invariants

These hold every run of every build. A build that breaks one is wrong even if
it reconciles.

1. **No filtering.** No `WHERE` clause anywhere excludes a source record.
2. **No aggregation.** Source-line grain from staging through semantic.
3. **No repair.** Malformed codes, inverted signs and contradictory labels are
   reported, never fixed. Fixing is inference.
4. **No invention.** No surrogate keys, no fuzzy matching, no bucketing an
   unclassified account into a plausible neighbour. `Unclassified` is a value.
5. **Completeness is a count.** `COUNT(*)`, per lane, exact, at every boundary.
6. **The classification table is the only classifier.**
7. **Six tables in `SEMANTIC`**, and nothing else besides the procedures that
   build them. Drop every scratch object before a procedure returns.

---

## 2. What a build is

**One build covers one or two companies.** It runs in `DEV_G2M_AI`, is verified
against all six checks, and is then promoted out manually. **`DEV_G2M_AI`
accumulates:** each build adds its lanes' objects alongside every earlier
build's, and nothing is cleared.

```
the owner names the source schema CLN.<SOURCE>, clones it to CLN.<SOURCE>_BUILD
and grants this build's tables in the clone
  -> M1 to M6 in DEV_G2M_AI, reading only CLN.<SOURCE>_BUILD
  -> all six checks pass
  -> the owner approves
  -> the owner promotes the code (CLN.UTIL.SPROC_PROMOTE) and inserts
     this build's classifications into the master
  -> the repo is archived (below)
  -> this build's CLN.<SOURCE>_BUILD grants are revoked; its objects stay in DEV_G2M_AI
  -> next build
```

**Lanes are declared, never assumed.** A lane is one coherent source set that
gets its own staging and transformation models. The number of lanes, their
names and which tables belong to each are inputs to M1 — **ask the owner, do
not infer them.** A source system's own name is often not the lane name the
owner wants.

**Scope is the tables belonging to the declared lanes, not everything
visible.** A previous build's grants may not have been revoked, so the role can
see tables that have nothing to do with this build. M1 lists everything it can
see, then **assigns each table to a declared lane or marks it out of scope**,
and the owner confirms before any model is written. An out-of-scope table is
never staged and never profiled beyond identifying it.

**No count is fixed and none is reconciled against.** If the grants change
mid-build, that is a finding to report, not a check to fail.

**The source is one `CLN` schema, declared per build, and frozen for the whole
build.** The owner names it at the start (`CLN.CLEAN`, `CLN.BOX_INVESTMENT_DATA`,
...; called `CLN.<SOURCE>` here) and, before M1, takes a zero-copy clone,
`create or replace schema CLN.<SOURCE>_BUILD clone CLN.<SOURCE>;`, granting
this build's tables in it. M1 records the source schema in `docs/sources.md`.
**Throughout this document, the source `CLN.CLEAN` means that clone:** every
query and every procedure in the build reads `CLN.<SOURCE>_BUILD`, never the
live schema, so a reload mid-build cannot move a figure between milestones.
Write it exactly as `CLN.<SOURCE>_BUILD.` in code, `SOURCE_TABLE` literals
included: promotion rewrites `CLN.<SOURCE>_BUILD.` to `CLN.<SOURCE>.` in one
pass, so promoted code reads the live source. M1 records the clone's `created` time; if a table in it
changes after that, stop and tell the owner (D-43).

**Nothing is cleared between builds.** Every staging and transformation object
is lane-named, so a new build's tables and procedures sit beside earlier
builds' without collision. Three things are shared and grow by one piece per
lane: the classification table (rows keyed by `SOURCE_LANE`), the seeder (one
derivation branch per lane) and the six semantic models (one lane block each).
`SPROC_SEM_AI_MAIN` stays a `CREATE OR REPLACE` union of every lane's
transformation tables, earlier builds' included.

**A build changes only its own lanes.** It never edits, redeploys, drops or
calls another build's staging or transformation objects, never edits another
lane's seeder branch or semantic lane block, and never deletes or updates
another lane's classification rows. Earlier builds' `CLN.CLEAN` grants are
revoked, so their MAINs cannot run and are never called. Adding a branch to
the seeder and a block to each semantic model is the only change a build makes
to code that serves other lanes.

**The build's records are archived; its code is not.** Before a new build
starts, move into `docs/completed-builds/<build-name>/`:

- the whole of `docs/findings/`
- `docs/sources.md`
- `scripts/run_build.sql` and each `scripts/reconcile_{LANE}.sql`

**`sql/` stays.** It matches what is deployed in `DEV_G2M_AI`, every lane of
every build, and parity checks all of it. **What else stays** is what no build
changes: `scripts/parity_check.py`, `scripts/check_line_endings.py`,
`scripts/probes/SPROC_PROBE_FAULT.sql` (the parity self-test's probe, never
deployed), `.gitattributes`, and these documents. Each build writes its own
lanes' MAINs and models and its own `run_build.sql`, and adds its branches to
the seeder and its blocks to the six semantic models.

**The owner does the archive, not the agent.** It happens between builds, when
no build is running, and it is the one operation that moves a `docs/findings/`
memo — which `AGENTS.md` otherwise forbids touching. **M1 confirms it has
happened before doing anything else:** `docs/findings/` should be empty,
`docs/sources.md` a blank template, `scripts/` holding only `parity_check.py`,
`check_line_endings.py` and `probes/SPROC_PROBE_FAULT.sql`, every lane found
under `sql/` or as a `SOURCE_LANE` in `DEV_G2M_AI` recorded in
`docs/completed-builds/`, and a parity check of `sql/` against `DEV_G2M_AI`
clean. **If
`docs/completed-builds/` does not exist, this is the first build; say so and
continue.** **If anything else is still populated, stop and tell the owner** —
a half-archived repo produces a build that silently rebuilds someone else's
company.
**Leave the old records in place and a new `M1.md` would overwrite a memo
`AGENTS.md` forbids touching.**

**Lane names must be unique across every build, not just within one.** The
master accumulates rows keyed by lane, so two companies both declaring a lane
called `GL` collide there and neither can be separated afterwards. At M1, check
the proposed names against `docs/completed-builds/` and against the
`SOURCE_LANE` values already in `DEV_G2M_AI` (the classification table and the
six semantic tables), and tell the owner what you found. **Checking the master is the owner's job**, not yours — the pipeline
never reads it (§7, D-03). Do not build until the owner confirms the names are
free.

---

## 3. Architecture

```
CLN.CLEAN ──► STAGING ──► [seed] ──► TRANSFORMATION ──► SEMANTIC
                             │              ▲
                             └──────────────┘
              XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION
```

| Layer | Does | Reads |
|---|---|---|
| `STAGING` | Standardise. Types, dates, empty-string handling, unpivots, structural decomposition of account numbers. **Lossless.** Facts **and dictionaries** — anything the seed needs is staged. | `CLN.CLEAN` |
| *seed* | Extract every distinct classification key, propose a classification, insert keys not already present. | `STAGING` → writes `XREF_SNAPSHOT` |
| `TRANSFORMATION` | Join the classification, apply the sign, split into five streams. Lanes stay separate. | `STAGING` + `XREF_SNAPSHOT` |
| `SEMANTIC` | Union the lanes into six tables. Lanes converge here and only here. | `TRANSFORMATION` |

**Staging diverges by source. Transformation converges. Semantic is one place.**

Each source arrives in its own shape, so each gets its own staging model and no
two look alike. **Transformation is where that stops:** every lane produces the
same four `H1`-routed streams, with the same columns, at the same grain, under
the same rules. The fifth, `PACING`, keeps the lane's own columns (D-24). By the time anything reaches `SEMANTIC` the lanes are already comparable.

Adding a lane means staging models shaped like its source, one transformation
procedure shaped like everyone else's, and **six `UNION ALL` branches in
`SEMANTIC`.** If a new source seems to require a different semantic shape, that
is a signal the transformation layer has not finished its job.

**Reads flow downhill.** `SEMANTIC` never reads `CLN` or `XREF_SNAPSHOT`. **The
seed reads `STAGING` only** — which is why source dictionaries get staging
models alongside the facts.

**Staging carries the raw join keys through** — site code, department, account,
statistic account, `SOURCE_ITEM_ID`, the lane's line identifier, the record-type discriminator. A
key dropped in staging cannot be recovered downstream.

### Staging is lossless

No filters, no classification, no dropped rows, no aggregation. Duplicates are
kept, including duplicate lines within one file.

Source-to-staging reconciles in one of two forms, and **which form applies is
stated per model**:

| Source shape | Identity |
|---|---|
| Long | `count(source) = count(staged)` |
| Wide | `count(source) × columns unpivoted = count(staged)` |

The wide form is not `× 12` by default. Count the columns unpivoted and state
the number.

Splitting an account number into its segments is structural and belongs in
staging. Deciding what a segment means is a classification and does not.

**`RECORD_TYPE` is the one declared exception.** On a lane that states it in a
column, normalising two values is structural. On a lane that does not, deriving
it *is* a classification act — and it happens in staging anyway, because it is
a key part and the seed cannot resolve a key it has not been given. Derive it,
record the rule in `RECORD_TYPE_SOURCE`, and carry that column through to
semantic. It is the only classification staging performs.

### Five streams per lane

```
XFRM_{LANE}_INCOME_STATEMENT     H1 in Revenue, Expense, Below the Line,
                                    Allocations & Reserves
XFRM_{LANE}_BALANCE_SHEET        H1 = Balance Sheet
XFRM_{LANE}_OPERATING_METRICS    H1 = Statistic
XFRM_{LANE}_PACING               from the lane's pacing and pickup sources
XFRM_{LANE}_UNKNOWN              H1 = Unclassified, or the category does not
                                    resolve
```

**Four streams route on `H1`; pacing routes on its source.** A row from a
pacing or pickup table goes to `XFRM_{LANE}_PACING` whatever its account
classifies as, because it is a different kind of record rather than an
unclassified version of a normal one. Every other row routes on `H1`, with one
addition: **a row whose category does not resolve goes to unknown regardless of
`H1`.** Said as *category*, not *scenario* — what fails to resolve differs by
lane (§6).

**Pacing is not `UNKNOWN`.** `UNKNOWN` is a queue of records that should fit a
classified stream and could not, and the point of watching it is that it
shrinks. Pacing records would never leave, so putting them there buries the
signal.

**The five are mutually exclusive and exhaustive against staging, per lane.**

**Category and scenario are columns here**, not tables. The split into three
income statement tables happens once, in semantic.

### Pacing and pickup

**A pacing or pickup source measures the same period more than once**, from
different vantage points in time — a forward booking position as it stood last
week against how it stands today, and the movement between the two. That needs
an **as-of date distinct from the period it describes**, which no other stream
in this build carries.

**It stops at transformation.** There is no semantic model, because its grain
is not the one the six semantic tables share. It is built so the data is not
lost and so a consumer can reach it, not so it conforms.

**M1 establishes whether pacing is derivable at all**, for each table whose
name or content suggests it:

- Is there an as-of or snapshot date on the row, distinct from the period?
- If not, does each extract represent one snapshot, with the date in the table
  name or a load column — making `SOURCE_TABLE` the as-of?
- If neither, **the source holds only current values and pacing cannot be
  built from it.** Say so plainly; do not synthesise a snapshot date.

**Build the stream either way.** Where an as-of exists, carry it. Where it does
not, carry what is there and **state in the memo exactly what is missing and
what the source would need to supply** — an empty or partial table with a
stated reason is worth more than no table and no explanation.

**Its shape is whatever the source holds.** The stream keeps the lane's own
columns rather than conforming to the semantic common block. Record the shape
in `docs/sources.md`.

### One procedure per lane

All five tables for a lane are built by one procedure from one join. Separate
procedures joining independently can disagree — and a disagreement does not
break the count, because a misrouted row still lands in exactly one stream.

```
SPROC_XFRM_{LANE}              the lane's five tables
SPROC_XFRM_{LANE}_MAIN         the lane's orchestrator, builds nothing
```

**The procedure reads the classification in exactly one place**: a CTE marked
`-- CLASSIFICATION SOURCE: swap to the master at promotion`, selecting by name
only the columns the join needs. No other reference to the classification table
appears anywhere in the procedure. In the build it reads
`XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION` (D-03); at promotion the owner
points that one CTE at the master, a one-line change.

### Naming

| Object | Pattern |
|---|---|
| Per-source orchestrator | `SPROC_{STG\|XREF\|XFRM}_{LANE}_MAIN` |
| Semantic orchestrator | `SPROC_SEM_AI_MAIN`, one, shared by every lane |
| Seeder | `SPROC_XREF_ACCOUNT_CLASSIFICATION`, one for the environment, named for its table |
| Model procedure | `SPROC_{STG\|XFRM}_{SUBJECT}`, or `SPROC_SEM_AI_{SUBJECT}` in `SEMANTIC` |
| Staging table | `STG_{LANE}_{SUBJECT}`, dictionaries included |
| Transformation table | `XFRM_{LANE}_{STREAM}` |
| Semantic table | `SEM_AI_{SUBJECT}` |

**Semantic objects carry the `AI` infix** (`SEM_AI_*`, `SPROC_SEM_AI_*`) so they
read as the same objects in `DEV_G2M_AI` and in the promoted database, where
other semantic objects exist without it.

`{LANE}` is whatever the owner declared at M1. Streams are
`INCOME_STATEMENT`, `BALANCE_SHEET`, `OPERATING_METRICS`, `PACING`, `UNKNOWN`. No `_OLD`,
`_NEW`, `_BKUP`, no dated copies.

**A dictionary serving more than one lane is staged once per lane**, as
`STG_{LANE}_{SUBJECT}`, losslessly each time. Shared staging names would
collide across builds in an environment that accumulates (D-42). The existing
`STG_SHARED_CHART_OF_ACCOUNTS` belongs to the build that created it; no later
build reuses or redefines it.

### Orchestration: per-source MAINs, not a cascade

**Each lane gets its own MAIN in each per-source layer, and no MAIN calls
another.** Each can be called on its own, with no arguments. Run them in
sequence: STG, then XREF, then XFRM, then SEM.

| Schema | Orchestrator | Calls |
|---|---|---|
| `STAGING` | `SPROC_STG_{LANE}_MAIN` | every staging model for that lane |
| `XREF_SNAPSHOT` | `SPROC_XREF_{LANE}_MAIN` | the seeder with that lane (`P_LANE`), then the three review views |
| `TRANSFORMATION` | `SPROC_XFRM_{LANE}_MAIN` | `SPROC_XFRM_{LANE}` |
| `SEMANTIC` | `SPROC_SEM_AI_MAIN` | the six semantic models, which union every lane |

**Semantic is shared, not per-source.** The six semantic models are the one
place every source comes together, so they have one MAIN. Transformation is
where each lane is aligned to the semantic shape; semantic only unions.

**Every MAIN stamps its own `RUN_ID`** when it starts (timestamp-derived, e.g.
`RUN_20261015_143005_123`) and passes it to the procedures it calls. MAINs take
no parameters. Layers do not share a `RUN_ID` and nothing needs them to. A
shared staging model called by two lanes' MAINs is deterministic and rebuilds
identically.

**`scripts/run_build.sql` is a test harness, not part of the pipeline.** A
script under `scripts/`, never deployed, so parity never sees it. It calls this
build's lanes' MAINs and then `SPROC_SEM_AI_MAIN`, in sequence, and stops at the
first failure, so checks 5 and 6 can run the whole build in one step. It never
calls an earlier build's MAINs.

**Nothing catches exceptions.** Not the models, not the MAINs. A failure
propagates out of the MAIN unchanged, so whatever called it stops and the
error names its origin. Notification hooks belong to the promoted environment.

**Semantic models are built from marked lane blocks.** Each semantic model's
body is a `UNION ALL` of one block per lane:

```sql
-- BEGIN LANE <LANE>
select <the semantic columns, by name, in section 4 order>
from DEV_G2M_AI.TRANSFORMATION.XFRM_<LANE>_<STREAM>
-- END LANE <LANE>
```

**Each block is self-contained**: no CTE or alias shared with another lane's
block, columns listed by name, nothing outside the markers that the block
depends on. At promotion the owner lifts the block out and pastes it into the
master semantic model as one more `UNION ALL` branch.

**Only MAINs call models. A procedure not in a MAIN does not exist.**

### Procedure standards

`LANGUAGE SQL`, `EXECUTE AS OWNER`, `RETURNS VARCHAR`, `$$`-delimited.

Every table is `CREATE OR REPLACE TABLE ... AS SELECT`, **except
`XREF_ACCOUNT_CLASSIFICATION`**, which is `CREATE TABLE IF NOT EXISTS` followed
by `MERGE`. The seeder issues the `IF NOT EXISTS` every run — a `MERGE` with no
target fails, and the first run of a build is exactly that case.

House style: banner comments marking CTE sections, leading-comma columns,
`where 1=1`, lowercase SQL inside an uppercase procedure header.

**Write the file first, then execute that same text.** Compose the body once
and send the identical string to both. Retyping drops comment blocks and parity
then fails on a procedure whose logic is correct.

```
sql/staging/          staging models and each SPROC_STG_{LANE}_MAIN
sql/xref_snapshot/    the seeder and each SPROC_XREF_{LANE}_MAIN
sql/transformation/   the lane models and each SPROC_XFRM_{LANE}_MAIN
sql/semantic/         semantic models and SPROC_SEM_AI_MAIN
scripts/              parity_check.py and check_line_endings.py (permanent);
                      run_build.sql and reconcile_{LANE}.sql (per build)
.gitattributes        forces LF line endings (repo root)
scripts/probes/       fault-injection files, never deployed
docs/                 sources, rationale, findings
docs/findings/        this build's milestone memos and deliverables
docs/completed-builds/ records of previous builds; history, not instructions
```

Nothing else under `sql/`. The parity check walks that tree, so a stray `.sql`
is a failure.

---

## 4. The deliverable

**Six tables in `DEV_G2M_AI.SEMANTIC`, all at source-line grain, identical in
every build.** This shape does not change when a lane is added. If a new source
seems to require a different one, the transformation layer has not finished its
job.

```
SEM_AI_INCOME_STATEMENT_ACTUAL      SEM_AI_BALANCE_SHEET
SEM_AI_INCOME_STATEMENT_BUDGET      SEM_AI_OPERATING_METRICS
SEM_AI_INCOME_STATEMENT_FORECAST    SEM_AI_UNKNOWN
```

### One row per source line

**No aggregation anywhere.** Staging copies, transformation classifies and
signs, semantic unions the lanes. Nothing sums, groups or collapses.

That is what makes the completeness claim provable by counting:

```sql
-- per lane, every run, exact; fact staging only. Pacing staging rows
-- equal XFRM_{LANE}_PACING instead, which has no semantic table.
fact staging rows  =  SEM_AI_INCOME_STATEMENT_ACTUAL
              +  SEM_AI_INCOME_STATEMENT_BUDGET
              +  SEM_AI_INCOME_STATEMENT_FORECAST
              +  SEM_AI_BALANCE_SHEET
              +  SEM_AI_OPERATING_METRICS
              +  SEM_AI_UNKNOWN
```

### Common columns

Every semantic table carries these, in this order:

```sql
RUN_ID                   VARCHAR       -- timestamp-derived; the only run stamp
SOURCE_LANE              VARCHAR       -- as declared at M1
SOURCE_SITE_CODE         VARCHAR
ASSET_NAME               VARCHAR
DEPARTMENT               VARCHAR
DEPARTMENT_NAME          VARCHAR       -- null where the lane supplies no name
ACCOUNT_NUMBER           VARCHAR       -- raw, malformed included
STAT_ACCOUNT             VARCHAR       -- raw, where the lane has one
ACCOUNT_KEY              VARCHAR       -- the key part actually used
RECORD_TYPE              VARCHAR       -- AMOUNT | STATISTIC
RECORD_TYPE_SOURCE       VARCHAR       -- stated by the source, or the rule used
STAT_UNIT_FAMILY         VARCHAR       -- where the lane carries one (D-29)
ACCOUNT_DESC             VARCHAR
PERIOD_END               DATE
CATEGORY                 VARCHAR       -- ACTUAL | BUDGET | FORECAST
SCENARIO                 VARCHAR       -- verbatim, never flattened
H1, H2, H3, H4, H5       VARCHAR
P_L_SECTION              VARCHAR       -- fixed function of H2
NORMAL_BALANCE           VARCHAR       -- Debit | Credit | Mixed | null
IS_SUBTOTAL              BOOLEAN       -- the source's own total or rollup row
SUBTOTAL_SOURCE          VARCHAR       -- how it was identified, or that it cannot be
SOURCE_AMOUNT            FLOAT         -- as booked, sign included
STAT_VALUE               FLOAT         -- the statistic measure
SOURCE_LINE_KEY          VARCHAR       -- null where the lane has no natural key
SOURCE_TABLE             VARCHAR       -- which source table the row came from; never null
```

**`SOURCE_AMOUNT` and `STAT_VALUE` are the only two measures and are never
added together.** There is no separate metric value column.

**Five columns exist in both staging and the classification table, and semantic
takes the staging value.** `ASSET_NAME`, `DEPARTMENT_NAME`, `ACCOUNT_NUMBER`,
`STAT_ACCOUNT` and `ACCOUNT_DESC` are per-row facts here, showing what that
source line actually held. The classification table's copies are `MIN()`-picked
per key (§5) and exist only so a reviewer can read a row in the master — **never
join to them for a semantic value.** A row whose description differs from its
key's displayed description is not an error; it is the source varying.

**`SOURCE_AMOUNT` is carried as booked, sign included.** A source that books
expenses negative keeps those negatives. The build applies no sign of its own;
that is `VALUE`.

### Subtotals the source supplies

**A source may carry its own total lines** — a "Total Revenue" row, a regional
rollup, a grand total. They are records, so the no-filter rule keeps them
(D-25). Sum the table without accounting for them and every one is
double-counted.

**`IS_SUBTOTAL` marks them.** Set in staging, per row, default `FALSE`. A
subtotal is a property of the source line, not of the account, so it is a
staging column and not part of the classification.

**Identify them from what the source itself says** — a level or depth column, a
total flag, a description that is a section name rather than an account name, a
row whose site or department is a rollup value rather than a real one. **Record
the rule in `SUBTOTAL_SOURCE`** alongside it, the same way `RECORD_TYPE_SOURCE`
works. Where a lane supplies no way to tell, say so at M1 and leave the flag
`FALSE` on every row — an unmarked subtotal is a known gap, a wrongly marked
detail row is a silently missing figure.

**Verify the rule against the source where you can.** Compare a sample of
flagged rows with the sum of the detail they should total, and report the match
rate either way. A rule justified by structure alone is acceptable if you say
so; a rule you claim is verified must show the comparison.

**Borderline groups go to the owner.** Where a group of rows looks like a total
by one signal and like detail by another, list each group in
`open-questions.md` with sample identifiers, descriptions and row counts, say
how each reads, and let the owner decide. Do not pick a side and report it as
settled.

**Nothing is removed.** The flag exists so a consumer can exclude them, and so
`reconciliation.md` can state the detail total and the subtotal total
separately. The count invariant counts both.

**Computed measures are not records.** EBITDA, NOI, gross margin and the like
are sums over the hierarchy, not rows — gross profit is `P_L_SECTION = 'Gross
Profit'`, operating profit adds `Operating`, and so on. The build stores none
of them, which is what D-21 means by the detail supporting anything a consumer
needs.

**`SOURCE_TABLE` is never null** (check 2(i)), so duplication from overlapping
extracts is addressable rather than invisible.

### Per-table additions

Appended in the order shown, after the common block.

| Table | Adds, in order |
|---|---|
| The three income statement tables | `VALUE_SIGN NUMBER(2,0)`, `VALUE FLOAT` |
| `SEM_AI_BALANCE_SHEET` | `VALUE_SIGN NUMBER(2,0)`, `VALUE FLOAT` — both null unless someone signs balance sheet accounts. Carried for shape consistency; do not read them as a measure. |
| `SEM_AI_OPERATING_METRICS` | `METRIC_UNIT VARCHAR`, `AGGREGATION_TYPE VARCHAR` — and **no** `VALUE_SIGN` or `VALUE`. A count has no polarity. The measure is `STAT_VALUE` from the common block, except on a classifier override (§5), where an amount row lands here with `STAT_VALUE` null and its number in `SOURCE_AMOUNT`. |
| `SEM_AI_UNKNOWN` | `UNKNOWN_REASON VARCHAR` — `UNCLASSIFIED_ACCOUNT`, `UNRESOLVED_CATEGORY` or `BOTH` — then `UNRESOLVED_CATEGORY_VALUE VARCHAR`, `METRIC_UNIT VARCHAR`, `AGGREGATION_TYPE VARCHAR`, all nullable. |

**`CATEGORY` and `H1`–`H5` are null only where they genuinely did not resolve.**
In `SEM_AI_UNKNOWN` that means `CATEGORY` is null on an `UNRESOLVED_CATEGORY` or
`BOTH` row and **populated on an `UNCLASSIFIED_ACCOUNT` row**, whose category
resolved fine; `H1`–`H5` are the other way round. Nulling a column because of
the table it is in throws away work that was done.

### `SEM_AI_UNKNOWN`

**Every record that reached no classified stream, with a stated reason, and
carrying whatever did resolve.** It is a destination, not a failure.

Two independent causes. An unclassified account has a known category and no
destination. An unresolved category has a good account and no table to land in.
A row can have both. They are resolved by different people doing different
things, which is why `UNKNOWN_REASON` separates them.

**Within a build, this table is the measure of how much the source resisted
classification.** It is not comparable across builds — each one is a different
company with a different chart of accounts, so a larger unknown population says
nothing about whether the rules got worse.

### Invariants

**Six tables in `SEMANTIC`, and nothing else besides the procedures that
build them.** Drop every temporary table before a procedure returns; a `LOCAL TEMPORARY` table still occupies the schema
namespace while the session lasts.

**Every column typed, every column present.** A column that cannot be filled
for a lane is null of the right type, never absent.

**Never invent a key.** No surrogate ids, no hashing a name into an id, no
fuzzy matching. `Unclassified` is a value.

---

## 5. The classification table

`DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION`. Generated from this
build's source data, machine-proposed, and **not edited by anyone here.**

### What it is, and what it is not

**It is the pipeline's classification output.** Every distinct source
combination gets a row with a best-guess hierarchy derived from the source's
own structure. That is its whole job.

**Nobody edits it in `DEV_G2M_AI`.** `REVIEW_STATUS` is always `UNREVIEWED`
here. Human correction happens after promotion, in the master table (§7), and
**nothing flows back** — a later build seeds only its own lanes and never
reads the master.

**It persists across runs and across builds**, one set of rows per lane, which
is what keeps the review report stable. A build's seeder calls touch only its
own lanes' rows.

### The key — five parts, unique

```
SOURCE_LANE  |  SOURCE_SITE_CODE  |  DEPARTMENT  |  ACCOUNT_KEY  |  RECORD_TYPE
```

**Unique, with no wildcards, no inheritance and no precedence.** Every staged
row resolves to exactly one classification row.

**`ACCOUNT_KEY` is built in staging, not at join time:**

```sql
ACCOUNT_KEY = coalesce( nullif(trim(ACCOUNT_NUMBER), '')
                      , nullif(trim(STAT_ACCOUNT),   '')
                      , nullif(trim(SOURCE_ITEM_ID), '')
                      , '~BLANK~' )
```

`SOURCE_ITEM_ID` is the lane's own line-item identifier (an item tag, a pay
label), established per lane at M1 and recorded in `docs/sources.md`; null on a
lane that has none. It is a staging column only. The raw columns are all
carried through unchanged alongside the key. Falling back to the statistic
account or the item identifier is not invention — each is the source's own
identifier for rows that have no other. Without it, every blank-account row on a site and
department collapses to one key, and a measure split across many statistic
segments resolves to a single classification with a single unit.

**`RECORD_TYPE` is the lane's money-versus-statistic discriminator**,
normalised to `AMOUNT` or `STATISTIC` in staging (§3). **Check every new lane
for this trap:** a lane may carry the same account number as both an amount row
and a statistic row, distinguished only by a type column. Without `RECORD_TYPE`
in the key those two share one classification and one is permanently misrouted,
with nothing in the build able to detect it.

**`RECORD_TYPE` is what the source says; `H1` is what the classifier decides.**
Where they disagree, the classifier wins and the disagreement is reported.

**The measure follows the row, not the stream.** A row carries `SOURCE_AMOUNT`
and `STAT_VALUE` unchanged into whichever stream `H1` sends it. Neither is
corrected. Check 3 states its bridge per measure per table, so an override
shows as a stated shift rather than an unexplained gap.

**Every key part is sentinel-coalesced**,
`coalesce(nullif(trim(x),''),'~BLANK~')`, using the **identical expression at
seed time and at join time.** A null key part drops the row silently on a left
join: no error, no warning, and the count invariant breaks with nothing to
point at.

### The table

```sql
XREF_ACCOUNT_CLASSIFICATION
  SOURCE_LANE              VARCHAR       -- key
  SOURCE_SITE_CODE         VARCHAR       -- key
  DEPARTMENT               VARCHAR       -- key
  ACCOUNT_KEY              VARCHAR       -- key
  RECORD_TYPE              VARCHAR       -- key: AMOUNT | STATISTIC
  ASSET_NAME               VARCHAR       -- attribute
  DEPARTMENT_NAME          VARCHAR       -- attribute
  ACCOUNT_NUMBER           VARCHAR       -- attribute: the raw account, or null
  STAT_ACCOUNT             VARCHAR       -- attribute: the raw statistic account
  ACCOUNT_DESC             VARCHAR       -- attribute
  H1                       VARCHAR       -- routes the row; never null
  H2                       VARCHAR       -- Level 1, or unit family
  H3                       VARCHAR       -- Level 2
  H4, H5                   VARCHAR       -- reserved; UNCLASSIFIED
  P_L_SECTION              VARCHAR       -- fixed function of H2
  NORMAL_BALANCE           VARCHAR       -- Debit | Credit | Mixed | null
  VALUE_SIGN               NUMBER(2,0)   -- +1 | -1 | null; follows NORMAL_BALANCE
  METRIC_UNIT              VARCHAR       -- H1 = Statistic only
  AGGREGATION_TYPE         VARCHAR       -- H1 = Statistic only
  REVIEW_STATUS            VARCHAR       -- always UNREVIEWED here
  SEED_SOURCE              VARCHAR       -- how H1/H2 were derived
  FIRST_SEEN_RUN_ID        VARCHAR
  LAST_SEEN_RUN_ID         VARCHAR
```

**The attribute columns exist so a person can read the row.** `ACCOUNT_KEY` on
its own does not say whether a value is a real account number or the
`STAT_ACCOUNT` fallback, and a reviewer correcting the hierarchy in the master
needs to know which. Carrying the raw `ACCOUNT_NUMBER` and `STAT_ACCOUNT`
alongside it answers that at a glance.

**They are attributes, not key parts.** Names get re-spelled between extracts,
and a key that moves breaks the merge.

**Because they are not in the key they can differ across the source rows
sharing one key, so the pick must be deterministic: take `MIN()` of each
attribute in the extract step.** Not `ANY_VALUE`, and not "the row that created
the key" — every row of that key in the first run qualifies, so neither
identifies one row.

**Check 5 would not catch this**, because the insert-only merge freezes the
attributes after the first run and a second run inserts nothing. The risk is
one run further out: two clean builds of the same company, on the same extract,
showing different descriptions with nothing to explain the difference.

`MIN()` is arbitrary but stable, which is all that is needed.

They are for reading, never for joining.

### `H1` — the statement, and the router

| `H1` | Stream |
|---|---|
| `Revenue` | Income statement |
| `Expense` | Income statement |
| `Below the Line` | Income statement |
| `Allocations & Reserves` | Income statement |
| `Balance Sheet` | Balance sheet |
| `Statistic` | Operating metrics |
| `Unclassified` | Unknown |

The sign is not derived from `H1`. It follows `NORMAL_BALANCE`, below.

Seven values, exhaustive, never null.

### The standard hierarchy

**`H2` is Level 1 and `H3` is Level 2 of a standard chart of accounts.** The
vocabulary is fixed across every build so that lanes stay comparable; what
differs per lane is how a source account is mapped onto it.

| `H2` — Level 1 | `H3` — Level 2 | `P_L_SECTION` | `NORMAL_BALANCE` |
|---|---|---|---|
| Revenue | Product Revenue | Gross Profit | Credit |
| Revenue | Service Revenue | Gross Profit | Credit |
| Revenue | Other Revenue | Gross Profit | Credit |
| Revenue | Revenue Adjustments | Gross Profit | Credit |
| Cost of Goods Sold | Product COGS | Gross Profit | Debit |
| Cost of Goods Sold | Service COGS | Gross Profit | Debit |
| Cost of Goods Sold | Inventory Adjustments | Gross Profit | Debit |
| Payroll | Salaries & Wages | Operating | Debit |
| Payroll | Payroll Taxes | Operating | Debit |
| Payroll | Employee Benefits | Operating | Debit |
| Payroll | Other Personnel Costs | Operating | Debit |
| Operating Expenses | Facilities | Operating | Debit |
| Operating Expenses | Technology | Operating | Debit |
| Operating Expenses | Sales & Marketing | Operating | Debit |
| Operating Expenses | Professional Fees | Operating | Debit |
| Operating Expenses | Travel & Entertainment | Operating | Debit |
| Operating Expenses | General & Administrative | Operating | Debit |
| Depreciation & Amortization | Depreciation | Operating | Debit |
| Depreciation & Amortization | Amortization | Operating | Debit |
| Other Income / (Expense) | Interest | Non-Operating | Mixed |
| Other Income / (Expense) | Non-Operating Gains / (Losses) | Non-Operating | Mixed |
| Income Taxes | Income Tax Expense | Non-Operating | Debit |

**`P_L_SECTION` and `NORMAL_BALANCE` are a fixed function of `H2`** — never
guessed independently, never set per account. Check 2(k) asserts they agree
with the row's `H2`.

**Four `H1` values sit outside this table**, and their rows carry a null
`P_L_SECTION` and a null `NORMAL_BALANCE`:

| `H1` | `H2` | Why no section or balance |
|---|---|---|
| `Balance Sheet` | `Assets`, `Liabilities`, `Equity` | Not an income statement row. |
| `Statistic` | the unit family | Not money. |
| `Allocations & Reserves` | `UNCLASSIFIED` | A digit-9 range is a catch-all with no settled position or direction. These rows therefore sit on the awaiting-sign floor until someone classifies them. |
| `Unclassified` | `UNCLASSIFIED` | Nothing derived. |

**Check 2(k) tests only rows whose `H2` appears in the hierarchy table above.**
A null `P_L_SECTION` or `NORMAL_BALANCE` on one of the four is correct, not a
violation.

`H4` and `H5` are reserved and seed `UNCLASSIFIED`. They are filled in the
master, by people.

### Seeding the hierarchy from a section digit

Most financial sources number accounts on a conventional scheme. Where a lane
carries a section digit, this is the best guess it seeds:

| Digit | `H1` | `H2` |
|---|---|---|
| 1 | Balance Sheet | `Assets` |
| 2 | Balance Sheet | `Liabilities` |
| 3 | Balance Sheet | `Equity` |
| 4 | Revenue | `Revenue` |
| 5 | Expense | `Cost of Goods Sold` |
| 6 | Expense | `Payroll` |
| 7 | Expense | `Operating Expenses` |
| 8 | Below the Line | `Other Income / (Expense)` |
| 9 | Allocations & Reserves | `UNCLASSIFIED` |

**Which digit, and where it sits, is established per lane at M1** — it may be
the leading digit of a whole code, of a middle segment, or absent entirely.
Never carry one lane's position to another.

**The digit reaches Level 1 and no further.** `H3` is not derivable from a
digit and seeds `UNCLASSIFIED` unless the source supplies something better — a
dictionary that states a sub-category, or an account description that matches a
Level 2 name unambiguously. **Do not keyword-guess `H3` from loose description
matches;** a wrong Level 2 that looks settled is worse than an honest
`UNCLASSIFIED`.

**Two Level 1 values have no digit of their own.**
`Depreciation & Amortization` and `Income Taxes` usually sit inside a 7 or 8
range, so the digit alone cannot find them. Where a source dictionary or a
clear description identifies them, seed them; otherwise they arrive as
`Operating Expenses` or `Other Income / (Expense)` and get corrected in the
master. **Report how many accounts this affects** so the owner knows what is
waiting.

**Where a lane has no digit**, a source dictionary usually states a section in
words. Map its vocabulary onto `H1`/`H2` above at M1 and record the mapping in
`docs/sources.md`. A source section that mixes income and expense maps to
`Below the Line`, not to `Expense`.

**Unit families for statistics come out of M1 profiling per lane.**

**Label with what the source says, never with an invented name.** A statistic's
`H2` is the family name the source states; where it states none, use the
source's own code (for example `STAT_90`) and record the vocabulary in
`docs/sources.md`. A plausible English label for a code is invention, and it is
often wrong.

**`METRIC_UNIT` is a unit** (a count, hours, currency, a percentage), **not a
description.** Where the source does not state one, it is null. Report how many
`Statistic` keys have a null unit.

### `VALUE_SIGN` follows `NORMAL_BALANCE`

| `NORMAL_BALANCE` | `VALUE_SIGN` |
|---|---|
| `Credit` | `+1` |
| `Debit` | `-1` |
| `Mixed` | **null** |
| null — balance sheet, statistic, unclassified | **null** |

`Mixed` is the honest answer for `Other Income / (Expense)`, which holds
interest expense and gains together: no class-level sign is correct there, so
the amount publishes unsigned until someone decides per account.

**A null sign means the record carries `SOURCE_AMOUNT` and no `VALUE`.** It
appears in its stream, it is counted, and it contributes nothing to any total.
An unsigned amount is honest; a wrongly signed one is a wrong number that
reconciles.

**`METRIC_UNIT` and `AGGREGATION_TYPE` are per key, not per row.** That is
sound only if no key holds two units — **check 2(d) asserts it.**
`AGGREGATION_TYPE` is `FLOW`, `STOCK` or `UNRATIFIED`, seeded from the source
where the source states it, and `UNRATIFIED` only where nothing is known.
Defaulting to `FLOW` asserts a count can be summed across periods, which for a
stock multiplies it by the number of periods.

### Seeding

Four steps, in order, every run.

1. **Extract.** One row per distinct five-part key across the lane's fact
   staging tables, **every key part, `DEPARTMENT` included, through the full
   expression `coalesce(nullif(trim(x),''),'~BLANK~')`**, textually identical
   to the join. **Pacing tables never feed the seeder** (D-37). Attributes are
   picked with `MIN()`.
2. **Propose.** **`RECORD_TYPE = 'STATISTIC'` sets `H1 = 'Statistic'` before
   any section digit is read** — a statistic account's code may carry a digit
   that would otherwise seed a money section. Then derive `H1` and `H2` from the
   staged source, per the lane rules M1 established, then `P_L_SECTION` and
   `NORMAL_BALANCE` from `H2`. **`H3`
   only where the source states a sub-category outright** (D-11) — otherwise
   `UNCLASSIFIED`, and never from a loose description match. `H4` and `H5` are
   always `UNCLASSIFIED`. Where nothing derives, `H1` is `Unclassified` and
   `SEED_SOURCE` says so.
3. **Merge.** A key not present is inserted with its proposal and
   `REVIEW_STATUS = 'UNREVIEWED'`. A key already present has
   **`LAST_SEEN_RUN_ID` updated and nothing else touched.**
4. **Join and route.** Transformation left-joins on the five-part key, appends
   the classification, applies the sign, routes on `H1`.

**One seeder for the environment**, `SPROC_XREF_ACCOUNT_CLASSIFICATION(P_RUN_ID,
P_LANE)`, with one derivation branch per lane. Each build adds its lanes'
branches and leaves existing branches untouched. Each lane's XREF MAIN calls it
with its own lane, so a call seeds only that lane's keys.

**Classification derivation exists only in step 2**, once per new key. It never
runs on the row-level path. Category derivation is separate and necessarily
row-level (§6).

**A proposal competes with nothing.** The merge never touches an existing row,
so there is no precedence mechanism and none is to be built.

**Dead keys are not deleted.** Extracts vary. `LAST_SEEN_RUN_ID` makes a key
that stopped appearing visible.

### The review report

Three views in the `XREF_SNAPSHOT` schema — `VW_XREF_NEW_THIS_RUN`,
`VW_XREF_UNCLASSIFIED`, `VW_XREF_AWAITING_SIGN` — created with
`CREATE OR REPLACE VIEW` inside every `SPROC_XREF_{LANE}_MAIN`, with identical
text, every run. Not standalone
files under `sql/`: parity walks that tree and a `.sql` with no matching
procedure reports as a stray file.

| View | Definition |
|---|---|
| **New this run** | `FIRST_SEEN_RUN_ID` = that lane's latest `LAST_SEEN_RUN_ID` (`RUN_ID` is a fixed-format timestamp, so the maximum is the latest). Per lane, so one lane's run never hides another's new keys, and the view text needs no parameter. |
| **Unclassified** | not new, `H1 = 'Unclassified'` |
| **Awaiting sign** | not new, not unclassified, `VALUE_SIGN` null, `H1` in `Below the Line`, `Allocations & Reserves`, `Balance Sheet` |

**This is a report, not a worklist.** It says what the pipeline could not
classify, so the owner knows what will need attention in the master after
promotion. Nobody acts on it inside `DEV_G2M_AI`.

**Report each list per lane, by count and by amount, sorted by amount.** Neither
number alone is honest — a lane can have many small misses or few large ones.
Say where the tail was cut.

**Awaiting sign has a permanent floor.** Those three `H1` values seed null by
design. Report it as a floor.

Plus a fourth, from a different mechanism: **values awaiting a category** (§6),
grouped by the unresolved value itself.

---

## 6. Category and scenario

**No lane has a category column.** It is derived per lane, row by row, in
**`SPROC_XFRM_{LANE}`** — the transformation model, never the staging one.

Where category comes from differs by lane and is established at M1. Common
shapes: a scenario name on the fact row matched by keyword; a measure or type
column; or the source table the row came from, carried through staging as
`SOURCE_TABLE`.

**Every lane can fail to resolve a category.** A keyword rule will not claim a
scenario name nobody anticipated; a new extract may arrive with a table name
that is not in the mapping.

**An unresolved category sends the whole row to `UNKNOWN`** with `CATEGORY`
null, `UNKNOWN_REASON = 'UNRESOLVED_CATEGORY'`, and
`UNRESOLVED_CATEGORY_VALUE` carrying whatever did not resolve. Not to the income
statement with a null category, which would put a fourth value in a three-table
split.

**`UNRESOLVED_CATEGORY_VALUE` is what makes the report work across lanes.** A
list named after one lane's mechanism misses the others; grouping by the
unresolved value describes all of them.

**An unresolved category never blocks the build.** Ask the owner about a value
you cannot map, record it in `open-questions.md`, and carry on: until answered,
it routes to `UNKNOWN` as above. That is the design working, not a gap.

**A status or state column is an attribute, not a category signal**, unless the
owner says otherwise. A posted/pending flag, a batch status, an export state:
carry it verbatim in staging, where `SOURCE_LINE_KEY` reaches it, and do not
route on it.

**Never flatten a scenario into its category and never merge two named
scenarios.** A lane may carry several budgets or several forecasts. Category
chooses the table; scenario is carried so a consumer can filter to one.

---

## 7. Promotion and the master table

**`CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`** accumulates account classifications
across every company, and is where people correct and complete the hierarchy.

**It carries the full five-part key** — lane, site, department, account key and
record type — matching the build's classification table exactly, so a row
inserted from a build lands at the same grain it was produced at.

**Its columns are every column of `XREF_ACCOUNT_CLASSIFICATION` (§5), same
names, plus five for review and promotion.** A transformation procedure reads
the master by name once promoted, so a classification column missing here
breaks it.

```sql
KSL_MASTER_ACCOUNT_HIERARCHY
  SOURCE_LANE, SOURCE_SITE_CODE, DEPARTMENT, ACCOUNT_KEY, RECORD_TYPE   -- key
  ASSET_NAME, DEPARTMENT_NAME, ACCOUNT_NUMBER, STAT_ACCOUNT, ACCOUNT_DESC
  H1, H2, H3, H4, H5, P_L_SECTION, NORMAL_BALANCE, VALUE_SIGN
  METRIC_UNIT, AGGREGATION_TYPE, REVIEW_STATUS, SEED_SOURCE
  FIRST_SEEN_RUN_ID, LAST_SEEN_RUN_ID
  REVIEWED_BY           VARCHAR         -- review: who corrected the row
  REVIEWED_AT           TIMESTAMP_LTZ   -- review: when
  PROMOTED_FROM_RUN_ID  VARCHAR         -- promotion: the run the key came from
  PROMOTED_AT           TIMESTAMP_LTZ   -- promotion: when it was inserted
  LAST_UPDATED_AT       TIMESTAMP_LTZ   -- any change to the row
```

A change to the classification table's columns is a change to the master's
too, made by the owner before the next promotion.

**Promotion is manual and one-way.** The owner moves the code to its permanent
home and inserts this build's classifications into the master. **The build
environment never reads or writes that table.** `CLN.XREF` is otherwise out of
scope entirely (D-03) — no legacy lookup in that schema is consulted.

**What promotion moves, and how:**

| Built here | At promotion |
|---|---|
| Staging models and `SPROC_STG_{LANE}_MAIN` | Moved whole; `CLN.<SOURCE>_BUILD.` becomes `CLN.<SOURCE>.`. |
| `SPROC_XFRM_{LANE}` and `SPROC_XFRM_{LANE}_MAIN` | Moved whole; the one marked classification CTE is pointed at the master. |
| `SPROC_SEM_AI_*` | Moved whole. They union every lane of this process, and `SEM_AI_*` in the target holds nothing else. |
| The seeder and `SPROC_XREF_{LANE}_MAIN` | Moved whole; each promoted environment seeds its own snapshot. |
| `XREF_ACCOUNT_CLASSIFICATION` rows | Inserted into the master by the owner at the build's first promotion, checking for existing keys (Snowflake does not enforce the master's primary key). After that, `CLN.UTIL.SPROC_RUN_PIPELINE` inserts each run's new keys itself. |
| `scripts/run_build.sql` | Build tool; not promoted. A promoted environment runs through `CLN.UTIL.SPROC_RUN_PIPELINE`. |

`CLN.UTIL.SPROC_PROMOTE(FROM, TO, DRY_RUN)` does every code move above, along
the allowed paths only. Neither utility is part of a build, and the agent
never calls either.

**The master is a worklist, not verified truth.** Everything the pipeline sends
it is a machine-derived best guess. Its value is that every combination is
present with a reasonable starting point and the source's own values visible
alongside, so a person can correct in bulk.

---

## 8. Traps

The general ones. This build's lane-specific findings go in `docs/sources.md`
as M1 measures them.

| | |
|---|---|
| `REGEXP_LIKE` matches the whole string | `regexp_like('4004','^[0-9]')` is false. Use `try_to_number(substr(x,1,1))`. |
| `UNPIVOT` drops NULL cells | Always `INCLUDE NULLS`, or a wide source loses its empty months. |
| `UNPIVOT` consumes the source alias | After the clause the alias is the unpivot's, not the table's. Wrap it in a CTE and select from that. |
| `COUNT(DISTINCT a,b,c)` skips rows where any expression is null | Concatenate with `COALESCE`. |
| A nullable join key drops rows silently | Hence the sentinel, at seed and at join, identically. |
| The section digit sits in a different position per lane | Leading digit of a whole code, of a middle segment, or absent entirely with a dictionary stating it. **Establish it per lane; never carry one lane's rule to another.** |
| Labels contain the delimiter | Split on the **first** occurrence, and verify the split round-trips on every row. |
| Missing values may be empty strings, not nulls | `NULLIF(TRIM(col),'')` on every text column, and verify it happened. |
| Two columns on one row may use different conventions | Read a statistic segment from the statistic column, never the account column. |
| Malformed codes carry real data | Report, never repair. Stripping a prefix to recover a digit is inference. |
| Statistics sit **inside** the money sections | The section digit does not identify them. `RECORD_TYPE` does. |
| A sign column in a source dictionary may be constant | Sign comes from `NORMAL_BALANCE` (§5), not from the source. |
| A source dictionary may not be unique on its own key | Deduplicate on the join or the uniqueness guarantee is gone. |
| `INFORMATION_SCHEMA` is privilege-filtered | An empty result is not an empty database. |
| Non-ASCII in a procedure body | An em-dash is 3 UTF-8 bytes against 1 for a hyphen, so the file and the deployed definition differ in length and check 4 reports a mismatch on a correct procedure. ASCII only. |
| CRLF line endings | Snowflake stores procedure text with LF. Same failure, and Windows tools write CRLF to new files by default. `.gitattributes` forces LF in the repo; **run `scripts/check_line_endings.py` after writing any file and before every parity check**, because a file is CRLF on disk until it is normalised. |
| Comparing a partial period with a full one | A daily or transaction feed covering part of a month cannot be checked against a monthly total; a mismatch proves nothing. Compare only complete periods, or record the comparison as undetermined. |
| A code column in a non-financial table is not an account | A pacing or booking table's `ACCOUNT_CODE` is usually a client, CRM or rate code. Never map it to `ACCOUNT_NUMBER`; test it against the GL format first. |

---

## 9. Checks

Six. Each runs as soon as it has something to run against, and every run.

**A check is `PASS` with evidence, or `N/A` with a stated reason. Never `PASS`
by assertion.** Say which did not apply and why.

### 1. Completeness, by count

**Per lane, exact, at every boundary.**

```sql
-- source to staging: long sources
count(source) = count(STG)
-- source to staging: wide sources
count(source) × <columns unpivoted> = count(STG)

-- staging to transformation, the partition
count(STG) = count(XFRM_IS) + count(XFRM_BS) + count(XFRM_METRICS)
           + count(XFRM_PACING) + count(XFRM_UNKNOWN)

-- transformation to semantic
count(XFRM, four streams excluding PACING) = count(SEM, six tables)
--   the income statement stream fans out to three tables by category;
--   the other three map one to one; PACING has no semantic model and is
--   excluded from this identity but not from the partition above
```

**`COUNT(*)`, never `SUM()`.** A zero-amount row leaves a total unmoved and
there are thousands of those; a sum matching while a count does not is a lost
population hiding behind arithmetic.

**Every identity is grouped by `SOURCE_LANE`.** Two lanes wrong in opposite
directions net to zero and pass.

### 2. Classification integrity

Every one must return zero. **The object column matters:**

| | Assertion | Runs against |
|---|---|---|
| a | The five-part key is unique | `XREF_SNAPSHOT` |
| b | No null `H1`, no null key part | `XREF_SNAPSHOT` |
| c | No staged row fails to find a classification | `STAGING` joined to `XREF_SNAPSHOT` |
| d | No key carries more than one `METRIC_UNIT`, or more than one `AGGREGATION_TYPE` | `XREF_SNAPSHOT` |
| e | No row in a stream whose `H1` does not route there | the four `H1`-routed `XFRM` streams; `PACING` is exempt, it routes on source |
| f | No row with `H1 = 'Statistic'` and a non-null `VALUE_SIGN` | `XREF_SNAPSHOT` and `XFRM` |
| g | No row in `SEM_AI_INCOME_STATEMENT_<CAT>` whose `CATEGORY <> '<CAT>'` | `SEMANTIC` |
| h | No row where `SOURCE_AMOUNT` and `VALUE_SIGN` are **both** non-null and `VALUE` is null or differs from the product beyond `0.005`; and none where `VALUE` is non-null while `VALUE_SIGN` is null | `SEMANTIC` |
| i | No row with a null `SOURCE_TABLE` | `SEMANTIC` |
| j | No row where `UNRESOLVED_CATEGORY_VALUE` is null while `UNKNOWN_REASON` is `UNRESOLVED_CATEGORY` or `BOTH`, or non-null otherwise | `SEM_AI_UNKNOWN` |
| k | Of rows whose `H2` appears in the standard hierarchy, none whose `P_L_SECTION` or `NORMAL_BALANCE` disagrees with it; and of rows whose `H2` does not, none with either column non-null | `XREF_SNAPSHOT` and `SEMANTIC` |
| l | No row whose `VALUE_SIGN` disagrees with its `NORMAL_BALANCE` | `XREF_SNAPSHOT` |

**Label every assertion with the letter in this table and run it exactly as
defined here.** Never renumber, merge or substitute one; an assertion with the
right letter and a different meaning is a false pass.

**(c) cannot fail today** — the seed makes a miss structurally impossible. Keep
it: the day something changes that, this says so rather than rows quietly
appearing in unknown.

**(d) is what licenses storing the unit per key.** If it fires, the key is too
coarse for that lane and the answer is a key change, not a workaround.

**(h) is worded around the classifier override**, not carelessly. A statistic
row overridden to a money `H1` lands with a sign, a null amount and therefore a
null `VALUE`. That is legal. A `VALUE` with no sign behind it is not.

Report alongside: the review lists, and rows where `RECORD_TYPE` and `H1`
disagree — meaning `H1 = 'Statistic'` with `RECORD_TYPE = 'AMOUNT'`, or `H1` in
the five money values with `RECORD_TYPE = 'STATISTIC'`. `Unclassified` is not a
disagreement in either direction.

### 3. Amount reconciliation

At every boundary, `SUM()` every numeric measure — `SOURCE_AMOUNT` and
`STAT_VALUE` separately, never added. This catches a value corrupted in transit
while the row survives, which check 1 cannot see.

Reconcile `SOURCE_AMOUNT`, not `VALUE`: the sign is intended to change the
total. Check 2(h) covers `VALUE`.

**State the bridge per measure, per table, per lane**, so a classifier override
shows as a stated shift rather than a gap on one side. **Show the figures** —
both sides and the difference — for every numeric column, pacing's own columns
included. A line saying the totals match is not evidence.

**Compare with a tolerance**, `abs(a-b) > 0.005`, never by rounding both sides
and testing equality. Rounding is discontinuous at the boundary, so two
independently rounded floats can differ by a cent from a difference of 1e-10.

**This check must run at the staging-to-transformation boundary**, not only end
to end. Comparing transformation to semantic cannot test the join; a corruption
there shows both sides matching and both wrong.

### 4. File / object parity

MD5 of each `$$` body against `PROCEDURE_DEFINITION`. Confirming a file exists
is not parity.

**The deployed side comes from a live query, never from a cached tool output.**

**The script must not connect to Snowflake** (§11). It reads files and prints
hashes; you supply the deployed side as an argument.

**Redeploy immediately after rewriting any `.sql` file**, before running this
check. Rewrite-then-forget is the most common cause of a false mismatch.

**Run `scripts/check_line_endings.py` first.** It fails on any CRLF file under
`sql/`, `scripts/` or `docs/`, and on any non-ASCII byte in a `.sql` file. A
failure there is fixed before parity runs, because either one makes a correct
procedure report a mismatch.

**Test the check itself.** A parity check that cannot fail is worse than none:

| Fault | Expect |
|---|---|
| clean baseline | pass — without this the rest means nothing |
| a wrong hash | reported as a mismatch |
| a stray `.sql` under `sql/` deployed nowhere | reported |
| a deployed object with no file | reported |
| a file in the wrong layer folder | **fails on folder, not on hash** |
| the recursion finding nothing | a distinct failure, not a clean pass |

**Three exit codes:** pass, fault detected, check broken. A missing or
malformed input file is **check broken**, not fault detected. Remove probe
files in a `finally` block and assert the tree is clean afterwards.

### 5. Idempotency

Run the whole build twice through `scripts/run_build.sql`, then `HASH_AGG` over
full content of every table, excluding `RUN_ID` and `LAST_SEEN_RUN_ID`.
**Matching row counts are not idempotency;** compare the hashes.

**Expect bit-identical results everywhere.** No layer aggregates, so there is no
floating-point addition and no order-dependent drift. **Any difference at all is
a defect** — there is no known-benign category to dismiss it into.

**The classification table needs its own assertion:** a second run inserts zero
rows and changes no classification value.

**Earlier builds need their own assertion:** every earlier lane's staging and
transformation tables, and its rows in the classification table and the six
semantic tables, hash identically before this build's first run and after its
last. That is the evidence a build touched only its own lanes.

### 6. Fault propagation

A success return proves only that the procedure ran — `QUERY_HISTORY` does not
log statements executed inside a procedure, and `CALL` binds at runtime, so a
clean `CREATE` proves nothing about the wiring. **Fault one procedure, run
`scripts/run_build.sql`, and confirm three things:** the error surfaces with
its origin named, every MAIN before the faulted one completed, and nothing
after it ran. Restore from file and re-verify parity.

**Twice per build:** at M2, faulting an empty per-source MAIN itself; at M6,
faulting a model inside a MAIN, so a model's error is shown to propagate
through its MAIN.

### The blind spot

**A case shift in a key column is invisible to all six.** Counts pass because
nothing was lost, reconciliation because no amount moved, idempotency because it
was consistently wrong, parity because the file matched the object. **Read the
output, not only the check results:** after staging, profile each fact table by
`RECORD_TYPE`, `IS_SUBTOTAL`, blank `ACCOUNT_KEY`, null `DEPARTMENT` and
`STAT_UNIT_FAMILY`, and compare every figure with `docs/sources.md`.

---

## 10. How to work

**Analyse first.** The cheapest query is the one that tells you what a column
actually contains. Read the columns nobody mentioned — a disposition flag, a
notes field, a cutoff date, a coverage count. That is where answers tend to be.

**Nothing about a new lane is known until measured.** Records of previous
builds in `docs/completed-builds/` show how similar sources behaved; they are
not evidence about this one.

**Ask rather than work around.** A question costs a message; the same question
worked around silently costs a run. New questions go in `docs/findings/open-questions.md`.

**Prefer a measurement to a convention.** A rule that holds for one lane rarely
holds for the next.

**Counting right is not classifying right.** The count invariant proves nothing
was lost. It does not prove anything landed in the correct stream — a misrouted
row is still exactly one row.

**So find an independent anchor** — a stated total, a rollup row, a note in a
dictionary — and check your figure against it. That catches what arithmetic
cannot.

**Check your own arithmetic before reporting it.** Add up every breakdown
against its own total.

**Every figure in a document comes from a query run in this session.** Never
from memory, an earlier memo or a summary. The M6 documents in particular are
generated from live queries against the deployed objects, and any figure that
differs from an earlier milestone is explained, not silently replaced.

**Never assert a table is used without naming the procedure and the column.**

**Rewrite files; never string-replace.** Read the file, rewrite it in full.

**Compile or parse any generated file before offering it for review.**

**Say when this document is wrong.**

### Where the numbers live

| | Exact currency figures | Counts, bands, variances |
|---|---|---|
| `sql/` files, everything in `docs/findings/` including milestone memos | ✓ | ✓ |
| Chat summaries, these process documents | ✗ — point to the memo | ✓ |

**Row counts are not currency and are not restricted.**

---

## 11. Environment

Everything is built in **`DEV_G2M_AI`**. Warehouse `G2M_MCP_AGENT_WH`.

```sql
USE WAREHOUSE G2M_MCP_AGENT_WH;
```

| | Where |
|---|---|
| **Source data** | `CLN.<SOURCE>_BUILD`, the owner's frozen clone of this build's source schema (§2): the tables assigned to this build's declared lanes. Code never names the live schema. **`CLN.XREF` is not read.** |
| **Build target** | `DEV_G2M_AI` — schemas `STAGING`, `XREF_SNAPSHOT`, `TRANSFORMATION`, `SEMANTIC` |
| **Metadata** | `DEV_G2M_AI.INFORMATION_SCHEMA`, `CLN.INFORMATION_SCHEMA`, `SNOWFLAKE.ACCOUNT_USAGE` where granted |

If a value cannot be derived from the staged source, it is `Unclassified` and
routes to unknown. That is the answer, not a reason to reach outside.

**`CLN.XREF` is a schema, not a word.** A `CLN.CLEAN` table whose name contains
`XREF` is in scope like any other. The boundary is the schema.

### One path to the database

**There is exactly one execution path per run, stated in `AGENTS.md`.** Three
rules hold whatever it is:

**No script ever connects.** No connection profile, no key file, no driver
import, no credentials in anything under `scripts/`. A utility that needs data
takes it as an **argument**.

**Nothing runs outside the session's own connection.** No second tool, no
ad-hoc client, no shelling out to a different profile.

**The role is the boundary.** What the agent cannot reach under its grants, it
reports rather than routing around.

---

## 12. Milestones

**Every milestone writes `docs/findings/M{n}.md`. The build stops and waits
for approval four times; at M2, M4 and M5 it summarises in one line and
continues.** Phase *n* produces
milestone **M*n***; there is no offset.

| Stop | When | Wait for |
|---|---|---|
| 1 | M1, after listing the granted tables and proposing how they group | The owner's lane names and scope |
| 2 | End of M1 | Approval of the findings and open questions |
| 3 | End of M3 | Approval of staging |
| 4 | End of M6 | Approval of the build |

M2, M4 and M5 run straight on once their checks pass. **Stop anyway, at any
point, when:**

- a check fails and the fix is not both obvious and contained to the current
  phase;
- a question only the owner can answer blocks the next step. A question that
  does not block is recorded in `open-questions.md` and the build continues;
- a rule in this document looks wrong for the source in front of you;
- you are about to decide something the owner should (a borderline subtotal
  group, a category mapping, a key composition).

Approval at a stop covers every phase up to the next stop, DDL included.

| Phase | Do | Milestone |
|---|---|---|
| **M1. Analysis** | **Confirm the repo is archived (§2) before anything else.** List every granted `CLN.CLEAN` table and propose how they group into lanes, without naming them. **Stop (stop 1): the owner names the lanes and confirms which tables are in scope.** Check each name against `docs/completed-builds/` and report; the owner confirms it is unused in the master (D-32). Profile the in-scope tables. Establish per lane: `RECORD_TYPE` derivation, `ACCOUNT_KEY` composition, the section or dictionary giving `H1`/`H2`, statistic unit vocabulary, category derivation, `SOURCE_LINE_KEY`, period derivation, **how the source marks its own subtotal and rollup rows, and how its accounts map onto the standard hierarchy**. Write `docs/sources.md`. No DDL. | Findings, the lane declaration, and `docs/findings/open-questions.md` |
| **M2. Skeleton** | Four schemas, created if not present. Per lane, the three per-source MAINs with zero model calls; `SPROC_SEM_AI_MAIN` with zero calls if it does not yet exist, otherwise left as it is until M6; `scripts/run_build.sql`. Confirm `.gitattributes`, `scripts/check_line_endings.py` and `scripts/parity_check.py` are present, and run the parity check's six-fault self-test. | `run_build.sql` runs it; line-ending check clean; checks 4 and 6 pass |
| **M3. Staging** | One model per source subject — facts, pacing and dictionaries alike — dictionaries staged per lane even where several lanes share one. Lossless. | Checks 1, 3, 4, 5 pass; identity form stated per model; the output profile (§9, the blind spot) compared with `sources.md` |
| **M4. Classification** | The seeder, the table, the three review views | Check 2(a)–(d), (f), (k), (l); checks 4 and 5 including the classification assertion; the review report |
| **M5. Transformation** | One procedure per lane, five streams each | Check 1 partition per lane; checks 2(e), 2(f), 3, 4, 5; the four lists; `RECORD_TYPE`/`H1` disagreements |
| **M6. Semantic** | Six tables, lanes unioned in marked lane blocks | All six checks; five documents; `scripts/reconcile_{LANE}.sql` run with zero failures |

**A build ends at M6.** Hardening - notification hooks and run logging - is a
one-time task for the promoted environment, not part of any company build. Do
not start it, and do not stop to ask about it.


**`scripts/reconcile_{LANE}.sql` is a standard M6 deliverable.** A read-only
anonymous block comparing row count and every numeric sum per source table
across CLN, STG, XFRM and SEM, with PASS or FAIL per row and a total failure
count. Take the CLN-side column names from the deployed staging code, never from memory.
Zero failures is required.

**M1 is the largest phase and the most valuable.** Nearly every expensive
mistake would have been caught by one more query at M1.

### Reporting

**File first, then chat.** Write the memo, then summarise: what was built, the
most important finding, anything blocking, the file path. Never summarise a
memo you have not written. At a milestone that does not stop, the summary is
one line.

**Every milestone from M4 reports the four lists** — new, unclassified,
awaiting sign, values awaiting a category — per lane, by count and amount,
sorted by amount, with the awaiting-sign floor stated.

**At M6, five documents.** Each answers one question and only that one; where
one needs a figure another owns, it points rather than repeats.

| Document | The question |
|---|---|
| `reconciliation.md` | Does every record arrive? |
| `field-lineage.md` | Where does each **column** come from? |
| `classification-coverage.md` | Which **accounts** are classified, and correctly? |
| `table-usage.md` | How were the **tables** wired? |
| `open-questions.md` | What needs a person? |

**`classification-coverage.md`** carries coverage first, then the harder
question — did each account find the *right* classification? Two tests:

**Keyword contradiction.** A description saying one thing against a
classification saying another. A candidate list, not proof: contra accounts
legitimately look like this. Report them; do not reclassify them.

**Sign anomaly, the stronger of the two.** Group by classification and compare
each account's amount direction against the prevailing direction for its `H1`
on that lane. **An account running the opposite way to every other account in
its class is either misclassified or a contra account**, and both are worth
knowing.

`SOURCE_AMOUNT` is carried **as booked**, so the source's own signs survive. A
lane that books expenses negative, or a forecast that arrives pre-signed, shows
up here. The test is not about whether a class reads positive or negative in
absolute terms, which varies by source convention. It is about the outliers
within a class.

This is the one test in the build that can catch a misclassification the counts
cannot see; every other check confirms only that nothing was lost or moved.
**Run it, and report the outliers by count and amount** - do not reclassify
them.

**`table-usage.md`** covers every granted table without exception, including
unused ones, with the procedure and column named for every "used". An unread
table is otherwise invisible, and a reader cannot tell a deliberate omission
from an oversight.

---

## 13. Decisions

**Decisions are the register; questions are not kept here.**

**Decisions are the process and carry across every build.** They are settled.
If one looks wrong for the source in front of you, say so and wait — do not
quietly build something else. A decision changes only by the owner's agreement,
and then it changes here, for every build after.

**Questions belong to one build and do not carry.**

### Decisions

| | Item | Decision |
|---|---|---|
| D-01 | Filtering | Invariant 1. |
| D-02 | Aggregation | Invariant 2. |
| D-03 | `CLN.XREF` | Not read by the pipeline, ever. Classification is derived from the staged source. The master table in that schema is written by promotion only, outside the build. |
| D-04 | The classifier | `XREF_ACCOUNT_CLASSIFICATION` is the only classifier. Derivation proposes at insert; after insert a row is never re-proposed. No runtime precedence exists and none is to be built. |
| D-05 | Classification grain | Five parts: lane, site, department, `ACCOUNT_KEY`, `RECORD_TYPE`. Unique. No wildcards, no inheritance, no precedence. |
| D-06 | `ACCOUNT_KEY` | `coalesce(nullif(trim(ACCOUNT_NUMBER),''), nullif(trim(STAT_ACCOUNT),''), nullif(trim(SOURCE_ITEM_ID),''), '~BLANK~')`, built in staging, raw columns carried alongside. `SOURCE_ITEM_ID` is the lane's own line-item identifier, declared at M1, null where the lane has none. The `nullif(trim())` is not optional — without it an empty string becomes the key instead of the sentinel. No lane-specific exception. |
| D-07 | `RECORD_TYPE` | In the key, normalised in staging. Where a lane does not state it, staging derives it — the one declared exception to staging doing no classification — and records the rule in `RECORD_TYPE_SOURCE`. |
| D-08 | Blank key parts | `'~BLANK~'`, identical expression at seed and at join. |
| D-09 | `H1` | The statement. Seven values, exhaustive, never null, and the only thing that routes a row. |
| D-10 | `H2` | Section for money, unit family for statistics. |
| D-11 | The hierarchy | `H2` is Level 1 and `H3` is Level 2 of the standard chart of accounts in §5, fixed across every build. `H4` and `H5` are reserved and seed `UNCLASSIFIED`. A section digit reaches Level 1 and no further; `H3` seeds `UNCLASSIFIED` unless the source states a sub-category outright. Loose keyword guessing at Level 2 is rejected. |
| D-12 | `P_L_SECTION` and `NORMAL_BALANCE` | A fixed function of `H2`, never guessed independently and never set per account. Asserted by check 2(k). |
| D-13 | Polarity | `VALUE_SIGN` follows `NORMAL_BALANCE`: Credit `+1`, Debit `-1`, Mixed null, and null outside the income statement. `SOURCE_AMOUNT` is carried as booked with the source's own signs; `VALUE` is null wherever the sign is. |
| D-14 | The merge | Insert-only on classification columns; an existing key has only `LAST_SEEN_RUN_ID` updated. `CREATE TABLE IF NOT EXISTS` precedes it every run. |
| D-15 | Persistence | The classification table persists across runs **and across builds**, one set of rows per lane, which keeps the review report stable. A build seeds only its own lanes, and nothing is ever read back into it. |
| D-16 | Category | A column in transformation. In semantic the income statement splits into three tables by category; balance sheet and operating metrics each carry `CATEGORY` in one table. |
| D-17 | Scenario | Never flattened, never merged, always verbatim. An unresolved category sends the whole row to `UNKNOWN`. |
| D-18 | Statistics | No sign, no `VALUE`. The statistic measure is `STAT_VALUE`; there is no separate metric value column. |
| D-19 | `AGGREGATION_TYPE` and `METRIC_UNIT` | Stored per classification key, asserted one-per-key by check 2(d). |
| D-20 | Operating metrics | Its own stream and its own semantic table. |
| D-21 | Semantic shape | Detail only. Six tables, fixed and identical across lanes and builds. No aggregated layer. **Pacing stops at transformation** and has no semantic model: its grain carries an as-of date the six tables do not. |
| D-22 | Completeness | Invariant 5. |
| D-23 | Transformation procedures | One per lane, five tables from one join, reading the classification in one marked CTE so promotion swaps it in one line. |
| D-24 | Pacing and pickup | Their own transformation stream, routed on source rather than `H1`, counted in the partition, and ending at transformation with no semantic model. Not `UNKNOWN`, which is a queue that should shrink. M1 establishes whether an as-of date exists; where it does not, the stream is still built and the memo states what the source would need to supply. |
| D-25 | Duplicates and subtotals | Kept everywhere. Duplicate extracts are tagged with `SOURCE_TABLE`; the source's own total and rollup rows are tagged with `IS_SUBTOTAL`, set in staging per row with the rule recorded in `SUBTOTAL_SOURCE`. Nothing is removed, and no computed measure is stored. Deduplication is a decision and this build makes none. |
| D-26 | Dictionaries | Staged like facts, so the seed reads `STAGING` only. Staged per lane as `STG_{LANE}_*`, even when several lanes share one; no new `STG_SHARED_*` objects. |
| D-27 | `RUN_ID` | Stamped by each MAIN when it starts and passed to the procedures it calls. MAINs take no parameters. On every table except the classification table, which carries `FIRST_SEEN_RUN_ID` and `LAST_SEEN_RUN_ID` instead. The only run stamp. |
| D-28 | Schemas | `STAGING`, `XREF_SNAPSHOT`, `TRANSFORMATION`, `SEMANTIC` in `DEV_G2M_AI`. `XREF_SNAPSHOT` is a standard dual-purpose schema in the process databases. |
| D-29 | `STAT_UNIT_FAMILY` | Where a lane carries a statistic value alongside a money amount on one row, staging derives a `STAT_UNIT_FAMILY` attribute from the statistic account. It is not `METRIC_UNIT` and does not change the key or the routing. Retyping such rows as `STATISTIC` is rejected: it routes rows carrying real P&L amounts out of the income statement. |
| D-30 | `AGGREGATION_TYPE` seeding | From the source where the source states it; `UNRATIFIED` only where nothing is known. |
| D-31 | The master table | `CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY` carries the full five-part key including `RECORD_TYPE` and `SOURCE_LANE`, matching the build's grain exactly. |
| D-32 | Lanes | Declared per build by the owner at M1. Never hard-coded in these documents, never inferred from a source system's name. **A lane name must be unique across every build ever run**, because the master is keyed by lane and two builds sharing a name collide there irreversibly. M1 checks the proposed names against `docs/completed-builds/` and the `SOURCE_LANE` values in `DEV_G2M_AI`, and reports; the owner checks the master and confirms. |
| D-33 | The one-way loop | Nobody edits the classification table in `DEV_G2M_AI`. `REVIEW_STATUS` is always `UNREVIEWED` there. Human correction happens in the master after promotion and never flows back. |
| D-34 | Environment lifecycle | `DEV_G2M_AI` accumulates: nothing is cleared between builds, and `sql/` stays with it. Only a build's records are archived. Promotion is manual and the agent does not perform it. |
| D-35 | Orchestration | One MAIN per lane in each of `STAGING`, `XREF_SNAPSHOT` and `TRANSFORMATION`; one shared `SPROC_SEM_AI_MAIN`. No MAIN calls another; each runs on its own, in sequence. Nothing catches exceptions. |
| D-36 | Semantic lane blocks | Each semantic model is a `UNION ALL` of self-contained blocks marked `BEGIN LANE` / `END LANE`, so a lane's block can be pasted into the master semantic model unchanged. |
| D-37 | Pacing and the seeder | Pacing tables never feed the seeder, and their code columns are never mapped to `ACCOUNT_NUMBER`. |
| D-38 | Labels and units | No invented labels. A statistic's `H2` is the source's stated family or its own code; `METRIC_UNIT` is null unless the source states a unit. |
| D-39 | The seeder | One for the environment, `SPROC_XREF_ACCOUNT_CLASSIFICATION(P_RUN_ID, P_LANE)`, named for its table, one derivation branch per lane. A build adds its own lanes' branches and changes no other. |
| D-40 | Line endings | LF everywhere, enforced by `.gitattributes` and checked by `scripts/check_line_endings.py` before parity. |
| D-41 | Unresolved categories | Never blocking. Unanswered values route to `UNKNOWN`; a status column is an attribute, not a category signal. |
| D-42 | Accumulation | A build creates and changes only its own lanes' objects. To shared code it only adds: a branch to the seeder and a lane block to each of the six semantic models. Earlier builds' MAINs are never called, and check 5 proves earlier lanes are unchanged. |
| D-43 | Frozen source | Each build declares one source schema `CLN.<SOURCE>` and reads only `CLN.<SOURCE>_BUILD`, a zero-copy clone the owner takes before M1. Code names `CLN.<SOURCE>_BUILD.`; promotion rewrites it to `CLN.<SOURCE>.`. A change inside the clone mid-build is a stop. |

### Questions

**None here, ever.** This document holds only decisions, which carry across
every build.

**A build's questions live in `docs/findings/open-questions.md`**, numbered
`Q-01` upward within that build. That file is created at M1, maintained as the
build runs, and archived with `docs/findings/` when the build closes (§2) — so
questions reset on their own and never leak into the next company.

It is also the only place the agent can keep them: `AGENTS.md` permits writing
under `docs/`, and this document is not the agent's to edit.

A question is anything ambiguous that a decision above does not settle: a field
that could mean two things, a link that might exist, a table with no obvious
purpose, a rule that does not survive contact with the data. **Raise it; do not
build around it.**
