# Field lineage (build 15 changes)

Columns not listed are as in each lane's previous build field-lineage (archived).

| Column | Source |
|---|---|
| SOURCE_SIGN_CONVENTION, SOURCE_SIGN_CONVENTION_SOURCE (STG fact tables, XFRM streams) | staging constant per table (D-50, owner Q-03), evidence from M1 |
| VALUE (five lanes) | transformation: D-50 (DEBIT -SOURCE_AMOUNT, PROFIT SOURCE_AMOUNT, PRESENTED SOURCE_AMOUNT x VALUE_SIGN; null where VALUE_SIGN is null) |
| CURRENCY_CODE, CURRENCY_CODE_SOURCE (BEAUMIER) | staging: STG_BEAUMIER_CANCELLATIONS.CURRENCY on STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME, one currency per hotel; else UNCONFIRMED. Carried XFRM -> SEM (was the literal 'MIXED') |
| UNKNOWN_REASON DUPLICATE_DETAIL (HHG Anaplan, BEAUMIER BP) | transformation: FILE_DATE older than the latest for the entity + month + scenario (D-48, Q-08) |
| HHG BUDGET_BY_CLUB, all columns | as STG_HHG_TR12_DATA (ACCOUNT_CODE segments; ACCOUNTS on its own SOURCE_TABLE slice); SCENARIO = BUDGET_VERSION; CATEGORY BUDGET |
| HHG TR12 ACCOUNT_DESC, DEPARTMENT_NAME, PARENT_CODE | ACCOUNTS joined within its TR12 slice (SOURCE_TABLE), unchanged values |
| NEWBURY 870215 H1 / H2 / sign | seeder: Allocations & Reserves / UNCLASSIFIED, null section, balance, sign (D-44 re-seed, Q-05) |
