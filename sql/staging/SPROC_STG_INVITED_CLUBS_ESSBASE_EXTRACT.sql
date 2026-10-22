CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_INVITED_CLUBS_ESSBASE_EXTRACT
-- Builds STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT from
-- CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ESSBASE_EXTRACT.
-- Fact table, 17.1M source rows.
-- Identity form: wide, 3 columns unpivoted (ACTUAL_AMOUNT, FORECAST_AMOUNT,
-- BUDGET_AMOUNT), nulls kept: count(staged) = count(source) x 3. UNION ALL of one
-- branch per measure; no branch filters.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim;
-- DEPARTMENT is carried once, as the standard column (the raw value verbatim).
-- RECORD_TYPE from META_ACCOUNT.DATA_TYPE: non-currency -> STATISTIC (measure to
-- STAT_VALUE, SOURCE_AMOUNT null), else AMOUNT, including the 3 accounts META
-- does not list (owner Q-05).
-- META_* are not unique on their member; each is reduced with MIN() per member
-- before the join, so no join can add rows.
-- IS_SUBTOTAL: REPORT_LEVEL EBITDA_SUMMARY (owner Q-01). TotalDOMEnter stays
-- false and is recorded as borderline in SUBTOTAL_SOURCE (owner Q-01).
-- SCENARIO = VERSION_NAME; on the forecast branch FORECAST_VERSION is appended
-- (Q-07). Site = ENTITY. Names from META ALIAS_DEFAULT (DESCRIPTION is empty).
-- SOURCE_LINE_KEY: the 9 dimension columns, unique and never blank (M1), plus
-- the measure; one source file row feeds many cells, so path|row is not a key.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT as
    with
    -- ------------------------------------------------------------------------
    -- source
    -- ------------------------------------------------------------------------
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ESSBASE_EXTRACT
    )
    -- ------------------------------------------------------------------------
    -- unpivot: one branch per measure column, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select src.*, 'ACTUAL_AMOUNT'::varchar   as measure_column, src.actual_amount   as m_value, src.actual_source_file_path   as m_path, src.actual_source_row_number   as m_row, null::varchar             as m_version from src
        union all
        select src.*, 'FORECAST_AMOUNT'::varchar as measure_column, src.forecast_amount as m_value, src.forecast_source_file_path as m_path, src.forecast_source_row_number as m_row, src.forecast_version as m_version from src
        union all
        select src.*, 'BUDGET_AMOUNT'::varchar   as measure_column, src.budget_amount   as m_value, src.budget_source_file_path   as m_path, src.budget_source_row_number   as m_row, null::varchar             as m_version from src
    )
    -- ------------------------------------------------------------------------
    -- dictionaries, one row per member (MIN)
    -- ------------------------------------------------------------------------
    , acct as (
        select account, min(account_type) as account_type, min(data_type) as data_type, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
        group by account
    )
    , ent as (
        select entity, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ENTITY
        group by entity
    )
    , dept as (
        select department, min(alias_default) as alias_default
        from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_DEPARTMENT
        group by department
    )
    , cln as (
        select
              unp.*
            , acct.account_type
            , acct.data_type
            , acct.alias_default as account_description
            , ent.alias_default  as entity_description
            , dept.alias_default as department_description
            , iff(lower(trim(acct.data_type)) = 'non-currency', 'STATISTIC', 'AMOUNT') as c_rtype
        from unp
        left join acct on acct.account = unp.account
        left join ent  on ent.entity = unp.entity
        left join dept on dept.department = unp.department
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'INVITED_CLUBS'::varchar                                              as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_INVITED_CLUBS_ESSBASE_EXTRACT'::varchar as source_table
        , nullif(trim(cln.entity), '')::varchar                                 as source_site_code
        , cln.entity_description::varchar                                       as asset_name
        , cln.department::varchar                                               as department
        , cln.department_description::varchar                                   as department_name
        , cln.account::varchar                                                  as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(cln.account), ''), '~BLANK~')::varchar           as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , case
              when cln.data_type is null then 'account not in META_ACCOUNT: AMOUNT (owner Q-05)'
              else 'META_ACCOUNT.DATA_TYPE ' || cln.data_type || ': ' || cln.c_rtype || ' (stated by the source)'
          end::varchar                                                          as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.account_description::varchar                                      as account_desc
        , cln.period_date::date                                                 as period_end
        , (cln.version_name || iff(cln.m_version is not null, ' | ' || cln.m_version, ''))::varchar as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.m_value)::float              as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.m_value, null)::float              as stat_value
        , (cln.report_level = 'EBITDA_SUMMARY')::boolean                        as is_subtotal
        , case
              when cln.report_level = 'EBITDA_SUMMARY'
                  then 'REPORT_LEVEL EBITDA_SUMMARY: computed Adjusted Cash EBITDA rollup, by structure (owner Q-01)'
              when cln.day_of_month = 'TotalDOMEnter'
                  then 'DAY_OF_MONTH TotalDOMEnter: borderline, equals Day01-31 in 76 pct of groups; not flagged (owner Q-01)'
              else 'REPORT_LEVEL DETAIL'
          end::varchar                                                          as subtotal_source
        , (cln.report_level || '|' || cln.entity || '|' || cln.account || '|' || cln.department
            || '|' || cln.subaccount || '|' || cln.location || '|' || cln.version_name
            || '|' || cln.day_of_month || '|' || coalesce(to_char(cln.period_date, 'YYYY-MM-DD'), '~BLANK~')
            || '|' || cln.measure_column)::varchar                            as source_line_key
        , cln.measure_column::varchar                                           as measure_column
        , cln.account_type::varchar                                             as meta_account_type
        , cln.data_type::varchar                                                as meta_data_type
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim (DEPARTMENT above)
        -- --------------------------------------------------------------------
        , cln.source_folder
        , cln.property_name
        , cln.report_level
        , cln.entity
        , cln.account
        , cln.subaccount
        , cln.location
        , cln.version_name
        , cln.day_of_month
        , cln.period_date
        , cln.actual_amount
        , cln.forecast_amount
        , cln.forecast_version
        , cln.budget_amount
        , cln.actual_file_date
        , cln.forecast_file_date
        , cln.budget_file_date
        , cln.actual_source_file_path
        , cln.actual_source_row_number
        , cln.forecast_source_file_path
        , cln.forecast_source_row_number
        , cln.budget_source_file_path
        , cln.budget_source_row_number
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT);
    return 'STG_INVITED_CLUBS_ESSBASE_EXTRACT rows=' || v_rows;
end;
$$;
