# Build 26 open questions

| Q | Lane | Question | Proposal |
|---|---|---|---|
| Q-01 | both | Is any refresh scheduled on CLN.DATA_SHARE (Gary)? The tables are landed copies, unaltered since 11-04. | Freeze by agreement; prove with last_altered + HASH_AGG before every milestone; Time Travel reproduces the baseline if a reload happens. |
| Q-02 | BECKONS | Which amount is SOURCE_AMOUNT: *_BASE (local; four currencies, CURRENCY_CODE per lodge) or *_AUD (converted; one currency)? Only one measure is allowed. | *_BASE with CURRENCY_CODE from BASE_CURRENCY. The AUD figure is a conversion, and invariant 3 keeps it out of the measure. |
| Q-03 | BECKONS | Sign is not one per table: ACTUALS PROFIT except UNKNOWN (reversed); BUDGET PROFIT except Tierra (PRESENTED). D-50 states one convention per table. | Ask Gary whether these are source errors. Otherwise extend D-50 to a per-table-and-lodge convention, owner-approved. |
| Q-04 | BECKONS | BUDGET statistics (AROOM, NIGHT, OROOM) are in the amount column and were FX-converted on 63 lines. Take STAT_VALUE from *_BASE? | Yes, from *_BASE; report the 63 lines. |
| Q-05 | HAI | The table carries AMOUNT_BUDGET for every year. In scope as the lane's BUDGET (a second unpivoted measure column; D-45 SCENARIO = column name)? | Yes: unpivot AMOUNT_ACTUAL / AMOUNT_BUDGET, x2 identity. |
| Q-06 | BECKONS | ACTUALS hold lines for 2026-11 (292) and 2026-12 (7), past today (2026-11-17). Accruals or a load error? | Carry as booked; ask Gary. |
| Q-07 | HAI | Currency is not stated. USD (all US locations)? | USD on owner confirmation; UNCONFIRMED until then. |
| Q-08 | BECKONS | H1 for 8xxx (M&A wages, travel) and 9xxx (KSL related expenses, suspense 99999). | 8xxx Expense / Operating Expenses (corporate overhead); 9xxx Below the Line, H2 UNCLASSIFIED. |
| Q-09 | BECKONS | The 7-digit Chilean chart (SAN, ATA, PAT; 300 accounts) is a second chart in one lane. Classify it by first digit (4 Revenue, 5 COGS, 6 Expense with sueldos to Payroll, 7 / 8 Below the Line), or leave unmapped accounts Unclassified? | By digit for H1; H2 only where ILEVELMAPPING1 states it. |
| Q-10 | BECKONS | UNKNOWN location (no LODGE_CODE, 695 lines, revenue -85.5M with reversed sign). Site key '~BLANK~' and carry, or is it a known entity? | Carry as '~BLANK~'; ask Gary what it is. |
| Q-11 | HAI | 4 lines with a null HH_MST_LOC_KEY (UCHI BOSTON, 2026-08 / 09). | Carry as '~BLANK~' (sentinel); report. |

## Answers (owner, stop 2) and addendum
Q-01 freeze by last_altered + hash, Time Travel fallback. Q-02 base amount + per-lodge currency; AUD staged only. Q-03 D-50 per table + entity where proved. Q-04 counts from base; 63 converted lines logged. Q-05 AMOUNT_BUDGET is HAI's budget. Q-06 measured (non-zero; logged). Q-07 USD (confirmed by MARKET). Q-08 8xxx / 9xxx Below the Line; suspense Unclassified. Q-09 iLevel first, proven range fallback; unproven listed. Q-10 UNKNOWN kept as a site. Q-11 sentinel. Addendum A-D: measured and applied (M3.md, M4.md).

## Raised at M2-M6
| Q | Lane | Question | Proposal |
|---|---|---|---|
| Q-12 | BECKONS | 2023-24 budgets run 2.5-6x actuals in every revenue account and month (2025-26 near 1x). | Carry as booked; N-74 for the source owner. |
| Q-13 | BECKONS | 7 Chilean 62xx accounts (depreciation, amortisation, interest titles) left Unclassified because the 62 block is opex. Map them to D&A / Other Income by title? | Leave Unclassified until approved; the master can correct them. |

## Stop 4 (owner)
1. D-50 entry approved and added.
2. Q-12: carried as booked, N-74; multiple varies by account, not constant per lodge.
3. Q-13: Chilean D&A / interest titles to Below the Line / Other Income / (Expense) (32 keys re-seeded); suspense 99999 Unclassified.
4. Merge: 9,092 inserts, 0 updates.
5. Grant: owner to confirm before the pipeline run.

## Pre-promotion (owner)
Depreciation / amortisation by title -> Below the Line / Other Income / (Expense) at every Beckons lodge, overriding the mapping (sources.md build rule). 25 keys reclassified, 26 rows re-seeded.
