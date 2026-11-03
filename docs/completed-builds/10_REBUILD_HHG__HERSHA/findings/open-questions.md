# Open questions - build 10

| # | Lane | Question | Blocks |
|---|---|---|---|
| Q-01 | HHG, HERSHA | **Scope.** Assign the 4 new HHG tables (`ASSET_CODES`, `CHART_OF_ACCOUNTS`, `DEPARTMENT_KEY`, `TR12_ACCOUNTS`) and HERSHA `TB_ACTUAL` to their lanes (staged as dictionaries / a fact)? Everything else in the schema stays out of scope. | M3 |
| Q-02 | HHG | **ASSET_NAME source:** switch from `REFERENCES.CLUB_NAME` (45 entities, names with dates appended) to `ASSET_CODES.CLUB_NAME` (50 entities, bare names, 9050-9054 newly named)? This changes ASSET_NAME text for 39 entities (attribute only, no key). | M3 |
| Q-03 | HHG | **D-46 H2 mapping from the COA `ACCOUNT_TYPE`:** Revenue -> Revenue; Cost of Sales -> COGS; Labor -> Payroll; Operating Expense -> Operating Expenses; Other Income -> Other Income / (Expense); Below EBITDA -> OI/E except 82000/82100/82200 -> D&A and 84000 -> Income Taxes; Statistical unchanged. Changes 3,183 keys (2,727 Payroll -> Opex). Keys with no COA row keep today's rule. **Exception:** 51050 / 51060 "Cost of Retail Wine / Food Sales" are typed Revenue in the COA, but the names and block say COGS. Keep them COGS and list them for the source owner? | M4 |
| Q-04 | HHG | **H1 for COA Other Income and Below EBITDA rows** sitting in a digit-4 account (49400-49992, 205 + 2 keys). Keep H1 Revenue (digit, D-46) with H2 OI/E, or set H1 Below the Line as for INVITED_CLUBS A50 (build 09 Q-16)? | M4 |
| Q-05 | HERSHA | **TB_ACTUAL role:** (a) TB is the ACTUAL source; GL ACTUAL rows at the 12 TB hotels -> DUPLICATE_DETAIL; GL ACTUAL at 118/149/230 stays; GL FORECAST stays [recommended]; (b) TB replaces GL; (c) both as is (double counts; not recommended). | M3-M5 |
| Q-06 | HERSHA | **TB FORECAST** (does not restate GL: 135 of 660 within 1%): under (a), DUPLICATE_DETAIL, PLANNING_INPUT, or a second forecast scenario in the IS (SCENARIO = `FORECAST_AMOUNT` of TB vs GL; category FORECAST twice)? | M5 |
| Q-07 | HERSHA | **TB `FLAG_COL_1`** (a date on 144 Stat rows) and **`FLAG_COL_2`** (`1` on 11,438 rows, codes on 144): carry as attributes, no routing? Meaning not stated in the source. | M3 |
| Q-08 | HHG | **ASSET_CODES `ACQUISITION_DATE`** has years 0024 / 0026 for 9041-9047 and 9050. Not used by the build; for the source owner. | no |

## Answered by the owner (stop 1)

Q-01 to Q-08 answered; see `M1.md`, "Stop 1 answers". The source-owner items
are logged in `docs/open-items.md` (N-3 to N-6).

| Q-09 | HHG | **49950 Misc Income at departments 901-908 (136 keys).** The COA lists them and types them Revenue; only at 950 (48 keys) is 49950 Other Income. The stop-2 correction (single-type extension) does not move them. Override 49950 -> Below the Line / OI/E at every department, so they follow the 207? Or keep the COA's Revenue? | M4 (seeder) |

- **Q-03 correction (owner, stop 2):** single-type accounts extend to their unlisted departments (2 keys); mixed-type accounts (49950, 51990, 52100) keep today's seed at unlisted departments. The stop-2 statement about the 136 keys was wrong (see `M1.md`).
- **Q-09 (owner, stop 3):** no override. 49950 follows the COA: Revenue at 901-908 (136 keys), Other Income / (Expense) at 950. 51990 and 52100 (mixed) keep today's seed at unlisted departments.

| Q-10 | HERSHA | **Q-05 / Q-06 routing conflicts with CLAUDE.md.** Rows with a *classified* account (GL ACTUAL at the 12 TB hotels; TB FORECAST) would go to UNKNOWN as DUPLICATE_DETAIL. Section 3 (UNKNOWN is H1 Unclassified or unresolved category), section 4 (specific reasons replace UNCLASSIFIED_ACCOUNT only) and check 2(e) forbid it. TB and GL rows share keys, so the classifier cannot split them. Amend CLAUDE.md (wording in `M4.md`), or choose (b) / (c)? | M5 |
