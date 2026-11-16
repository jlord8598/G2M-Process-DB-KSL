CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_BEAUMIER_OPS_STATS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_BEAUMIER_OPS_STATS
-- Builds STAGING.STG_BEAUMIER_OPS_STATS from
-- CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_OPS_STATS_MONTHLY.
-- Fact table. Build 23 (BEAUMIER rebuilt, D-44: 2027 budget add-on).
-- Identity form: wide. count(source) x 4 = count(staged); the four measure
-- columns BUDGET_OPENING_DAYS, BUDGET_KEYS, BUDGET_ROOMS_SOLD and
-- BUDGET_ROOMS_AVAILABLE are unpivoted INCLUDE NULLS.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Owner Q-14: the measure column name is the statistic account (STAT_ACCOUNT,
-- ACCOUNT_KEY), RECORD_TYPE STATISTIC, value in STAT_VALUE; SCENARIO is the
-- budget year (BUDGET_YEAR) verbatim; category BUDGET is derived in
-- transformation. Site = HOTEL_CODE; no department.
-- ASSET_NAME = STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE exactly, as
-- the lane's other facts (build 07 Q-03).
-- Zeros are seasonal closures, carried as booked (M1). No money, so no sign
-- convention and no currency. The source names no total line.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_BEAUMIER_OPS_STATS as
    with
    -- ------------------------------------------------------------------------
    -- source, measures cast to one type for the unpivot
    -- ------------------------------------------------------------------------
    src as (
        select
              s.*
            , s.budget_opening_days::float    as m_budget_opening_days
            , s.budget_keys::float            as m_budget_keys
            , s.budget_rooms_sold::float      as m_budget_rooms_sold
            , s.budget_rooms_available::float as m_budget_rooms_available
        from CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_OPS_STATS_MONTHLY s
        where 1=1
    )
    -- ------------------------------------------------------------------------
    -- unpivot, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select *
        from src
        unpivot include nulls (
            measure_value for measure_col in (
                  m_budget_opening_days
                , m_budget_keys
                , m_budget_rooms_sold
                , m_budget_rooms_available
            )
        )
    )
    , u as (
        select
              unp.*
            , replace(unp.measure_col, 'M_', '') as source_measure
        from unp
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'BEAUMIER'::varchar                                                   as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_BEAUMIER_OPS_STATS_MONTHLY'::varchar     as source_table
        , nullif(trim(u.hotel_code), '')::varchar                               as source_site_code
        , loc.hotel_name::varchar                                               as asset_name
        , case
              when loc.hotel_name is not null
                  then 'STG_BEAUMIER_LOCATION_MAP.HOTEL_NAME on HOTEL_CODE; ENTITY_TYPE ' || coalesce(loc.entity_type, '~BLANK~') || ' (build 07 Q-03)'
          end::varchar                                                          as asset_name_source
        , null::varchar                                                         as department
        , null::varchar                                                         as department_name
        , null::varchar                                                         as account_number
        , u.source_measure::varchar                                             as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(u.source_measure), ''), '~BLANK~')::varchar      as account_key
        , 'STATISTIC'::varchar                                                  as record_type
        , 'every measure is a count of days, keys or rooms (build 23 M1, Q-14)'::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , u.source_measure::varchar                                             as account_desc
        , u.period_date::date                                                   as period_end
        , u.source_measure::varchar                                             as source_measure
        , to_char(u.budget_year)::varchar                                       as scenario
        , 'BUDGET_YEAR (owner Q-14)'::varchar                                   as scenario_source
        , null::float                                                           as source_amount
        , u.measure_value::float                                                as stat_value
        , null::varchar                                                         as source_sign_convention
        , 'no money line'::varchar                                              as source_sign_convention_source
        , null::varchar                                                         as currency_code
        , 'no money line'::varchar                                              as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'source gives no way to tell'::varchar                                as subtotal_source
        , (coalesce(u.source_file_path, '~BLANK~') || '|' || coalesce(to_char(u.source_row_number), '~BLANK~') || '|' || u.source_measure)::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , u.source_folder
        , u.portfolio_name
        , u.hotel_code
        , u.period_date
        , u.budget_opening_days
        , u.budget_keys
        , u.budget_rooms_sold
        , u.budget_rooms_available
        , u.budget_year
        , u.file_date
        , u.source_file_path
        , u.source_row_number
    from u
    left join DEV_G2M_AI.STAGING.STG_BEAUMIER_LOCATION_MAP loc
        on  loc.hotel_code = u.hotel_code
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_BEAUMIER_OPS_STATS);
    return 'STG_BEAUMIER_OPS_STATS rows=' || v_rows;
end;
$$;
