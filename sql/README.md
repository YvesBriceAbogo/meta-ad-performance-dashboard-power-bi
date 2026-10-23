# SQL Equivalent Queries

This folder contains MS SQL Server queries that reproduce the analytical calculations implemented as DAX measures in the Power BI report.

## Purpose

These queries are provided for portfolio demonstration purposes. They show how the same KPIs can be computed using standard T-SQL, which is useful in environments where Power BI is not available or when the analysis needs to be performed directly against a relational database.

## Prerequisites

- MS SQL Server (2016 or later recommended).
- The four CSV files imported into tables: `ad_events`, `ads`, `campaigns`, `users`.
- Table and column names match the data model described in the documentation.

## File

| File | Content |
|---|---|
| `measures-equivalent.sql` | All core measures: event counts, engagement, rates, budget metrics, calendar generation, breakdowns by ad type, platform, gender, age, country, week, hour and campaign |

## Notes

- SQL queries return result sets; they do not replicate the interactive filtering behavior of Power BI slicers.
- The field parameter (dynamic measure switching) is a Power BI-specific feature and has no direct SQL equivalent.
- The `Dynamic Title` measure is a UI-level feature and is not replicated in SQL.
