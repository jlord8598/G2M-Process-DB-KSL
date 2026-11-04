# Proposed CLAUDE.md changes (build 12, for owner approval at stop 4)

Not applied: CLAUDE.md is the owner's to edit. The build already implements
each change below; the text brings the document in line with it.

## 1. Section 4, common columns: CURRENCY_CODE (owner Q-06 / Q-10)

```diff
 SOURCE_AMOUNT            FLOAT         -- as booked, sign included
+CURRENCY_CODE            VARCHAR       -- ISO code of SOURCE_AMOUNT, per lane from
+                                       -- source evidence or owner confirmation;
+                                       -- 'MIXED' / 'UNCONFIRMED' where not settled
 STAT_VALUE               FLOAT         -- the statistic measure
```

Add, after the paragraph "**`SOURCE_AMOUNT` is carried as booked, sign included.** ...":

```diff
+**`CURRENCY_CODE` states the currency of `SOURCE_AMOUNT` and `VALUE`.** Set
+per lane, from what the source states or the owner confirms, and recorded in
+`docs/sources.md`. It is never converted. Where a lane holds more than one
+currency and its rows cannot yet carry their own, the value is `MIXED`; where
+nothing states it, `UNCONFIRMED`. Both are logged in `docs/open-items.md`.
+Amounts in different currencies are never summed.
```

Values in this build's lane blocks:

| Lane | CURRENCY_CODE | Basis |
|---|---|---|
| KSL_SELECT_SERVICE, PEREGRINE_RESORTS, HHG, NEWBURY, HERSHA, DAVIDSON, ATLANTIC_AVIATION | USD | owner-confirmed (Q-10) |
| INVITED_CLUBS | USD | META_ENTITY.BASE_CURRENCY (stated) |
| JW_VENICE | EUR | report header "Currency Code: EUR" (owner) |
| BEAUMIER | MIXED | hotels EUR / CHF via LOCATION_MAP; per-row carry deferred (N-19) |
| ALTERRA | UNCONFIRMED | Canadian entities; not stated (N-18) |

## 2. Section 4: source unit scale (owner Q-07)

```diff
 **`SOURCE_AMOUNT` is carried as booked, sign included.** A source that books
 expenses negative keeps those negatives. The build applies no sign of its own;
 that is `VALUE`.
+
+**One exception: a stated unit scale.** Where a lane's source states that its
+figures are in thousands (or another unit) and the data proves it, staging
+carries the value as booked with `SOURCE_UNIT_SCALE` and its evidence in
+`SOURCE_UNIT_SCALE_SOURCE`, and transformation multiplies `SOURCE_AMOUNT` and
+`STAT_VALUE` by it. Only measures the data proves are scaled; the rest carry
+scale 1. Approved per lane and listed in D-49. The reconcile states CLN = STG
+as booked, and CLN x scale = STG x scale = XFRM = SEM.
```

New decision:

```diff
+| D-49 | Unit scale | A lane's stated source unit is applied in transformation from a staged `SOURCE_UNIT_SCALE`, only for measures the data proves, as approved by the owner and listed here. Staging stays as booked. **Scales:** ATLANTIC_AVIATION (build 12): x1000 for every dollar line, Fuel Margin and Gallons ("(000's)"; Fuel Revenue / Gallons = 5.11 per gallon as stored); MPG, Landings, Trips x1 (N-17). |
```

## 3. D-48: JW_VENICE rules (owner Q-02, Q-03, Q-09, Q-11)

```diff
-... ALTERRA (build 11): the resorts' "... - Rentals & Repairs - Ski Butlers" lines in `CLN_ALTERRA_MONTHLY_FINANCIALS` beat the Ski Butlers entity's "Alterra Resorts" section copy of them.
+... ALTERRA (build 11): the resorts' "... - Rentals & Repairs - Ski Butlers" lines in `CLN_ALTERRA_MONTHLY_FINANCIALS` beat the Ski Butlers entity's "Alterra Resorts" section copy of them. JW_VENICE (build 12): for `ACTUAL` in 2025-08 and 2026-08, `CLN_JW_VENICE_MONTHLY_PL_DEPT` beats `CLN_JW_VENICE_FCAST_ACT_FORECAST` and `CLN_JW_VENICE_FCAST_BY_PERIOD`; within `CLN_JW_VENICE_MONTHLY_PL_DEPT`, `PERIOD_TYPE` MONTH beats YTD, the TOT_HTL sheet beats every other sheet (the 16 department sheets, CB included), and the first 98xxxx hours block beats its repeat (`<code> | <text> | #n`).
```
