CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_DAVIDSON_SALES_ITEMS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_DAVIDSON_SALES_ITEMS  (build 21)
-- Builds STAGING.STG_DAVIDSON_SALES_ITEMS from
-- CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_SALES_ITEMS: sales item (segment 4) names.
-- Dictionary. Identity form: long, count(source) = count(staged). Every source
-- column verbatim, plus RUN_ID, SOURCE_LANE and SOURCE_TABLE. Unique on SALES_ITEM_CODE (341 / 341, M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_DAVIDSON_SALES_ITEMS as
    select
          :P_RUN_ID::varchar                                    as run_id
        , 'DAVIDSON'::varchar                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_SALES_ITEMS'::varchar as source_table
        , src.*
    from CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_REF_SALES_ITEMS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_DAVIDSON_SALES_ITEMS);
    return 'STG_DAVIDSON_SALES_ITEMS rows=' || v_rows;
end;
$$;
