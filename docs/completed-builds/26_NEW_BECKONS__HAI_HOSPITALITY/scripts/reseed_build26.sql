-- scripts/reseed_build26.sql (build 26, owner stop 4 item 3): sets the seeder's current BECKONS proposal on the keys whose proposal differs, classification columns only. Expected: the 32 Chilean 62xx depreciation / amortisation / interest keys, Unclassified -> Below the Line / Other Income / (Expense). The lane is not yet in the master. Keys are never added, removed or moved.
update DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
set tgt.h1 = p.h1, tgt.h2 = p.h2, tgt.h3 = p.h3, tgt.h4 = p.h4, tgt.h5 = p.h5, tgt.p_l_section = p.p_l_section, tgt.normal_balance = p.normal_balance, tgt.value_sign = p.value_sign, tgt.metric_unit = p.metric_unit, tgt.aggregation_type = p.aggregation_type, tgt.seed_source = p.seed_source
from (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , ilevelmapping1 as m1, null::varchar as m2
                from DEV_G2M_AI.STAGING.STG_BECKONS_ACTUALS
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , ilevelmapping1 as m1, null::varchar as m2
                from DEV_G2M_AI.STAGING.STG_BECKONS_BUDGET
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
                    , min(m1)                                                 as m1
                    , min(m2)                                                 as m2
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            , blk as (
                select
                      ext.*
                    , iff(m1 is null or m1 = 'Tierra Hotels Corporate EBITDA', null, m1) as m_stated
                    , length(k_acct) as a_len
                    , left(k_acct, 2) as a_blk
                    , upper(coalesce(account_desc, '')) as a_name
                from ext
            )
            , cls as (
                select
                      blk.*
                    , case
                          when k_rtype = 'STATISTIC'                                       then 'Statistic|' || k_acct
                          when m_stated like 'Revenue - %'                                 then 'Revenue|Revenue'
                          when m_stated like 'Expenses - Cost of Sales%'                   then 'Expense|Cost of Goods Sold'
                          when m_stated like 'Expenses - Payroll%'                         then 'Expense|Payroll'
                          when m_stated like 'Expenses - Departmental Direct%'
                            or m_stated like 'Undist. Op-Ex%'                              then 'Expense|Operating Expenses'
                          when m_stated like 'Expenses - Management Fees%'
                            or m_stated like 'Expenses - Non-Operating%'
                            or m_stated like 'Interest Income%'                            then 'Below the Line|Other Income / (Expense)'
                          when m_stated is not null                                        then 'Unclassified|UNCLASSIFIED'
                          when a_len = 5 and a_blk between '41' and '49'                   then 'Revenue|Revenue'
                          when a_len = 5 and a_blk between '54' and '59'                   then 'Expense|Cost of Goods Sold'
                          when a_len = 5 and a_blk = '61'                                  then 'Expense|Payroll'
                          when a_len = 5 and a_blk in ('70', '74')                         then 'Expense|Operating Expenses'
                          when a_len = 5 and k_acct in ('76005', '76009')                  then 'Below the Line|Other Income / (Expense)'
                          when a_len = 5 and a_blk = '76'                                  then 'Expense|Depreciation & Amortization'
                          when a_len = 5 and a_blk in ('75', '85', '91', '94')             then 'Below the Line|Other Income / (Expense)'
                          when a_len = 5 and a_blk = '95'                                  then 'Below the Line|Income Taxes'
                          when a_len = 7 and a_blk = '41'                                  then 'Revenue|Revenue'
                          when a_len = 7 and a_blk = '51'                                  then 'Expense|Cost of Goods Sold'
                          when a_len = 7 and a_blk = '61'                                  then 'Expense|Payroll'
                          when a_len = 7 and a_blk = '62' and (a_name like '%DEPRECIAC%' or a_name like '%AMORTIZAC%' or a_name like '%INTERES%') then 'Below the Line|Other Income / (Expense)'
                          when a_len = 7 and a_blk = '62'                                  then 'Expense|Operating Expenses'
                          when a_len = 7 and a_blk = '81' and a_name like 'IMPUESTO%'      then 'Below the Line|Income Taxes'
                          when a_len = 7 and a_blk in ('71', '77', '81')                   then 'Below the Line|Other Income / (Expense)'
                          else 'Unclassified|UNCLASSIFIED'
                      end as h12
                    , case
                          when k_rtype = 'STATISTIC'  then 'non-numeric ACCOUNT_NO (rooms / bed-night count): Statistic, H2 = the code (D-38)'
                          when m_stated is not null   then 'iLevel mapping ' || m_stated || ' (ILEVELMAPPING1; owner Q-09)'
                          when k_acct = '99999'       then 'suspense account: not classified (owner Q-08)'
                          when a_len = 7 and a_blk = '62' and (a_name like '%DEPRECIAC%' or a_name like '%AMORTIZAC%' or a_name like '%INTERES%') then 'Chilean block 62 (gastos), title states depreciation / amortisation / interest: Below the Line / Other Income / (Expense), as peers (owner stop 4)'
                          when a_len in (5, 7)        then iff(m1 is null, 'no iLevel mapping', 'iLevel bucket Tierra Hotels Corporate EBITDA') || '; account block ' || a_blk || ' of the ' || a_len || '-digit chart, proven from account names (owner Q-08, Q-09)'
                          else 'no mapping, no block: not classified'
                      end as seed_source
                from blk
            )
            , cls2 as (
                select cls.*, split_part(h12, '|', 1) as h1, split_part(h12, '|', 2) as h2 from cls
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
                , iff(h1 = 'Statistic', 'UNRATIFIED', null)::varchar as aggregation_type
                , seed_source
            from cls2
) p
where 1=1
  and tgt.source_lane      = p.k_lane
  and tgt.source_site_code = p.k_site
  and tgt.department       = p.k_dept
  and tgt.account_key      = p.k_acct
  and tgt.record_type      = p.k_rtype
  and (coalesce(tgt.h1::varchar,'~') <> coalesce(p.h1::varchar,'~') or coalesce(tgt.h2::varchar,'~') <> coalesce(p.h2::varchar,'~') or coalesce(tgt.h3::varchar,'~') <> coalesce(p.h3::varchar,'~') or coalesce(tgt.h4::varchar,'~') <> coalesce(p.h4::varchar,'~') or coalesce(tgt.h5::varchar,'~') <> coalesce(p.h5::varchar,'~') or coalesce(tgt.p_l_section::varchar,'~') <> coalesce(p.p_l_section::varchar,'~') or coalesce(tgt.normal_balance::varchar,'~') <> coalesce(p.normal_balance::varchar,'~') or coalesce(tgt.value_sign::varchar,'~') <> coalesce(p.value_sign::varchar,'~') or coalesce(tgt.metric_unit::varchar,'~') <> coalesce(p.metric_unit::varchar,'~') or coalesce(tgt.aggregation_type::varchar,'~') <> coalesce(p.aggregation_type::varchar,'~') or coalesce(tgt.seed_source::varchar,'~') <> coalesce(p.seed_source::varchar,'~'));

-- Second re-seed (owner, pre-promotion): 5-digit depreciation / amortisation titles -> Below the Line / Other Income / (Expense). Expected: 25 keys (block 76 Expense / D&A; LON 76004 already Below the Line). Same statement text as above; it sets whatever the current proposal gives.
update DEV_G2M_AI.XREF_SNAPSHOT.XREF_ACCOUNT_CLASSIFICATION tgt
set tgt.h1 = p.h1, tgt.h2 = p.h2, tgt.h3 = p.h3, tgt.h4 = p.h4, tgt.h5 = p.h5, tgt.p_l_section = p.p_l_section, tgt.normal_balance = p.normal_balance, tgt.value_sign = p.value_sign, tgt.metric_unit = p.metric_unit, tgt.aggregation_type = p.aggregation_type, tgt.seed_source = p.seed_source
from (
            with
            -- ----------------------------------------------------------------
            -- fact staging rows
            -- ----------------------------------------------------------------
            fact as (
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , ilevelmapping1 as m1, null::varchar as m2
                from DEV_G2M_AI.STAGING.STG_BECKONS_ACTUALS
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , ilevelmapping1 as m1, null::varchar as m2
                from DEV_G2M_AI.STAGING.STG_BECKONS_BUDGET
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
                    , min(m1)                                                 as m1
                    , min(m2)                                                 as m2
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            , blk as (
                select
                      ext.*
                    , iff(m1 is null or m1 = 'Tierra Hotels Corporate EBITDA', null, m1) as m_stated
                    , length(k_acct) as a_len
                    , left(k_acct, 2) as a_blk
                    , upper(coalesce(account_desc, '')) as a_name
                from ext
            )
            , cls as (
                select
                      blk.*
                    , case
                          when k_rtype = 'STATISTIC'                                       then 'Statistic|' || k_acct
                          when a_len = 5 and (a_name like '%DEPRECIAT%' or a_name like '%AMORTIS%' or a_name like '%AMORTIZ%') then 'Below the Line|Other Income / (Expense)'
                          when m_stated like 'Revenue - %'                                 then 'Revenue|Revenue'
                          when m_stated like 'Expenses - Cost of Sales%'                   then 'Expense|Cost of Goods Sold'
                          when m_stated like 'Expenses - Payroll%'                         then 'Expense|Payroll'
                          when m_stated like 'Expenses - Departmental Direct%'
                            or m_stated like 'Undist. Op-Ex%'                              then 'Expense|Operating Expenses'
                          when m_stated like 'Expenses - Management Fees%'
                            or m_stated like 'Expenses - Non-Operating%'
                            or m_stated like 'Interest Income%'                            then 'Below the Line|Other Income / (Expense)'
                          when m_stated is not null                                        then 'Unclassified|UNCLASSIFIED'
                          when a_len = 5 and a_blk between '41' and '49'                   then 'Revenue|Revenue'
                          when a_len = 5 and a_blk between '54' and '59'                   then 'Expense|Cost of Goods Sold'
                          when a_len = 5 and a_blk = '61'                                  then 'Expense|Payroll'
                          when a_len = 5 and a_blk in ('70', '74')                         then 'Expense|Operating Expenses'
                          when a_len = 5 and k_acct in ('76005', '76009')                  then 'Below the Line|Other Income / (Expense)'
                          when a_len = 5 and a_blk = '76'                                  then 'Expense|Depreciation & Amortization'
                          when a_len = 5 and a_blk in ('75', '85', '91', '94')             then 'Below the Line|Other Income / (Expense)'
                          when a_len = 5 and a_blk = '95'                                  then 'Below the Line|Income Taxes'
                          when a_len = 7 and a_blk = '41'                                  then 'Revenue|Revenue'
                          when a_len = 7 and a_blk = '51'                                  then 'Expense|Cost of Goods Sold'
                          when a_len = 7 and a_blk = '61'                                  then 'Expense|Payroll'
                          when a_len = 7 and a_blk = '62' and (a_name like '%DEPRECIAC%' or a_name like '%AMORTIZAC%' or a_name like '%INTERES%') then 'Below the Line|Other Income / (Expense)'
                          when a_len = 7 and a_blk = '62'                                  then 'Expense|Operating Expenses'
                          when a_len = 7 and a_blk = '81' and a_name like 'IMPUESTO%'      then 'Below the Line|Income Taxes'
                          when a_len = 7 and a_blk in ('71', '77', '81')                   then 'Below the Line|Other Income / (Expense)'
                          else 'Unclassified|UNCLASSIFIED'
                      end as h12
                    , case
                          when k_rtype = 'STATISTIC'  then 'non-numeric ACCOUNT_NO (rooms / bed-night count): Statistic, H2 = the code (D-38)'
                          when a_len = 5 and (a_name like '%DEPRECIAT%' or a_name like '%AMORTIS%' or a_name like '%AMORTIZ%') then 'title states depreciation / amortisation: Below the Line / Other Income / (Expense), overriding the iLevel mapping and block 76 (build rule, owner pre-promotion; as the Chilean chart and peers)'
                          when m_stated is not null   then 'iLevel mapping ' || m_stated || ' (ILEVELMAPPING1; owner Q-09)'
                          when k_acct = '99999'       then 'suspense account: not classified (owner Q-08)'
                          when a_len = 7 and a_blk = '62' and (a_name like '%DEPRECIAC%' or a_name like '%AMORTIZAC%' or a_name like '%INTERES%') then 'Chilean block 62 (gastos), title states depreciation / amortisation / interest: Below the Line / Other Income / (Expense), as peers (owner stop 4)'
                          when a_len in (5, 7)        then iff(m1 is null, 'no iLevel mapping', 'iLevel bucket Tierra Hotels Corporate EBITDA') || '; account block ' || a_blk || ' of the ' || a_len || '-digit chart, proven from account names (owner Q-08, Q-09)'
                          else 'no mapping, no block: not classified'
                      end as seed_source
                from blk
            )
            , cls2 as (
                select cls.*, split_part(h12, '|', 1) as h1, split_part(h12, '|', 2) as h2 from cls
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
                , iff(h1 = 'Statistic', 'UNRATIFIED', null)::varchar as aggregation_type
                , seed_source
            from cls2
) p
where 1=1
  and tgt.source_lane      = p.k_lane
  and tgt.source_site_code = p.k_site
  and tgt.department       = p.k_dept
  and tgt.account_key      = p.k_acct
  and tgt.record_type      = p.k_rtype
  and (coalesce(tgt.h1::varchar,'~') <> coalesce(p.h1::varchar,'~') or coalesce(tgt.h2::varchar,'~') <> coalesce(p.h2::varchar,'~') or coalesce(tgt.h3::varchar,'~') <> coalesce(p.h3::varchar,'~') or coalesce(tgt.h4::varchar,'~') <> coalesce(p.h4::varchar,'~') or coalesce(tgt.h5::varchar,'~') <> coalesce(p.h5::varchar,'~') or coalesce(tgt.p_l_section::varchar,'~') <> coalesce(p.p_l_section::varchar,'~') or coalesce(tgt.normal_balance::varchar,'~') <> coalesce(p.normal_balance::varchar,'~') or coalesce(tgt.value_sign::varchar,'~') <> coalesce(p.value_sign::varchar,'~') or coalesce(tgt.metric_unit::varchar,'~') <> coalesce(p.metric_unit::varchar,'~') or coalesce(tgt.aggregation_type::varchar,'~') <> coalesce(p.aggregation_type::varchar,'~') or coalesce(tgt.seed_source::varchar,'~') <> coalesce(p.seed_source::varchar,'~'));
