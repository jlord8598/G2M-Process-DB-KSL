CREATE OR REPLACE PROCEDURE DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_INCOME_STATEMENT_ACTUAL(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_SEM_AI_INCOME_STATEMENT_ACTUAL
-- Builds SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL: the CATEGORY = 'ACTUAL' rows of
-- every lane's XFRM_{LANE}_INCOME_STATEMENT. Unions lanes only (D-36): one
-- self-contained block per lane between BEGIN LANE / END LANE markers.
-- CURRENCY_CODE (build 12, owner Q-06 / Q-10): a per-lane literal after
-- SOURCE_AMOUNT; BEAUMIER per hotel from XFRM_BEAUMIER_* (build 15 Q-06, N-19
-- closed), ALTERRA UNCONFIRMED (N-18).
-- Build 14: UNDER_CANVAS block added (USD, owner Q-03). OUTRIGGER
-- is a pacing-only lane (build 21: THE_PIG gains a block, GBP, owner Q-06); THE_PIG was: no semantic block (D-24, owner Q-06).
-- Columns: the section 4 common block, then VALUE_SIGN, VALUE.
-- The category predicate splits the stream three ways; it excludes nothing
-- (every income statement row carries exactly one of ACTUAL, BUDGET,
-- FORECAST, checked at M5).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL as
    -- BEGIN LANE KSL_SELECT_SERVICE
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE KSL_SELECT_SERVICE
    union all
    -- BEGIN LANE PEREGRINE_RESORTS
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE PEREGRINE_RESORTS
    union all
    -- BEGIN LANE HHG
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE HHG
    union all
    -- BEGIN LANE NEWBURY
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE NEWBURY
    union all
    -- BEGIN LANE HERSHA
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_HERSHA_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE HERSHA
    union all
    -- BEGIN LANE INVITED_CLUBS
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_INVITED_CLUBS_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE INVITED_CLUBS
    union all
    -- BEGIN LANE BEAUMIER
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , currency_code::varchar      as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_BEAUMIER_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE BEAUMIER
    union all
    -- BEGIN LANE DAVIDSON
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_DAVIDSON_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE DAVIDSON
    union all
    -- BEGIN LANE ALTERRA
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'UNCONFIRMED'::varchar      as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_ALTERRA_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE ALTERRA
    union all
    -- BEGIN LANE ATLANTIC_AVIATION
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_ATLANTIC_AVIATION_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE ATLANTIC_AVIATION
    union all
    -- BEGIN LANE JW_VENICE
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'EUR'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_JW_VENICE_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE JW_VENICE
    union all
    -- BEGIN LANE UNDER_CANVAS
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'USD'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_UNDER_CANVAS_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE UNDER_CANVAS
    union all
    -- BEGIN LANE THE_PIG
    select
          :P_RUN_ID::varchar          as run_id
        , source_lane::varchar        as source_lane
        , source_site_code::varchar   as source_site_code
        , asset_name::varchar         as asset_name
        , department::varchar         as department
        , department_name::varchar    as department_name
        , account_number::varchar     as account_number
        , stat_account::varchar       as stat_account
        , account_key::varchar        as account_key
        , record_type::varchar        as record_type
        , record_type_source::varchar as record_type_source
        , stat_unit_family::varchar   as stat_unit_family
        , account_desc::varchar       as account_desc
        , period_end::date            as period_end
        , category::varchar           as category
        , scenario::varchar           as scenario
        , h1::varchar                 as h1
        , h2::varchar                 as h2
        , h3::varchar                 as h3
        , h4::varchar                 as h4
        , h5::varchar                 as h5
        , p_l_section::varchar        as p_l_section
        , normal_balance::varchar     as normal_balance
        , is_subtotal::boolean        as is_subtotal
        , subtotal_source::varchar    as subtotal_source
        , source_amount::float        as source_amount
        , 'GBP'::varchar              as currency_code
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_THE_PIG_INCOME_STATEMENT
    where 1=1
      and category = 'ACTUAL'
    -- END LANE THE_PIG
    ;

    v_rows := (select count(*) from DEV_G2M_AI.SEMANTIC.SEM_AI_INCOME_STATEMENT_ACTUAL);
    return 'SEM_AI_INCOME_STATEMENT_ACTUAL rows=' || v_rows;
end;
$$;
