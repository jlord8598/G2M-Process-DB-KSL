# Build 25 open questions

| Q | Lane | Question | Proposal |
|---|---|---|---|
| Q-01 | both | Declare KSL_SELECT_SERVICE and PEREGRINE_RESORTS rebuilt (D-44), changing only transformation precedence (no staging, key or seeder change)? | Yes. Keys stay as they are; no re-seed. |
| Q-02 | both | **R1 scope:** the ledger's balance-sheet lines (KSL digit 1 +678.9M, digit 3 -76.7M) are journal movements, not monthly's balances (they match in 259 + 84 of 4,182 cells). Should they also go to UNKNOWN as DUPLICATE_DETAIL, or stay in the balance sheet? | The whole ledger in covered site-months goes to UNKNOWN (it is a restatement of daily activity already in daily / monthly), unless you want its movements in SEM_AI_BALANCE_SHEET. |
| Q-03 | both | **R2 scope:** apply monthly-beats-daily to all sections (balance sheet and operating metrics too, where daily = monthly at 99.9%) or only to the income statement? | All sections; daily keeps only the site-months monthly lacks. |
| Q-04 | both | **GOP anchor:** TOTGOP (TOTDPDP - TOTOHEX) ties no block combination tested. Is there a GOP definition you want tied, or report GOP unanchored? | Report EBITDA and revenue as the anchors; GOP unanchored (not in landed data as an account-level rule). |
| Q-05 | PEREGRINE | ProfitSword's EBITDA excludes block 86 (other expense, rent, leases, condo owner payments) for PEREGRINE but not for KSL. Is that intended, or is block 86 classified differently between the two tenants? | Report as measured; no classification change in this build. |
| Q-06 | both | **D-50:** the ledger books DEBIT. If R1 sends every covered ledger line to UNKNOWN, its convention only matters for KSL CAPICOP's 6 months. List LEDGER_BATCHES as DEBIT for both lanes anyway? | Yes, list it DEBIT (both lanes); the other tables stay PRESENTED. |
| Q-07 | KSL | CAPICOP has daily and ledger but no monthly Actuals for 6 months of 2026. With R1 and R2 the daily is its source. Should the ledger also lose to daily there? | Yes: daily beats ledger where monthly is absent. |
| Q-08 | both | Freeze: the 2026-11-16 01:19 reload is the extract measured. Confirm Gary's freeze on the 26 tables before M2. | â€” |

## Answers (owner, stop 2)
Q-01 yes, transformation-only. Q-02 the whole ledger to UNKNOWN. Q-03 R2 in every section. Q-04 GOP unanchored; TOTGOP mismatch logged (N-68). Q-05 each lane's ProfitSword EBITDA as is (N-22). Q-06 LEDGER_BATCHES DEBIT in D-50, both lanes. Q-07 daily beats the ledger at KSL CAPICOP. Q-08 freeze confirmed with Gary.

## Raised at M5 / M6
| Q | Lane | Question | Proposal |
|---|---|---|---|
| Q-09 | PEREGRINE | Two datasets new in the 11-16 reload, "Budget 4" (FCID per STG_PEREGRINE_RESORTS_DATASETS) and "Budget 5", have no category mapping: 18,349 monthly lines are UNRESOLVED_CATEGORY / BOTH in UNKNOWN. They keep H1, so check 2(e)'s wording counts 18,334 of them. Map them to BUDGET? | Map both to BUDGET in a later build; until then they stay in UNKNOWN (Â§6). |
| Q-10 | KSL, PEREGRINE | 128 equity keys (KSL 110, PEREGRINE 18) carry the pre-build-13 seed-source text "section digit 3"; their H1 / H2 already match. The master holds the same text. Re-seed the text? | Leave as is; text only, no H2 change. |
| Q-11 | both | D-50's wording puts the convention in staging (SOURCE_SIGN_CONVENTION). Under Q-01 it is set in transformation by SOURCE_TABLE. Accept, and word the D-50 entry accordingly? | Accept; D-50 entry text at stop 4. |

## Stop 4 (owner)
D-48 and D-50 entries approved (D-50 set in transformation, Q-11). Q-09: Budget 4 / 5 stay in UNKNOWN pending Gary (N-21); the 2(e) count is data-driven. Q-10: seed notes left.
**Merge, corrected:** 5 unreviewed updates, not 3. The stop-4 count compared SEED_SOURCE (which the merge script does not) and omitted ACCOUNT_DESC / ASSET_NAME / DEPARTMENT_NAME (which it does). The 5 are 2 PEREGRINE labor keys (build 18 rule, pre-dating this build) and 3 PEREGRINE dept-115 keys whose DEPARTMENT_NAME the source relabelled from HEALTH CLUB REVENUE to PARKING SALARY between 11-06 and 11-16 (this build's extract). The KSL seed-note key is not updated. Detail: M6.md.

