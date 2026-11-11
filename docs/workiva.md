# Workiva Property Level table

`REPORTING.RPT_WORKIVA_PROPERTY_LEVEL` replaces the iLevel landing sheet's
"Property Level" tab as the source for Workiva. Built for KSL, Q3 2026 onward.

| | |
|---|---|
| Owner | G2M (Joseph Lord) |
| Environments | DEV1, TEST, PROD (same code, database prefix swapped) |
| Current versions | `SPROC_RPT_WORKIVA_ITEM_MAP` v10.15, `SPROC_RPT_WORKIVA_PROPERTY_LEVEL` v10.13 |
| Scope | Heritage Golf Group (Fund V) + Fund VI portfolio companies (Monaco excluded: realized) |
| Source today | iLevel, through `CLN` and the iLevel-based `SEMANTIC` schema. **Not** `DEV_G2M_AI` |
| Deploy | Manual. Not part of `SPROC_PROMOTE` (REPORTING holds another team's tables) |

## Objects

| Object | Built by | Purpose |
|---|---|---|
| `RPT_WORKIVA_ITEM_MAP` | `SPROC_RPT_WORKIVA_ITEM_MAP` | How each Workiva data item is built (source, selector, sign, aggregation, owner rule) |
| `RPT_WORKIVA_OWNER_CONFIG` | `SPROC_RPT_WORKIVA_ITEM_MAP` | One row per owner (portfolio company): scope and per-owner rules |
| `RPT_INVESTMENT_NAME_OVERRIDE`, `RPT_TIMEFRAME_DEF` | `SPROC_RPT_WORKIVA_ITEM_MAP` | Display-name exceptions; timeframes (Month, L3M, FYTD, LTM, ReportingPeriod) |
| `RPT_WORKIVA_PROPERTY_LEVEL` | `SPROC_RPT_WORKIVA_PROPERTY_LEVEL` | **The deliverable.** Landing-sheet layout plus helper columns |
| `RPT_WORKIVA_VALIDATION` | `SPROC_RPT_WORKIVA_PROPERTY_LEVEL` | Tie-out against the landing-sheet baselines (validation only) |
| `HERITAGE_` / `FUND6_LANDING_BASELINE_2026Q3` | Loaded / cloned once | Landing-sheet snapshots. **Validation only; never a build input** |

## Sources

- `SEMANTIC.SEM_INCOME_STATEMENT_ACTUAL` (iLevel income statement, via the xref)
- `CLN.CLEAN.CUR_ILEVEL_PERIODIC_DATA` (KPIs, valuation, ownership, reported items)
- `CLN.CLEAN.CUR_ILEVEL_CASH_TRANSACTION` (fund returns: IRR, multiples, capital)
- `CLN.XREF.XREF_INCOME_STATEMENT_DATA_ITEM_MAPPING` (investment list, owner, line flags)
- `CLN.XREF.ASSET_ATTRIBUTE` (`STORE_MATURITY` = segment)

## Running it (quarterly)

```sql
call <ENV>.REPORTING.SPROC_RPT_WORKIVA_ITEM_MAP();
call <ENV>.REPORTING.SPROC_RPT_WORKIVA_PROPERTY_LEVEL('2026-09-30'::date);
```

Refresh `SEMANTIC` first (`TRANSFORMATION.SPROC_XFRM_INCOME_STATEMENT`, then
`SEMANTIC.SPROC_SEM_INCOME_STATEMENT_ACTUAL`) if the xref or iLevel data changed.

The second call builds every owner with `in_scope = true` in the owner config.
Passing an owner list as the second argument overrides that (testing only).

## Changing scope or rules

Edit `SPROC_RPT_WORKIVA_ITEM_MAP.sql`, redeploy, call it. Manual updates to the
config tables are overwritten on the next run.

- **Add / remove a portfolio company:** row in the owner config insert; `in_scope` update.
- **Per-owner rules** (owner config columns):

| Column | Meaning | Set for |
|---|---|---|
| `child_rows` | Emit property-level rows | Heritage, Mission Hill 2.0, Maldives |
| `pre_coh_rule` | `REPORTED_PRE_COH` = use iLevel's reported Pre-COH | Invited Clubs |
| `reserve_pct` | Replacement reserve = % of revenue | Hersha (4%, confirmed by KSL) |
| `comp_rooms_in_occupied` | Add iLevel Comp Rooms to occupied rooms | Martin, Maldives |
| `owner_level_kpis` | Rounds / membership on the owner row | Invited Clubs |
| `overhead_from_ebitda` | Overhead = owner's own `REPORTING_EBITDA` | The Pig |
| `in_scope` | Built by the quarterly run | All but Monaco |

## Definitions agreed with KSL (David, Nov 2026)

- **EBITDA** = before corporate overhead, every hotel portco. **Adjusted EBITDA** = after overhead (Post-COH).
- **Pre-COH EBITDA excludes non-operating owner expenses** (insurance, leases, property tax, other non-op); management fees stay in. This lives in the xref (`EBITDA_MINUS_COH = 0` on those lines), not in code.
- **RC** = the portfolio company's own currency for operating items; fund returns in USD.
- **Mid-year acquisitions** count every month since acquisition in FYTD / LTM (Palisades, from June 2026).
- Values where the landing sheet shows "No Data Available" are kept.
- The landing sheet is outdated; validate against KSL's latest reports going forward.

Principle: business rules live in the xref, asset attributes or the owner config,
never in iLevel or the landing sheet.

## Promotion (DEV1 -> TEST -> PROD)

1. Copy both procedure files; replace `DEV1.` with `<ENV>.` (leave `CLN.` alone).
2. Run All on each file. If the old v9 procedure exists, the `DROP PROCEDURE` line at
   the top must run first (`(DATE, NUMBER, DATE, NUMBER, NUMBER)` signature).
3. Optional: `create or replace table <ENV>.REPORTING.<baseline> clone DEV1.REPORTING.<baseline>;`
4. Call both procedures; the run summary should match DEV1.

**Grants:** schema future grants cover the G2M and service roles. `KSL_USER` has
manual `SELECT` on `RPT_WORKIVA_PROPERTY_LEVEL` and `RPT_WORKIVA_ITEM_MAP`, kept
across reruns by `COPY GRANTS`. No schema-wide grant to `KSL_USER` (other teams'
tables share the schema).

## Validation statuses

`TIED`, `OPEN`, `TIED_ZERO` (No Data vs 0), `ADDED_VALUE` (we have a value, sheet
blank), `OUTPUT_NO_DATA`, `NOT_IN_OUTPUT*`, `MAYBERN` (Net Fund AUM, Unfunded
Commitment: Maybern's), `OUT_OF_SCOPE_CURRENCY` (AUD/EUR/GBP translations),
`ITEM_NOT_MAPPED`, `TEMPLATE_ERROR`, `COMBINED_ROW`, `BOTH_NO_DATA`.

Q3 2026 (DEV1): TIED 3,493, OPEN 76. Open rows are confirmed sheet differences
(Pig EBITDA, Palisades timing, Heritage zeroed fund returns, golf membership,
Pig blank-owner totals) or waiting on the data team (Mission Hill 2.0 xref flags,
Invited Clubs expense double count in SEMANTIC).

## Moving to G2M direct integrations (`DEV_G2M_AI`)

Planned: switch a portfolio company from iLevel to its lane only after it reconciles,
at a quarter boundary, with one source per portfolio company per data domain
(fund returns stay on iLevel / Maybern). Prerequisites:

- A site-to-investment crosswalk (`SEM_AI` tables have `source_lane` +
  `source_site_code` only; proposed `CLN.XREF.XREF_SOURCE_SITE_INVESTMENT`).
- Reviewed account mappings (all UNREVIEWED today).
- Currency: `SEM_AI` keeps the booked currency per row (`CURRENCY_CODE`), which matches
  Workiva's RC convention; no FX needed for operating items.
- KPI coverage from actuals (pacing is forward-looking and not used): occupied /
  available rooms to confirm per lane; HHG rounds landed; membership not landed (N-31).
- History back to 2023-03.

Suggested first pilot: Heritage income statement (HHG lane).
