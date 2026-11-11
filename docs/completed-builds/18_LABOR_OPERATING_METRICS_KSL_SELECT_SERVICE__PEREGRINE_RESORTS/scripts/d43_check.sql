-- scripts/d43_check.sql (build 18): freeze check on the three CLN.CLEAN tables the
-- restaged labor models read. Baseline 2026-11-11 13:20:30 PST; freeze ends
-- 22:00 MT = 21:00 PST (owner: Gary). Read-only. Never deployed.
with base (t, v) as (select * from values
    ('CUR_PROFITSWORD_KSL_DAILY_LABOR', '793934|-8343837243550270008'), ('CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR', '366164|-8052673052642264596'), ('CUR_PROFITSWORD_DEPARTMENTS', '1522|3924174782672254594')),
cur (t, v) as (
    select 'CUR_PROFITSWORD_KSL_DAILY_LABOR', count(*)||'|'||hash_agg(*) from CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR
    union all select 'CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR', count(*)||'|'||hash_agg(*) from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR
    union all select 'CUR_PROFITSWORD_DEPARTMENTS', count(*)||'|'||hash_agg(*) from CLN.CLEAN.CUR_PROFITSWORD_DEPARTMENTS)
select current_timestamp() checked_at, datediff(minute, current_timestamp(), '2026-11-11 21:00:00 -0800'::timestamp_tz) freeze_minutes_left,
       count(*) tables, count_if(base.v = cur.v) unchanged, listagg(iff(base.v = cur.v, null, base.t), ', ') changed
from base join cur using (t);
