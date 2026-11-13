-- scripts/d43_check.sql (build 22): D-43 freeze check, the 10 tables of WESTIN_HILTON_HEAD, W_SHERATON_MALDIVES and THIRD_SPACE against the M2 baseline (11-13 09:39 / 09:48 loads). Read-only.
with b(t, n, la) as (select * from values
    ('CLN_THIRD_SPACE_FIN_PL_MONTHLY', 29405, '2026-11-13 09:39:38.745 -0800'::timestamp_tz),
    ('CLN_THIRD_SPACE_REF_ACCOUNTS', 850, '2026-11-13 09:39:39.885 -0800'::timestamp_tz),
    ('CLN_WESTIN_HILTON_HEAD_FIN_PL_MONTHLY', 37212, '2026-11-13 09:39:12.269 -0800'::timestamp_tz),
    ('CLN_WESTIN_HILTON_HEAD_PACE_GROUP_MONTHLY', 2040, '2026-11-13 09:39:12.548 -0800'::timestamp_tz),
    ('CLN_WESTIN_HILTON_HEAD_REF_ACCOUNTS', 1842, '2026-11-13 09:39:13.714 -0800'::timestamp_tz),
    ('CLN_W_SHERATON_MALDIVES_FIN_BALANCE_SHEET', 138, '2026-11-13 09:48:34.934 -0800'::timestamp_tz),
    ('CLN_W_SHERATON_MALDIVES_FIN_PL_MONTHLY', 3948, '2026-11-13 09:48:34.731 -0800'::timestamp_tz),
    ('CLN_W_SHERATON_MALDIVES_FIN_PL_OWNER', 272, '2026-11-13 09:48:34.528 -0800'::timestamp_tz),
    ('CLN_W_SHERATON_MALDIVES_FIN_PL_SUMMARY', 558, '2026-11-13 09:48:34.257 -0800'::timestamp_tz),
    ('CLN_W_SHERATON_MALDIVES_REF_ACCOUNTS', 421, '2026-11-13 09:48:37.181 -0800'::timestamp_tz)),
c as (select table_name t, row_count n, last_altered la from CLN.INFORMATION_SCHEMA.TABLES where table_schema = 'BOX_INVESTMENT_DATA' and table_name in (select t from b))
select current_timestamp() checked_at, count(*) tables_, count_if(c.n = b.n and c.la = b.la) unchanged, listagg(iff(c.n = b.n and c.la = b.la, null, b.t), ', ') changed
from b left join c on c.t = b.t;
