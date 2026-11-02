# Table usage - build 09

**How were the tables wired?** All 11 + 7 tables visible in
`CLN.BOX_INVESTMENT_DATA` during the build are listed. The schema showed the
INVITED_CLUBS tables only after Q-01.

## In scope (7)

| Table | Used by | Columns read / change |
|---|---|---|
| CLN_INVITED_CLUBS_ESSBASE_EXTRACT | `SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT` | as build 08; `ACCOUNT` now also feeds the Q-04 subtotal flag |
| CLN_INVITED_CLUBS_META_ACCOUNT | `SPROC_STG_INVITED_CLUBS_META_ACCOUNT` (verbatim). Read downstream via `STG_INVITED_CLUBS_META_ACCOUNT` by the fact model (`ACCOUNT_TYPE`, `DATA_TYPE`, `ALIAS_DEFAULT`, MIN per member) and **new:** by the seeder (`TIME_BALANCE`, `DATA_STORAGE` <> shared) | |
| CLN_INVITED_CLUBS_META_ENTITY, _META_DEPARTMENT | their staging models; the fact model (`ALIAS_DEFAULT`) | unchanged |
| CLN_INVITED_CLUBS_META_LOCATION, _META_SUBACCOUNT | their staging models only | unchanged |
| CLN_INVITED_CLUBS_ACCOUNTS | `SPROC_STG_INVITED_CLUBS_ACCOUNTS` only (verbatim; rebuilt by the source owner to one row per entity + account, 288,714 rows; not joined anywhere, M3) | unchanged |

## Out of scope, not read

- CLN_HERITAGE_GOLF_ACCOUNTS, _ASSET_CODES, _CHART_OF_ACCOUNTS, _CLUB_LIST,
  _DEPARTMENT_KEY, _FORECAST_ANAPLAN, _REFERENCES, _ROUNDS_DETAIL,
  _TR12_ACCOUNTS, _TR12_DATA;
- CLN_BEAUMIER_LOCATION_MAP.

**Earlier lanes:** 138 of 138 objects are unchanged (check 5).
**`CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`:** read-only, at the owner's
instruction, for the key match and the before-figures. Never written.
