# Proposed CLAUDE.md changes (build 15, for owner approval at stop 4)

Not applied: CLAUDE.md is the owner's to edit. The build already implements each change; the text brings the document in line with it.

## 1. New decision D-50 (owner Q-03)

```diff
+| D-50 | Source sign convention | Each fact staging table states how its source books money in `SOURCE_SIGN_CONVENTION`, one value per table with its evidence in `SOURCE_SIGN_CONVENTION_SOURCE`, proved at M1 against the source's own totals or structure and approved by the owner: `PRESENTED` (revenue and costs both positive), `DEBIT` (debits positive, credits negative), `PROFIT` (revenue positive, costs negative). Transformation applies it: `PRESENTED` VALUE = SOURCE_AMOUNT x VALUE_SIGN; `DEBIT` VALUE = -SOURCE_AMOUNT; `PROFIT` VALUE = SOURCE_AMOUNT; VALUE is null wherever VALUE_SIGN is null. SOURCE_AMOUNT stays as booked; the classification's VALUE_SIGN is unchanged (D-13), so no classification row changes. Carried on the transformation streams. **Conventions:** HERSHA (build 15): GL_ACTUAL, TB_ACTUAL DEBIT; GL_STAT PRESENTED. BEAUMIER (build 15): BP, BUDGET PROFIT. HHG (build 15): FORECAST_ANAPLAN PROFIT; TR12_DATA, ROUNDS_DETAIL, BUDGET_BY_CLUB PRESENTED. JW_VENICE, NEWBURY (build 15): every table PRESENTED. A lane not listed is PRESENTED until its next build or rebuild. |
```

## 2. Section 5, VALUE_SIGN follows NORMAL_BALANCE

After "`Mixed` is the honest answer ... until someone decides per account.":

```diff
+**`VALUE` also depends on how the source books (D-50).** `VALUE_SIGN` is a
+property of the class; whether a source line already carries the class's sign
+is a property of the source table. Staging states the table's convention in
+`SOURCE_SIGN_CONVENTION`, and transformation computes `VALUE` from both:
+`PRESENTED` multiplies by `VALUE_SIGN`, `DEBIT` negates, `PROFIT` keeps the
+amount. A null `VALUE_SIGN` still means a null `VALUE`.
```

## 3. Check 2(h)

```diff
-| h | No row where `SOURCE_AMOUNT` and `VALUE_SIGN` are **both** non-null and `VALUE` is null or differs from the product beyond `0.005`; and none where `VALUE` is non-null while `VALUE_SIGN` is null | `SEMANTIC` |
+| h | No row where `SOURCE_AMOUNT` and `VALUE_SIGN` are **both** non-null and `VALUE` is null or differs beyond `0.005` from the D-50 value (`PRESENTED` SOURCE_AMOUNT x VALUE_SIGN, `DEBIT` -SOURCE_AMOUNT, `PROFIT` SOURCE_AMOUNT); and none where `VALUE` is non-null while `VALUE_SIGN` is null | the income statement `XFRM` streams, which carry `SOURCE_SIGN_CONVENTION`; and `SEMANTIC` for the null-sign half |
```

## 4. D-48: build 15 rules (owner Q-08)

```diff
-... and the first 98xxxx hours block beats its repeat (`<code> \| <text> \| #n`). UNDER_CANVAS (build 14): ...
+... UNDER_CANVAS (build 14): ... (N-25). HHG (build 15): within `CLN_HERITAGE_GOLF_FORECAST_ANAPLAN`, the latest `FILE_DATE` wins per entity + month + scenario; an older file's rows count only for entity-months the latest file lacks entirely. BEAUMIER (build 15): the same rule within `CLN_BEAUMIER_BP`. |
```

(Appended to the existing D-48 text after the UNDER_CANVAS rule; nothing else in D-48 changes.)
