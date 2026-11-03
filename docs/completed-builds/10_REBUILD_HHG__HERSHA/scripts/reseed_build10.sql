-- Build 10 one-time D-44 re-seed of HHG (owner Q-03, Q-04, Q-09, stop 2 correction).
-- Columns D-44 allows: H1-H5, section, balance, sign, METRIC_UNIT, AGGREGATION_TYPE,
-- seed source. Keyed on the five-part key; no insert, no delete; UNREVIEWED only.
-- Source = the seeder branch's own USING block, copied verbatim by generator.
-- HERSHA is not re-seeded: no mapping change was approved for it.

merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_HHG_TR12_DATA
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_HHG_FORECAST_ANAPLAN
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_HHG_ROUNDS_DETAIL
            )
            -- ----------------------------------------------------------------
            -- extract: one row per five-part key, attributes by MIN()
            -- ----------------------------------------------------------------
            , ext as (
                select
                      coalesce(nullif(trim(source_lane), ''), '~BLANK~')      as k_lane
                    , coalesce(nullif(trim(source_site_code), ''), '~BLANK~') as k_site
                    , coalesce(nullif(trim(department), ''), '~BLANK~')       as k_dept
                    , coalesce(nullif(trim(account_key), ''), '~BLANK~')      as k_acct
                    , coalesce(nullif(trim(record_type), ''), '~BLANK~')      as k_rtype
                    , min(asset_name)                                         as asset_name
                    , min(department_name)                                    as department_name
                    , min(account_number)                                     as account_number
                    , min(stat_account)                                       as stat_account
                    , min(account_desc)                                       as account_desc
                    , min(source_table)                                       as src_tbl
                    , min(stat_unit_family)                                   as unit_family
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- Anaplan line item map (owner Q-04, stop 3)
            -- ----------------------------------------------------------------
            , amap as (
                select column1 as line_item, column2 as h1, column3 as h2
                from values
                      ('Ala Carte Revenue', 'Revenue', 'Revenue')
                    , ('Banquet F&B Revenue', 'Revenue', 'Revenue')
                    , ('Lodging/Pool Revenue', 'Revenue', 'Revenue')
                    , ('Other Golf Revenue', 'Revenue', 'Revenue')
                    , ('Tennis/Fitness/Spa Revenue', 'Revenue', 'Revenue')
                    , ('Merchandise Sales', 'Revenue', 'Revenue')
                    , ('Cart Fees', 'Revenue', 'Revenue')
                    , ('Green Fees', 'Revenue', 'Revenue')
                    , ('Initiation Fees', 'Revenue', 'Revenue')
                    , ('Membership Dues', 'Revenue', 'Revenue')
                    , ('Timeshare Dues', 'Revenue', 'Revenue')
                    , ('Other F&B Income', 'Revenue', 'Revenue')
                    , ('Food & Beverage Cost of Sales', 'Expense', 'Cost of Goods Sold')
                    , ('Merchandise Cost of Sales', 'Expense', 'Cost of Goods Sold')
                    , ('Administrative Labor', 'Expense', 'Payroll')
                    , ('Course Maintenance Labor', 'Expense', 'Payroll')
                    , ('Food & Beverage Labor', 'Expense', 'Payroll')
                    , ('Golf Operations Labor', 'Expense', 'Payroll')
                    , ('Lodging/Pool Labor', 'Expense', 'Payroll')
                    , ('Membership & Marketing Labor', 'Expense', 'Payroll')
                    , ('Tennis/Fitness/Spa Labor', 'Expense', 'Payroll')
                    , ('Administrative Expense', 'Expense', 'Operating Expenses')
                    , ('Course Maintenance Expense', 'Expense', 'Operating Expenses')
                    , ('Fixed G&A Expense', 'Expense', 'Operating Expenses')
                    , ('Food & Beverage Expense', 'Expense', 'Operating Expenses')
                    , ('Golf Operations Expense', 'Expense', 'Operating Expenses')
                    , ('Lodging/Pool Expense', 'Expense', 'Operating Expenses')
                    , ('Membership & Marketing Expense', 'Expense', 'Operating Expenses')
                    , ('Tennis/Fitness/Spa Expense', 'Expense', 'Operating Expenses')
                    , ('Other Income', 'Below the Line', 'Other Income / (Expense)')
            )
            -- ----------------------------------------------------------------
            -- chart of accounts: type per department + natural account, and the
            -- type per natural account where it is single across departments
            -- ----------------------------------------------------------------
            , coa as (
                select department_code as c_dept, natural_account as c_nat, min(account_type) as c_type
                from DEV_G2M_AI.STAGING.STG_HHG_CHART_OF_ACCOUNTS
                where 1=1
                group by 1, 2
            )
            , coa_nat as (
                select natural_account as c_nat, min(account_type) as c_type
                from DEV_G2M_AI.STAGING.STG_HHG_CHART_OF_ACCOUNTS
                where 1=1
                group by 1
                having count(distinct account_type) = 1
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , nullif(trim(ext.account_number), '')                                          as c_acct
                    , regexp_like(nullif(trim(ext.account_number), ''), '[0-9]{4}-[0-9]{3}-[0-9]{5}') as acct_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 10, 1))           as digit
                    , amap.h1                                                                       as a_h1
                    , amap.h2                                                                       as a_h2
                    , split_part(nullif(trim(ext.account_number), ''), '-', 3)                      as nat
                    , coalesce(coa.c_type, coa_nat.c_type)                                          as t_type
                    , iff(coa.c_type is not null, 'department + natural account', 'natural account, single type') as t_how
                from ext
                left join amap
                    on  ext.src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                    and amap.line_item = ext.k_acct
                left join coa
                    on  ext.src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA'
                    and coa.c_dept = split_part(nullif(trim(ext.account_number), ''), '-', 2)
                    and coa.c_nat  = split_part(nullif(trim(ext.account_number), ''), '-', 3)
                left join coa_nat
                    on  ext.src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_TR12_DATA'
                    and coa_nat.c_nat = split_part(nullif(trim(ext.account_number), ''), '-', 3)
            )
            , prop2 as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC' or not acct_ok or t_type is null then null
                          when t_type = 'Revenue' and nat in ('51050', '51060')        then 'Expense|Cost of Goods Sold'
                          when t_type = 'Revenue'                                       then 'Revenue|Revenue'
                          when t_type = 'Cost of Sales'                                 then 'Expense|Cost of Goods Sold'
                          when t_type = 'Labor'                                         then 'Expense|Payroll'
                          when t_type = 'Operating Expense'                             then 'Expense|Operating Expenses'
                          when t_type = 'Other Income'                                  then 'Below the Line|Other Income / (Expense)'
                          when t_type = 'Below EBITDA' and nat in ('82000', '82100', '82200')
                                                                                        then 'Below the Line|Depreciation & Amortization'
                          when t_type = 'Below EBITDA' and nat = '84000'               then 'Below the Line|Income Taxes'
                          when t_type = 'Below EBITDA'                                  then 'Below the Line|Other Income / (Expense)'
                      end as t_map
                from prop
            )
            , cls as (
                select
                      prop2.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when t_map is not null                then split_part(t_map, '|', 1)
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                              then coalesce(a_h1, 'Unclassified')
                          when c_acct is null                   then 'Unclassified'
                          when not acct_ok                      then 'Unclassified'
                          when digit = 4                        then 'Revenue'
                          when digit in (5, 6, 7)               then 'Expense'
                          when digit = 8                        then 'Below the Line'
                          when digit = 9                        then 'Allocations & Reserves'
                          when digit in (1, 2, 3)               then 'Balance Sheet'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'
                               and src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL' then 'ROUNDS_COUNT'
                          when k_rtype = 'STATISTIC'             then 'STAT_9'
                          when t_map is not null                 then split_part(t_map, '|', 2)
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                              then coalesce(a_h2, 'UNCLASSIFIED')
                          when c_acct is null or not acct_ok     then 'UNCLASSIFIED'
                          when digit = 1                         then 'Assets'
                          when digit = 2                         then 'Liabilities'
                          when digit = 3                         then 'Equity'
                          when digit = 4                         then 'Revenue'
                          when digit = 5                         then 'Cost of Goods Sold'
                          when digit = 6                         then 'Payroll'
                          when digit = 7                         then 'Operating Expenses'
                          when digit = 8                         then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'
                               and src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_ROUNDS_DETAIL'
                              then 'RECORD_TYPE STATISTIC; H2 = ROUNDS_COUNT, the source column name (Q-07)'
                          when k_rtype = 'STATISTIC'
                              then 'RECORD_TYPE STATISTIC (dept 999, owner Q-01); H2 = STAT_9, section code, no family stated'
                          when t_map is not null and nat in ('51050', '51060') and t_type = 'Revenue'
                              then 'COA ACCOUNT_TYPE Revenue overridden to COGS for ' || nat || ' (build 10 Q-03)'
                          when t_map is not null
                              then 'COA ACCOUNT_TYPE ' || t_type || ' by ' || t_how || ' (D-46, build 10 Q-03)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN' and a_h1 is not null
                              then 'LINE_ITEM name as stated section (owner Q-04, stop 3)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_HERITAGE_GOLF_FORECAST_ANAPLAN'
                              then 'LINE_ITEM not in the approved map: nothing to derive'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 10 of ACCOUNT_CODE)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop2
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                  then 'Gross Profit'
                      when 'Cost of Goods Sold'       then 'Gross Profit'
                      when 'Payroll'                  then 'Operating'
                      when 'Operating Expenses'       then 'Operating'
                      when 'Other Income / (Expense)' then 'Non-Operating'
                      when 'Depreciation & Amortization' then 'Operating'
                      when 'Income Taxes'             then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                      when 'Depreciation & Amortization' then 'Debit'
                      when 'Income Taxes'             then 'Debit'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                      when 'Depreciation & Amortization' then -1
                      when 'Income Taxes'             then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
        ) src
    on tgt.source_lane = src.k_lane and tgt.source_site_code = src.k_site and tgt.department = src.k_dept and tgt.account_key = src.k_acct and tgt.record_type = src.k_rtype
when matched and tgt.review_status = 'UNREVIEWED' and (not equal_null(tgt.h1, src.h1) or not equal_null(tgt.h2, src.h2) or not equal_null(tgt.h3, src.h3) or not equal_null(tgt.h4, src.h4) or not equal_null(tgt.h5, src.h5) or not equal_null(tgt.p_l_section, src.p_l_section) or not equal_null(tgt.normal_balance, src.normal_balance) or not equal_null(tgt.value_sign, src.value_sign) or not equal_null(tgt.metric_unit, src.metric_unit) or not equal_null(tgt.aggregation_type, src.aggregation_type)) then update set
    tgt.h1 = src.h1, tgt.h2 = src.h2, tgt.h3 = src.h3, tgt.h4 = src.h4, tgt.h5 = src.h5, tgt.p_l_section = src.p_l_section, tgt.normal_balance = src.normal_balance, tgt.value_sign = src.value_sign, tgt.metric_unit = src.metric_unit, tgt.aggregation_type = src.aggregation_type, tgt.seed_source = src.seed_source;
