CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_STG_UNDER_CANVAS_CONSOLIDATED_PL(P_RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
-- ============================================================================
-- SPROC_STG_UNDER_CANVAS_CONSOLIDATED_PL
-- Builds STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL from
-- CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CONSOLIDATED_PL.
-- Fact table: the actuals file's P&L summary, one YTD value per line at
-- 2026-09-30. Every row loses to the P&L detail under D-48 in transformation
-- (owner Q-04): UNKNOWN, DUPLICATE_DETAIL.
-- Identity form: long, one branch (ACTUAL_AMOUNT); FORECAST / BUDGET null (M1).
-- Key: SITE = ENTITY_NAME; DEPARTMENT = SOURCE_SECTION_LABEL; ACCOUNT_KEY =
-- LINE_ITEM as SOURCE_ITEM_ID (no account number). RECORD_TYPE derived: the
-- named statistic and ratio lines -> STATISTIC, else AMOUNT.
-- IS_SUBTOTAL: the total and chain lines that tie to their members (M1 tie
-- test, by LINE_ORDER); line 148 does not tie and is not marked.
-- SCENARIO: the source's SCENARIO, verbatim. PERIOD_TYPE (YTD) carried raw.
-- SOURCE_LINE_KEY: LINE_ORDER | PERIOD_TYPE.
-- Source column SCENARIO is carried as SRC_SCENARIO.
-- ============================================================================
declare
    v_rows integer;
begin
    create or replace table DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL as
    with
    src as (
        select *
        from CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CONSOLIDATED_PL
    )
    , cln as (
        select
              src.*
            , (case when src.line_item in ('Days Open', '# of Tents/Rooms', 'Rooms Available', 'Rooms Sold', 'Occupancy %', 'Average Daily Rate', 'Revenue per Available Room', 'Operating CPORs', 'Non-Operating CPORs', 'Adjusted GOP %', 'Adjusted EBITDA Margin %') then 'STATISTIC' else 'AMOUNT' end) as c_rtype
            , coalesce(src.line_order in (23, 33, 40, 45, 50, 55, 70, 72, 73, 75, 88, 94, 98, 99, 105, 128, 133, 135), false) as c_subtotal
        from src
    )
    select
          :P_RUN_ID::varchar                                                    as run_id
        , 'UNDER_CANVAS'::varchar                                               as source_lane
        , 'CLN.BOX_INVESTMENT_DATA.CLN_UNDER_CANVAS_CONSOLIDATED_PL'::varchar as source_table
        , nullif(trim(cln.entity_name), '')::varchar                            as source_site_code
        , cln.entity_name::varchar                                              as asset_name
        , nullif(trim(cln.source_section_label), '')::varchar                   as department
        , cln.source_section_label::varchar                                     as department_name
        , null::varchar                                                         as account_number
        , null::varchar                                                         as stat_account
        , nullif(trim(cln.line_item), '')::varchar                              as source_item_id
        , coalesce(nullif(trim(cln.line_item), ''), '~BLANK~')::varchar         as account_key
        , cln.c_rtype::varchar                                                  as record_type
        , (case when cln.c_rtype = 'STATISTIC' then 'LINE_ITEM named statistic or ratio: STATISTIC (derived, M1)' else 'LINE_ITEM money line: AMOUNT (derived, M1)' end)::varchar as record_type_source
        , null::varchar                                                         as stat_unit_family
        , cln.line_item::varchar                                                as account_desc
        , cln.period_date::date                                                 as period_end
        , cln.scenario::varchar                                                 as scenario
        , iff(cln.c_rtype = 'STATISTIC', null, cln.actual_amount)::float        as source_amount
        , iff(cln.c_rtype = 'STATISTIC', cln.actual_amount, null)::float        as stat_value
        , cln.c_subtotal::boolean                                               as is_subtotal
        , (case when cln.c_subtotal then 'total or chain line, ties to its members (M1 tie test)' else 'not a tested total' end)::varchar as subtotal_source
        , (coalesce(to_char(cln.line_order), '~BLANK~') || '|' || coalesce(cln.period_type, '~BLANK~'))::varchar as source_line_key
        , 'ACTUAL'::varchar                                                     as measure_column
        -- --------------------------------------------------------------------
        -- raw source columns, verbatim
        -- --------------------------------------------------------------------
        , cln.* exclude (c_rtype, c_subtotal) rename (scenario as src_scenario)
    from cln
    where 1=1;

    v_rows := (select count(*) from DEV_G2M_AI.STAGING.STG_UNDER_CANVAS_CONSOLIDATED_PL);
    return 'STG_UNDER_CANVAS_CONSOLIDATED_PL rows=' || v_rows;
end;
$$;
