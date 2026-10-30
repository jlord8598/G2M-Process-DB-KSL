-- Build 08 one-time D-44 re-seed (owner Q-08). Classification columns only,
-- keyed on the five-part key; no insert, no delete; review_status UNREVIEWED only.
-- Source = the seeder branch's own USING block, copied verbatim by generator.

merge into DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
using (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, meta_account_type
                from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_ESSBASE_EXTRACT
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
                    , min(meta_account_type)                                  as m_type
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , lower(trim(ext.m_type))                                                as c_type
                    , regexp_like(nullif(trim(ext.account_number), ''), 'A[0-9]{5}')         as acct_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 2, 1))      as digit
                from ext
            )
            , prop6 as (
                select
                      prop.*
                    , case
                          when not (c_type = 'expense' and acct_ok and digit = 6) then null
                          when substr(trim(account_number), 2, 5) in ('63004', '63009', '63010', '63014', '63015', '63019', '63020')
                                                                                   then 'Income Taxes'
                          when substr(trim(account_number), 2, 5) in ('62824', '62838', '62839', '62849')
                                                                                   then 'Other Income / (Expense)'
                          when substr(trim(account_number), 2, 5) = '63504'       then 'Operating Expenses'
                          when substr(trim(account_number), 2, 5) = '63699'       then 'UNCLASSIFIED'
                          when substr(trim(account_number), 2, 3) in ('600', '601', '602')        then 'Cost of Goods Sold'
                          when substr(trim(account_number), 2, 3) in ('603', '604', '605', '606') then 'Payroll'
                          when substr(trim(account_number), 2, 3) between '607' and '633'
                            or substr(trim(account_number), 2, 3) = '638'         then 'Operating Expenses'
                          when substr(trim(account_number), 2, 3) = '635'         then 'Other Income / (Expense)'
                          when substr(trim(account_number), 2, 3) = '636'         then 'Depreciation & Amortization'
                          else 'UNCLASSIFIED'
                      end as h2_6
                from prop
            )
            , cls as (
                select
                      prop6.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_type = 'asset'                 then 'Balance Sheet'
                          when c_type = 'liability'             then 'Balance Sheet'
                          when c_type = 'equity'                then 'Balance Sheet'
                          when c_type = 'revenue'               then 'Revenue'
                          when h2_6 in ('Other Income / (Expense)', 'Depreciation & Amortization', 'Income Taxes')
                                                                                     then 'Below the Line'
                          when c_type = 'expense' and acct_ok and digit in (5, 6, 7) then 'Expense'
                          when c_type = 'expense' and acct_ok and digit = 8          then 'Below the Line'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'             then k_acct
                          when c_type = 'asset'                  then 'Assets'
                          when c_type = 'liability'              then 'Liabilities'
                          when c_type = 'equity'                 then 'Equity'
                          when c_type = 'revenue'                then 'Revenue'
                          when c_type = 'expense' and acct_ok and digit = 5 then 'Cost of Goods Sold'
                          when c_type = 'expense' and acct_ok and digit = 6 then h2_6
                          when c_type = 'expense' and acct_ok and digit = 7 then 'Operating Expenses'
                          when c_type = 'expense' and acct_ok and digit = 8 then 'Other Income / (Expense)'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC (META DATA_TYPE non-currency); H2 = account member name'
                          when c_type is null                    then 'account not in META_ACCOUNT: nothing to derive (owner Q-05)'
                          when c_type in ('asset', 'liability', 'equity', 'revenue')
                              then 'META_ACCOUNT.ACCOUNT_TYPE ' || c_type || ' (stated; owner Q-05)'
                          when c_type = 'expense' and acct_ok and digit = 6
                              then 'META ACCOUNT_TYPE expense; A6 block ' || substr(trim(account_number), 2, 3) || ' mapping (owner, build 08 Q-03/Q-05)'
                          when c_type = 'expense' and acct_ok and digit between 5 and 8
                              then 'META ACCOUNT_TYPE expense; section digit ' || digit || ' (char 2 of A-code; owner Q-05)'
                          when c_type = 'expense'                then 'META ACCOUNT_TYPE expense, no usable A-code digit: Unclassified (owner Q-05)'
                          else 'META ACCOUNT_TYPE ' || c_type || ': no standard section (owner Q-05)'
                      end as seed_source
                from prop6
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
when matched and tgt.review_status = 'UNREVIEWED' and (not equal_null(tgt.h1, src.h1) or not equal_null(tgt.h2, src.h2) or not equal_null(tgt.h3, src.h3) or not equal_null(tgt.h4, src.h4) or not equal_null(tgt.h5, src.h5) or not equal_null(tgt.p_l_section, src.p_l_section) or not equal_null(tgt.normal_balance, src.normal_balance) or not equal_null(tgt.value_sign, src.value_sign)) then update set
    tgt.h1 = src.h1, tgt.h2 = src.h2, tgt.h3 = src.h3, tgt.h4 = src.h4, tgt.h5 = src.h5, tgt.p_l_section = src.p_l_section, tgt.normal_balance = src.normal_balance, tgt.value_sign = src.value_sign, tgt.seed_source = src.seed_source;

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
                from DEV_G2M_AI.STAGING.STG_NEWBURY_TRIAL_BALANCE
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_BGT
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, stat_unit_family
                from DEV_G2M_AI.STAGING.STG_NEWBURY_OPERATING_STATS_PYACT
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
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , nullif(trim(ext.account_number), '')                                                              as c_acct
                    , regexp_like(nullif(trim(ext.account_number), ''), '[0-9]{4}-[0-9]{6}-[0-9]{4}-[0-9]{6}-[0-9]{4}') as acct_ok
                    , try_to_number(substr(nullif(trim(ext.account_number), ''), 6, 1))                                as digit
                    , substr(nullif(trim(ext.account_number), ''), 6, 6)                                                as seg2
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
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
                          when k_rtype = 'STATISTIC'             then coalesce(nullif(trim(unit_family), ''), 'UNCLASSIFIED')
                          when c_acct is null or not acct_ok     then 'UNCLASSIFIED'
                          when seg2 in ('870105', '870110', '870120', '870125', '870205', '870210', '870215', '880430')
                                                                 then 'Depreciation & Amortization'
                          when seg2 = '890010'                   then 'Income Taxes'
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
                          when k_rtype = 'STATISTIC' and nullif(trim(unit_family), '') is not null
                              then 'RECORD_TYPE STATISTIC (VALUE_TYPE STAT); H2 = SUBACCOUNT label as stated'
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC; no SUBACCOUNT label'
                          when c_acct is null                    then 'no ACCOUNT_NUMBER: nothing to derive (Q-19)'
                          when not acct_ok                       then 'ACCOUNT_NUMBER malformed: not repaired'
                          when seg2 in ('870105', '870110', '870120', '870125', '870205', '870210', '870215', '880430', '890010')
                              then 'section digit ' || digit || ' (H1); H2 by named account ' || seg2 || ' (owner, build 08 Q-07)'
                          when digit between 1 and 9             then 'section digit ' || digit || ' (char 6 of FULL_ACCOUNT_KEY)'
                          else 'section digit ' || coalesce(to_char(digit), 'none') || ': not in digit table'
                      end as seed_source
                from prop
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
when matched and tgt.review_status = 'UNREVIEWED' and (not equal_null(tgt.h1, src.h1) or not equal_null(tgt.h2, src.h2) or not equal_null(tgt.h3, src.h3) or not equal_null(tgt.h4, src.h4) or not equal_null(tgt.h5, src.h5) or not equal_null(tgt.p_l_section, src.p_l_section) or not equal_null(tgt.normal_balance, src.normal_balance) or not equal_null(tgt.value_sign, src.value_sign)) then update set
    tgt.h1 = src.h1, tgt.h2 = src.h2, tgt.h3 = src.h3, tgt.h4 = src.h4, tgt.h5 = src.h5, tgt.p_l_section = src.p_l_section, tgt.normal_balance = src.normal_balance, tgt.value_sign = src.value_sign, tgt.seed_source = src.seed_source;
