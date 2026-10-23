CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED
-- Builds STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED from
-- CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED. Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim; standard columns derived alongside (docs/sources.md).
-- FCID and SCENARIO_NAME are carried for category derivation, which happens
-- in transformation, not here.
-- ASSET_NAME: the fact's SITE_NAME; where that is null, STG_PEREGRINE_RESORTS_SITES on an
-- exact SITE_TAG match (unique there), named in ASSET_NAME_SOURCE (owner Q-13).
-- STG_PEREGRINE_RESORTS_SITES is built first by the lane's MAIN.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.site_tag), '')       as c_site
            , nullif(trim(src.account_number), '') as c_acct
            , nullif(trim(src.stat_account), '')   as c_stat
            , nullif(trim(src.item_tag), '')       as c_item
        from src
    )
    -- ------------------------------------------------------------------------
    -- department name dictionary from the lane's COA, one row per department
    -- code; a name only where the code carries exactly one distinct
    -- DEPARTMENT_NAME, otherwise null (owner Q-02, build 04)
    -- ------------------------------------------------------------------------
    , dept as (
        select
              nullif(trim(coa.acct_dept_segment), '')                       as dept_code
            , iff(count(distinct nullif(trim(coa.department_name), '')) = 1
                , min(nullif(trim(coa.department_name), ''))
                , null)                                                     as department_name
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_COA coa
        group by 1
    )
    -- ------------------------------------------------------------------------
    -- COA total flag, one row per tag: the tag is a COA total line, and whether
    -- any COA row of the tag carries an account or a stat account
    -- (owner Q-05, Q-08, build 04)
    -- ------------------------------------------------------------------------
    , tot as (
        select
              nullif(trim(coa.tag), '')                                     as tag
            , boolor_agg(coalesce(coa.is_total_line, false))                as coa_total
            , count_if(nullif(trim(coa.account_number), '') is not null
                    or nullif(trim(coa.stat_acct_number), '') is not null) = 0 as coa_no_account
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_COA coa
        group by 1
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'PEREGRINE_RESORTS'::varchar                                          as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED'::varchar       as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , coalesce(cln.site_name, sites.site_name)::varchar                     as asset_name
        , case
              when cln.site_name is not null   then 'fact SITE_NAME'
              when sites.site_name is not null then 'STG_PEREGRINE_RESORTS_SITES.SITE_NAME on SITE_TAG (owner Q-13)'
          end::varchar                                                          as asset_name_source
        , split_part(cln.c_acct, '-', 1)::varchar                               as department
        , dept.department_name::varchar                                         as department_name
        , cln.account_number::varchar                                           as account_number
        , cln.stat_account::varchar                                             as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_acct is null and cln.c_stat is not null then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_acct is not null and cln.c_stat is not null
                  then 'ACCOUNT_NUMBER and STAT_ACCOUNT present: AMOUNT, STAT_UNIT_FAMILY set (owner Q-01, D-29)'
              when cln.c_acct is not null
                  then 'ACCOUNT_NUMBER present, STAT_ACCOUNT blank: AMOUNT (build 01 rule; chart ACCOUNT_KIND DOLLAR at build 01 M1)'
              when cln.c_stat is not null
                  then 'STAT_ACCOUNT present, ACCOUNT_NUMBER blank: STATISTIC (build 01 rule; chart ACCOUNT_KIND STAT at build 01 M1)'
              else 'ACCOUNT_NUMBER and STAT_ACCOUNT blank: AMOUNT (assumption, Q-15)'
          end::varchar                                                          as record_type_source
        , nullif(left(split_part(cln.c_stat, '-', 2), 2), '')::varchar          as stat_unit_family
        , cln.description::varchar                                              as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario_name::varchar                                            as scenario
        , cln.amt::float                                                        as source_amount
        , cln.stat::float                                                       as stat_value
        , (coalesce(cln.c_item like 'TOT%', false)
            or coalesce(tot.coa_total and tot.coa_no_account, false))::boolean  as is_subtotal
        , case
              when cln.c_item like 'TOT%'
                  then 'ITEM_TAG prefix TOT: source rollup (owner Q-05)'
              when tot.coa_total and tot.coa_no_account
                  then 'COA IS_TOTAL_LINE, tag carries no account: source rollup (owner Q-05, Q-08)'
              when tot.coa_total
                  then 'COA IS_TOTAL_LINE on account-coded detail: unflagged (owner Q-08)'
              when left(cln.c_item, 2) = 'RF'
                  then 'ITEM_TAG prefix RF: borderline, unflagged (owner Q-05)'
              when left(cln.c_item, 3) in ('DVR', 'CFL', 'SEQ')
                  then 'ITEM_TAG prefix ' || left(cln.c_item, 3) || ': borderline, unflagged (owner Q-05)'
              else 'ITEM_TAG not a rollup prefix'
          end::varchar                                                          as subtotal_source
        , (coalesce(to_char(cln.fcid), '~BLANK~')
            || '|' || coalesce(cln.site_tag, '~BLANK~')
            || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || coalesce(cln.item_tag, '~BLANK~'))::varchar               as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.tenant
        , cln.fcid
        , cln.scenario_name
        , cln.site_tag
        , cln.site_name
        , cln.item_tag
        , cln.description
        , cln.year
        , cln.month
        , cln.period_date
        , cln.stat
        , cln.amt
        , cln.source_insert_date
        , cln.dw_updated_date
        , cln.cur_load_date
    from cln
    left join DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES sites
        on  sites.site_tag = cln.site_tag
    left join dept
        on  dept.dept_code = split_part(cln.c_acct, '-', 1)
    left join tot
        on  tot.tag = cln.c_item
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED);
    return 'STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED rows=' || v_rows;
end;
$$;
