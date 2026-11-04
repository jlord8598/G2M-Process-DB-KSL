-- ============================================================================
-- scripts/d43_check.sql  (build 12)
-- D-43: row count and HASH_AGG(*) of the 9 frozen source tables against the
-- M1 baseline (findings/M1.md section 1), and the freeze minutes remaining
-- (freeze ends 2026-11-05 06:00 America/Los_Angeles, owner Q-01). Read-only.
-- ============================================================================
with b as (
    select * from values
      ('ATLANTIC_AVIATION_ACCOUNTS', 1149, '1816830751459244000')
    , ('ATLANTIC_AVIATION_OC_DATA', 109995, '-805039552727121348')
    , ('JW_VENICE_ACCOUNTS', 2360, '-4474948644677297740')
    , ('JW_VENICE_CAPEX', 200, '-2398897289528261542')
    , ('JW_VENICE_FCAST_ACT_FORECAST', 808, '-8506196185378544053')
    , ('JW_VENICE_FCAST_BY_PERIOD', 761, '3848384668570664544')
    , ('JW_VENICE_FTE', 1044, '-5503771762041690548')
    , ('JW_VENICE_HEADCOUNT', 1080, '-4105530968933583267')
    , ('JW_VENICE_MONTHLY_PL_DEPT', 8656, '-7754782521118946605')
    t(tb, n, h)
)
, c as (
              select 'ATLANTIC_AVIATION_ACCOUNTS' tb, count(*) n, hash_agg(*)::varchar h from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_ACCOUNTS
    union all select 'ATLANTIC_AVIATION_OC_DATA', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_ATLANTIC_AVIATION_OC_DATA
    union all select 'JW_VENICE_ACCOUNTS', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_ACCOUNTS
    union all select 'JW_VENICE_CAPEX', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_CAPEX
    union all select 'JW_VENICE_FCAST_ACT_FORECAST', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_ACT_FORECAST
    union all select 'JW_VENICE_FCAST_BY_PERIOD', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FCAST_BY_PERIOD
    union all select 'JW_VENICE_FTE', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_FTE
    union all select 'JW_VENICE_HEADCOUNT', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_HEADCOUNT
    union all select 'JW_VENICE_MONTHLY_PL_DEPT', count(*), hash_agg(*)::varchar from CLN.BOX_INVESTMENT_DATA.CLN_JW_VENICE_MONTHLY_PL_DEPT
)
select current_timestamp() as checked_at
     , datediff(minute, current_timestamp(), '2026-11-05 06:00:00 -0800'::timestamp_tz) as freeze_minutes_left
     , count(*) as tables
     , count_if(b.n = c.n and b.h = c.h) as unchanged
     , listagg(iff(b.n = c.n and b.h = c.h, null, b.tb), ', ') as changed
from b join c using (tb)
