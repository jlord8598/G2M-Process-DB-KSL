CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_TR12_DATA(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_TR12_DATA
-- Builds STAGING.STG_HHG_TR12_DATA from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY. Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim; standard columns derived alongside (docs/sources.md).
-- SCENARIO is carried once: the standard column is the raw value verbatim.
-- ACCOUNT_CODE = entity(4)-department(3)-natural account(5).
-- Site = the entity segment as written. ASSET_NAME = STG_HHG_ASSET_CODES.CLUB_NAME
-- where the entity equals CLUB_NUMBER exactly, else null (build 10 Q-02; was
-- REFERENCES, build 06 Q-02; 9055, 9056, 9099, 9102 are not in landed data);
-- ASSET_NAME_SOURCE names the source.
-- Department 999 is STATISTIC (owner Q-01): its AMOUNT goes to STAT_VALUE
-- and SOURCE_AMOUNT is null; on every other row AMOUNT is SOURCE_AMOUNT.
-- ACCOUNT_DESC, DEPARTMENT_NAME and PARENT_CODE from the lane's ACCOUNTS
-- dictionary on FULL_ACCOUNT_STRING = ACCOUNT_CODE within its TR12 slice
-- (SOURCE_TABLE = CLN_HERITAGE_GOLF_TR12_DATA, unique; build 15 M3: the
-- dictionary now holds one slice per fact table and is no longer unique on
-- FULL_ACCOUNT_STRING alone): ACCOUNT_DESCRIPTION, DEPARTMENT_DESCRIPTION as supplied per
-- account, no normalising (build 08 Q-09), PARENT_CODE an unused attribute
-- (build 08 Q-11). Null where the source supplies none.
-- Build 15 (D-50): SOURCE_SIGN_CONVENTION PRESENTED for every row, with its evidence
-- in SOURCE_SIGN_CONVENTION_SOURCE; applied in transformation.
-- Build 16: reads the new table name directly; the old-name view's select
-- (added PROPERTY_NAME) is inlined, every new-table column carried (rule 3).
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
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY)
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
            , a.source_table
            , a.account_description
            , a.department_description
            , a.parent_code
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_REF_ACCOUNTS) a
    )
    -- ------------------------------------------------------------------------
    -- club name by GL entity, unique on CLUB_NUMBER (build 10 M1)
    -- ------------------------------------------------------------------------
    , refs as (
        select
              r.club_number
            , r.club_name
        from DEV_G2M_AI.STAGING.STG_HHG_ASSET_CODES r
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HHG'::varchar                                                        as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'::varchar        as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , refs.club_name::varchar                                               as asset_name
        , case
              when refs.club_name is not null
                  then 'STG_HHG_ASSET_CODES.CLUB_NAME on entity = CLUB_NUMBER (build 10 Q-02)'
          end::varchar                                                          as asset_name_source
        , cln.c_dept::varchar                                                   as department
        , acct.department_description::varchar                                 as department_name
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
        , 'PRESENTED'::varchar                                                as source_sign_convention
        , 'presented-positive: revenue and costs both positive (build 15 M1, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        , acct.parent_code::varchar                                             as parent_code
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
        and acct.source_table = 'CLN_HERITAGE_GOLF_FIN_PL_MONTHLY'
    left join refs
        on  refs.club_number = cln.c_site
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA);
    return 'STG_HHG_TR12_DATA rows=' || v_rows;
end;
$$;
