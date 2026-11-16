CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_HICV_ROOM_KEYS(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_HICV_ROOM_KEYS
-- Builds STAGING.STG_HICV_ROOM_KEYS from
-- CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_PROPERTY_ROOM_KEYS.
-- Dictionary (owner Q-07): reference data, not a fact; it feeds no stream.
-- Build 23 (new lane HICV).
-- Identity form: long. count(source) = count(staged).
-- Lossless: no filter, no aggregation, no repair. 29 resorts x COUNT_YEAR
-- 2008-2023, one file. A 2025-26 room base is not in landed data (M1).
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_HICV_ROOM_KEYS as
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'HICV'::varchar                                                       as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_PROPERTY_ROOM_KEYS'::varchar    as source_table
        , nullif(trim(src.site_id), '')::varchar                                as site_id_clean
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , src.source_folder
        , src.portfolio_name
        , src.site_id
        , src.resort_name
        , src.resort_location
        , src.year_acquired
        , src.units
        , src.current_keys
        , src.bedrooms
        , src.ihg_count
        , src.count_year
        , src.room_keys
        , src.file_date
        , src.source_file_path
        , src.source_row_number
    from CLN.BOX_INVESTMENT_DATA.CLN_HICV_REF_PROPERTY_ROOM_KEYS src
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_HICV_ROOM_KEYS);
    return 'STG_HICV_ROOM_KEYS rows=' || v_rows;
end;
$$;
