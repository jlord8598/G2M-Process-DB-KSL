-- ============================================================================
-- scripts/d43_check.sql  (build 14)
-- D-43 freeze check: UNDER_CANVAS, THE_PIG, OUTRIGGER source tables in
-- CLN.BOX_INVESTMENT_DATA, baseline taken 2026-11-06 07:55:14.618 PST (first
-- read). Freeze ends 2026-11-07 06:00 America/Los_Angeles (owner Q-01).
-- ============================================================================
with base (t, n, h) as (select * from values
    ('CLN_OUTRIGGER_PACE', 13256, -926676262620762058),
    ('CLN_PIG_HOTELS_PACE_NEXT_YEAR', 1728, -6626632639382259087),
    ('CLN_PIG_HOTELS_PACE_THIS_YEAR', 1728, -6667705148816344511),
    ('CLN_UNDER_CANVAS_ACCOUNTS', 2623, 8591774308905816307),
    ('CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES', 27505, 546088064065887215),
    ('CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES', 6722, 1586988466465073507),
    ('CLN_UNDER_CANVAS_CANCELLATIONS', 408, 6309105477389416414),
    ('CLN_UNDER_CANVAS_CONSOLIDATED_PL', 102, -7071390872765718498),
    ('CLN_UNDER_CANVAS_DUETTO_DATA', 408, 2065469859008614681),
    ('CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS', 1363, -6911953387288909797),
    ('CLN_UNDER_CANVAS_TOTAL_REVENUE', 56663, -192211268073281671),
    ('CLN_UNDER_CANVAS_WEEKLY_PACE', 72576, -6837978762827795817)
),
cur as (
    select 'CLN_OUTRIGGER_PACE' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_OUTRIGGER_PACE
    union all select 'CLN_PIG_HOTELS_PACE_NEXT_YEAR' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_NEXT_YEAR
    union all select 'CLN_PIG_HOTELS_PACE_THIS_YEAR' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_PIG_HOTELS_PACE_THIS_YEAR
    union all select 'CLN_UNDER_CANVAS_ACCOUNTS' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_ACCOUNTS
    union all select 'CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_NON_OPERATING_EXPENSES
    union all select 'CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CAMP_OPERATING_EXPENSES
    union all select 'CLN_UNDER_CANVAS_CANCELLATIONS' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CANCELLATIONS
    union all select 'CLN_UNDER_CANVAS_CONSOLIDATED_PL' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CONSOLIDATED_PL
    union all select 'CLN_UNDER_CANVAS_DUETTO_DATA' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_DUETTO_DATA
    union all select 'CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_STATISTICAL_ACCOUNTS
    union all select 'CLN_UNDER_CANVAS_TOTAL_REVENUE' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_TOTAL_REVENUE
    union all select 'CLN_UNDER_CANVAS_WEEKLY_PACE' t, count(*) n, hash_agg(*) h from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_WEEKLY_PACE
)
select current_timestamp() as checked_at
     , datediff(minute, current_timestamp(), '2026-11-07 06:00:00 -0800'::timestamp_tz) as freeze_minutes_left
     , count(*) as tables
     , count_if(base.n = cur.n and base.h = cur.h) as unchanged
     , listagg(iff(base.n = cur.n and base.h = cur.h, null, base.t), ', ') as changed
from base join cur using (t);
