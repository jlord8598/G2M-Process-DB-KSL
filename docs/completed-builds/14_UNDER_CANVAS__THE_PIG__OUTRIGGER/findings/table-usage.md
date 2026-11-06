# Table usage (build 14)

All 12 `CLN.BOX_INVESTMENT_DATA` tables of the three lanes are read, each by one staging procedure. UNDER_CANVAS facts (TOTAL_REVENUE, CAMP_OPERATING_EXPENSES, CAMP_NON_OPERATING_EXPENSES, STATISTICAL_ACCOUNTS, CONSOLIDATED_PL) feed the seeder and the four H1 streams; ACCOUNTS is staged as a dictionary only; WEEKLY_PACE, DUETTO_DATA, CANCELLATIONS, PIG_HOTELS_PACE_THIS_YEAR / NEXT_YEAR and OUTRIGGER_PACE feed PACING only. No table retired. Procedures 129 -> 153 (+24: 12 STG models, 3 STG / 3 XREF / 3 XFRM MAINs, 3 XFRM models).
