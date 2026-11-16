CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HICV_PL(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HICV_PL
-- Builds STAGING.STG_HICV_PL from
-- CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_PL_MONTHLY.
-- Fact table. Build 23 (new lane HICV).
-- Identity form: wide. count(source) x 4 = count(staged); the four measure
-- columns ACTUAL_AMOUNT, FORECAST_AMOUNT, PREVIOUS_FORECAST_AMOUNT and
-- BUDGET_AMOUNT are unpivoted INCLUDE NULLS, one staged line per source line
-- and measure. Empty cells are kept (invariant 1), as in the peer lanes.
-- Lossless: no filter, no aggregation, no repair. Raw columns carried verbatim.
-- Key (owner Q-09): site = LOCATION_CODE, department = COST_CENTER_CODE,
-- account = ACCOUNT_CODE; ledger and LOB carried, not keyed. No statistic
-- account and no item id: every line is money, RECORD_TYPE AMOUNT (M1).
-- SOURCE_MEASURE is the unpivoted column name; category is derived from it in
-- transformation. SCENARIO (D-45): the version the source names for the
-- measure (FORECAST_VERSION, PREVIOUS_FORECAST_VERSION, BUDGET_VERSION),
-- verbatim; where it names none, the measure column name verbatim (Q-18).
-- LINE_DESCRIPTION reads account-cost center-P&L category-location-LOB.
-- Structural split (owner Q-04): spaced hyphens (' - ', ' -', '- ') belong to
-- names and are protected, then the text is split on the remaining hyphens.
-- CLEAN: exactly 5 parts; every part carried.
-- ANCHORED (owner Q-15): not 5 parts, but the category is read against the
-- source's own category list, the distinct third parts of the CLEAN lines of
-- this table: first the third part from the end where it is on the list,
-- otherwise the one list name occurring as '-<name>-' where exactly one does.
-- Only DESC_PL_CATEGORY is carried; the other parts are not separable.
-- AMBIGUOUS: neither; every part null. Nothing else is inferred.
-- ACCOUNT_DESC carries LINE_DESCRIPTION verbatim.
-- ASSET_NAME and DEPARTMENT_NAME: the description's own location and cost
-- center parts, CLEAN lines only; null otherwise.
-- Sign (D-50, owner Q-06, Q-16): PROFIT, as booked; nothing flipped.
-- Currency (owner Q-05): USD, an owner assumption; not in landed data.
-- The source names no total line (M1): IS_SUBTOTAL false.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HICV_PL as
    with
    -- ------------------------------------------------------------------------
    -- source, measures cast to one type for the unpivot
    -- ------------------------------------------------------------------------
    src as (
        select
              s.*
            , s.actual_amount::float            as m_actual_amount
            , s.forecast_amount::float          as m_forecast_amount
            , s.previous_forecast_amount::float as m_previous_forecast_amount
            , s.budget_amount::float            as m_budget_amount
            , replace(replace(replace(s.line_description, ' - ', '~SP~'), ' -', '~SL~'), '- ', '~SR~') as desc_protected
        from CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_PL_MONTHLY s
        where 1=1
    )
    -- ------------------------------------------------------------------------
    -- description parse, once per distinct description
    -- ------------------------------------------------------------------------
    , dsc as (
        select distinct
              line_description
            , desc_protected
            , split(desc_protected, '-') as parts
        from src
        where 1=1
    )
    , cat_list as (
        -- the source's own category vocabulary: third part of every CLEAN line
        select distinct
              replace(replace(replace(parts[2]::varchar, '~SP~', ' - '), '~SL~', ' -'), '~SR~', '- ') as category
        from dsc
        where 1=1
          and array_size(parts) = 5
    )
    , dsc_right as (
        select
              d.line_description
            , d.desc_protected
            , d.parts
            , array_size(d.parts) = 5 as is_clean
            , iff(array_size(d.parts) >= 3, replace(replace(replace(d.parts[array_size(d.parts) - 3]::varchar, '~SP~', ' - '), '~SL~', ' -'), '~SR~', '- '), null) as right_candidate
        from dsc d
    )
    , dsc_contains as (
        select
              d.line_description
            , count(c.category) as n_match
            , min(c.category)   as only_match
        from dsc_right d
        left join cat_list c
            on contains(d.line_description, '-' || c.category || '-')
        group by d.line_description
    )
    , dsc_parsed as (
        select
              r.line_description
            , r.parts
            , case
                  when r.is_clean                  then 'CLEAN'
                  when cr.category is not null     then 'ANCHORED'
                  when cc.n_match = 1              then 'ANCHORED'
                  else 'AMBIGUOUS'
              end as desc_split_status
            , case
                  when r.is_clean                  then 'five parts'
                  when cr.category is not null     then 'third part from the end is on the category list'
                  when cc.n_match = 1              then 'exactly one category-list name occurs as -name-'
                  else 'no unique category-list match'
              end as desc_split_rule
            , case
                  when r.is_clean                  then replace(replace(replace(r.parts[2]::varchar, '~SP~', ' - '), '~SL~', ' -'), '~SR~', '- ')
                  when cr.category is not null     then cr.category
                  when cc.n_match = 1              then cc.only_match
              end as desc_pl_category
        from dsc_right r
        left join cat_list cr
            on cr.category = r.right_candidate
        left join dsc_contains cc
            on cc.line_description = r.line_description
    )
    -- ------------------------------------------------------------------------
    -- unpivot, nulls kept
    -- ------------------------------------------------------------------------
    , unp as (
        select *
        from src
        unpivot include nulls (
            measure_value for measure_col in (
                  m_actual_amount
                , m_forecast_amount
                , m_previous_forecast_amount
                , m_budget_amount
            )
        )
    )
    , u as (
        select
              unp.*
            , replace(unp.measure_col, 'M_', '')                      as source_measure
            , p.desc_split_status
            , p.desc_split_rule
            , p.desc_pl_category
            , p.desc_split_status = 'CLEAN'                           as desc_clean
        from unp
        left join dsc_parsed p
            on  p.line_description = unp.line_description
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HICV'::varchar                                                       as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_FIN_PL_MONTHLY'::varchar            as source_table
        , nullif(trim(u.location_code), '')::varchar                            as source_site_code
        , iff(u.desc_clean, replace(replace(replace(split_part(u.desc_protected, '-', 4), '~SP~', ' - '), '~SL~', ' -'), '~SR~', '- '), null)::varchar as asset_name
        , iff(u.desc_clean, 'LINE_DESCRIPTION part 4 (location), clean split', 'LINE_DESCRIPTION does not split cleanly')::varchar as asset_name_source
        , nullif(trim(u.cost_center_code), '')::varchar                         as department
        , iff(u.desc_clean, replace(replace(replace(split_part(u.desc_protected, '-', 2), '~SP~', ' - '), '~SL~', ' -'), '~SR~', '- '), null)::varchar as department_name
        , nullif(trim(u.account_code), '')::varchar                             as account_number
        , null::varchar                                                         as stat_account
        , null::varchar                                                         as source_item_id
        , coalesce(nullif(trim(u.account_code), ''), '~BLANK~')::varchar        as account_key
        , 'AMOUNT'::varchar                                                     as record_type
        , 'every line is money; no unit or count lines (M1)'::varchar           as record_type_source
        , null::varchar                                                         as stat_unit_family
        , u.line_description::varchar                                           as account_desc
        , u.period_date::date                                                   as period_end
        , u.source_measure::varchar                                             as source_measure
        , coalesce(
              case u.source_measure
                  when 'FORECAST_AMOUNT'          then u.forecast_version
                  when 'PREVIOUS_FORECAST_AMOUNT' then u.previous_forecast_version
                  when 'BUDGET_AMOUNT'            then u.budget_version
              end
            , u.source_measure)::varchar                                        as scenario
        , case
              when u.source_measure = 'FORECAST_AMOUNT'          and u.forecast_version is not null          then 'FORECAST_VERSION'
              when u.source_measure = 'PREVIOUS_FORECAST_AMOUNT' and u.previous_forecast_version is not null then 'PREVIOUS_FORECAST_VERSION'
              when u.source_measure = 'BUDGET_AMOUNT'            and u.budget_version is not null            then 'BUDGET_VERSION'
              else 'measure column name (D-45)'
          end::varchar                                                          as scenario_source
        , u.measure_value::float                                                as source_amount
        , null::float                                                           as stat_value
        , 'PROFIT'::varchar                                                     as source_sign_convention
        , 'profit-signed: revenue positive, most costs negative; interest expense booked positive, as booked (build 23 M1, Q-06, Q-16, N-60)'::varchar as source_sign_convention_source
        , 'USD'::varchar                                                        as currency_code
        , 'owner assumption (build 23 Q-05); not in landed data'::varchar       as currency_code_source
        , false::boolean                                                        as is_subtotal
        , 'no total, subtotal or computed line found (build 23 M1)'::varchar     as subtotal_source
        , u.desc_split_status::varchar                                          as desc_split_status
        , u.desc_split_rule::varchar                                            as desc_split_rule
        , iff(u.desc_clean, replace(replace(replace(split_part(u.desc_protected, '-', 1), '~SP~', ' - '), '~SL~', ' -'), '~SR~', '- '), null)::varchar as desc_account_name
        , u.desc_pl_category::varchar                                           as desc_pl_category
        , iff(u.desc_clean, replace(replace(replace(split_part(u.desc_protected, '-', 5), '~SP~', ' - '), '~SL~', ' -'), '~SR~', '- '), null)::varchar as desc_lob_name
        , (coalesce(u.ledger_tab, '~BLANK~') || '|' || coalesce(u.account_code, '~BLANK~') || '|' || coalesce(u.cost_center_code, '~BLANK~') || '|' || coalesce(u.lob_code, '~BLANK~') || '|' || coalesce(u.location_code, '~BLANK~') || '|' || coalesce(u.line_id, '~BLANK~') || '|' || coalesce(to_char(u.period_date, 'YYYY-MM-DD'), '~BLANK~') || '|' || u.source_measure)::varchar as source_line_key
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , u.source_folder
        , u.portfolio_name
        , u.ledger_code
        , u.ledger_tab
        , u.account_code
        , u.cost_center_code
        , u.lob_code
        , u.location_code
        , u.line_id
        , u.line_description
        , u.section
        , u.period_date
        , u.actual_amount
        , u.forecast_amount
        , u.previous_forecast_amount
        , u.budget_amount
        , u.forecast_version
        , u.previous_forecast_version
        , u.budget_version
        , u.actual_file_date
        , u.forecast_file_date
        , u.budget_file_date
        , u.source_file_path
        , u.source_row_number
    from u
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HICV_PL);
    return 'STG_HICV_PL rows=' || v_rows;
end;
$$;
