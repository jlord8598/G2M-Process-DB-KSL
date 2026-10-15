# Design rationale

Why the architecture in `CLAUDE.md` is shaped the way it is. Read once.
Consult when a rule looks arbitrary or a shortcut looks obviously better.

None of this overrides `CLAUDE.md`. Where the two appear to disagree, the
operative document wins and the disagreement is a finding.

---

## Why nothing is filtered

A filter is a decision taken once, in code, by whoever was writing that model
that day. It leaves no trace. A record that was filtered and a record that
never existed look identical downstream, so "where did this account go" has no
answer and the only way to find out is to read the pipeline.

Keeping everything converts that question into a lookup. A record is in a
stream or it is in unknown, and either way it is visible with a stated
classification.

The cost is real: duplicate extracts land twice, and totals across them are
wrong. That is accepted deliberately and tagged with `SOURCE_TABLE`, because a
visible duplicate is a problem someone can solve and a silently dropped one is
not.

## Why completeness is a count, not a sum

A sum is the intuitive check and it cannot prove completeness. A zero-amount
row leaves the total unmoved, so an entire population of them can vanish with
the arithmetic still closing. Financial extracts carry thousands of such rows —
placeholders, statistical offsets, empty months in a wide extract.

Worse, a sum can match while a count does not, which reads as a clean run. The
count is the claim; the sum is a second, different check that catches a value
corrupted in transit while its row survives.

Both are needed and neither substitutes for the other.

## Why there is no aggregation anywhere

Aggregation destroys the account. Once several source lines have collapsed into
one figure, no downstream table can say which accounts produced it, and the
count invariant becomes an argument rather than a query.

It also removes the only source of non-determinism in the build.
Floating-point addition is not associative, so summing in a different order
changes the last bits — which means an aggregating pipeline has a known-benign
category of idempotency failure, and a known-benign category is somewhere real
defects hide. With no aggregation, check 5 expects bit-identical output and
**any** difference is a defect. That is a much sharper check.

The cost is row count in the semantic layer. That is cheaper than the audit
trail it buys.

## Why the classification is a table

Not for editability — nobody edits it here. Three other reasons.

**It is how the pipeline reports what it does not know.** A new account
arrives, gets a generic classification and a flag, and appears on a list.
Nobody has to notice it. Without that, a new account is either silently
misclassified by a rule that was not written for it, or silently absent.

**It separates deriving from routing.** Derivation runs once per key, in one
place, and routing reads a single column. Put the rules on the row-level path
and they run millions of times, get copied between lanes, and drift.

**It is the shape the master table needs.** The pipeline's output has to arrive
at the same grain people will correct it at, and a table is the only form that
is true of.

### Why insert-only, and why there is no precedence

The merge never touches an existing row. Derivation proposes once, at insert.

Two things follow. **Derivation and the table never compete at runtime** —
there is no tie to break, so no precedence mechanism exists, and the absence is
deliberate. A priority-ordered rule engine is legible on the day it is written
and opaque six months later, and every wrong figure it produces looks like a
correct one. A flat unique table cannot have that failure mode.

And **the review report stays stable across runs within a build.** A key seen
on run one is still flagged the same way on run five, so the report describes
the build rather than the last few minutes.

### Why nobody edits the table inside the pipeline

An earlier version had people correcting classifications in the build
environment, and the insert-only merge existed to protect those edits. That
model is gone: the build environment is cleared between builds, so anything
entered there would be lost.

Human correction now happens in the master table, after promotion, where it
accumulates across every company. The pipeline produces best guesses; people
improve them downstream; nothing flows back.

**The loop is one-way, and that is a real trade.** A company rebuilt after
promotion gets fresh machine proposals, not its reviewed values. That is
acceptable because companies are built once. If rebuilds ever become routine,
the answer is to read reviewed rows from the master at seed time — a
deliberate change, made on evidence.

### Why the key has five parts

Each part earns its place by a failure it prevents.

**Lane** — different companies share no account vocabulary. The same number
means different things.

**Site** — the same account is used differently at different properties, and a
site-level correction has to be expressible without a wildcard mechanism.

**Department** — the account alone is rarely the unit of classification.

**`ACCOUNT_KEY` rather than the raw account number** — because a source may
carry statistics on rows with no account number at all. Keyed on the raw
column, every such row on a site and department collapses to one key, and a
measure split across many statistic segments resolves to a single
classification with a single unit. Falling back to the statistic account is not
invention: it is the source's own identifier for rows that have no other.

**`RECORD_TYPE`** — because a source may carry the same account number as both
an amount row and a statistic row, separated only by a type column. Without it
in the key those two get one classification row and one `H1`, so one of them is
misrouted, permanently, with nothing in the build able to detect it. This is
the part that was missing from the first design and it was a blocker. **Check
it on every new lane.**

### Why the unit lives on the classification row

`METRIC_UNIT` and `AGGREGATION_TYPE` sit on a key, not a row, so every source
row sharing a key gets the same values. That is only sound if no key holds two
units — which is what check 2(d) asserts, and what the `ACCOUNT_KEY` fallback
is designed to guarantee.

The alternative, deriving the unit per row in the lane model, puts derivation
logic back on the row-level path where the classification table cannot override
it.

`AGGREGATION_TYPE` is stated rather than defaulted because defaulting to `FLOW`
asserts that a count can be summed across periods. For a stock — an ending
member count, a closing balance — that multiplies the figure by the number of
periods and the result looks plausible. `UNRATIFIED` exists so "we do not know"
is a value rather than a guess.

## Why `H1` is the statement rather than the money axis

An earlier shape had `H1` as Revenue or Expense, with the section in `H2`. It
fails on two populations.

Statistics are neither. A room night forced into a currency hierarchy is a
count sitting in a money classification, and every downstream group-by has to
know to exclude it.

Below-the-line is neither, reliably. That section commonly holds interest
expense and gain on sale together, so signing it as a class is wrong roughly
half the time. Keeping it as its own `H1` value means its sign is decided per
account, and until someone decides, the amount publishes unsigned rather than
wrong.

Once `H1` spans statistics, balance sheet and unclassified, it is the statement
— and then one column routes every row and there is no second routing mechanism
to keep in sync.

## Why an unsigned amount is better than a signed guess

A wrongly signed figure reconciles. It passes every count, every sum, every
idempotency check, and it is wrong by twice its value. Nothing in the build can
find it.

A null sign is loud. The amount is carried, the row is counted, and it
contributes nothing to any total until someone decides. The cost is that some
totals are incomplete; the benefit is that no total is wrong.

This is also why `SOURCE_AMOUNT` and `VALUE` both exist. One column cannot
distinguish "the polarity rule fired" from "the polarity rule was never
written".

## Why one measure column, not two

An earlier draft gave the operating metrics table its own metric value column
alongside the common `STAT_VALUE`. That made the table's headline number the
one column no check reconciled, because check 3 walks the two common measures.

`STAT_VALUE` is the measure. One column, carried on every table, reconciled
everywhere.

## Why a classifier override does not move the measure

The classifier wins over the source's own `RECORD_TYPE`, which means an amount
row can land in operating metrics and a statistic row in an income statement
table. The tempting fix is to move the value into the column that table
expects.

That would be a repair, and repairs are invisible. The row carries both measure
columns unchanged, so an override shows up as a stated shift between tables in
check 3's per-measure bridge — legible, and reversible if the override was
wrong.

## Why an unresolved category takes the whole row

A row with a good account and an unmapped category has a classification worth
keeping. The temptation is to publish it to the income statement with a null
category.

The three income statement tables split on category. A fourth value has nowhere
to land, and a null category in a three-table split means a consumer summing
all three either double-counts or misses it depending on how the split was
written. Sending the row to unknown keeps the published tables strictly
three-valued.

But it carries its classification with it — `H1` through `H5`, the unit, the
aggregation type. Discarding them would make it impossible to report what the
unknown population *would* have classified as, which is the most useful thing
about it.

## Why the dictionaries are staged

The seed needs the source dictionaries to propose a classification. It could
read `CLN.CLEAN` directly, but then reads no longer flow downhill and the layer
table is a lie.

Staging them costs one model each, they are small, and they reconcile
trivially. In exchange, every layer's read list stays true and the seed has
exactly one upstream.

## Why one transformation procedure per lane

Separate procedures per stream, each joining to the classification table
independently, is several chances to write the join slightly differently.

The failure that creates is invisible to the headline check: a row misrouted
between two streams still lands in exactly one, so the count invariant passes
while the classification is wrong. One join, one source of truth, removes it.

## Why three income statement tables rather than one with a category column

A check against a whole table is a comparison. A check against a predicate is a
comparison plus a predicate, and the predicate can be wrong.

The category column still exists on the row, so check 2(g) asserts it agrees
with the table it is in — without that assertion the split buys nothing,
because a row in the wrong table with the right column value is undetectable.

## Why the review views are a report, not a worklist

They were a worklist in an earlier model, when people edited the pipeline's own
classification table. They are not now.

What they are for is telling the owner what will need attention in the master
after promotion, and giving a sense of how well the derivation rules performed
on a new source. A lane with ten unclassified keys needs a different
conversation from one with ten thousand.

They are evaluated in order so a key appears on exactly one, because
overlapping lists cannot be read as progress. The awaiting-sign list has a
permanent floor — below-the-line, allocations and balance sheet accounts seed
unsigned by design — so the floor is stated rather than discovered.

## Why `RUN_ID` exists from the skeleton

Not for check 5, which excludes it from the hash precisely so two runs match.
Its consumers are the review report's "new this run", the first-seen and
last-seen columns on the classification table, and run logging.

A `VARCHAR` column costs almost nothing early and cannot be retrofitted
cheaply once a dozen tables exist without it. Being timestamp-derived, it also
removes the need for a separate creation timestamp — two columns saying the
same thing, both excluded from the idempotency hash.

Each MAIN stamps its own, because every consumer lives inside one layer. No
check or report needs the layers to share an ID, so passing one between them
would be complication with no use.

## Why per-source MAINs rather than one cascade

The promoted environment runs every company through one master orchestrator.
A build whose MAINs called each other would have to be unpicked at every
promotion: its wiring encodes one build's order, not the master's. A MAIN per
lane per layer, calling nothing but its own models, moves whole and is called
by whatever owns the order there.

Semantic is the exception because it is where the lanes meet. Its six models
union every source, so a per-lane semantic MAIN would rebuild tables holding
other companies' rows. Instead each lane contributes a self-contained, marked
block to each semantic model, and promotion pastes that block into the master
model as one more `UNION ALL` branch.

Transformation reads the classification in one marked place for the same
reason: in the build it reads the seeded table, once promoted it reads the
master, and the difference should be one line, not a search.

Nothing catches exceptions because nothing has a child to report on. An
uncaught error leaves the MAIN with its origin intact, and whatever called it
stops.

## Why the environment is cleared between builds

Every check groups by lane, so two lanes reconcile exactly as rigorously as
fifteen. A clean environment adds nothing to prove and removes a real risk: a
new build cannot break a lane that already works.

The promoted environment eventually holds one model unioning every path. That
is possible precisely because the lanes are already identical in shape by the
time anything reaches `SEMANTIC`.
