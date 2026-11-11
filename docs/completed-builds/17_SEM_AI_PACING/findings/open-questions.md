# Open questions - build 17

## Stop 1
- **Q-01. Unpivot column list (blocking k).** (a) Each table's currently populated metric columns (8,452,970 rows), a later column appearing is a code change; or (b) every numeric column of the stream INCLUDE NULLS (more rows, all-null for absent columns). Recommendation (a).
- **Q-02. BEAUMIER.** BUSINESS_DATE (105 values, 5,970 rows dated after the stay month) is a cancellation-date axis, not a snapshot; FILE_DATE (3) is the only as-of. Proposal: SNAPSHOT_DATE = FILE_DATE::date, BUSINESS_DATE carried as VANTAGE / attribute. And OCCUPANCY (0..772): COUNT (room nights) or RATIO?
- **Q-03. NEWBURY OPS_RATE_SHOPS.** Competitor rate shops, not pace. Include (SITE = competitor hotel, METRIC_UNIT RATE, IS_ADDITIVE FALSE) or leave in XFRM only?
- **Q-04. KSL / PEREGRINE EVENTS.** No occupancy date; use EVENT_DATE as STAY_PERIOD_START with STAY_GRAIN EVENT_DAY?
- **Q-05. Attributes beyond the shape.** Carry KSL / PEREGRINE booking / event / sales-manager codes, NEWBURY OTA / room type / IS_BAR, UNDER_CANVAS COLUMN10 / GROUP_LEISURE as extra nullable columns, or only via SOURCE_LINE_KEY back to XFRM? Recommendation: an ATTRIBUTES object (VARIANT) per row holding the lane's other non-metric columns verbatim.
- **Q-06. KSL / PEREGRINE SOURCE_LINE_KEY.** No file / row columns on these streams; propose BOOKING_CODE|EVENT_CODE|LINE_SEQ|AS_OF_DATE, uniqueness proved at M3 before use.
- **Q-07. ALTERRA currency** remains UNCONFIRMED (build 11); carried as such unless you confirm it.

**Stop 1 answers (owner):** Q-01 populated columns only (skipped list in M1). Q-02 BEAUMIER snapshot = file date, BUSINESS_DATE in ATTRIBUTES, OCCUPANCY = rooms (additive). Q-03 rate shops stay in XFRM; N-41. Q-04 EVENT_DATE, STAY_GRAIN 'EVENT'. Q-05 ATTRIBUTES OBJECT incl. COLUMN10. Q-06 prove first (failed, below). Q-07 UNCONFIRMED.

## Stop 2
- **Q-08. KSL / PEREGRINE SOURCE_LINE_KEY (blocking for those two lanes).** The approved key is not unique in any of the 6 tables (M1). Options: (a) the 8-part key SITE_TAG | BOOKING_CODE | EVENT_CODE | LINE_SEQ | AS_OF_DATE | stay or event date | MARKET_SEGMENT_CODE | STATUS, unique today but asserted every run by check 2 and failing loudly if it stops being unique; (b) SOURCE_LINE_KEY null for these two lanes (allowed: "null where the lane has no natural key"), with reconcile at lane / table / metric / snapshot grain only; (c) ask the source owner for a line id (N-42) and leave the two lanes out of SEM_AI_PACING until then. Recommendation (b): (a) builds a key from attributes the source never promised.

**Stop 2 answer:** Q-08 (b). Line key null for KSL / PEREGRINE; transformation carries no row identifier for them (LINE_SEQ in ATTRIBUTES). N-42 open.
**Stop 3:** approved, both WHERE clauses; add the lane-coverage check (done: reconcile_PACING.sql COVERAGE, D-51 text).

## Stop 4
- **Q-09.** CLAUDE.md invariant 7, section 3, section 4, check 1, D-21, D-24 and D-51 text: `claude-md-diff.md`. Approve, edit or reject; not applied.
- **Q-10.** KSL / PEREGRINE EVENTS QTY has no stated unit (509,463 rows, METRIC_UNIT null, IS_ADDITIVE TRUE). Confirm, or name the unit (attendees?).

**Stop 4 answers (owner):** approved. Q-09 applied as written. Q-10: EVENTS QTY METRIC_UNIT 'count', additive; N-43 logged.
