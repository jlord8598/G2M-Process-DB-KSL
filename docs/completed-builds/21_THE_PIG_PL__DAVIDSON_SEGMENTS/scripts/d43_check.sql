-- scripts/d43_check.sql (build 21): D-43 freeze check, 16 tables (CLN_PIG_HOTELS_*, CLN_DAVIDSON_* except the retired REF_ACCOUNT_LOOKUP) against the M2 baseline (Pig 06:48, Davidson 08:10 on 2026-11-13). Read-only.
with b(t, n, la) as (select * from values
    ('CLN_DAVIDSON_FIN_BUDGET_MONTHLY', 245676, '2026-11-13 08:10:25.978 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_BUDGET_SUMMARY', 239616, '2026-11-13 08:10:25.574 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_PL_MONTHLY', 157020, '2026-11-13 08:10:26.389 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_PL_SUMMARY', 238944, '2026-11-13 08:10:25.794 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_PACE_GROUP_ANNUAL', 2856, '2026-11-13 08:10:23.907 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_ACCOUNTS', 44839, '2026-11-13 08:10:28.035 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_ACCOUNT_MAPPING', 5504, '2026-11-13 08:10:26.181 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_CHART_OF_ACCOUNTS', 220, '2026-11-13 08:10:24.692 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_DEPARTMENTS', 66, '2026-11-13 08:10:24.402 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_LABOR_TYPES', 293, '2026-11-13 08:10:25.192 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_REVENUE_CATEGORIES', 83, '2026-11-13 08:10:24.164 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_SALES_ITEMS', 341, '2026-11-13 08:10:25.377 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_SPEND_CATEGORIES', 323, '2026-11-13 08:10:23.610 -0800'::timestamp_tz),
    ('CLN_PIG_HOTELS_FIN_PL_MONTHLY', 12528, '2026-11-13 06:48:10.366 -0800'::timestamp_tz),
    ('CLN_PIG_HOTELS_PACE_OTB_MONTHLY', 5184, '2026-11-13 06:48:10.662 -0800'::timestamp_tz),
    ('CLN_PIG_HOTELS_REF_ACCOUNTS', 1044, '2026-11-13 06:48:12.172 -0800'::timestamp_tz)),
c as (select table_name t, row_count n, last_altered la from CLN.INFORMATION_SCHEMA.TABLES where table_schema = 'BOX_INVESTMENT_DATA' and table_name in (select t from b))
select current_timestamp() checked_at, count(*) tables_, count_if(c.n = b.n and c.la = b.la) unchanged, listagg(iff(c.n = b.n and c.la = b.la, null, b.t), ', ') changed
from b left join c on c.t = b.t;
