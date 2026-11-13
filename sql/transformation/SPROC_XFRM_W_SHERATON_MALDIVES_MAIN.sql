CREATE OR REPLACE PROCEDURE DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_W_SHERATON_MALDIVES_MAIN()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_XFRM_W_SHERATON_MALDIVES_MAIN
-- Transformation orchestrator for lane W_SHERATON_MALDIVES. Builds nothing
-- itself. Stamps its own RUN_ID and passes it to SPROC_XFRM_W_SHERATON_MALDIVES.
-- Calls no other MAIN. Catches no exception.
-- Build 22 (new lane).
-- ============================================================================
declare
    v_run_id varchar default 'RUN_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MISS_FF3');
    v_models integer default 0;
    v_r      varchar default '';
begin
    -- ------------------------------------------------------------------------
    -- model calls
    -- ------------------------------------------------------------------------
    call DEV_G2M_AI.TRANSFORMATION.SPROC_XFRM_W_SHERATON_MALDIVES(:v_run_id) into :v_r;
    v_models := v_models + 1;

    return 'SPROC_XFRM_W_SHERATON_MALDIVES_MAIN ' || v_run_id || ' models=' || v_models || ' | ' || v_r;
end;
$$;
