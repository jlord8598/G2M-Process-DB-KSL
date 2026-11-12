# Field lineage (build 20)

| Column | Source | Rule |
|---|---|---|
| STG_DAVIDSON_HOTEL_MONTHLY_REPORT / HOTEL_BUDGET.ACCOUNT_DESC | REF_ACCOUNTS, else CLN_DAVIDSON_REF_ACCOUNT_LOOKUP (exact CONCATENATED_PROFITSWORD_STRING = ACCOUNT), else the lookup's segment-name dictionaries | sources.md build rule |
| .ACCOUNT_DESC_SOURCE | derived | REF_ACCOUNTS, LOOKUP_EXACT, SEGMENT_BUILT, or null |
| XFRM_DAVIDSON_*.ACCOUNT_DESC, SEM_AI_* (DAVIDSON).ACCOUNT_DESC | the staged ACCOUNT_DESC | unchanged path (XFRM line 114) |
| XREF ACCOUNT_DESC (DAVIDSON) | MIN at insert | unchanged (Q-02) |
