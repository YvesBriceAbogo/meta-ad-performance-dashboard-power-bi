# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2025-07-15

### Added

- Initial Power BI report: Meta Ad Performance Dashboard (two pages: Facebook and Instagram).
- Four source CSV files: `ad_events.csv`, `ads.csv`, `campaigns.csv`, `users.csv`.
- Power Query scripts for all four tables with parameterized file path.
- DAX measures: Impressions, Clicks, Shares, Comments, Purchases, Likes, Engagement, CTR, Engagement Rate, Conversion Rate, Purchase Rate, Total Budget, Avg Budget per Campaign.
- DAX calculated table: Calendar with Month Name, Day Name, week and month number columns.
- DAX field parameter: Select Dynamic Measure with Dynamic Title.
- SQL equivalent queries (MS SQL Server) for all core measures.
- Star schema data model: ad_events (fact), ads, users, campaigns (dimensions), Calendar (calculated).
- Publication to Power BI Service with on-premises standard gateway.
- Scheduled refresh at 11:30 AM and 5:00 PM (South Africa time, UTC+2).
- Complete documentation: data model, installation guide, publishing guide, gateway guide, limitations.
- PDF export of the report.
- Repository structure with README, LICENSE, CHANGELOG and .gitignore.
