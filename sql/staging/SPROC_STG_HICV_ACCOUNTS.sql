CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HICV_ACCOUNTS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HICV_ACCOUNTS
-- Builds STAGING.STG_HICV_ACCOUNTS from
-- CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_ACCOUNTS.
-- Dictionary. Build 23 (new lane HICV).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair, no dedup. A derived dictionary:
-- one row per entity + account string per source table it was seen in (GL or
-- P&L, column SOURCE_TABLE). PARENT_CODE is the GL sub-category 1 or the P&L
-- section (M1). Not unique on FULL_ACCOUNT_STRING across SOURCE_TABLE (M1); a
-- join to it must state which SOURCE_TABLE it reads.
-- The source's own SOURCE_TABLE column is carried as REF_SOURCE_TABLE, since
-- SOURCE_TABLE here names the CLN table staged.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HICV_ACCOUNTS as
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HICV'::varchar                                                       as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_ACCOUNTS'::varchar              as source_table
        , nullif(trim(src.entity_code), '')::varchar                            as entity_code_clean
        , nullif(trim(src.account_code), '')::varchar                           as account_code_clean
        , nullif(trim(src.department_code), '')::varchar                        as department_code_clean
        , nullif(trim(src.parent_code), '')::varchar                            as parent_code_clean
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.portfolio_name
        , src.entity_code
        , src.full_account_string
        , src.account_code
        , src.account_description
        , src.department_code
        , src.department_description
        , src.subaccount_code
        , src.subaccount_description
        , src.parent_code
        , src.alias
        , src.source_table                                                      as ref_source_table
        , src.first_seen_date
        , src.last_seen_date
        , src.row_count                                                         as ref_row_count
        , src.entity_name
    from CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_ACCOUNTS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HICV_ACCOUNTS);
    return 'STG_HICV_ACCOUNTS rows=' || v_rows;
end;
$$;
