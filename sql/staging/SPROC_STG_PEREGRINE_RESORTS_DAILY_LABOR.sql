CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_PEREGRINE_RESORTS_DAILY_LABOR(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_PEREGRINE_RESORTS_DAILY_LABOR
-- Builds STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR from
-- CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR. Fact table (owner Q-06).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair.
-- No account column in the source: ACCOUNT_NUMBER and STAT_ACCOUNT are null,
-- SOURCE_ITEM_ID = LABEL, DEPARTMENT = numeric prefix of DEPARTMENT_LABEL,
-- SOURCE_LINE_KEY null. PERSON_ID, EMPLOYEE_ID and EMPLOYEE_NAME are staged
-- here only and never reach SEMANTIC (owner Q-06).
-- DEPARTMENT_NAME: STG_PEREGRINE_RESORTS_DEPARTMENTS.DEPARTMENT_GENERIC on an exact join of
-- tenant, SITE_TAG and department code, unique there so the join cannot fan
-- out; null where no row matches (owner Q-03 (b), Q-04). Build 05 (D-44).
-- ASSET_NAME: the fact's SITE_NAME; where that is null, STG_PEREGRINE_RESORTS_SITES on an
-- exact SITE_TAG match (unique there), named in ASSET_NAME_SOURCE (owner Q-13).
-- STG_PEREGRINE_RESORTS_SITES is built first by the lane's MAIN.
-- SCENARIO: the source names none; the table name without schema (D-45).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR
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
    -- department name dictionary: STG_PEREGRINE_RESORTS_DEPARTMENTS, unique on
    -- (TENANT, SITE_TAG, DEPT_CODE); DEPARTMENT_GENERIC only, DEPARTMENT_OUTLET
    -- not used (owner Q-03 (b), build 05)
    -- ------------------------------------------------------------------------
    , dept as (
        select
              d.tenant
            , d.site_tag
            , d.dept_code
            , d.department_generic                                          as department_name
        from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DEPARTMENTS d
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'PEREGRINE_RESORTS'::varchar                                          as source_lane
        , 'CLN.CLEAN.CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR'::varchar            as source_table
        , cln.c_site::varchar                                                   as source_site_code
        , coalesce(cln.site_name, sites.site_name)::varchar                     as asset_name
        , case
              when cln.site_name is not null   then 'fact SITE_NAME'
              when sites.site_name is not null then 'STG_PEREGRINE_RESORTS_SITES.SITE_NAME on SITE_TAG (owner Q-13)'
          end::varchar                                                          as asset_name_source
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
        , 'CUR_PROFITSWORD_PEREGRINE_DAILY_LABOR'::varchar                    as scenario
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
    left join DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_SITES sites
        on  sites.site_tag = cln.site_tag
    left join dept
        on  dept.tenant    = 'PEREGRINE'
        and dept.site_tag  = cln.site_tag
        and dept.dept_code = cln.c_dept
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_PEREGRINE_RESORTS_DAILY_LABOR);
    return 'STG_PEREGRINE_RESORTS_DAILY_LABOR rows=' || v_rows;
end;
$$;
