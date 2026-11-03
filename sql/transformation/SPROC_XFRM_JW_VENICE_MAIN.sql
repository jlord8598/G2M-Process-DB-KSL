CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_JW_VENICE_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_JW_VENICE_MAIN
-- Transformation orchestrator for lane JW_VENICE. Builds nothing
-- itself. Stamps its own RUN_ID and passes it to SPROC_XFRM_JW_VENICE.
-- Calls no other MAIN. Catches no exception.
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_JW_VENICE(:v_run_id) into :v_r;
    v_models := v_models + 1;

    return 'SPROC_XFRM_JW_VENICE_MAIN ' || v_run_id || ' models=' || v_models || ' | ' || v_r;
end;
$$;
