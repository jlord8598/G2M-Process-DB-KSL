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
    -- department name dictionary, one row per (tenant, department code)
    -- ------------------------------------------------------------------------
    , dept as (
        select
              coa.tenant
            , split_part(nullif(trim(coa.account_number), ''), '-', 1) as dept_code
            , min(coa.department)                                     as department_name
        from CLN.CLEAN.CUR_PROFITSWORD_CHART_OF_ACCOUNTS coa
        group by 1, 2
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'PEREGRINE_RESORTS'::varchar                                          as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_MONTHLY_EXTENDED'::varchar       as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.site_name::varchar                                                as asset_name
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
                  then 'ACCOUNT_NUMBER present, STAT_ACCOUNT blank: AMOUNT (chart ACCOUNT_KIND DOLLAR, M1)'
              when cln.c_stat is not null
                  then 'STAT_ACCOUNT present, ACCOUNT_NUMBER blank: STATISTIC (chart ACCOUNT_KIND STAT, M1)'
              else 'ACCOUNT_NUMBER and STAT_ACCOUNT blank: AMOUNT (assumption, Q-15)'
          end::varchar                                                          as record_type_source
        , nullif(left(split_part(cln.c_stat, '-', 2), 2), '')::varchar          as stat_unit_family
        , cln.description::varchar                                              as account_desc
        , last_day(cln.period_date)::date                                       as period_end
        , cln.scenario_name::varchar                                            as scenario
        , cln.amt::float                                                        as source_amount
        , cln.stat::float                                                       as stat_value
        , coalesce(cln.c_item like 'TOT%', false)::boolean                      as is_subtotal
        , case
              when cln.c_item like 'TOT%'
                  then 'ITEM_TAG prefix TOT: source rollup (owner Q-05)'
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
    left join dept
        on  dept.tenant    = 'PEREGRINE'
        and dept.dept_code = split_part(cln.c_acct, '-', 1)
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED);
    return 'STG_PEREGRINE_RESORTS_MONTHLY_EXTENDED rows=' || v_rows;
end;
$$;
