# CLAUDE.md changes proposed by build 17 (for the owner at stop 4; not applied)

## Invariant 7
Current:
> 7. **Six tables in `SEMANTIC`**, and nothing else besides the procedures that build them. Drop every scratch object before a procedure returns.

Proposed:
> 7. **Seven tables in `SEMANTIC`**: the six detail tables and `SEM_AI_PACING` (D-51), and nothing else besides the procedures that build them. Drop every scratch object before a procedure returns.

## Section 4, opening
Current:
> **Six tables in `DEV_G2M_AI.SEMANTIC`, all at source-line grain, identical in every build.** This shape does not change when a lane is added. ...

Proposed (the existing paragraph and table kept, then):
> **A seventh table, `SEM_AI_PACING`, holds every lane's pacing** (D-51). It has its own columns, not the common block, because pacing's grain carries a snapshot date the six do not. It is long: one row per pacing row and metric column. It is outside the fact count identity; its own identity is `XFRM_{LANE}_PACING rows x k = SEM_AI_PACING rows`, per source table, with k the metric columns that table populates. **Snapshots are never summed across:** a sum over it is valid only within one SNAPSHOT_DATE (or IS_LATEST_SNAPSHOT), one VANTAGE, one CURRENCY_CODE, and IS_ADDITIVE.

Section 4 "Invariants": "**Six tables in `SEMANTIC`**" becomes "**Seven tables in `SEMANTIC`**".

## Section 3, "Pacing and pickup"
Current: "**It stops at transformation.** There is no semantic model, because its grain is not the one the six semantic tables share."
Proposed: "**It reaches semantic only through `SEM_AI_PACING`** (D-51), in its own long shape, because its grain is not the one the six detail tables share. Its transformation stream keeps the lane's own columns."

## Section 9, check 1 (transformation to semantic)
Add: `count(XFRM_{LANE}_PACING rows of a table) x k = count(SEM_AI_PACING rows of that table)`, per lane and source table, and every lane with pacing rows present in SEM_AI_PACING.

## D-21, current
| D-21 | Semantic shape | Detail only. Six tables, fixed and identical across lanes and builds. No aggregated layer. **Pacing stops at transformation** and has no semantic model: its grain carries an as-of date the six tables do not. |

## D-21, proposed
| D-21 | Semantic shape | Detail only. Six detail tables, fixed and identical across lanes and builds, and `SEM_AI_PACING` (D-51). No aggregated layer. **Pacing reaches semantic only through `SEM_AI_PACING`**, in its own long shape: its grain carries a snapshot date the six do not. |

## D-24, current
| D-24 | Pacing and pickup | Their own transformation stream, routed on source rather than `H1`, counted in the partition, and ending at transformation with no semantic model. Not `UNKNOWN`, which is a queue that should shrink. M1 establishes whether an as-of date exists; where it does not, the stream is still built and the memo states what the source would need to supply. |

## D-24, proposed
| D-24 | Pacing and pickup | Their own transformation stream, routed on source rather than `H1`, counted in the partition, and keeping the lane's own columns. It reaches semantic only through `SEM_AI_PACING` (D-51). Not `UNKNOWN`, which is a queue that should shrink. M1 establishes whether an as-of date exists; where it does not, the stream is still built and the memo states what the source would need to supply. |

## D-51, new
| D-51 | Semantic pacing | `SEM_AI_PACING` is the seventh semantic table: the union of every lane's `XFRM_{LANE}_PACING` in marked lane blocks (D-36), one row per pacing row x metric column, built by `SPROC_SEM_AI_PACING`, called last by `SPROC_SEM_AI_MAIN`. Columns: RUN_ID, SOURCE_LANE, SITE, SITE_NAME, SNAPSHOT_DATE, SNAPSHOT_SOURCE, STAY_PERIOD_START, STAY_PERIOD_END, STAY_GRAIN (`DAY`, `MONTH`, `EVENT`), SEGMENT, SEGMENT_SOURCE, BOOKING_STATUS, VANTAGE, METRIC_NAME (the source column, verbatim), METRIC_UNIT, IS_ADDITIVE, VALUE, CURRENCY_CODE (currency and rate metrics only), IS_LATEST_SNAPSHOT, SOURCE_TABLE, SOURCE_LINE_KEY, ATTRIBUTES (OBJECT: every other column of the stream as stored). Each source table unpivots the metric columns it populates, `INCLUDE NULLS`, with k stated per table; an all-null cell of an undeclared column is not emitted, and every non-null value and every undeclared table always is. VALUE is never scaled, signed or recomputed. METRIC_UNIT and IS_ADDITIVE come from a per-lane mapping approved by the owner: rates, ratios and percent changes are not additive. IS_LATEST_SNAPSHOT marks SNAPSHOT_DATE = the maximum per lane, site and source table. A sum over it is valid only within one SNAPSHOT_DATE (or IS_LATEST_SNAPSHOT), one VANTAGE, one CURRENCY_CODE, and IS_ADDITIVE. SOURCE_LINE_KEY is null where the lane has no unique line id. Pacing never feeds the seeder (D-37). Reconciled per lane, source table, metric and snapshot (rows, non-null count, sum) by `reconcile_PACING.sql`, which also fails for **any lane whose `XFRM_{LANE}_PACING` has rows and `SEM_AI_PACING` has none**, so a new lane's pacing fails loudly until it has a block. Build 17: NEWBURY `CLN_NEWBURY_BOSTON_OPS_RATE_SHOPS` stays in transformation only (competitor rates, not pace); KSL_SELECT_SERVICE and PEREGRINE_RESORTS have a null SOURCE_LINE_KEY (N-42). |
