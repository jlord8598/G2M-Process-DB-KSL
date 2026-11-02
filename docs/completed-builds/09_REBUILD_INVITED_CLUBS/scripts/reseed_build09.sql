-- Build 09 one-time D-44 re-seed of INVITED_CLUBS (owner, stops 1-3, Q-16, Q-17).
-- Columns D-44 allows: H1-H5, section, balance, sign, METRIC_UNIT, AGGREGATION_TYPE,
-- seed source. Keyed on the five-part key; no insert, no delete; UNREVIEWED only.
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
            -- META TIME_BALANCE, primary instance (not shared), one row per member
            -- ----------------------------------------------------------------
            , mtb as (
                select account, min(time_balance) as m_time_balance
                from DEV_G2M_AI.STAGING.STG_INVITED_CLUBS_META_ACCOUNT
                where 1=1
                  and lower(trim(data_storage)) <> 'shared'
                group by account
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
                    , lower(trim(mtb.m_time_balance))                                        as c_tb
                    , case
                          when ext.k_rtype = 'STATISTIC'                                     then null
                          when startswith(ext.k_acct, 'Ind')                                 then 'IND'
                          when ext.k_acct = 'Adjusted Cash EBITDA'                           then 'ACE'
                          when startswith(ext.k_site, 'Plan ')                               then 'PLAN'
                          when lower(trim(ext.m_type)) = 'expense'
                           and regexp_like(ext.k_acct, '(MPLost|RMBase|XferOutBase|DMBase|PALost|XLSLost|LULost|PRMB|PDMB|AALost).*')
                                                                                             then 'DUES'
                          when lower(trim(ext.m_type)) = 'revenue'
                           and not regexp_like(nullif(trim(ext.account_number), ''), 'A[0-9]{5}') then 'KPI'
                          when lower(trim(ext.m_type)) = 'revenue'
                           and try_to_number(substr(trim(ext.account_number), 2, 1)) <> 4    then 'A5REV'
                      end                                                                    as r_class
                from ext
                left join mtb on mtb.account = ext.k_acct
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
                          when r_class in ('IND', 'ACE', 'PLAN') then 'Unclassified'
                          when r_class in ('DUES', 'KPI')       then 'Statistic'
                          when r_class = 'A5REV'                then 'Below the Line'
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
                          when r_class in ('IND', 'ACE', 'PLAN')  then 'UNCLASSIFIED'
                          when r_class in ('DUES', 'KPI')        then k_acct
                          when r_class = 'A5REV'                 then 'Other Income / (Expense)'
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
                          when r_class = 'IND'                   then 'member name starts Ind (Indicated/planning or Ind-Total rollup): Unclassified (build 09 Q-02, Q-07)'
                          when r_class = 'ACE'                   then 'Adjusted Cash EBITDA, dynamic calc rollup: Unclassified (build 09 Q-04)'
                          when r_class = 'PLAN'                  then 'Plan entity ' || k_site || ': planning input, Unclassified (build 09 Q-05, Q-10)'
                          when r_class = 'DUES'                  then 'dues roll-forward, META expense currency: H1 Statistic, RECORD_TYPE AMOUNT kept (build 09 Q-06)'
                          when r_class = 'KPI' and regexp_like(k_acct, '(BegBase|EndBase)_.*')
                              then 'META revenue, not A4 GL: H1 Statistic (B09-D4); AGGREGATION_TYPE STOCK, owner override of META TIME_BALANCE (Q-13)'
                          when r_class = 'KPI'                   then 'META revenue, not A4 GL: H1 Statistic, RECORD_TYPE AMOUNT kept (B09-D4)'
                          when r_class = 'A5REV'                 then 'META revenue A-code outside A4: Other Income / (Expense) (build 09 Q-16)'
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
                , case when r_class in ('DUES', 'KPI') then 'currency' end::varchar as metric_unit
                , case
                      when r_class in ('DUES', 'KPI') and regexp_like(k_acct, '(BegBase|EndBase)_.*') then 'STOCK'
                      when r_class in ('DUES', 'KPI') and c_tb = 'flow'          then 'FLOW'
                      when h1 = 'Statistic'                                      then 'UNRATIFIED'
                  end as aggregation_type
                , seed_source
            from cls
        ) src
    on tgt.source_lane = src.k_lane and tgt.source_site_code = src.k_site and tgt.department = src.k_dept and tgt.account_key = src.k_acct and tgt.record_type = src.k_rtype
when matched and tgt.review_status = 'UNREVIEWED' and (not equal_null(tgt.h1, src.h1) or not equal_null(tgt.h2, src.h2) or not equal_null(tgt.h3, src.h3) or not equal_null(tgt.h4, src.h4) or not equal_null(tgt.h5, src.h5) or not equal_null(tgt.p_l_section, src.p_l_section) or not equal_null(tgt.normal_balance, src.normal_balance) or not equal_null(tgt.value_sign, src.value_sign) or not equal_null(tgt.metric_unit, src.metric_unit) or not equal_null(tgt.aggregation_type, src.aggregation_type)) then update set
    tgt.h1 = src.h1, tgt.h2 = src.h2, tgt.h3 = src.h3, tgt.h4 = src.h4, tgt.h5 = src.h5, tgt.p_l_section = src.p_l_section, tgt.normal_balance = src.normal_balance, tgt.value_sign = src.value_sign, tgt.metric_unit = src.metric_unit, tgt.aggregation_type = src.aggregation_type, tgt.seed_source = src.seed_source;
