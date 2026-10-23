# DAX Measures and Calculated Tables

This folder contains all DAX expressions used in the Power BI data model.

## Files

| File | Content |
|---|---|
| `measures.dax` | All DAX measures: event counts, rates, budget metrics and dynamic title |
| `calendar-table.dax` | Calendar calculated table and its computed columns |
| `field-parameter.dax` | Select Dynamic Measure field parameter definition |

## Design Principles

1. **Safe division:** all rate measures use `DIVIDE()` to avoid division-by-zero errors.
2. **Explicit filtering:** event counts use `COUNTROWS(FILTER(...))` for clarity and auditability.
3. **Composite metric:** Engagement = Clicks + Shares + Comments (excluding Likes and Purchases by design).
4. **Calendar table:** generated from the fact table date range using `CALENDAR(MIN, MAX)`.
5. **Field parameter:** enables dynamic measure switching in a single visual without duplicating charts.

## How to Apply

1. Open the `.pbix` file in Power BI Desktop.
2. Go to **Modeling → New Measure** (or **New Table** for the Calendar).
3. Paste the DAX expression from the corresponding file.
4. Adjust table references if your table names differ.
