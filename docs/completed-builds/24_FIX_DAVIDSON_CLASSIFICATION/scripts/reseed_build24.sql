-- scripts/reseed_build24.sql (build 24, owner Q-01, Q-02, Q-08; D-44 re-seed of DAVIDSON).
-- Sets the seeder's current proposal on the DAVIDSON keys whose proposal differs from the stored row, D-44 columns only.
-- Keys are never added, removed or moved. Expected: 975 rows (363 six-segment at 5990 / 6000 / 7000-7400 / 7600;
-- 612 one-segment, of which 40 change SEED_SOURCE only).
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
                     , source_table, natural_account, alias_natural_account
                from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_MONTHLY_REPORT
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , source_table, null::varchar as natural_account, null::varchar as alias_natural_account
                from DEV_G2M_AI.STAGING.STG_DAVIDSON_FULL_YEAR_PL
                union all
                select source_lane, source_site_code, department, account_key, record_type
                     , asset_name, department_name, account_number, stat_account, account_desc
                     , 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY'::varchar as source_table
                     , natural_account, alias_natural_account
                from DEV_G2M_AI.STAGING.STG_DAVIDSON_HOTEL_BUDGET
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
                    , min(natural_account)                                    as nat_stated
                    , min(alias_natural_account)                              as nat_alias
                from fact
                where 1=1
                group by 1, 2, 3, 4, 5
            )
            , prop as (
                select
                      ext.*
                    , coalesce(ext.nat_stated, iff(left(ext.nat_alias, 1) = '9', null, ext.nat_alias)) as nat
                    , try_to_number(coalesce(ext.nat_stated, iff(left(ext.nat_alias, 1) = '9', null, ext.nat_alias))) as n
                    , iff(ext.nat_stated is null and ext.nat_alias is not null and left(ext.nat_alias, 1) <> '9', 'ALIAS', 'STATED') as nat_source
                from ext
            )
            -- ----------------------------------------------------------------
            -- propose H1 / H2
            -- ----------------------------------------------------------------
            , cls as (
                select
                      prop.*
                    , case
                          when k_rtype = 'STATISTIC'                 then 'Statistic'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' then
                              case
                                  when n between 4000 and 4999       then 'Revenue'
                                  when n between 5000 and 5006       then 'Expense'
                                  when n in (5100, 5110)             then 'Expense'
                                  when n between 5200 and 5204       then 'Expense'
                                  when n = 5900                      then 'Expense'
                                  when n = 5990                      then 'Expense'
                                  when n = 6000                      then 'Below the Line'
                                  when n in (7000, 7100, 7200, 7300, 7400, 7600) then 'Below the Line'
                                  when n between 6000 and 7999       then 'Expense'
                                  when n between 8000 and 8999       then 'Below the Line'
                                  else 'Unclassified'
                              end
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY' then
                              case
                                  when k_dept in ('Operating Revenues', 'MISCELLANEOUS INCOME')                            then 'Revenue'
                                  when k_dept in ('Departmental Expenses', 'Undistributed Operating Expenses')              then 'Expense'
                                  when k_dept in ('Non-Operating Income and Expenses', 'NON-OPERATING INCOME & EXPENSE')   then 'Below the Line'
                                  else 'Unclassified'
                              end
                          else 'Unclassified'
                      end as h1
                    , case
                          when k_rtype = 'STATISTIC'                 then coalesce(nat, k_acct)
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' then
                              case
                                  when n between 4000 and 4999       then 'Revenue'
                                  when n between 5000 and 5006       then 'Payroll'
                                  when n in (5100, 5110)             then 'Cost of Goods Sold'
                                  when n between 5200 and 5204       then 'Operating Expenses'
                                  when n = 5900                      then 'Operating Expenses'
                                  when n = 5990                      then 'Operating Expenses'
                                  when n = 6000                      then 'Other Income / (Expense)'
                                  when n in (7000, 7100, 7200, 7300, 7400, 7600) then 'Other Income / (Expense)'
                                  when n between 6000 and 6999       then 'Payroll'
                                  when n between 7000 and 7999       then 'Operating Expenses'
                                  when n between 8000 and 8999       then 'Other Income / (Expense)'
                                  else 'UNCLASSIFIED'
                              end
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY' then
                              case
                                  when k_dept in ('Operating Revenues', 'MISCELLANEOUS INCOME')                            then 'Revenue'
                                  when k_dept in ('Departmental Expenses', 'Undistributed Operating Expenses')              then 'Operating Expenses'
                                  when k_dept in ('Non-Operating Income and Expenses', 'NON-OPERATING INCOME & EXPENSE')   then 'Other Income / (Expense)'
                                  else 'UNCLASSIFIED'
                              end
                          else 'UNCLASSIFIED'
                      end as h2
                    , case
                          when k_rtype = 'STATISTIC' and nat = '9990'
                              then 'RECORD_TYPE STATISTIC; natural 9990 (LAOFF/STOFF) stat-ledger offset, adds to no total; H2 = the natural account (owner Q-07)'
                          when k_rtype = 'STATISTIC' and nat is not null
                              then 'RECORD_TYPE STATISTIC; H2 = the natural account, the source code (owner Q-07)'
                          when k_rtype = 'STATISTIC'
                              then 'RECORD_TYPE STATISTIC; H2 = the source line identifier (LINE_CLASS or PL line text; Q-06)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' and n is null and left(nat_alias, 1) = '9'
                              then 'one-segment ACCOUNT; its REF_ACCOUNTS alias is a 9xxx statistic ledger on an AMOUNT key: not in landed data as money, nothing derived (build 24 Q-02)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' and n is null
                              then 'no natural account (one-segment or blank ACCOUNT, no usable REF_ACCOUNTS alias): not in landed data, nothing derived (build 24 Q-02)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' and n = 5990
                              then iff(nat_source = 'ALIAS', 'REF_ACCOUNTS alias ', '') || 'natural account 5990 Allocations: inside GOP as Operating Expenses (build 24 Q-08)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' and (n = 6000 or n in (7000, 7100, 7200, 7300, 7400, 7600))
                              then iff(nat_source = 'ALIAS', 'REF_ACCOUNTS alias ', '') || 'natural account ' || nat || ': non-operating / below-GOP ledger, Other Income / (Expense) (build 24 Q-08; no management-fee Level 1 between GOP and EBITDA in the hierarchy or a peer lane)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' and nat_source = 'ALIAS'
                              then 'REF_ACCOUNTS alias natural account ' || nat || ' of a one-segment ACCOUNT (build 24 Q-01; lane map)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' and (n between 4000 and 5006 or n in (5100, 5110) or n between 5200 and 5204 or n = 5900)
                              then 'natural account ' || nat || ' (owner Q-09 map, from data; source owner to confirm)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY' and n between 6000 and 8999
                              then 'section digit ' || left(nat, 1) || ' of natural account ' || nat || ' (owner Q-09: as proposed)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_MONTHLY'
                              then 'natural account ' || nat || ': not in the owner map, nothing derived'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY' and h1 <> 'Unclassified'
                              then 'PL SECTION ' || k_dept || ' as stated section (owner Q-09)'
                          when src_tbl = 'CLN.BOX_INVESTMENT_DATA.CLN_DAVIDSON_FIN_PL_SUMMARY'
                              then 'PL SECTION ' || k_dept || ': department section, mixes revenue and expense, not mapped (owner Q-09)'
                          else 'source table not in the lane: nothing to derive'
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
