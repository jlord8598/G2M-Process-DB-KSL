CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_THIRD_SPACE_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_THIRD_SPACE_ACCOUNTS  (build 22, new lane)
-- Builds STAGING.STG_THIRD_SPACE_ACCOUNTS from CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_REF_ACCOUNTS.
-- Dictionary (lines by entity; no descriptions beyond the line names).
-- Identity form: long, count(source) = count(staged). Every source column
-- verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE (the source's own
-- SOURCE_TABLE column carried as RAW_SOURCE_TABLE where present).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_THIRD_SPACE_ACCOUNTS as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'THIRD_SPACE'::varchar                                         as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_REF_ACCOUNTS'::varchar as source_table
        , src.* rename (source_table as raw_source_table)
    from CLN.BOX_INVESTMENT_DATA.CLN_THIRD_SPACE_REF_ACCOUNTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_THIRD_SPACE_ACCOUNTS);
    return 'STG_THIRD_SPACE_ACCOUNTS rows=' || v_rows;
end;
$$;
