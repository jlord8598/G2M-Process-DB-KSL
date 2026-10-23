# Open questions - build 04 (rebuild of KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

Numbered within this build. Figures come from queries run on 2026-10-22
against `CLN.CLEAN`; detail is in `docs/sources.md` and `M1.md`.

**Build 01's answered questions are carried into this build as decisions**
unless this extract contradicts them:
- record type (Q-01, Q-15);
- `ITEM_TAG` / `LABEL` as `SOURCE_ITEM_ID`, null on the ledger (Q-02, Q-06,
  Q-14);
- department from segment 1 (Q-03);
- `TOT*` subtotals (Q-05; amended for this build by Q-05 below);
- labor as a fact (Q-06), bookings as a pacing-side dictionary (Q-07);
- the overlap note (Q-09), the digit table for 2 and 8 (Q-10, Q-11),
  malformed codes (Q-12);
- the scenario mapping (Q-04; extended by Q-03 below).

Build 01's Q-08 (pace window) is answered by this extract: the forward
position is present (M1.md, Pacing).

## Answered at stop 1

| # | Question | Owner's answer (stop 1) |
|---|---|---|
| Q-01 | Lane declaration and scope | Confirmed: 13 tables per lane. The two COA tables are staged as `STG_{LANE}_COA`. |
| Q-02 | Source of `DEPARTMENT_NAME` | The COA name only where a department code has exactly one name, otherwise null. The rule is recorded in `sources.md`. |
| Q-03 | Smart Forecast | `FORECAST`, scenario verbatim, in both lanes by exact name. Other zero-row scenarios stay unmapped. |
| Q-04 | KSL ledger stat codes in `GL_ACCT` | Report only; no repair. M1 found a second code (`900-9999-000`, 456 rows); the same answer applies. |
| Q-05 | Subtotals | `IS_SUBTOTAL = TRUE` for `TOT*` tags and for any tag the COA flags as a total; `SUBTOTAL_SOURCE` states which rule applied. At M3, compare a sample of the COA-flagged non-`TOT` rows with their detail and report the match rate. **See Q-08.** |
| Q-06 | Retire `STG_SHARED_CHART_OF_ACCOUNTS` | Retire as proposed. |
| Q-07 | Freeze window | Ends 2026-10-25 14:27 PDT. The owner is asking about PEREGRINE's daily, ledger and labor history; treat what is visible as the extract. |

## Answered at stop 2 (M1 approved)

| # | Question | Owner's answer (stop 2) |
|---|---|---|
| Q-08 | Q-05 meets account-coded detail | Approved as proposed. The COA total flag applies only to tags with no account and no stat account. `I00058`, `I00114` and `I00382` stay unflagged, with the reason in `SUBTOTAL_SOURCE`. The M3 sample covers all three groups (`TOT*`, COA-flagged calculated lines, the three unflagged tags). |
| Q-04 (extended) | `900-9999-000` in KSL ledger `GL_ACCT` | Report only, as proposed. |
| Q-09 | KSL 2024 labor labels without a prefix | Report only; Q-06 kept (`DEPARTMENT` null). |
| Q-10 | Forward pacing rows | Report only; built as-is. |
| Q-11 | KSL ledger status `S` | Report only; carried as an attribute. |
| Q-12 | Malformed codes, trailing tab | Report only; not repaired. |
| Q-13 | **New check (business validation).** PEREGRINE `ASSET_NAME` is empty on about 2.3% of actual rows in DEV1. | At M3: profile which tables and periods carry a blank `SITE_NAME` in the source, and whether any table in this lane states the name for those sites. Report only; no fix without the owner's approval. |

## Raised at stop 2 (now answered above)

| # | Lane | Question | Blocks | Proposal |
|---|---|---|---|---|
| Q-08 | KSL | **Q-05 meets account-coded detail.** The COA flags `IS_TOTAL_LINE` on three KSL tags that are **not** calculated lines and carry real accounts on every fact row: `I00058` RESERVATION EXPENSE (`115-7652-000`, 4,982 rows), `I00114` SERVICE CHARGE PAY (`193-6722-000`, 1,681), and `I00382` MANAGEMENT FEES (`860-7520-000`, 6,938); 13,601 daily and monthly rows in all. Read literally, Q-05 marks them subtotals, so consumers excluding subtotals would lose those expenses. Every other COA-flagged tag is a calculated line with no account (KSL 57,439 rows, PEREGRINE 323). | **M3** | Apply the COA-flag rule only to tags with no account and no stat account. The three tags stay `FALSE`, with `SUBTOTAL_SOURCE` recording "COA IS_TOTAL_LINE on account-coded detail: unflagged". The M3 sample comparison then covers all three groups. |
| Q-09 | KSL | **2024 labor department labels have no numeric prefix.** 112,679 rows, 196 labels, 14 sites, 2024-01-01 to 2024-12-05 (`Front Office`, `Kitchen`, `Unknown (Punch Maintenance Needed)`, ...). From 2024-12-16 every label has a prefix. Under build 01 Q-06 their `DEPARTMENT` is null, so the key part is `~BLANK~` and `DEPARTMENT_NAME` is null. Mapping a name to a code would be inference. | no | Keep Q-06 and report the population. These are new keys (history), not moved ones. |
| Q-10 | both | **Pacing now has forward rows.** At build 01 every pace row trailed its as-of date (build 01 Q-08). Now 265,627 of 481,337 KSL transient rows and 76,755 of 79,160 PEREGRINE transient rows are on or after the as-of; rooms and events are similar. PEREGRINE's three pace tables are populated, with 4 snapshots. | no | Report; pacing is built as-is, with the as-of carried. |
| Q-11 | KSL | **Ledger status `S` (49 rows) is new.** Build 01 saw only `E` and `N`. Its meaning is not stated. | no | Carry as an attribute, as `STATUS` already is. |
| Q-12 | KSL | **Malformed codes have grown,** and one carries a control character. 212 malformed account values (59,173 rows) and 31 malformed stat values (43,468 rows), including `...-BOGUS` codes. The ledger `GL_ACCT` `100-4030-006` plus a trailing tab appears on 220 rows. `trim()` keeps the tab, so it keys apart from `100-4030-006` and seeds `Unclassified`. PEREGRINE: 0 malformed accounts, 6 stat values (704 rows). | no | Build 01 Q-12: carried raw, not repaired. The tab is listed for correction at source. |

## Raised at stop 3 (answered below)

| # | Lane | Question | Blocks | Proposal |
|---|---|---|---|---|
| Q-13 | PEREGRINE | **Blank `SITE_NAME` (profiled at M3).** Only the ledger is affected: 9,468 of 31,791 rows (CABRDOP 1,426, CASVROP 6,614, CAYRDOP 788, PABMROP 640; 2026-06 to 2026-08), with `SITE_NAME` null. Every other PEREGRINE table and every KSL table is fully named. The source states the name for all four sites in `SITES` (unique on `SITE_TAG`), in `SITE_GROUPS`, and on every other fact table, with one name per site. | no | Your call. Fix option: `ASSET_NAME = coalesce(SITE_NAME, STG_{LANE}_SITES.SITE_NAME)` on `SITE_TAG`, recording the source used. Not applied; staging carries the blank as booked. |

## Answered at stop 3 (M3 approved)

| # | Question | Owner's answer (stop 3) |
|---|---|---|
| Q-13 | PEREGRINE blank `SITE_NAME` | Yes. Where a fact row's `SITE_NAME` is null, fill `ASSET_NAME` from `STG_{LANE}_SITES` on an exact site-code match. Record which source supplied the name and report the rows each covers. Apply it to every KSL/PEREGRINE fact model with the same gap. |
| Q-02 (follow-up) | `DEPARTMENT_NAME` | Keep the one-name-per-code rule for now; the owner is asking the source owner whether the API has a department list keyed by code. `classification-coverage.md` reports how many KSL and PEREGRINE rows lose a department name compared with build 01, and why (COA `DEPARTMENT_NAME` holds report groupings, up to 56 per code). |

**How the stop-3 answers were applied.**
- **Q-13.** `ASSET_NAME` falls back to `STG_{LANE}_SITES` in all 8 fact
  models, and `ASSET_NAME_SOURCE` records which source supplied it. It
  covered 9,468 PEREGRINE ledger rows; every other row uses the fact's own
  `SITE_NAME`, and none is left null (`field-lineage.md`).
- **Q-02.** The loss against build 01 is 2,427,596 KSL rows and 450,482
  PEREGRINE rows (`classification-coverage.md`).

## Open at stop 4

| # | Lane | Question | Blocks | State |
|---|---|---|---|---|
| Q-02 | both | **A department list keyed by department code.** The owner is asking the source owner. Until one exists, `DEPARTMENT_NAME` is null wherever the COA's report-grouping names disagree. | no | One-name-per-code rule, as built. |
| Q-14 | KSL | **Monthly expense sign outliers:** 751 keys run negative against a positive class (-85.4M). They were not examined by account. | no | Report only, for the master. |
| Q-15 | KSL | **6 `100-9036-000` `AMOUNT` keys** (stat code booked in ledger `GL_ACCT`, `STATISTICAL OFFSET`) seed `Allocations & Reserves` by digit 9. | no | Report only (Q-04); listed for correction in the master. |

## Answered at stop 4 (build 04 approved)

| # | Owner's answer (stop 4) |
|---|---|
| Q-02 | Waits on the source owner (a department list keyed by department code). No build change until then. |
| Q-14 | Open for the master; no build change. |
| Q-15 | Open for the master; no build change. |

