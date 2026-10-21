CREATE OR REPLACE PROCEDURE DEV_G2M_AI.SEMANTIC.SPROC_SEM_AI_BALANCE_SHEET(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_SEM_AI_BALANCE_SHEET
-- Builds SEMANTIC.SEM_AI_BALANCE_SHEET from every lane's
-- XFRM_{LANE}_BALANCE_SHEET. Unions lanes only (D-36): one self-contained
-- block per lane between BEGIN LANE / END LANE markers.
-- Columns: the section 4 common block, then VALUE_SIGN, VALUE. Both are null
-- (balance sheet accounts are unsigned, section 5); carried for shape only.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET as
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
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_KSL_SELECT_SERVICE_BALANCE_SHEET
    where 1=1
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
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_PEREGRINE_RESORTS_BALANCE_SHEET
    where 1=1
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
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_HHG_BALANCE_SHEET
    where 1=1
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
        , stat_value::float           as stat_value
        , source_line_key::varchar    as source_line_key
        , source_table::varchar       as source_table
        , value_sign::number(2,0)     as value_sign
        , value::float                as value
    from DEV_G2M_AI.TRANSFORMATION.XFRM_NEWBURY_BALANCE_SHEET
    where 1=1
    -- END LANE NEWBURY
    ;

    v_rows := (select count(*) from DEV_G2M_AI.SEMANTIC.SEM_AI_BALANCE_SHEET);
    return 'SEM_AI_BALANCE_SHEET rows=' || v_rows;
end;
$$;
