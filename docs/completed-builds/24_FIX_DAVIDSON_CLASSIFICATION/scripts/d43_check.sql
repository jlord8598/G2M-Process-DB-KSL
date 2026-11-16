-- scripts/d43_check.sql (build 24): D-43 freeze check, the 14 CLN_DAVIDSON_* tables of lane DAVIDSON against the M1 baseline (2026-11-16 loads; REF_ACCOUNT_LOOKUP 2026-11-12). Read-only.
with b(t, n, la) as (select * from values
    ('CLN_DAVIDSON_FIN_BUDGET_MONTHLY', 245676, '2026-11-16 03:04:52.512 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_BUDGET_SUMMARY', 239616, '2026-11-16 03:04:53.992 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_PL_MONTHLY', 158760, '2026-11-16 03:04:51.900 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_PL_SUMMARY', 242784, '2026-11-16 03:04:51.707 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_PACE_GROUP_ANNUAL', 2856, '2026-11-16 03:04:53.370 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_ACCOUNTS', 45304, '2026-11-16 03:04:55.543 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_ACCOUNT_LOOKUP', 5504, '2026-11-12 11:07:13.297 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_ACCOUNT_MAPPING', 5504, '2026-11-16 03:04:52.942 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_CHART_OF_ACCOUNTS', 220, '2026-11-16 03:04:52.718 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_DEPARTMENTS', 66, '2026-11-16 03:04:53.567 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_LABOR_TYPES', 293, '2026-11-16 03:04:53.768 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_REVENUE_CATEGORIES', 83, '2026-11-16 03:04:51.483 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_SALES_ITEMS', 341, '2026-11-16 03:04:52.105 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_SPEND_CATEGORIES', 323, '2026-11-16 03:04:53.153 -0800'::timestamp_tz)),
c as (select table_name t, row_count n, last_altered la from CLN.INFORMATION_SCHEMA.TABLES where table_schema = 'BOX_INVESTMENT_DATA' and table_name in (select t from b))
select current_timestamp() checked_at, count(*) tables_, count_if(c.n = b.n and c.la = b.la) unchanged, listagg(iff(c.n = b.n and c.la = b.la, null, b.t), ', ') changed
from b left join c on c.t = b.t;
