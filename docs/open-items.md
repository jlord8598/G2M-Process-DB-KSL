# Open items carried between builds

Items raised in a build that need someone outside it: the source owner, or a
later build. **Not instructions.** Each names the build that raised it; the
record is in `docs/completed-builds/<build>/`.

| # | From | Lane | Item | For |
|---|---|---|---|---|
| N-1 | build 09 | INVITED_CLUBS | **Future-period ACTUAL values changed.** 490 ACTUAL rows dated Nov-Dec 2026 changed value between the build 08 extract (2026-10-28) and the build 09 extract (net -3,562,114.35). The 5 largest are all private-event curve values at D0220: E00268 `PER_Wedding_CP_Curve_Value` 2026-11, 2,734,050.00 -> 39,700.00; E00763 `PER_Business_CP_Curve_Value` 2026-12, 358,250.00 -> 263,360.00; E00648 `PER_Business_CP_Curve_Value` 2026-11, 212,113.00 -> 156,312.50; E02889 `PER_Social_CP_Curve_Value` 2026-12, 230,206.00 -> 176,915.58; E00674 `PER_Social_CP_Curve_Value` 2026-12, 138,496.00 -> 89,828.75. Actuals for future periods need explaining. | source owner |
| N-2 | build 09 | INVITED_CLUBS | **ACCOUNTS is not unique on entity + account.** In the rebuilt `CLN_INVITED_CLUBS_ACCOUNTS` (288,714 rows), 42,332 `ENTITY_CODE` + `ACCOUNT_CODE` pairs occur more than once. Nothing joins it today; any future join needs more than those two columns. | source owner |
| Q-09 | build 09 | INVITED_CLUBS | **Covers members** (`Breakfast_Covers`, `Lunch_Covers`, `Dinner_Covers`) are META ACCOUNT_TYPE revenue. Their DATA_TYPE (currency or not) was not checked. If currency, B09-D4 routes them to operating metrics as `currency`, although they are counts. | a later build |
| N-3 | build 10 | HHG | **Entity names not in landed data:** 9055, 9056, 9099, 9102 (624 TR12 rows) have no name in ASSET_CODES, REFERENCES or any other HHG table. | source owner |
| N-4 | build 10 | HHG | **ASSET_CODES ACQUISITION_DATE typos:** years 0024 / 0026 on 9041-9047 and 9050. | source owner |
| N-5 | build 10 | HERSHA | **TB_ACTUAL lacks hotels 118 (HGI Tribeca), 149 (Cadillac Hotel & Beach Club), 230 (Parrot Key)**, which GL_ACTUAL carries; their actuals stay on GL. | source owner |
| N-6 | build 10 | HERSHA | **Which forecast is current?** TB_ACTUAL and GL_ACTUAL forecasts disagree (135 of 660 shared entity-account-months within 1%; TB -20,986,076.91 vs GL -96,108,648.44). GL is used; TB's forecast is kept in UNKNOWN as DUPLICATE_DETAIL. Also: TB `FLAG_COL_1` / `FLAG_COL_2` meanings. | source owner |
| N-7 | build 10 | HHG | **ROUNDS_DETAIL SOURCE_LINE_KEY includes the source file name** (`SOURCE_FILE_PATH|SOURCE_ROW_NUMBER|CLUB_CODE`), so every replacement file changes every line key (build 10: 91,300 of 91,300). Propose a key without the file name in a later build. | a later build |
