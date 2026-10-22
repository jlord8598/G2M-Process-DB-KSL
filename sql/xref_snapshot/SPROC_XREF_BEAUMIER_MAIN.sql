CREATE OR REPLACE PROCEDURE DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_BEAUMIER_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XREF_BEAUMIER_MAIN
-- Classification orchestrator for lane BEAUMIER. Builds no table
-- itself. Stamps its own RUN_ID and passes it to the seeder, then recreates
-- the three review views (identical text in every XREF MAIN).
-- Calls no other MAIN. Catches no exception.
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar;
begin
    -- ------------------------------------------------------------------------
    -- model calls
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.XREF_SNAPSHOT.SPROC_XREF_ACCOUNT_CLASSIFICATION(:v_run_id, 'BEAUMIER') into :v_r;
    v_models := v_models + 1;

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

    return 'SPROC_XREF_BEAUMIER_MAIN ' || v_run_id || ' models=' || v_models || ' | ' || v_r;
end;
$$;
