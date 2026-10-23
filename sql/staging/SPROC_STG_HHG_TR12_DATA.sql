CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_TR12_DATA(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_TR12_DATA
-- Builds STAGING.STG_HHG_TR12_DATA from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA. Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim; standard columns derived alongside (docs/sources.md).
-- SCENARIO is carried once: the standard column is the raw value verbatim.
-- ACCOUNT_CODE = entity(4)-department(3)-natural account(5).
-- Site = the entity segment as written. ASSET_NAME = STG_HHG_REFERENCES.CLUB_NAME
-- where the entity equals CLUB_NUMBER exactly, else null (build 06 Q-02; the
-- 9 unmatched entities are a client item); ASSET_NAME_SOURCE names the source.
-- Department 999 is STATISTIC (owner Q-01): its AMOUNT goes to STAT_VALUE
-- and SOURCE_AMOUNT is null; on every other row AMOUNT is SOURCE_AMOUNT.
-- ACCOUNT_DESC from the lane's ACCOUNTS dictionary, null on every TR12
-- string at M1 (Q-02). No department dictionary: DEPARTMENT_NAME null.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.account_code), '')                     as c_acct
            , null::varchar                                          as c_stat
            , null::varchar                                          as c_item
            , nullif(split_part(trim(src.account_code), '-', 1), '') as c_site
            , nullif(split_part(trim(src.account_code), '-', 2), '') as c_dept
        from src
    )
    -- ------------------------------------------------------------------------
    -- account description dictionary, unique on FULL_ACCOUNT_STRING (M1)
    -- ------------------------------------------------------------------------
    , acct as (
        select
              a.full_account_string
            , a.account_description
        from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ACCOUNTS a
    )
    -- ------------------------------------------------------------------------
    -- club name by GL entity, unique on CLUB_NUMBER (build 06 M1)
    -- ------------------------------------------------------------------------
    , refs as (
        select
              r.club_number
            , r.club_name
        from DEV_G2M_AI.STAGING.STG_HHG_REFERENCES r
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA'::varchar        as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , refs.club_name::varchar                                               as asset_name
        , case
              when refs.club_name is not null
                  then 'STG_HHG_REFERENCES.CLUB_NAME on entity = CLUB_NUMBER (build 06 Q-02)'
          end::varchar                                                          as asset_name_source
        , cln.c_dept::varchar                                                   as department
        , null::varchar                                                         as department_name
        , cln.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_dept = '999' then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_dept = '999'
                  then 'department 999: STATISTIC (dept 999, section 9, all whole numbers; owner Q-01)'
              else 'department not 999: AMOUNT (no stating column; M1)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , acct.account_description::varchar                                     as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , iff(cln.c_dept = '999', null, cln.amount)::float                      as source_amount
        , iff(cln.c_dept = '999', cln.amount, null)::float                      as stat_value
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (SCENARIO above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.account_code
        , cln.period_date
        , cln.amount
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join acct
        on  acct.full_account_string = cln.account_code
    left join refs
        on  refs.club_number = cln.c_site
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA);
    return 'STG_HHG_TR12_DATA rows=' || v_rows;
end;
$$;
