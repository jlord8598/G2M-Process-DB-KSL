# Sources — this build

**This document is written during M1 and is empty before it.** It records what
this build's lanes actually contain, measured rather than assumed.

Records of previous builds are in `docs/completed-builds/`. They show how
similar sources behaved and are useful for knowing what to look for. **They are
not evidence about this build's sources.**

---

## Source schema

`CLN.CLEAN` (the lanes' staging reads `CLN.CLEAN.CUR_PROFITSWORD_*`; not repointed in build 16). Load freeze: **not in place for M1** (owner); Gary's freeze is to be confirmed before any M2. Every in-scope table was reloaded 2026-11-16 01:19:06-01:19:44 PST (measured). DEV_G2M_AI staging for both lanes is the 2026-11-04 extract (daily labor 11-11), so this M1 measures CLN directly; DEV1 is not visible to this role.

| Table | row_count | last_altered (PST) |
|---|---|---|
| CUR_PROFITSWORD_KSL_DAILY_EXTENDED | 13,375,664 | 2026-11-16 01:19:23 |
| CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED | 1,250,349 | 01:19:15 |
| CUR_PROFITSWORD_KSL_LEDGER_BATCHES | 1,041,808 | 01:19:28 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED | 2,428,509 | 01:19:26 |
| CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED | 645,328 | 01:19:17 |
| CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES | 40,866 | 01:19:29 |

The other 20 CUR_PROFITSWORD_{KSL,PEREGRINE}_* tables (COA, ACCOUNT_CLASS, DATASETS, SITES, SITE_GROUPS, DAILY_LABOR, SALES_*) were reloaded in the same window; listed in findings/M1.md.

## Lane declaration

| Lane | Source tables | Notes |
|---|---|---|
| KSL_SELECT_SERVICE | CUR_PROFITSWORD_KSL_* (13) | existing lane, proposed rebuilt (D-44) for source precedence only |
| PEREGRINE_RESORTS | CUR_PROFITSWORD_PEREGRINE_* (13) | same |

Names are the owner's (build 25 request); both exist (builds 01-18). Scope as builds 13 / 18; no new table.

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

Only what build 25 measures (precedence among the three ProfitSword fact tables). Keys, account structure, subtotal rules, category and scenario are unchanged from build 13 / 18 (archived) and were not re-measured; *unverified* for this extract.

### LEDGER_BATCHES (both lanes), measured
- One batch type: `TYPE_ID` INJ, `BATCH_DESCRIPTION` "Daily Income Journal" on every line. KSL 30,895 batches, 2024-01 to 2026-11; STATUS E 1,033,193 / N 8,566 / S 49 lines (an attribute, decides nothing).
- **Double-entry journal, DEBIT convention:** on GL lines 30,319 of 30,895 KSL batches balance to 0.01 (absolute imbalance 6.3M over the rest). Revenue (digit 4) is credited: KSL net -598.1M; offsets are cash / receivables (digit 1, +678.9M) and taxes payable (digit 3, -76.7M). Expense (digits 5-7) is almost absent (KSL +3.1M). 224,864 lines carry no GL account (157,175 with a stat account).
- **Restates monthly Actuals revenue by account, sign inverted:** at site + account + month, ledger = -monthly in 22,704 of 24,543 shared KSL revenue cells (92.5%) and 1,419 of 1,698 Peregrine (83.6%). Not other sections: digit 1 259 / 4,182, digit 3 347 / 4,650 (KSL).
- D-50 does not list either lane, so the ledger is treated as PRESENTED: VALUE = SOURCE_AMOUNT x VALUE_SIGN keeps the ledger's revenue negative, and it cancels monthly.

### DAILY_EXTENDED vs MONTHLY_EXTENDED (Actuals, FCID -3), measured
- **Daily summed to the month equals monthly** at site + account + month in 99.9% of shared cells, in every section (KSL revenue 33,594 / 33,623; payroll 6xxx 124,866 / 125,103; Peregrine revenue 20,657 / 20,659). Totals: KSL revenue daily 835.4M against monthly 834.0M; Peregrine 1,103.3M against 1,102.9M.
- **Daily-only accounts** (complementary): KSL 2,141 site-account-month cells, Peregrine 83; digit 4 KSL 44 cells, 0 amount. Effectively none carry revenue or expense.
- The owner's "~12%" comes from the semantic layer: daily rows carry PERIOD_END = the business date (1,038 distinct dates), so a site-month join on PERIOD_END compares a day with a month.
- **Site-months with daily but no monthly Actuals:** KSL CAPICOP, 6 months of 2026 (also in the ledger); Peregrine CABRDOP and CAYRDOP, 24 months of 2024 (2,196 daily lines).

### ProfitSword's own totals (anchor), measured
- Only DAILY_EXTENDED carries calculated lines (no account; COA `IS_CALCULATED_LINE`). Monthly Actuals carry none.
- **Revenue:** `TOTOPRV` ("Department Sales" in KSL; "TOTAL OPERATING REVENUE" in PEREGRINE), summed to the month, equals monthly-actual digit-4 revenue in 1,262 of 1,391 KSL and 184 of 186 Peregrine site-months. `TOTSHRV` / `TOTRV01` / `TOTRV` tie less often (175, 537, 7).
- **EBITDA:** `EBITDA` equals revenue less blocks 50-78 in 1,015 of 1,398 KSL site-months; in PEREGRINE it equals revenue less blocks 50-78 and 86, in 135 of 186.
- **GOP:** `TOTGOP` ties no tested block combination (KSL 24, Peregrine 1). Its formula (TOTDPDP - TOTOHEX) is a calculated line over other calculated lines; not resolved at M1.

---

### Build 25 rules (owner stop 2)
- D-48: for ACTUAL, MONTHLY_EXTENDED (IS_ACTUALS) beats DAILY_EXTENDED and LEDGER_BATCHES at every site-month it carries; DAILY_EXTENDED beats LEDGER_BATCHES where monthly is absent (KSL CAPICOP 2026). Every section, calculated lines included. Every ledger line is in UNKNOWN (it is a journal, not balances; Q-02).
- D-50: LEDGER_BATCHES DEBIT, both lanes; the rest PRESENTED. Set in transformation by SOURCE_TABLE (Q-01, Q-11).
- Stop 4: PEREGRINE "Budget 4" / "Budget 5" stay in UNKNOWN (UNRESOLVED_CATEGORY) pending Gary (N-21); their 2(e) count is data-driven. Seed notes on 128 equity keys left (Q-10).
- GOP is unanchored (TOTGOP ties no classification-based GOP; N-68). Revenue anchor: TOTOPRV. EBITDA anchor: ProfitSword's EBITDA, by each lane's own definition (PEREGRINE ties with block 86 subtracted; KSL subtracts it at some sites and months only, N-22).

---

## Corrections

- Build 01's "filter on SOURCE_TABLE" guidance for the actual income statement is superseded by the D-48 rule above.
- The DEV1 figure "daily is ~12% of monthly" was a grain artefact (daily PERIOD_END is the business date). Daily = monthly at 99.9% of site-account-months.

**When a measurement contradicts something written here, correct it and say
so.** A finding that a documented rule is wrong is worth more than a clean run.
