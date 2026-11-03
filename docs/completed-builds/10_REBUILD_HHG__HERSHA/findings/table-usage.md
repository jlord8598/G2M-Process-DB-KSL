# Table usage - build 10

**How were the tables wired?** All 14 HHG and HERSHA tables are in scope
(Q-01). Every other table in `CLN.BOX_INVESTMENT_DATA` is out of scope and
not read.

| Table | Lane | Used by | Columns read / change |
|---|---|---|---|
| CLN_HERITAGE_GOLF_TR12_DATA | HHG | `SPROC_STG_HHG_TR12_DATA` | as build 08; name join now ASSET_CODES |
| CLN_HERITAGE_GOLF_ASSET_CODES (new) | HHG | `SPROC_STG_HHG_ASSET_CODES`; via STG by the TR12 model (`CLUB_NUMBER`, `CLUB_NAME`) | |
| CLN_HERITAGE_GOLF_CHART_OF_ACCOUNTS (new) | HHG | `SPROC_STG_HHG_CHART_OF_ACCOUNTS`; via STG by the seeder (`DEPARTMENT_CODE`, `NATURAL_ACCOUNT`, `ACCOUNT_TYPE`) | |
| CLN_HERITAGE_GOLF_DEPARTMENT_KEY, _TR12_ACCOUNTS (new) | HHG | their staging models only | lineage only |
| CLN_HERITAGE_GOLF_ACCOUNTS | HHG | `SPROC_STG_HHG_ACCOUNTS`; the TR12 model (descriptions, department names) | unchanged |
| CLN_HERITAGE_GOLF_REFERENCES | HHG | `SPROC_STG_HHG_REFERENCES` only (no longer joined; Q-02) | |
| CLN_HERITAGE_GOLF_CLUB_LIST, _FORECAST_ANAPLAN, _ROUNDS_DETAIL | HHG | their models | unchanged |
| CLN_HERSHA_TB_ACTUAL (new) | HERSHA | `SPROC_STG_HERSHA_TB_ACTUAL`; via STG by the seeder and `SPROC_XFRM_HERSHA` (D-48) | |
| CLN_HERSHA_GL_ACTUAL, _GL_STAT, _ACCOUNTS | HERSHA | their models | unchanged |

**Earlier lanes:** unchanged (check 5).
**`CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY`:** read-only, for key match only.
