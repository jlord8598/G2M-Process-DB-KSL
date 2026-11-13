CREATE OR REPLACE PROCEDURE DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_WESTIN_HILTON_HEAD_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XREF_WESTIN_HILTON_HEAD_MAIN
-- Classification orchestrator for lane WESTIN_HILTON_HEAD. Builds no table
-- itself. Stamps its own RUN_ID and recreates the three review views
-- (identical text in every XREF MAIN).
-- Calls no other MAIN. Catches no exception.
-- Build 22 (new lane), pace-only this build (owner Q-02): the P&L waits for a
-- chart of accounts, so no seeder call (D-37). Recreates the three review views only.
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- review views
    -- ------------------------------------------------------------------------
    create or replace view DEV_G2M_AI.XREF_SNAPSHOT.VW_XREF_NEW_THIS_RUN as
    select x.*
    from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION x
    join (
        select source_lane, max(last_seen_run_id) as latest_run_id
        from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION
        group by source_lane
    ) l
        on  l.source_lane = x.source_lane
    where 1=1
      and x.first_seen_run_id = l.latest_run_id;

    create or replace view DEV_G2M_AI.XREF_SNAPSHOT.VW_XREF_UNCLASSIFIED as
    select x.*
    from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION x
    join (
        select source_lane, max(last_seen_run_id) as latest_run_id
        from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION
        group by source_lane
    ) l
        on  l.source_lane = x.source_lane
    where 1=1
      and x.first_seen_run_id <> l.latest_run_id
      and x.h1 = 'Unclassified';

    create or replace view DEV_G2M_AI.XREF_SNAPSHOT.VW_XREF_AWAITING_SIGN as
    select x.*
    from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION x
    join (
        select source_lane, max(last_seen_run_id) as latest_run_id
        from DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION
        group by source_lane
    ) l
        on  l.source_lane = x.source_lane
    where 1=1
      and x.first_seen_run_id <> l.latest_run_id
      and x.h1 <> 'Unclassified'
      and x.value_sign is null
      and x.h1 in ('Below the Line', 'Allocations & Reserves', 'Balance Sheet');

    return 'SPROC_XREF_WESTIN_HILTON_HEAD_MAIN ' || v_run_id || ' models=' || v_models || ' | ' || v_r;
end;
$$;
