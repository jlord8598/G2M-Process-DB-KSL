# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

---

## Source schema

`CLN.BOX_INVESTMENT_DATA` (*measured*). Load freeze window: 2026-10-28
13:27:59.529 -0700 to 2026-10-30 13:27:59.529 -0700. That is 48 hours from
this build's first query, `01c80a0b-010a-65ab-0003-4ff21c156b82`, as stated
by the owner.

Every in-scope table's `last_altered` is recorded in `findings/M1.md` section 3
(`CLAUDE.md` D-43). The latest is 2026-10-19 15:41:03.950 PDT, before the
freeze began.

## Lane declaration

**Ask the owner. Do not infer lane names from source system names.**

| Lane | Source tables | Notes |
|---|---|---|
| HHG (rebuilt, D-44) | CLN_HERITAGE_GOLF_ACCOUNTS, _CLUB_LIST, _FORECAST_ANAPLAN, _REFERENCES, _ROUNDS_DETAIL, _TR12_DATA | Re-granted. All six recreated 2026-10-27, before the freeze. The new descriptions are in ACCOUNTS (`findings/M1.md` section 9). |
| INVITED_CLUBS (rebuilt, D-44) | CLN_INVITED_CLUBS_ACCOUNTS, _ESSBASE_EXTRACT, _META_ACCOUNT, _META_DEPARTMENT, _META_ENTITY, _META_LOCATION, _META_SUBACCOUNT | Scope: the A6 H2 mapping (D-46) and `UNKNOWN_REASON`. |
| NEWBURY (rebuilt, D-44) | CLN_NEWBURY_BOSTON_ACCOUNTS, _OPERATING_STATS_BGT, _EVENTSANDOOO, _FCST, _PYACT, _SHOPS, _OTB_1DAY_PICKUP, _OTB_3DAY_PICKUP, _TRIAL_BALANCE | Scope: 11 accounts' H2 (D-46). |
| *out of scope* | BEAUMIER (5), DAVIDSON (3), HERSHA (3) | Visible from earlier builds' grants; not this build's. |

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
where table_schema = 'BOX_INVESTMENT_DATA'
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

## Build 08 lanes (rebuild scope only)

Everything not listed here is unchanged from the archived records: builds 02
and 06 for HHG, build 03 for INVITED_CLUBS, builds 02 and 07 for NEWBURY.

**HHG** (*measured*, `findings/M1.md` section 9).
- **Description source:** `CLN_HERITAGE_GOLF_ACCOUNTS`, now with
  `ACCOUNT_DESCRIPTION`, `DEPARTMENT_DESCRIPTION` and `PARENT_CODE` filled.
- **Join:** `FULL_ACCOUNT_STRING` = TR12 `ACCOUNT_NUMBER`, where
  `SOURCE_TABLE = 'CLN_HERITAGE_GOLF_TR12_DATA'`. Unique, one-to-one, 0
  unmatched.
- **Coverage:** 13,685 of 13,729 accounts, 164,232 of 164,760 fact rows.
- **Entity names:** no table supplies names for 9050-9056, 9099 or 9102.
- **Department 950** carries section-like descriptions (Q-09).

**INVITED_CLUBS: chart structure** (*measured*; detail in `findings/M1.md`
section 5).
- Accounts are `A` + 5 digits, and character 2 is the section digit.
- META `ACCOUNT_TYPE` states the statement.
- The A6 range is 460 accounts and 113,857 keys, all META expense, all seeded
  H1 `Expense`, H2 `UNCLASSIFIED` (build 03, Q-13).
- They group into 3-digit blocks: 600-609, 611-633, 635, 636, 638.
- META `PARENT` names a rollup group for each account (for example ACCTS-INTEX,
  ACCTS-TAXEX, ACCTS-DEPAM). These parents are the second evidence source
  for the mapping.

**INVITED_CLUBS: H2 mapping** (D-46). *Approved at stop 1* (Q-03, Q-04,
Q-05). It applies to the A6 accounts only; all other INVITED_CLUBS rules are
unchanged from build 03.

**Evidence.** Each block uses the 3-digit block (characters 2-4 of the
A-code), the account description, and the account's META `ACCTS-*` parent.

| Accounts | H1 / H2 | Evidence; examples |
|---|---|---|
| A600xx-A602xx | Expense / Cost of Goods Sold | "COGS:" descriptions; parents COGS1, COGSR, MGCG*. A60001 COGS: Food, A60103 COGS: Merchandise, A60201 COGS: General |
| A603xx-A606xx | Expense / Payroll | parents HWAGE, SALRY, BONUS, PYTAX, BENEF, EMREL. A60301 Payroll: Gross Wages, A60501 Payroll Taxes, A60601 Education Reimbursement |
| A607xx-A633xx and A638xx, and A63504 | Expense / Operating Expenses | operating parents. A60801 Advertising, A62601 Premium Expense, A62901 Electric, A63001 Property Taxes: Real, A63201 Facility Lease, A63804 Web Hosting, A63504 Intercompany Management Fees |
| A635xx (except A63504), A62838 | Below the Line / Other Income / (Expense) | parents INTEX, INTFV. A63501 Interest Expense, A63551 Amortization of Debt Issuance Costs, A62838 Capitalized Interest |
| A62824, A62839, A62849 | Below the Line / Other Income / (Expense) | parents SGA01, PMINI. Impairment of assets; Minority Interest Expense |
| A636xx (except A63699) | Below the Line / Depreciation & Amortization | parents DEPAM, AMORT. A63601 Depreciation, A63602 Amortization |
| A63004, A63009, A63010, A63014, A63015, A63019, A63020 | Below the Line / Income Taxes | parent TAXEX on all seven. A63009 Federal Income Tax |
| A63699 Life / TAM Dues Clearing | Expense / UNCLASSIFIED | parent AMORT, but the description is not D&A. Listed for the business. |

Where an account's block and its `ACCTS-*` parent disagree, the block applies
(owner, Q-12). H3 stays `UNCLASSIFIED` throughout (D-11).

**For the business to spot-check: 14 accounts where block and parent
disagree, and A63699.**

| Account | Block H2 (applied) | ACCTS parent | Parent's majority H2 |
|---|---|---|---|
| A60005 COGS: Other F&B | Cost of Goods Sold | ACCTS-FBSUP | Operating Expenses |
| A60201 COGS: General | Cost of Goods Sold | ACCTS-MISCE | Operating Expenses |
| A60202 COGS: Owners Distribution | Cost of Goods Sold | ACCTS-MISCE | Operating Expenses |
| A60205 COGS: Guest Laundry | Cost of Goods Sold | ACCTS-MISCE | Operating Expenses |
| A60206 COGS: Equipment | Cost of Goods Sold | ACCTS-MISCE | Operating Expenses |
| A60207 COGS: MIS Intercompany | Cost of Goods Sold | ACCTS-MISCE | Operating Expenses |
| A60208 COGS: MIS External | Cost of Goods Sold | ACCTS-MISCE | Operating Expenses |
| A60211 COGS: Amenity Access/Membership Fee | Cost of Goods Sold | ACCTS-MISCE | Operating Expenses |
| A60203 COGS: Property | Cost of Goods Sold | ACCTS-OOEXP | Operating Expenses |
| A60517 TPA Dental | Payroll | ACCTS-OTINS | Operating Expenses |
| A60518 COBRA Administration | Payroll | ACCTS-OTINS | Operating Expenses |
| A60528 IBNR: Medical | Payroll | ACCTS-OTINS | Operating Expenses |
| A62424 Drinks, Coffee, First Aid | Operating Expenses | ACCTS-EMREL | Payroll |
| A62431 Selection Tools | Operating Expenses | ACCTS-EMREL | Payroll |
| A63699 Life / TAM Dues Clearing | UNCLASSIFIED (owner Q-05) | ACCTS-AMORT | Depreciation & Amortization |

**Q-04, recorded.** The standard hierarchy (`CLAUDE.md` section 5) is used as
it is:
- `Depreciation & Amortization` carries P_L_SECTION `Operating` and
  NORMAL_BALANCE `Debit`, even where H1 is `Below the Line`. A consumer
  computing operating profit from P_L_SECTION therefore includes D&A.
- `Income Taxes` is `Non-Operating`, `Debit`.
- `Other Income / (Expense)` is `Non-Operating`, `Mixed`, so unsigned.

**NEWBURY: H2 mapping** (D-46). *Approved at stop 1* (Q-07). H1 stays
`Below the Line`. Evidence: the 87/88/89 blocks of segment 2 and the account
descriptions.
- **Depreciation & Amortization:** 870105, 870110, 870120, 870125, 870205,
  870210, 870215 (Depr Expense-...) and 880430 Amort Expense-Intangible Lease
  Assets.
- **Income Taxes:** 890010 Federal Income Tax.
- **Unchanged, Other Income / (Expense):** 880420 Amort Expense-Loan Fees and
  880440 Amort Expense-Interest Rate Cap (financing costs, Q-07), and the other
  24 keys in the group.

That makes 9 keys re-seeded, all at business unit 9000.

---

## Corrections

**When a measurement contradicts something written here, correct it and say
so.** A finding that a documented rule is wrong is worth more than a clean run.
