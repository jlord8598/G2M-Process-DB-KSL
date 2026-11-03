# Table usage - build 11

**How were the tables wired?** In scope are the 11 tables of the three
lanes. The other 38 in `CLN.BOX_INVESTMENT_DATA` belong to earlier builds and
were listed, not read.

| Table | Lane | Used by (procedure: columns) |
|---|---|---|
| CLN_ALTERRA_MONTHLY_FINANCIALS | ALTERRA | `SPROC_STG_ALTERRA_MONTHLY_FINANCIALS`: every column; via STG, the seeder ALTERRA branch (key, `IS_SUBTOTAL`, `SUBTOTAL_SOURCE`) and `SPROC_XFRM_ALTERRA` (facts, D-48 on SOURCE_SITE_CODE / DEPARTMENT) |
| CLN_ALTERRA_PACE_BY_STAY_MONTH | ALTERRA | `SPROC_STG_ALTERRA_PACE_BY_STAY_MONTH`: every column; `SPROC_XFRM_ALTERRA` -> `XFRM_ALTERRA_PACING` (SNAPSHOT_DATE as AS_OF_DATE). Never seeded (D-37). |
| CLN_ALTERRA_ACCOUNTS | ALTERRA | `SPROC_STG_ALTERRA_ACCOUNTS` only (lineage; it restates the facts' section, which the seeder reads directly) |
| CLN_ATLANTIC_AVIATION_OC_DATA | ATLANTIC_AVIATION | `SPROC_STG_ATLANTIC_AVIATION_OC_DATA`: every column (IS_ROLLUP and IS_SUBTOTAL drive `IS_SUBTOTAL`); seeder ATLANTIC branch; `SPROC_XFRM_ATLANTIC_AVIATION` |
| CLN_ATLANTIC_AVIATION_ACCOUNTS | ATLANTIC_AVIATION | `SPROC_STG_ATLANTIC_AVIATION_ACCOUNTS`; via STG, the seeder ATLANTIC branch (`ENTITY_CODE` = Total Company, `FULL_ACCOUNT_STRING`, `DEPARTMENT_DESCRIPTION`) |
| CLN_JW_VENICE_FCAST_ACT_FORECAST, _FCAST_BY_PERIOD, _FTE, _HEADCOUNT | JW_VENICE | their `SPROC_STG_JW_VENICE_*` models; seeder JW branch; `SPROC_XFRM_JW_VENICE` |
| CLN_JW_VENICE_ACCOUNTS | JW_VENICE | `SPROC_STG_JW_VENICE_ACCOUNTS` only (lineage) |
| CLN_JW_VENICE_CAPEX | JW_VENICE | **not used: out of scope** (owner, Q-05; N-9) |

**Not in landed data:** `CLN_JW_VENICE_MONTHLY_PL_DEPT`, named by
JW_VENICE_ACCOUNTS (N-8).

**`CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`:** read once, at stop 2, to confirm
0 keys for the three lanes (amended D-03). It is never written.
