-- scripts/d43_check.sql (build 26): freeze proof for CLN.DATA_SHARE (owner Q-01).
-- last_altered and HASH_AGG(*) per in-scope table against the M1 record (docs/sources.md).
-- Read-only. Any CHANGED is a stop.
with rec as (
    select * from values
          ('CLN_BECKONS_INCOME_STATEMENT_ACTUALS', '2026-11-04 12:30:05.711 -0800', -7855247829544083558)
        , ('CLN_BECKONS_INCOME_STATEMENT_BUDGET',  '2026-11-04 12:30:07.098 -0800',  6361584687308303984)
        , ('CLN_HAI_HOSPITALITY_INCOME_STATEMENT', '2026-11-04 14:04:43.551 -0800',  -650502652644412764)
        v(table_name, rec_altered, rec_hash)
)
, now_ as (
    select 'CLN_BECKONS_INCOME_STATEMENT_ACTUALS' as table_name, hash_agg(*) as h from CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_ACTUALS
    union all
    select 'CLN_BECKONS_INCOME_STATEMENT_BUDGET', hash_agg(*) from CLN.DATA_SHARE.CLN_BECKONS_INCOME_STATEMENT_BUDGET
    union all
    select 'CLN_HAI_HOSPITALITY_INCOME_STATEMENT', hash_agg(*) from CLN.DATA_SHARE.CLN_HAI_HOSPITALITY_INCOME_STATEMENT
)
select current_timestamp()::varchar as checked_at, rec.table_name, t.last_altered::varchar as last_altered, now_.h as content_hash
     , iff(t.last_altered = rec.rec_altered::timestamp_tz and now_.h = rec.rec_hash, 'UNCHANGED', 'CHANGED') as status
from rec
join CLN.INFORMATION_SCHEMA.TABLES t on t.table_schema = 'DATA_SHARE' and t.table_name = rec.table_name
join now_ on now_.table_name = rec.table_name
order by rec.table_name
