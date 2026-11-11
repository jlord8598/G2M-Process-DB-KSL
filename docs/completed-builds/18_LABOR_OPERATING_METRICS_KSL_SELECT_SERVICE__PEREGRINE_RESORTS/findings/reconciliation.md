# Reconciliation (build 18): does every labor record arrive?

Yes. Every DAILY_LABOR row of today's extract (KSL 793,934, PEREGRINE 366,164) is in SEM_AI_OPERATING_METRICS exactly once. Rows, wages and hours are equal in CLN, STG, XFRM and SEM, and 0 labor rows are anywhere else. Every other fact table of both lanes is equal STG -> XFRM -> SEM. Outputs: `reconcile_<LANE>_output.csv`, 0 failures each.
