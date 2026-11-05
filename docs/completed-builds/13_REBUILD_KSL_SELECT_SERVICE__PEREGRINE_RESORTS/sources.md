# Sources - build 13 (rebuild of KSL_SELECT_SERVICE, PEREGRINE_RESORTS)

**State: stop 1.** Written from queries run in this session against `CLN.CLEAN`. Build 04 / 05 records (`docs/completed-builds/`) describe how the key was built; this build must build it the same way.

## Source schema and freeze (D-43)

- **Source:** `CLN.CLEAN`, 27 tables (the 26 per-tenant ProfitSword tables and the shared `CUR_PROFITSWORD_DEPARTMENTS`), exactly the tables these lanes' deployed staging code reads.
- **Freeze:** from **2026-11-04 14:02:31.718 PST** (first successful read) to **2026-11-05 06:00 America/Los_Angeles**. If the build runs past 06:00 it continues only while the D-43 check shows no change.
- **Extract:** all 27 tables recreated 2026-11-04 01:20:15 to 01:21:10 PST (before the freeze).
- **Baseline (`scripts/d43_check.sql`):**

| Table | Rows | HASH_AGG(*) |
|---|---|---|
| CUR_PROFITSWORD_DEPARTMENTS | 1,524 | -4769948639303968173 |
| CUR_PROFITSWORD_KSL_ACCOUNT_CLASS | 54 | -9077950097647059783 |
| CUR_PROFITSWORD_KSL_COA | 8,634 | -1408529459157179808 |
| CUR_PROFITSWORD_KSL_DAILY_EXTENDED | 13,193,369 | -1477134767756980351 |
| CUR_PROFITSWORD_KSL_DAILY_LABOR | 787,419 | 9108941632935292262 |
| CUR_PROFITSWORD_KSL_DATASETS | 24 | -7798930584592928406 |
| CUR_PROFITSWORD_KSL_LEDGER_BATCHES | 1,027,090 | 347618745738077768 |
| CUR_PROFITSWORD_KSL_MONTHLY_EXTENDED | 1,241,063 | 8827083392530679151 |
| CUR_PROFITSWORD_KSL_SALES_BOOKINGS | 19,344 | 8294909691007090918 |
| CUR_PROFITSWORD_KSL_SALES_PACE_EVENTS | 27,733 | -6080058670045861678 |
| CUR_PROFITSWORD_KSL_SALES_PACE_ROOMS | 47,979 | -1342819542014119778 |
| CUR_PROFITSWORD_KSL_SALES_PACE_TRANSIENT | 481,337 | -4663166724712669791 |
| CUR_PROFITSWORD_KSL_SITES | 41 | -2364632047807362331 |
| CUR_PROFITSWORD_KSL_SITE_GROUPS | 137 | -2828211983003164952 |
| CUR_PROFITSWORD_PEREGRINE_ACCOUNT_CLASS | 123 | 3151850940166204947 |
| CUR_PROFITSWORD_PEREGRINE_COA | 22,555 | -7518664759051017925 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_EXTENDED | 2,358,860 | 2097405821673023607 |
| CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR | 354,052 | -5594625161567808514 |
| CUR_PROFITSWORD_PEREGRINE_DATASETS | 15 | -5513936796430517321 |
| CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES | 37,411 | -4689096335136693383 |
| CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED | 640,793 | -2871373994763055687 |
| CUR_PROFITSWORD_PEREGRINE_SALES_BOOKINGS | 7,628 | 8335093000215399593 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_EVENTS | 481,730 | -1381455262300918084 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_ROOMS | 62,929 | 8695250766730963994 |
| CUR_PROFITSWORD_PEREGRINE_SALES_PACE_TRANSIENT | 79,160 | -792553699598088473 |
| CUR_PROFITSWORD_PEREGRINE_SITES | 6 | 4097703520649551086 |
| CUR_PROFITSWORD_PEREGRINE_SITE_GROUPS | 13 | -7449227437968030482 |

## Lanes (owner, D-44)

KSL_SELECT_SERVICE and PEREGRINE_RESORTS, rebuilt under their existing names. Each table keeps its build 04 / 05 role. CURRENCY_CODE stays USD (owner).

## The key (unchanged, build 01 / 04 rule)

| Part | Rule |
|---|---|
| SOURCE_SITE_CODE | `SITE_TAG` |
| DEPARTMENT | segment 1 of `ACCOUNT_NUMBER` / `GL_ACCT`; labor: digits before the first `.` of `DEPARTMENT_LABEL` |
| ACCOUNT_KEY | coalesce(account, stat account, `SOURCE_ITEM_ID`); `SOURCE_ITEM_ID` = `ITEM_TAG` (daily, monthly), null (ledger), `LABEL` (labor) |
| RECORD_TYPE | STATISTIC when the stat account is present and the account blank, else AMOUNT |

Applied read-only to today's extract: every existing key but 22 is reproduced; see M1.md.

## Chart structure (D-46 evidence)

Account `DDD-DDDD-DDD`: segment 1 = department, character 5 = section digit, characters 5-6 = block. COA `GL_CATEGORY` flags: digit 4 `GREV`; 5-7 `GEXP` (67 also `GLAB`); 1-3 balance flags (`CR`, `RCV`, ledger codes) or null. Block names (both lanes): 10-19 cash, receivables, inventory, fixed assets; 20-29 due-from; 30-31 A/P and taxes payable; 34-35 intercompany, passthrough; 36 accrued payroll; 37 accrued expenses; 38 deposits, deferred income, notes; 39 long-term liabilities (3900-3955) and equity (3956-3970); 40-49 revenue; 52-57 cost of sales; 67 wages and paid leave; 68 payroll taxes and benefits; 70-78 operating expenses (advertising, services, M&R, utilities); 86 other expense, rent, leases, condo owner payments; 87 amortization (8704, 8705, 8712), depreciation (8720), gains / losses, interest; 97 contract labor hours (KSL), construction in progress (PEREGRINE); 99 capital reserve (KSL).

## Subtotals: ProfitSword calculated lines

Every daily / monthly row with no account and no stat account is on a COA tag with `IS_CALCULATED_LINE` (KSL 10,872,761 rows, PEREGRINE 1,605,093). Members are stated only in `BUD_FORMULA`: an explicit `+/-` list or a single reference can be tested; `=TOT` (members not stated), other expressions and lines with no formula cannot. Q-16 results in M1.md.

## Decisions at stop 1 (owner)

- **H2 mapping (D-46, account blocks):** 1x Assets; 20-29 Assets (due-from); 30-38 and 3900-3955 Liabilities; 3956-3999 Equity; 4x Revenue; 5x COGS; 6x Payroll; 7x Operating Expenses; 8704/8705/8712/8720 Depreciation & Amortization; other 8x Other Income / (Expense); 9x Allocations & Reserves / UNCLASSIFIED. PEREGRINE block 86 -> Operating Expenses proposed (Q-05). D-44 re-seed of the affected keys only.
- **Subtotals:** SOURCE_ROLLUP + IS_SUBTOTAL on calculated lines that tie (Q-16) and on `=TOT` lines (IS_CALCULATED_LINE); the 28 that fail stay UNCLASSIFIED_ACCOUNT. Q-07 / Q-08 pending.
- **Labor:** no D-48 rule; stays UNKNOWN / UNCLASSIFIED_ACCOUNT.
- **ACCOUNT_DESC:** unchanged (already complete).
- **Budget 4 / 5:** UNKNOWN / UNRESOLVED_CATEGORY (N-21).
- **Tie-out at stop 4:** per lane, match rate and 5 largest differences.

## Build 13 staging (M3)

- DAILY_EXTENDED and MONTHLY_EXTENDED, both lanes: IS_SUBTOTAL / SUBTOTAL_SOURCE from the COA calculated-line flag, BUD_FORMULA kind and the M1 Q-16 fail list (M3.md). Every other model unchanged. Identity: long on every model.
