CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_LEDGER_BATCHES(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_LEDGER_BATCHES
-- Builds STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES from
-- CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES. Fact table.
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. Raw columns carried
-- verbatim; standard columns derived alongside (docs/sources.md).
-- SOURCE_ITEM_ID is null: the source has no ITEM_TAG column (Q-14).
-- STATUS is carried as an attribute and decides nothing.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.site_tag), '')  as c_site
            , nullif(trim(src.gl_acct), '')   as c_acct
            , nullif(trim(src.stat_acct), '') as c_stat
            , null::varchar                   as c_item
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
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_LEDGER_BATCHES'::varchar         as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.site_name::varchar                                                as asset_name
        , split_part(cln.c_acct, '-', 1)::varchar                               as department
        , dept.department_name::varchar                                         as department_name
        , cln.gl_acct::varchar                                                  as account_number
        , cln.stat_acct::varchar                                                as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , case
              when cln.c_acct is null and cln.c_stat is not null then 'STATISTIC'
              else 'AMOUNT'
          end::varchar                                                          as record_type
        , case
              when cln.c_acct is not null and cln.c_stat is not null
                  then 'GL_ACCT and STAT_ACCT present: AMOUNT, STAT_UNIT_FAMILY set (owner Q-01, D-29)'
              when cln.c_acct is not null
                  then 'GL_ACCT present, STAT_ACCT blank: AMOUNT (chart ACCOUNT_KIND DOLLAR, M1)'
              when cln.c_stat is not null
                  then 'STAT_ACCT present, GL_ACCT blank: STATISTIC (chart ACCOUNT_KIND STAT, M1)'
              else 'GL_ACCT and STAT_ACCT blank: AMOUNT (assumption, Q-15)'
          end::varchar                                                          as record_type_source
        , nullif(left(split_part(cln.c_stat, '-', 2), 2), '')::varchar          as stat_unit_family
        , cln.item_description::varchar                                         as account_desc
        , last_day(cln.fiscal_period_date)::date                                as period_end
        , null::varchar                                                         as scenario
        , cln.amt::float                                                        as source_amount
        , cln.qty::float                                                        as stat_value
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(cln.site_tag, '~BLANK~')
            || '|' || coalesce(to_char(cln.batch_id), '~BLANK~')
            || '|' || coalesce(cln.gl_acct, '~BLANK~')
            || '|' || coalesce(cln.stat_acct, '~BLANK~')
            || '|' || coalesce(cln.item_description, '~BLANK~')
            || '|' || coalesce(to_char(cln.line_seq), '~BLANK~'))::varchar      as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.tenant
        , cln.site_tag
        , cln.site_name
        , cln.batch_id
        , cln.batch_description
        , cln.type_id
        , cln.status
        , cln.date_posted
        , cln.fiscal_year
        , cln.fiscal_period
        , cln.fiscal_period_date
        , cln.gl_acct
        , cln.stat_acct
        , cln.item_description
        , cln.qty
        , cln.amt
        , cln.line_seq
        , cln.source_insert_date
        , cln.dw_updated_date
        , cln.cur_load_date
    from cln
    left join dept
        on  dept.tenant    = 'PEREGRINE'
        and dept.dept_code = split_part(cln.c_acct, '-', 1)
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_LEDGER_BATCHES);
    return 'STG_PEREGRINE_RESORTS_LEDGER_BATCHES rows=' || v_rows;
end;
$$;
