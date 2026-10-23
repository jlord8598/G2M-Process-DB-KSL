CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_HHG_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_HHG_MAIN
-- Transformation orchestrator for lane HHG. Builds nothing
-- itself. Stamps its own RUN_ID and passes it to SPROC_XFRM_HHG.
-- Calls no other MAIN. Catches no exception.
-- Build 06 M2 skeleton: no model call yet.
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls: none at M2
    -- ------------------------------------------------------------------------

    return 'SPROC_XFRM_HHG_MAIN ' || v_run_id || ' models=' || v_models || ' | ' || v_r;
end;
$$;
