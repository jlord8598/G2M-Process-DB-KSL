-- scripts/reseed_build23.sql (build 23, owner stop 4: Q-21 HICV provision keys, Q-24 BEAUMIER USALI keys).
-- Sets the seeder's current proposal on the keys whose proposal differs from the stored row, and only the
-- D-44 columns (H1-H5, section, balance, sign, METRIC_UNIT, AGGREGATION_TYPE, SEED_SOURCE). Keys are never added,
-- removed or moved; REVIEW_STATUS and the run ids are untouched. The proposal text is the seeder branch's own
-- USING clause, copied verbatim. Expected: HICV 297 rows, BEAUMIER 3 rows.
-- HICV
update DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
set tgt.h1 = p.h1
    , tgt.h2 = p.h2
    , tgt.h3 = p.h3
    , tgt.h4 = p.h4
    , tgt.h5 = p.h5
    , tgt.p_l_section = p.p_l_section
    , tgt.normal_balance = p.normal_balance
    , tgt.value_sign = p.value_sign
    , tgt.metric_unit = p.metric_unit
    , tgt.aggregation_type = p.aggregation_type
    , tgt.seed_source = p.seed_source
from (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , null::varchar as gl_sub_category, desc_pl_category as pl_category
                from DEV_G2M_AI.STAGING.STG_HICV_PL
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , pl_sub_category_1 as gl_sub_category, null::varchar as pl_category
                from DEV_G2M_AI.STAGING.STG_HICV_GL
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
                    , iff(count(distinct gl_sub_category) = 1, min(gl_sub_category), null) as key_gl
                    , iff(count(distinct pl_category) = 1, min(pl_category), null)         as key_pl
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            -- ----------------------------------------------------------------
            -- account-level stated categories (owner Q-15 fallbacks)
            -- ----------------------------------------------------------------
            , acct_gl as (
                select coalesce(nullif(trim(account_key), ''), '~BLANK~') as k_acct
                     , iff(count(distinct gl_sub_category) = 1, min(gl_sub_category), null) as acct_gl
                from fact
                where 1=1
                group by 1
            )
            , acct_pl as (
                select coalesce(nullif(trim(account_key), ''), '~BLANK~') as k_acct
                     , iff(count(distinct pl_category) = 1, min(pl_category), null) as acct_pl
                from fact
                where 1=1
                group by 1
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , prop as (
                select
                      ext.*
                    , try_to_number(substr(ext.k_acct, 1, 1)) as digit
                    , ag.acct_gl
                    , ap.acct_pl
                from ext
                left join acct_gl ag on ag.k_acct = ext.k_acct
                left join acct_pl ap on ap.k_acct = ext.k_acct
            )
            -- ----------------------------------------------------------------
            -- each stated category mapped to H2 (owner Q-04); a category that
            -- names revenue, HOA or Other states no cost section and maps to null
            -- ----------------------------------------------------------------
            , cat as (
                select
                      prop.*
                    , case key_gl
                          when 'Club Expense'                              then 'Operating Expenses'
                          when 'Cost Reimbursement'                        then 'Operating Expenses'
                          when 'General & Administrative'                  then 'Operating Expenses'
                          when 'License Fee Expense'                       then 'Operating Expenses'
                          when 'Property Mgmt. Expense'                    then 'Operating Expenses'
                          when 'Rental Expense'                            then 'Operating Expenses'
                          when 'Retail & Resort Ops. Expense'              then 'Operating Expenses'
                          when 'Non-Recurring Items'                       then 'Other Income / (Expense)'
                          when 'Financing Expense'                         then 'Other Income / (Expense)'
                          when 'Provision for Loan Loss'                   then 'Revenue'
                          when 'Sales and marketing'                       then 'Operating Expenses'
                          when 'Retail and resort expense'                 then 'Operating Expenses'
                          when 'Property management expense'               then 'Operating Expenses'
                          when 'General and administrative'                then 'Operating Expenses'
                          when 'Rental expense'                            then 'Operating Expenses'
                          when 'Cost reimbursement'                        then 'Operating Expenses'
                          when 'Club expense'                              then 'Operating Expenses'
                          when 'License fees'                              then 'Operating Expenses'
                          when 'Depreciation and amortization'             then 'Depreciation & Amortization'
                          when 'Income taxes'                              then 'Income Taxes'
                          when 'Provision'                                 then 'Revenue'
                          when 'Financing expense - provision'             then 'Revenue'
                          when 'Financing expense - mortgage servicing'    then 'Other Income / (Expense)'
                          when 'Interest expense'                          then 'Other Income / (Expense)'
                          when '(Losses) gains'                            then 'Other Income / (Expense)'
                          when 'Foreign currency translation adjustment'   then 'Other Income / (Expense)'
                      end as h2_key_gl
                    , case acct_gl
                          when 'Club Expense'                              then 'Operating Expenses'
                          when 'Cost Reimbursement'                        then 'Operating Expenses'
                          when 'General & Administrative'                  then 'Operating Expenses'
                          when 'License Fee Expense'                       then 'Operating Expenses'
                          when 'Property Mgmt. Expense'                    then 'Operating Expenses'
                          when 'Rental Expense'                            then 'Operating Expenses'
                          when 'Retail & Resort Ops. Expense'              then 'Operating Expenses'
                          when 'Non-Recurring Items'                       then 'Other Income / (Expense)'
                          when 'Financing Expense'                         then 'Other Income / (Expense)'
                          when 'Provision for Loan Loss'                   then 'Revenue'
                          when 'Sales and marketing'                       then 'Operating Expenses'
                          when 'Retail and resort expense'                 then 'Operating Expenses'
                          when 'Property management expense'               then 'Operating Expenses'
                          when 'General and administrative'                then 'Operating Expenses'
                          when 'Rental expense'                            then 'Operating Expenses'
                          when 'Cost reimbursement'                        then 'Operating Expenses'
                          when 'Club expense'                              then 'Operating Expenses'
                          when 'License fees'                              then 'Operating Expenses'
                          when 'Depreciation and amortization'             then 'Depreciation & Amortization'
                          when 'Income taxes'                              then 'Income Taxes'
                          when 'Provision'                                 then 'Revenue'
                          when 'Financing expense - provision'             then 'Revenue'
                          when 'Financing expense - mortgage servicing'    then 'Other Income / (Expense)'
                          when 'Interest expense'                          then 'Other Income / (Expense)'
                          when '(Losses) gains'                            then 'Other Income / (Expense)'
                          when 'Foreign currency translation adjustment'   then 'Other Income / (Expense)'
                      end as h2_acct_gl
                    , case key_pl
                          when 'Club Expense'                              then 'Operating Expenses'
                          when 'Cost Reimbursement'                        then 'Operating Expenses'
                          when 'General & Administrative'                  then 'Operating Expenses'
                          when 'License Fee Expense'                       then 'Operating Expenses'
                          when 'Property Mgmt. Expense'                    then 'Operating Expenses'
                          when 'Rental Expense'                            then 'Operating Expenses'
                          when 'Retail & Resort Ops. Expense'              then 'Operating Expenses'
                          when 'Non-Recurring Items'                       then 'Other Income / (Expense)'
                          when 'Financing Expense'                         then 'Other Income / (Expense)'
                          when 'Provision for Loan Loss'                   then 'Revenue'
                          when 'Sales and marketing'                       then 'Operating Expenses'
                          when 'Retail and resort expense'                 then 'Operating Expenses'
                          when 'Property management expense'               then 'Operating Expenses'
                          when 'General and administrative'                then 'Operating Expenses'
                          when 'Rental expense'                            then 'Operating Expenses'
                          when 'Cost reimbursement'                        then 'Operating Expenses'
                          when 'Club expense'                              then 'Operating Expenses'
                          when 'License fees'                              then 'Operating Expenses'
                          when 'Depreciation and amortization'             then 'Depreciation & Amortization'
                          when 'Income taxes'                              then 'Income Taxes'
                          when 'Provision'                                 then 'Revenue'
                          when 'Financing expense - provision'             then 'Revenue'
                          when 'Financing expense - mortgage servicing'    then 'Other Income / (Expense)'
                          when 'Interest expense'                          then 'Other Income / (Expense)'
                          when '(Losses) gains'                            then 'Other Income / (Expense)'
                          when 'Foreign currency translation adjustment'   then 'Other Income / (Expense)'
                      end as h2_key_pl
                    , case acct_pl
                          when 'Club Expense'                              then 'Operating Expenses'
                          when 'Cost Reimbursement'                        then 'Operating Expenses'
                          when 'General & Administrative'                  then 'Operating Expenses'
                          when 'License Fee Expense'                       then 'Operating Expenses'
                          when 'Property Mgmt. Expense'                    then 'Operating Expenses'
                          when 'Rental Expense'                            then 'Operating Expenses'
                          when 'Retail & Resort Ops. Expense'              then 'Operating Expenses'
                          when 'Non-Recurring Items'                       then 'Other Income / (Expense)'
                          when 'Financing Expense'                         then 'Other Income / (Expense)'
                          when 'Provision for Loan Loss'                   then 'Revenue'
                          when 'Sales and marketing'                       then 'Operating Expenses'
                          when 'Retail and resort expense'                 then 'Operating Expenses'
                          when 'Property management expense'               then 'Operating Expenses'
                          when 'General and administrative'                then 'Operating Expenses'
                          when 'Rental expense'                            then 'Operating Expenses'
                          when 'Cost reimbursement'                        then 'Operating Expenses'
                          when 'Club expense'                              then 'Operating Expenses'
                          when 'License fees'                              then 'Operating Expenses'
                          when 'Depreciation and amortization'             then 'Depreciation & Amortization'
                          when 'Income taxes'                              then 'Income Taxes'
                          when 'Provision'                                 then 'Revenue'
                          when 'Financing expense - provision'             then 'Revenue'
                          when 'Financing expense - mortgage servicing'    then 'Other Income / (Expense)'
                          when 'Interest expense'                          then 'Other Income / (Expense)'
                          when '(Losses) gains'                            then 'Other Income / (Expense)'
                          when 'Foreign currency translation adjustment'   then 'Other Income / (Expense)'
                      end as h2_acct_pl
                from prop
            )
            , pick as (
                select
                      cat.*
                    , coalesce(h2_key_gl, h2_acct_gl, h2_key_pl, h2_acct_pl) as c_h2
                    , case
                          when h2_key_gl  is not null then 'GL PL_SUB_CATEGORY_1 of the key ' || key_gl
                          when h2_acct_gl is not null then 'GL PL_SUB_CATEGORY_1 of the account ' || acct_gl
                          when h2_key_pl  is not null then 'P&L DESC_PL_CATEGORY of the key ' || key_pl
                          when h2_acct_pl is not null then 'P&L DESC_PL_CATEGORY of the account ' || acct_pl
                      end as c_source
                from cat
            )
            , cls as (
                select
                      pick.*
                    , case
                          when k_rtype = 'STATISTIC'   then 'Statistic'
                          when digit = 3               then 'Revenue'
                          when digit in (7, 8) and c_h2 = 'Revenue' then 'Revenue'
                          when digit in (4, 5, 7)      then 'Expense'
                          when digit = 8               then 'Below the Line'
                          when digit = 9               then 'Allocations & Reserves'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'   then k_acct
                          when digit = 3               then 'Revenue'
                          when digit = 4               then 'Cost of Goods Sold'
                          when digit = 5               then 'Payroll'
                          when digit in (7, 8) and c_h2 is not null then c_h2
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'   then 'RECORD_TYPE STATISTIC'
                          when digit = 3               then 'digit 3 (owner Q-04)'
                          when digit = 4               then 'digit 4 (owner Q-04)'
                          when digit = 5               then 'digit 5 (owner Q-04)'
                          when digit = 9               then 'digit 9: Allocations & Reserves, H2 unclassified (section 5)'
                          when digit in (7, 8) and c_h2 = 'Revenue'
                              then 'digit ' || digit || '; ' || c_source || ': loan-loss provision is contra-revenue, H1 Revenue (owner Q-04, Q-21)'
                          when digit in (7, 8) and c_h2 is not null
                              then 'digit ' || digit || '; ' || c_source || ' (owner Q-04, Q-15)'
                          when digit in (7, 8)
                              then 'digit ' || digit || '; no single stated cost category: H2 unclassified (owner Q-15)'
                          else 'no section digit: nothing to derive'
                      end as seed_source
                from pick
            )
            select
                  k_lane, k_site, k_dept, k_acct, k_rtype
                , asset_name, department_name, account_number, stat_account, account_desc
                , h1, h2
                , 'UNCLASSIFIED' as h3
                , 'UNCLASSIFIED' as h4
                , 'UNCLASSIFIED' as h5
                , case h2
                      when 'Revenue'                     then 'Gross Profit'
                      when 'Cost of Goods Sold'          then 'Gross Profit'
                      when 'Payroll'                     then 'Operating'
                      when 'Operating Expenses'          then 'Operating'
                      when 'Depreciation & Amortization' then 'Operating'
                      when 'Other Income / (Expense)'    then 'Non-Operating'
                      when 'Income Taxes'                then 'Non-Operating'
                  end as p_l_section
                , case h2
                      when 'Revenue'                     then 'Credit'
                      when 'Cost of Goods Sold'          then 'Debit'
                      when 'Payroll'                     then 'Debit'
                      when 'Operating Expenses'          then 'Debit'
                      when 'Depreciation & Amortization' then 'Debit'
                      when 'Other Income / (Expense)'    then 'Mixed'
                      when 'Income Taxes'                then 'Debit'
                  end as normal_balance
                , case h2
                      when 'Revenue'                     then 1
                      when 'Cost of Goods Sold'          then -1
                      when 'Payroll'                     then -1
                      when 'Operating Expenses'          then -1
                      when 'Depreciation & Amortization' then -1
                      when 'Income Taxes'                then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then 'UNRATIFIED' end as aggregation_type
                , seed_source
            from cls
) p
where 1=1
  and tgt.source_lane      = p.k_lane
  and tgt.source_site_code = p.k_site
  and tgt.department       = p.k_dept
  and tgt.account_key      = p.k_acct
  and tgt.record_type      = p.k_rtype
  and (coalesce(tgt.h1::varchar,'~') <> coalesce(p.h1::varchar,'~')
       or coalesce(tgt.h2::varchar,'~') <> coalesce(p.h2::varchar,'~')
       or coalesce(tgt.h3::varchar,'~') <> coalesce(p.h3::varchar,'~')
       or coalesce(tgt.h4::varchar,'~') <> coalesce(p.h4::varchar,'~')
       or coalesce(tgt.h5::varchar,'~') <> coalesce(p.h5::varchar,'~')
       or coalesce(tgt.p_l_section::varchar,'~') <> coalesce(p.p_l_section::varchar,'~')
       or coalesce(tgt.normal_balance::varchar,'~') <> coalesce(p.normal_balance::varchar,'~')
       or coalesce(tgt.value_sign::varchar,'~') <> coalesce(p.value_sign::varchar,'~')
       or coalesce(tgt.metric_unit::varchar,'~') <> coalesce(p.metric_unit::varchar,'~')
       or coalesce(tgt.aggregation_type::varchar,'~') <> coalesce(p.aggregation_type::varchar,'~')
       or coalesce(tgt.seed_source::varchar,'~') <> coalesce(p.seed_source::varchar,'~'));

-- BEAUMIER
update DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
set tgt.h1 = p.h1
    , tgt.h2 = p.h2
    , tgt.h3 = p.h3
    , tgt.h4 = p.h4
    , tgt.h5 = p.h5
    , tgt.p_l_section = p.p_l_section
    , tgt.normal_balance = p.normal_balance
    , tgt.value_sign = p.value_sign
    , tgt.metric_unit = p.metric_unit
    , tgt.aggregation_type = p.aggregation_type
    , tgt.seed_source = p.seed_source
from (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, pl_section, pl_line, ebitda_group, null::varchar as h_section, null::integer as h_btl
                from DEV_G2M_AI.STAGING.STG_BEAUMIER_BP
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, pl_section, pl_line, ebitda_group, null::varchar as h_section, null::integer as h_btl
                from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET
                union all
                -- build 23: the 2027 USALI budget states no PL_SECTION; its section is
                -- read from the lane's hierarchy dictionary on LINE_ITEM (owner Q-24)
                select u.source_lane, u.source_site_code, u.department, u.account_key, u.record_type
                     , u.asset_name, u.department_name, u.account_number, u.stat_account, u.account_desc
                     , u.source_table, null::varchar as pl_section, null::varchar as pl_line, null::varchar as ebitda_group
                     , case h.pl_group
                           when 'Revenue'  then 'Total Operating Revenue'
                           when 'COGS'     then 'COGS'
                           when 'Payroll'  then '* Payroll Expenses'
                           when 'Expenses' then 'Other Expenses'
                       end::varchar as h_section
                     , iff(h.level_2 = 'Non-Operating Income and Expenses', 1, 0)::integer as h_btl
                from DEV_G2M_AI.STAGING.STG_BEAUMIER_BUDGET_USALI u
                left join DEV_G2M_AI.STAGING.STG_BEAUMIER_HIERARCHY h
                    on  h.line_item = u.line_item
                union all
                -- build 23: the 2027 operating statistics (owner Q-14)
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, null::varchar as pl_section, null::varchar as pl_line, null::varchar as ebitda_group, null::varchar as h_section, null::integer as h_btl
                from DEV_G2M_AI.STAGING.STG_BEAUMIER_OPS_STATS
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
                    , iff(count(pl_section) > 0, min(pl_section), min(h_section))                   as m_section
                    , iff(count(pl_section) > 0, count(distinct pl_section), count(distinct h_section)) as n_section
                    , iff(count(pl_section) > 0
                        , max(iff(pl_line = 'Non-Operating Income & Expenses' or ebitda_group = 'NOI', 1, 0))
                        , max(coalesce(h_btl, 0)))                                as m_btl
                    , iff(count(pl_section) > 0, 'PL_SECTION', 'HIERARCHY')   as m_section_source
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
                    , iff(ext.n_section = 1, ext.m_section, null)               as c_section
                from ext
            )
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'            then 'Statistic'
                          when c_section = 'Total Operating Revenue' then 'Revenue'
                          when c_section = 'COGS'               then 'Expense'
                          when c_section = '* Payroll Expenses' then 'Expense'
                          when c_section = 'Other Expenses' and m_btl = 1 then 'Below the Line'
                          when c_section = 'Other Expenses'     then 'Expense'
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'             then k_acct
                          when c_section = 'Total Operating Revenue' then 'Revenue'
                          when c_section = 'COGS'                then 'Cost of Goods Sold'
                          when c_section = '* Payroll Expenses'  then 'Payroll'
                          when c_section = 'Other Expenses' and m_btl = 1 then 'Other Income / (Expense)'
                          when c_section = 'Other Expenses'      then 'Operating Expenses'
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC'             then 'RECORD_TYPE STATISTIC'
                          when c_section is null                 then 'PL_SECTION absent or not single-valued: nothing to derive'
                          when c_section = 'Other Expenses' and m_btl = 1
                              then 'PL_SECTION Other Expenses with Non-Operating PL_LINE or NOI group: Below the Line (owner Q-06)'
                          when m_section_source = 'HIERARCHY'
                              then 'STG_BEAUMIER_HIERARCHY.PL_GROUP on LINE_ITEM -> ' || c_section || ' (owner Q-24)'
                          else 'PL_SECTION ' || c_section || ' (stated; owner Q-06)'
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
                  end as p_l_section
                , case h2
                      when 'Revenue'                  then 'Credit'
                      when 'Cost of Goods Sold'       then 'Debit'
                      when 'Payroll'                  then 'Debit'
                      when 'Operating Expenses'       then 'Debit'
                      when 'Other Income / (Expense)' then 'Mixed'
                  end as normal_balance
                , case h2
                      when 'Revenue'                  then 1
                      when 'Cost of Goods Sold'       then -1
                      when 'Payroll'                  then -1
                      when 'Operating Expenses'       then -1
                  end::number(2,0) as value_sign
                , null::varchar as metric_unit
                , case when h1 = 'Statistic' then case when k_acct = 'BUDGET_KEYS' then 'STOCK' when k_acct in ('BUDGET_ROOMS_SOLD', 'BUDGET_ROOMS_AVAILABLE', 'BUDGET_OPENING_DAYS') then 'FLOW' else 'UNRATIFIED' end end as aggregation_type
                , seed_source
            from cls
) p
where 1=1
  and tgt.source_lane      = p.k_lane
  and tgt.source_site_code = p.k_site
  and tgt.department       = p.k_dept
  and tgt.account_key      = p.k_acct
  and tgt.record_type      = p.k_rtype
  and (coalesce(tgt.h1::varchar,'~') <> coalesce(p.h1::varchar,'~')
       or coalesce(tgt.h2::varchar,'~') <> coalesce(p.h2::varchar,'~')
       or coalesce(tgt.h3::varchar,'~') <> coalesce(p.h3::varchar,'~')
       or coalesce(tgt.h4::varchar,'~') <> coalesce(p.h4::varchar,'~')
       or coalesce(tgt.h5::varchar,'~') <> coalesce(p.h5::varchar,'~')
       or coalesce(tgt.p_l_section::varchar,'~') <> coalesce(p.p_l_section::varchar,'~')
       or coalesce(tgt.normal_balance::varchar,'~') <> coalesce(p.normal_balance::varchar,'~')
       or coalesce(tgt.value_sign::varchar,'~') <> coalesce(p.value_sign::varchar,'~')
       or coalesce(tgt.metric_unit::varchar,'~') <> coalesce(p.metric_unit::varchar,'~')
       or coalesce(tgt.aggregation_type::varchar,'~') <> coalesce(p.aggregation_type::varchar,'~')
       or coalesce(tgt.seed_source::varchar,'~') <> coalesce(p.seed_source::varchar,'~'));
