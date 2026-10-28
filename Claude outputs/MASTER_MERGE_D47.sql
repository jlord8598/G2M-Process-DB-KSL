-- ============================================================================
-- D-47 guarded merge into CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY
-- Promotion step 1 (replaces the insert-only statement). Run as G2M_SYSADMIN,
-- after the build is approved. Edit ONE thing: the lane list in step 1.
--   new key                                  -> INSERT
--   existing key, never reviewed (REVIEWED_BY is null), seed changed -> UPDATE
--   existing key a person reviewed           -> never touched (listed in step 2)
--   unchanged                                -> left alone
-- Every UPDATE is archived to ..._HISTORY first.
-- SPROC_RUN_PIPELINE stays insert-only; only this script updates.
-- ============================================================================

-- 0. once only: history table (same columns as the master + archive stamp)
create table if not exists CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY_HISTORY as
select m.*, current_timestamp()::timestamp_ltz as ARCHIVED_AT, ''::varchar as ARCHIVE_REASON
from CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY m
where false;

-- 1. plan: what this build would insert or update (EDIT THE LANE LIST)
create or replace temporary table MERGE_PLAN as
select s.*
     , iff(m.SOURCE_LANE is null, 'INSERT', 'UPDATE') as ACTION
     , m.H1 as OLD_H1, m.H2 as OLD_H2
from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION s
left join CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY m
  on  m.SOURCE_LANE = s.SOURCE_LANE and m.SOURCE_SITE_CODE = s.SOURCE_SITE_CODE
  and m.DEPARTMENT = s.DEPARTMENT and m.ACCOUNT_KEY = s.ACCOUNT_KEY
  and m.RECORD_TYPE = s.RECORD_TYPE
where s.SOURCE_LANE in ('INVITED_CLUBS')                 -- <== this build's lanes
  and ( m.SOURCE_LANE is null
     or ( m.REVIEWED_BY is null
          and not ( equal_null(m.H1, s.H1) and equal_null(m.H2, s.H2) and equal_null(m.H3, s.H3)
                and equal_null(m.H4, s.H4) and equal_null(m.H5, s.H5)
                and equal_null(m.P_L_SECTION, s.P_L_SECTION)
                and equal_null(m.NORMAL_BALANCE, s.NORMAL_BALANCE)
                and equal_null(m.VALUE_SIGN, s.VALUE_SIGN)
                and equal_null(m.METRIC_UNIT, s.METRIC_UNIT)
                and equal_null(m.AGGREGATION_TYPE, s.AGGREGATION_TYPE)
                and equal_null(m.ACCOUNT_DESC, s.ACCOUNT_DESC)
                and equal_null(m.ASSET_NAME, s.ASSET_NAME)
                and equal_null(m.DEPARTMENT_NAME, s.DEPARTMENT_NAME) ) ) );

-- 2. review before merging
--    a) counts by action
select ACTION, count(*) as keys from MERGE_PLAN group by 1;
--    b) every reclassification, old -> new
select ACTION, OLD_H1, OLD_H2, H1 as NEW_H1, H2 as NEW_H2, count(*) as keys
from MERGE_PLAN where ACTION = 'UPDATE' group by 1,2,3,4,5 order by keys desc;
--    c) reviewed rows the seed disagrees with: NOT changed, listed for the business
select m.SOURCE_LANE, m.ACCOUNT_KEY, m.H1, m.H2, s.H1 as SEED_H1, s.H2 as SEED_H2, m.REVIEWED_BY
from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION s
join CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY m
  on  m.SOURCE_LANE = s.SOURCE_LANE and m.SOURCE_SITE_CODE = s.SOURCE_SITE_CODE
  and m.DEPARTMENT = s.DEPARTMENT and m.ACCOUNT_KEY = s.ACCOUNT_KEY
  and m.RECORD_TYPE = s.RECORD_TYPE
where s.SOURCE_LANE in (select distinct SOURCE_LANE from MERGE_PLAN)
  and m.REVIEWED_BY is not null
  and not (equal_null(m.H1, s.H1) and equal_null(m.H2, s.H2));

-- 3. archive the rows about to be updated
insert into CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY_HISTORY
select m.*, current_timestamp(), 'D-47 merge: seed changed, unreviewed'
from CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY m
join MERGE_PLAN p
  on  m.SOURCE_LANE = p.SOURCE_LANE and m.SOURCE_SITE_CODE = p.SOURCE_SITE_CODE
  and m.DEPARTMENT = p.DEPARTMENT and m.ACCOUNT_KEY = p.ACCOUNT_KEY
  and m.RECORD_TYPE = p.RECORD_TYPE
where p.ACTION = 'UPDATE';

-- 4. merge
merge into CLN.XREF.KSL_MASTER_ACCOUNT_HIERARCHY m
using MERGE_PLAN p
  on  m.SOURCE_LANE = p.SOURCE_LANE and m.SOURCE_SITE_CODE = p.SOURCE_SITE_CODE
  and m.DEPARTMENT = p.DEPARTMENT and m.ACCOUNT_KEY = p.ACCOUNT_KEY
  and m.RECORD_TYPE = p.RECORD_TYPE
when matched and p.ACTION = 'UPDATE' and m.REVIEWED_BY is null then update set
    H1 = p.H1, H2 = p.H2, H3 = p.H3, H4 = p.H4, H5 = p.H5
  , P_L_SECTION = p.P_L_SECTION, NORMAL_BALANCE = p.NORMAL_BALANCE, VALUE_SIGN = p.VALUE_SIGN
  , METRIC_UNIT = p.METRIC_UNIT, AGGREGATION_TYPE = p.AGGREGATION_TYPE
  , ACCOUNT_DESC = p.ACCOUNT_DESC, ASSET_NAME = p.ASSET_NAME, DEPARTMENT_NAME = p.DEPARTMENT_NAME
  , SEED_SOURCE = p.SEED_SOURCE, LAST_SEEN_RUN_ID = p.LAST_SEEN_RUN_ID
  , PROMOTED_FROM_RUN_ID = p.LAST_SEEN_RUN_ID, PROMOTED_AT = current_timestamp()
  , LAST_UPDATED_AT = current_timestamp()
when not matched then insert (
    SOURCE_LANE, SOURCE_SITE_CODE, DEPARTMENT, ACCOUNT_KEY, RECORD_TYPE
  , ASSET_NAME, DEPARTMENT_NAME, ACCOUNT_NUMBER, STAT_ACCOUNT, ACCOUNT_DESC
  , H1, H2, H3, H4, H5, P_L_SECTION, NORMAL_BALANCE, VALUE_SIGN
  , METRIC_UNIT, AGGREGATION_TYPE, REVIEW_STATUS, SEED_SOURCE
  , FIRST_SEEN_RUN_ID, LAST_SEEN_RUN_ID, PROMOTED_FROM_RUN_ID, PROMOTED_AT, LAST_UPDATED_AT )
values (
    p.SOURCE_LANE, p.SOURCE_SITE_CODE, p.DEPARTMENT, p.ACCOUNT_KEY, p.RECORD_TYPE
  , p.ASSET_NAME, p.DEPARTMENT_NAME, p.ACCOUNT_NUMBER, p.STAT_ACCOUNT, p.ACCOUNT_DESC
  , p.H1, p.H2, p.H3, p.H4, p.H5, p.P_L_SECTION, p.NORMAL_BALANCE, p.VALUE_SIGN
  , p.METRIC_UNIT, p.AGGREGATION_TYPE, p.REVIEW_STATUS, p.SEED_SOURCE
  , p.FIRST_SEEN_RUN_ID, p.LAST_SEEN_RUN_ID, p.LAST_SEEN_RUN_ID, current_timestamp(), current_timestamp() );
-- expect: rows inserted = step 2a INSERT, rows updated = step 2a UPDATE
