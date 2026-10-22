# DRAFT: rebuild decision for CLAUDE.md (for review; not applied)

## 1. New subsection in section 2, after "A build changes only its own lanes."

**A build may rebuild an existing lane.** The owner declares it at M1: which
existing lanes are rebuilt, and why (a source table changed, replaced or was
removed). A rebuilt lane keeps its name, so its classification rows and the
master's rows for it, corrections included, still apply. For a rebuilt lane
the build may:

- replace the lane's staging models, its transformation procedure and its
  three MAINs;
- replace the lane's branch in the seeder and its lane block in each of the six
  semantic models;
- retire objects that only the rebuilt lanes used (drop the procedure and its
  table in `DEV_G2M_AI` and remove its file from `sql/`). In a promoted
  environment the owner drops them by hand, because promotion never deletes.

It may not delete or update the lane's classification rows. The merge stays
insert-only: existing keys keep their classification, and only keys new to
this extract are proposed.

**A rebuild must prove its keys did not move.** The key rule (D-05, D-06,
D-07) is the same as before, so the five-part key of every source line comes
out as it did. At M4, report for each rebuilt lane:

- existing keys the new staging reproduces;
- keys that are new in this extract, which must be explained by new data
  (new accounts, sites, months), never by a changed derivation;
- existing keys no longer produced (dead keys, kept, D-14).

If an existing account comes out under a different key, stop: that is a
derivation change, and it would orphan the master rows people have corrected.

Every lane not being rebuilt is covered by the earlier-build baseline in
check 5 as usual. The rebuilt lanes are excluded from that baseline and
covered by the key report above.

## 2. M1 row (section 12): add after "Confirm the repo is archived"

For a rebuild, list the lanes being rebuilt and read their archived build
record in `docs/completed-builds/` first: it shows how the key was built, and
the rebuild must build it the same way.

## 3. Decisions table

- D-32, add: "A rebuild re-declares an existing lane under its existing name
  (D-44); that is the only reuse of a name."
- D-42, add: "except for lanes the owner declares rebuilt (D-44)."
- New row:

| D-44 | Rebuilding a lane | The owner may declare existing lanes rebuilt at M1. The build may replace those lanes' code, seeder branch and lane blocks, and retire objects only they used. Classification rows are never deleted. The key rule is unchanged, and M4 proves it: existing keys reproduced, new keys explained by new data, dead keys kept. Any existing account appearing under a different key is a stop. |

## 4. AGENTS.md "Never" list, amend the D-42 line

"...change another lane's classification rows (`CLAUDE.md` D-42), except for
lanes the owner has declared rebuilt (D-44), and even then never their
classification rows."
