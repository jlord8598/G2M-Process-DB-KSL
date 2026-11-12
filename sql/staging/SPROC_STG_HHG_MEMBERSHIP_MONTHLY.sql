CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HHG_MEMBERSHIP_MONTHLY(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HHG_MEMBERSHIP_MONTHLY  (build 19, owner Q-03, N-31)
-- Builds STAGING.STG_HHG_MEMBERSHIP_MONTHLY from
-- CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY (the membership
-- block of 'Budget by Club.xlsx': 2026 budget member movements by club and
-- segment). Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Site = CLUB_NUMBER (equals segment 1 of ACCOUNT_CODE on every coded row, M3).
-- ASSET_NAME = STG_HHG_ASSET_CODES.CLUB_NAME on CLUB_NUMBER, as the budget model.
-- Department = segment 2 of ACCOUNT_CODE (999 on every coded row), else null.
-- ACCOUNT_KEY = ACCOUNT_CODE (the 999-94xxx / 95xxx account, the budget model's
-- key), else MEMBER_LINE_KEY | CLUB_SEGMENT (SOURCE_ITEM_ID; the 1,656
-- 'Ending Member Count' rows, which have no account).
-- RECORD_TYPE STATISTIC on every row (member counts; department 999 rule, Q-01);
-- BUDGET_AMOUNT is STAT_VALUE, SOURCE_AMOUNT null.
-- SCENARIO = 'BUDGET_AMOUNT', the measure column name: the source names none (D-45).
-- ACCOUNT_DESC = LINE_DESCRIPTION, the source's own label for the line.
-- D-48 (transformation): where FIN_BUDGET_MONTHLY carries the same club, month
-- and account, the budget row wins; this row goes to UNKNOWN as DUPLICATE_DETAIL.
-- SOURCE_LINE_KEY: file | row | period (unique, 9,936 / 9,936 at M3).
-- SOURCE_SIGN_CONVENTION PRESENTED: signed by movement as stated (Subs, -Tr
-- negative), D-50.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HHG_MEMBERSHIP_MONTHLY as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from (select *, portfolio_name as property_name from CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY)
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.account_code), '')                     as c_acct
            , null::varchar                                          as c_stat
            , (coalesce(src.member_line_key, '~BLANK~')
                || '|' || coalesce(src.club_segment, '~BLANK~'))     as c_item
            , nullif(trim(src.club_number), '')                      as c_site
            , nullif(split_part(trim(src.account_code), '-', 2), '') as c_dept
        from src
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
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_OPS_MEMBERSHIP_MONTHLY'::varchar as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , refs.club_name::varchar                                               as asset_name
        , case
              when refs.club_name is not null
                  then 'STG_HHG_ASSET_CODES.CLUB_NAME on CLUB_NUMBER (build 10 Q-02)'
          end::varchar                                                          as asset_name_source
        , cln.c_dept::varchar                                                   as department
        , null::varchar                                                         as department_name
        , cln.account_code::varchar                                             as account_number
        , null::varchar                                                         as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'STATISTIC'::varchar                                                  as record_type
        , 'member count (budget membership block; department 999 rule, owner Q-01; build 19 Q-03)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_description::varchar                                         as account_desc
        , cln.period_date::date                                                 as period_end
        , 'BUDGET_AMOUNT'::varchar                                              as scenario
        , null::float                                                           as source_amount
        , cln.budget_amount::float                                              as stat_value
        , 'PRESENTED'::varchar                                                  as source_sign_convention
        , 'presented as stated, signed by movement: Subs and -Transfer out negative or 0, Beg, Adds, +Transfer in and End positive or 0 (build 19 M3, D-50)'::varchar as source_sign_convention_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.source_file_path, '~BLANK~')
            || '|' || coalesce(to_char(cln.source_row_number), '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~'))::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.club_number
        , cln.member_line_key
        , cln.member_category
        , cln.movement_type
        , cln.club_segment
        , cln.line_description
        , cln.account_code
        , cln.period_date
        , cln.budget_amount
        , cln.file_date
        , cln.source_file_path
        , cln.source_row_number
    from cln
    left join refs
        on  refs.club_number = cln.c_site
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HHG_MEMBERSHIP_MONTHLY);
    return 'STG_HHG_MEMBERSHIP_MONTHLY rows=' || v_rows;
end;
$$;
