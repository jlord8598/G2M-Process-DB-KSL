CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_KSL_SELECT_SERVICE_DAILY_LABOR(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_KSL_SELECT_SERVICE_DAILY_LABOR
-- Builds STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR from
-- CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR. Fact table (owner Q-06).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair.
-- No account column in the source: ACCOUNT_NUMBER and STAT_ACCOUNT are null,
-- SOURCE_ITEM_ID = LABEL, DEPARTMENT = numeric prefix of DEPARTMENT_LABEL,
-- SOURCE_LINE_KEY null. PERSON_ID, EMPLOYEE_ID and EMPLOYEE_NAME are staged
-- here only and never reach SEMANTIC (owner Q-06).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR
    )
    -- ------------------------------------------------------------------------
    -- cleaned key inputs
    -- ------------------------------------------------------------------------
    , cln as (
        select
              src.*
            , nullif(trim(src.site_tag), '')                                as c_site
            , null::varchar                                                 as c_acct
            , null::varchar                                                 as c_stat
            , nullif(trim(src.label), '')                                   as c_item
            , regexp_substr(trim(src.department_label), '^([0-9]+)[.]', 1, 1, 'e') as c_dept
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
        , 'KSL_SELECT_SERVICE'::varchar                                         as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_KSL_DAILY_LABOR'::varchar                  as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , cln.site_name::varchar                                                as asset_name
        , cln.c_dept::varchar                                                   as department
        , dept.department_name::varchar                                         as department_name
        , cln.c_acct::varchar                                                   as account_number
        , cln.c_stat::varchar                                                   as stat_account
        , cln.c_item::varchar                                                   as source_item_id
        , coalesce(cln.c_acct, cln.c_stat, cln.c_item, '~BLANK~')::varchar      as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'No ACCOUNT_NUMBER or STAT_ACCOUNT column in source; AMOUNTS and HOURS on one row: AMOUNT (assumption, Q-15)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.label::varchar                                                    as account_desc
        , cln.business_date::date                                               as period_end
        , null::varchar                                                         as scenario
        , cln.amounts::float                                                    as source_amount
        , cln.hours::float                                                      as stat_value
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , null::varchar                                                         as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.tenant
        , cln.site_tag
        , cln.site_name
        , cln.business_date
        , cln.label
        , cln.department_label
        , cln.position_label
        , cln.labor_type
        , cln.person_id
        , cln.employee_id
        , cln.employee_name
        , cln.hours
        , cln.amounts
        , cln.effective_rate
        , cln.line_seq
        , cln.source_insert_date
        , cln.dw_updated_date
        , cln.cur_load_date
    from cln
    left join dept
        on  dept.tenant    = 'KSL'
        and dept.dept_code = cln.c_dept
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_KSL_SELECT_SERVICE_DAILY_LABOR);
    return 'STG_KSL_SELECT_SERVICE_DAILY_LABOR rows=' || v_rows;
end;
$$;
