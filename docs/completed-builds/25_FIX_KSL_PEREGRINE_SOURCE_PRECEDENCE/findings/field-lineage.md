# Build 25 field lineage (changed)
| Column | Where | Rule |
|---|---|---|
| UNKNOWN_REASON (XFRM_{LANE}_*, SEM_AI_UNKNOWN) | SPROC_XFRM_{LANE}, CTEs `mth`, `sm_monthly`, `sm_daily`, `prec` | DUPLICATE_DETAIL where `d48_loses_to` is set (D-48, build 25). Site = sentinel-coalesced SOURCE_SITE_CODE; month = date_trunc('month', PERIOD_END). |
| SOURCE_SIGN_CONVENTION (XFRM_{LANE}_INCOME_STATEMENT / BALANCE_SHEET / OPERATING_METRICS / UNKNOWN) | SPROC_XFRM_{LANE}, CTE `prec` | DEBIT for LEDGER_BATCHES, PRESENTED otherwise, by SOURCE_TABLE (D-50; staging states none). Not carried to SEMANTIC. |
| VALUE (XFRM, SEM) | SPROC_XFRM_{LANE} | null where VALUE_SIGN is null; DEBIT: -SOURCE_AMOUNT; PRESENTED: SOURCE_AMOUNT x VALUE_SIGN. |
