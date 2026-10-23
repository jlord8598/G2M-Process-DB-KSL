# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

---

## Source schema

`CLN.<SOURCE>`: *(fill at M1)*. Load freeze window: *(fill at M1)*.
Record every in-scope table's `last_altered` at M1 (`CLAUDE.md` D-43).

## Lane declaration

**Ask the owner. Do not infer lane names from source system names.**

| Lane | Source tables | Notes |
|---|---|---|
| *(fill at M1)* | | |

A lane is one coherent source set that gets its own staging models and one
transformation procedure. Two tenants of one system are usually two lanes, not
one, if their account vocabularies differ.

**Granted tables.** List everything the role can see, then assign each table to
a declared lane or mark it out of scope. **Being able to see a table does not
put it in scope** — a previous build's grants may still be in place. The owner
confirms before any model is written.

```sql
select table_schema, table_name, row_count, bytes, last_altered
from CLN.INFORMATION_SCHEMA.TABLES
where table_schema = 'CLEAN'
order by table_name;
```

---

## What every lane must supply to staging

**Every fact staging table** supplies all of these; the classification join
needs them. A lane missing one is a finding to raise, not a gap to work around
— except `SOURCE_LINE_KEY`, which may be null if the source has no natural line
identifier. **Pacing and dictionary staging tables keep their own shape**, plus
`RUN_ID`, `SOURCE_LANE` and `SOURCE_TABLE`; they never feed the seeder.

| | Used for |
|---|---|
| `SOURCE_LANE` | Key part. The declared lane name. |
| `SOURCE_SITE_CODE` | Key part. The lane's own site, property or entity identifier. |
| `DEPARTMENT` | Key part, as the source holds it. |
| `ACCOUNT_NUMBER` | Raw, malformed and blank included. |
| `STAT_ACCOUNT` | Raw, where the lane has one. |
| `ACCOUNT_KEY` | `coalesce(nullif(trim(ACCOUNT_NUMBER),''), nullif(trim(STAT_ACCOUNT),''), '~BLANK~')`, built here. |
| `RECORD_TYPE` | Key part. `AMOUNT` or `STATISTIC`, normalised here. |
| `RECORD_TYPE_SOURCE` | The stating column, or the derivation rule. Never null. |
| `STAT_UNIT_FAMILY` | Where a row carries both a money amount and a statistic value (D-29). |
| `ACCOUNT_DESC` | Carried, and shown in the review report. |
| `ASSET_NAME` | The site or property name, where a dimension supplies one. |
| `DEPARTMENT_NAME` | Where the lane supplies one; null otherwise. |
| `PERIOD_END` | A date, derived per lane. |
| `SCENARIO` | The named scenario, verbatim; where the source names none, the stating table or measure column name (D-45). Never null. |
| `SOURCE_AMOUNT` | As booked, **sign included**. Never strip a negative - that is a silent repair (invariant 3). |
| `STAT_VALUE` | Where the lane holds a statistic measure. |
| `IS_SUBTOTAL` | The source's own total or rollup row. Default `FALSE`. |
| `SUBTOTAL_SOURCE` | How a subtotal was identified, or that the source gives no way to tell. |
| `SOURCE_TABLE` | Which source table the row came from. Never null. |
| `SOURCE_LINE_KEY` | The natural key making a source row addressable, or null. |

---

## Per-lane findings

**One section per lane, written as M1 measures it.** Mark every statement
*measured*, meaning confirmed against this extract, or *unverified*, meaning
noted but not tested.

For each lane, establish and record:

**Shape.** Long or wide. If wide, how many columns are unpivoted — count them;
do not assume twelve.

**The account number.** Its structure, how reliably it parses, and what
fraction of rows conform.

**The section source.** A digit in the account code — and *which position*,
since this differs by lane — or a dictionary that states the section outright,
or neither.

**`RECORD_TYPE`.** A column that states it, or the rule used to derive it.
**Check specifically whether the same account number appears as both an amount
row and a statistic row.** If it does, `RECORD_TYPE` in the key is what keeps
those two populations apart, and without it one is permanently misrouted.

**Statistic unit vocabulary.** What identifies a statistic's unit, and the full
list of values. Enumerate every run if the list can grow. Record the source's
own codes and any names the source itself states; do not invent labels (D-38).

**Category.** Which column or table says actual, budget or forecast, and the
full catalogue of values it can take. State the category for **every** fact
table, including those with no scenario column. Values you cannot map are
questions for the owner, not blockers; they route to `UNKNOWN` until answered.

**Status and state columns.** Any posted/pending flag, batch status or export
state. Record its values and what they appear to mean; it is carried as an
attribute and does not decide category unless the owner says so.

**Coverage period of each fact table.** The first and last date each one
covers. Two tables can only be compared over periods both cover completely; a
partial month against a full one proves nothing.

**Scenario.** The named scenarios within each category.

**Period.** How a date is derived.

**Blank and malformed populations.** How many rows carry no account number, no
department, or a code that does not parse. Report; never repair. **For a large
blank-account population, profile it by every column it does carry** (an item
tag, a description, which measures are populated) and look for a link the
source states to a row that has an account number. A link the source states is
usable; a match on description wording alone is not.

**Dictionaries.** What each one supplies, whether it is unique on its own key,
and which fact combinations it fails to cover.

**How accounts map onto the standard hierarchy.** Which `H2` Level 1 value each
part of the chart belongs to, and whether anything identifies a Level 2
sub-category outright. Record the mapping; do not guess Level 2 from loose
description matches.

**Pacing and pickup sources.** Any table whose name or content suggests a
forward booking position, a pace against prior, or a pickup between snapshots.
For each, establish **whether an as-of date exists distinct from the period it
describes** — on the row, or implied by one extract per snapshot. **If neither,
say so: the source holds only current values and pacing cannot be built from
it.** Never synthesise a snapshot date. Record the table's own shape; the
pacing stream keeps it rather than conforming to the semantic common block.
**Test every code column in a pacing table against the GL account format**
before anything treats it as an account; it is usually a client, CRM or rate
code. Pacing tables never feed the seeder (D-37).

**Subtotal and rollup rows.** How the source marks its own total lines — a
level or depth column, a total flag, a description that names a section rather
than an account, a site or department value that is a rollup rather than a real
one. **If the source gives no way to tell, say so.** An unmarked subtotal is a
known gap; a wrongly marked detail row is a silently missing figure.

**Duplicates.** Overlapping extracts or repeated lines within one file. All are
kept (D-25) and tagged with `SOURCE_TABLE`; record what they are so a consumer
knows.

**Anything surprising.** A constant column, a flag nobody mentioned, a label
that contradicts its contents.

---

## Corrections

**When a measurement contradicts something written here, correct it and say
so.** A finding that a documented rule is wrong is worth more than a clean run.
