# Sources - this build (20: FIX_DAVIDSON_DESC, DAVIDSON descriptions)

Source schema CLN.BOX_INVESTMENT_DATA. Lane DAVIDSON (D-44, descriptions only). Freeze: to confirm (Q-01).

| Table | Rows | last_altered | Use |
|---|---|---|---|
| CLN_DAVIDSON_REF_ACCOUNT_LOOKUP | 5,504 | 2026-11-12 11:07 | new dictionary: ACCOUNT_DESC fill |
| CLN_DAVIDSON_FIN_PL_MONTHLY | 157,020 | 2026-11-12 03:03 | fact (fill) |
| CLN_DAVIDSON_FIN_BUDGET_MONTHLY | 245,676 | 2026-11-12 03:03 | fact (fill) |
| CLN_DAVIDSON_FIN_PL_SUMMARY | 240,468 | 2026-11-12 03:03 | fact (no change) |
| CLN_DAVIDSON_REF_ACCOUNTS | 44,840 | 2026-11-12 03:03 | dictionary (no change) |
| CLN_DAVIDSON_PACE_GROUP_ANNUAL | 2,856 | 2026-11-12 03:03 | not staged (N-51) |

Join: lookup CONCATENATED_PROFITSWORD_STRING = staged ACCOUNT_KEY (= ACCOUNT), exact.

## Build rule (owner, build 20)
ACCOUNT_DESC for STG_DAVIDSON_HOTEL_MONTHLY_REPORT and STG_DAVIDSON_HOTEL_BUDGET, in order:
1. REF_ACCOUNTS where non-blank;
2. LOOKUP_EXACT: the lookup line for the exact ACCOUNT;
3. SEGMENT_BUILT: a 6-segment ACCOUNT whose every non-XXXXX segment has a dictionary name;
4. otherwise null.

- **Retired** = ACCOUNT_NAME saying RETIRED or DO NOT USE, or any name starting zDNU. A retired line or name is chosen last; then the first alphabetically.
- **Format:** ledger | cost center | revenue category | sales item | spend category | labor type, empty parts skipped.
- **Freeze:** Gary, to 22:00 MT; baseline in `scripts/d43_check.sql`.
