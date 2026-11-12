-- scripts/d43_check.sql (build 20): D-43 freeze check, the 6 Davidson tables against the baseline taken at M2. Read-only. Returns check time, tables, matching, and the list of any that changed.
with b(t, n, la) as (select * from values
    ('CLN_DAVIDSON_FIN_BUDGET_MONTHLY', 245676, '2026-11-12 03:03:28.552 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_PL_MONTHLY', 157020, '2026-11-12 03:03:29.098 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_FIN_PL_SUMMARY', 240468, '2026-11-12 03:03:28.826 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_PACE_GROUP_ANNUAL', 2856, '2026-11-12 03:03:29.390 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_ACCOUNTS', 44840, '2026-11-12 03:03:31.293 -0800'::timestamp_tz),
    ('CLN_DAVIDSON_REF_ACCOUNT_LOOKUP', 5504, '2026-11-12 11:07:13.297 -0800'::timestamp_tz)),
c as (select table_name t, row_count n, last_altered la from CLN.INFORMATION_SCHEMA.TABLES where table_schema = 'BOX_INVESTMENT_DATA' and table_name in (select t from b))
select current_timestamp() checked_at, count(*) tables_, count_if(c.n = b.n and c.la = b.la) unchanged, listagg(iff(c.n = b.n and c.la = b.la, null, b.t), ', ') changed
from b left join c on c.t = b.t;
