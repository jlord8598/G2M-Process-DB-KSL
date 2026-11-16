-- scripts/d43_check.sql (build 23): D-43 freeze check, the 18 tables of HICV and BEAUMIER (the 8 HICV tables, the two new Beaumier 2027 tables and the 8 existing Beaumier tables the rebuilt lane reads) against the M2 baseline (2026-11-16 loads). Read-only.
with b(t, n, la) as (select * from values
    ('CLN_BEAUMIER_FIN_BUDGET_MONTHLY', 17577, '2026-11-16 03:04:25.563  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_FIN_BUDGET_MONTHLY_USALI', 7622, '2026-11-16 03:04:24.626  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_FIN_FORECAST_VERSIONS', 35893, '2026-11-16 03:04:23.873  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_OPS_STATS_MONTHLY', 132, '2026-11-16 03:04:25.338  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_PACE_CANCELLATIONS_MONTHLY', 16995, '2026-11-16 03:04:24.121  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_PACE_PRODUCTION_MONTHLY', 21638, '2026-11-16 03:04:24.869  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_REF_ACCOUNTS', 3282, '2026-11-16 03:04:27.069  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_REF_ACCOUNT_MAPPING', 1018, '2026-11-16 03:04:25.770  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_REF_HIERARCHY_PL_LINE', 147, '2026-11-16 03:04:25.094  -08:00'::timestamp_tz),
    ('CLN_BEAUMIER_REF_PROPERTIES', 13, '2026-11-10 04:53:56.491  -08:00'::timestamp_tz),
    ('CLN_HICV_FIN_GL_MONTHLY', 15257, '2026-11-16 07:56:54.415  -08:00'::timestamp_tz),
    ('CLN_HICV_FIN_PL_MONTHLY', 341688, '2026-11-16 07:56:52.901  -08:00'::timestamp_tz),
    ('CLN_HICV_OPS_KPI_WEEKLY', 1318, '2026-11-16 07:56:54.256  -08:00'::timestamp_tz),
    ('CLN_HICV_OPS_PRIORITIES_WEEKLY', 96, '2026-11-16 07:56:53.283  -08:00'::timestamp_tz),
    ('CLN_HICV_OPS_TREND_WEEKLY', 6849, '2026-11-16 07:56:54.085  -08:00'::timestamp_tz),
    ('CLN_HICV_PACE_RESERVATIONS_WEEKLY', 250, '2026-11-16 07:56:53.095  -08:00'::timestamp_tz),
    ('CLN_HICV_REF_ACCOUNTS', 22220, '2026-11-16 07:56:55.725  -08:00'::timestamp_tz),
    ('CLN_HICV_REF_PROPERTY_ROOM_KEYS', 304, '2026-11-16 07:56:53.880  -08:00'::timestamp_tz)),
c as (select table_name t, row_count n, last_altered la from CLN.INFORMATION_SCHEMA.TABLES where table_schema = 'BOX_INVESTMENT_DATA' and table_name in (select t from b))
select current_timestamp() checked_at, count(*) tables_, count_if(c.n = b.n and c.la = b.la) unchanged, listagg(iff(c.n = b.n and c.la = b.la, null, b.t), ', ') changed
from b left join c on c.t = b.t;
