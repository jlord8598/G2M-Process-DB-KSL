# Classification coverage - build 10 (HHG, HERSHA)

**Which accounts are classified, and correctly?**

| Lane | Keys | Re-seeded | New |
|---|---|---|---|
| HHG | 15,369 | 3,153 (COA mapping, `M4.md`) | 0 |
| HERSHA | 1,377 | 0 | 181 (174 from TB; 7 GL, already in the master) |

**HHG's structural error is corrected.** Natural accounts 62xxx-66xxx
(repairs, utilities, chemicals, landscaping, promotions) were seeded Payroll
by the digit; they are now Operating Expenses per the COA (2,729 keys).
- **2025:** Payroll falls from 53.8M to 38.8M.
- **2026:** Payroll falls from 126.2M to 89.5M.

**D&A and Income Taxes are now mapped** (82000-82200, 84000):
- 154 keys to D&A and 2 keys to Income Taxes;
- 2025 D&A is 43.9M.

**Not classified by the COA (today's seed kept):**
- 1,590 FORECAST_ANAPLAN line items;
- 50 ROUNDS statistics;
- 40 `xxxx-904-45950`;
- 3 at 9102;
- `9016-999-91000`;
- the mixed-type accounts 49950 (136 keys at 901-908 stay Revenue, Q-09),
  51990 and 52100.

**HERSHA:** no mapping change. Build 06's notes on 610000, 630000, 700000 and
714000 still stand for correction in the master.

Sign-anomaly and keyword-contradiction tests: not re-run for this build. Both
lanes' earlier records hold them.
