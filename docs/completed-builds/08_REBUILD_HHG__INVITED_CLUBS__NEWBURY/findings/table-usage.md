# Table usage - build 08

**How were the tables wired?** All 33 tables visible in
`CLN.BOX_INVESTMENT_DATA` are listed below.

## In scope (22)

| Table | Lane | Used by | Change in build 08 |
|---|---|---|---|
| CLN_HERITAGE_GOLF_TR12_DATA | HHG | `SPROC_STG_HHG_TR12_DATA` | now joined to ACCOUNTS |
| CLN_HERITAGE_GOLF_ACCOUNTS | HHG | `SPROC_STG_HHG_ACCOUNTS`; `SPROC_STG_HHG_TR12_DATA` (`FULL_ACCOUNT_STRING`, `ACCOUNT_DESCRIPTION`, `DEPARTMENT_DESCRIPTION`, `PARENT_CODE`) | three new columns read |
| CLN_HERITAGE_GOLF_FORECAST_ANAPLAN, _ROUNDS_DETAIL, _CLUB_LIST, _REFERENCES | HHG | their `SPROC_STG_HHG_*` models | none |
| CLN_INVITED_CLUBS_ESSBASE_EXTRACT | INVITED_CLUBS | `SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT` | `Ind-Total` subtotal flag |
| CLN_INVITED_CLUBS_ACCOUNTS, _META_ACCOUNT, _META_DEPARTMENT, _META_ENTITY, _META_LOCATION, _META_SUBACCOUNT | INVITED_CLUBS | their models | none |
| CLN_NEWBURY_BOSTON_* (9) | NEWBURY | their `SPROC_STG_NEWBURY_*` models | none |

**Downstream changes:**
- the seeder's INVITED_CLUBS and NEWBURY branches;
- `scripts/reseed_build08.sql` (run once);
- `SPROC_XFRM_INVITED_CLUBS`.

The SEM lane blocks are unchanged.

## Out of scope (11), not read

CLN_BEAUMIER_ACCOUNTS, _BP, _BUDGET, _CANCELLATIONS, _LOCATION_MAP;
CLN_DAVIDSON_ACCOUNTS, _FULL_YEAR_PL, _HOTEL_MONTHLY_REPORT;
CLN_HERSHA_ACCOUNTS, _GL_ACTUAL, _GL_STAT.

Their lanes are covered by the earlier-build baseline: 99 of 99 objects are
unchanged. 22 + 11 = 33 visible.
