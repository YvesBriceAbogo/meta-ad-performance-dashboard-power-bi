-- =============================================================================
-- SQL EQUIVALENT QUERIES — Meta Ad Performance Dashboard
-- Engine: MS SQL Server (T-SQL)
-- =============================================================================
-- These queries reproduce the core DAX measures from the Power BI report.
-- Prerequisites: tables ad_events, ads, campaigns, users imported from CSV.
--
-- Table of Contents:
--   1.  Individual event counts
--   2.  Engagement (composite metric)
--   3.  All event counts in a single query
--   4.  Rate measures (CTR, Engagement Rate, Conversion Rate, Purchase Rate)
--   5.  Budget measures
--   6.  Analysis by ad type
--   7.  Analysis by platform
--   8.  Engagement by gender
--   9.  Engagement by age
--   10. Engagement by country
--   11. Weekly engagement trend by ad type
--   12. Hourly engagement trend
--   13. Calendar table generation
--   14. Analysis by campaign
-- =============================================================================


-- =============================================================================
-- 1. INDIVIDUAL EVENT COUNTS
-- DAX equivalent: COUNTROWS(FILTER(ad_events, ad_events[event_type] = "X"))
-- =============================================================================

-- Impressions
SELECT COUNT(*) AS Impressions
FROM ad_events
WHERE event_type = 'Impression';

-- Clicks
SELECT COUNT(*) AS Clicks
FROM ad_events
WHERE event_type = 'Click';

-- Shares
SELECT COUNT(*) AS Shares
FROM ad_events
WHERE event_type = 'Share';

-- Comments
SELECT COUNT(*) AS Comments
FROM ad_events
WHERE event_type = 'Comment';

-- Purchases
SELECT COUNT(*) AS Purchases
FROM ad_events
WHERE event_type = 'Purchase';

-- Likes
SELECT COUNT(*) AS Likes
FROM ad_events
WHERE event_type = 'Like';


-- =============================================================================
-- 2. ENGAGEMENT (composite metric)
-- DAX equivalent: [Clicks] + [Shares] + [Comments]
-- =============================================================================

SELECT
    SUM(CASE WHEN event_type = 'Click'   THEN 1 ELSE 0 END)
  + SUM(CASE WHEN event_type = 'Share'   THEN 1 ELSE 0 END)
  + SUM(CASE WHEN event_type = 'Comment' THEN 1 ELSE 0 END) AS Engagement
FROM ad_events;


-- =============================================================================
-- 3. ALL EVENT COUNTS IN A SINGLE QUERY
-- Consolidated view of all metrics for quick validation against Power BI.
-- =============================================================================

SELECT
    SUM(CASE WHEN event_type = 'Impression' THEN 1 ELSE 0 END) AS Impressions,
    SUM(CASE WHEN event_type = 'Click'      THEN 1 ELSE 0 END) AS Clicks,
    SUM(CASE WHEN event_type = 'Share'      THEN 1 ELSE 0 END) AS Shares,
    SUM(CASE WHEN event_type = 'Comment'    THEN 1 ELSE 0 END) AS Comments,
    SUM(CASE WHEN event_type = 'Purchase'   THEN 1 ELSE 0 END) AS Purchases,
    SUM(CASE WHEN event_type = 'Like'       THEN 1 ELSE 0 END) AS Likes,
    SUM(CASE WHEN event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement
FROM ad_events;


-- =============================================================================
-- 4. RATE MEASURES
-- DAX equivalent: DIVIDE([numerator], [denominator])
-- SQL uses NULLIF to avoid division by zero (returns NULL instead of error).
-- =============================================================================

SELECT
    -- CTR = Clicks / Impressions
    CAST(
        SUM(CASE WHEN event_type = 'Click' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS CTR,

    -- Engagement Rate = (Clicks + Shares + Comments) / Impressions
    CAST(
        SUM(CASE WHEN event_type IN ('Click', 'Share', 'Comment') THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS EngagementRate,

    -- Conversion Rate = Purchases / Clicks
    CAST(
        SUM(CASE WHEN event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN event_type = 'Click' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS ConversionRate,

    -- Purchase Rate = Purchases / Impressions
    CAST(
        SUM(CASE WHEN event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS PurchaseRate
FROM ad_events;


-- =============================================================================
-- 5. BUDGET MEASURES
-- DAX equivalents: SUM(campaigns[total_budget]), AVERAGE(campaigns[total_budget])
-- =============================================================================

-- Total Budget
SELECT SUM(total_budget) AS TotalBudget
FROM campaigns;

-- Avg Budget per Campaign
SELECT AVG(total_budget) AS AvgBudgetPerCampaign
FROM campaigns;

-- Both in one query
SELECT
    SUM(total_budget) AS TotalBudget,
    AVG(total_budget) AS AvgBudgetPerCampaign
FROM campaigns;


-- =============================================================================
-- 6. ANALYSIS BY AD TYPE
-- Reproduces the "Analysis By Ad Type" table visual in the Power BI report.
-- =============================================================================

SELECT
    a.ad_type,

    SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END) AS Impressions,
    SUM(CASE WHEN e.event_type = 'Click'      THEN 1 ELSE 0 END) AS Clicks,

    -- CTR
    CAST(
        SUM(CASE WHEN e.event_type = 'Click' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS CTR,

    -- Purchase Rate
    CAST(
        SUM(CASE WHEN e.event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS PurchaseRate,

    -- Engagement Rate
    CAST(
        SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS EngagementRate,

    -- Conversion Rate
    CAST(
        SUM(CASE WHEN e.event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS ConversionRate

FROM ad_events AS e
INNER JOIN ads AS a ON e.ad_id = a.ad_id
GROUP BY a.ad_type
ORDER BY Impressions DESC;


-- =============================================================================
-- 7. ANALYSIS BY PLATFORM
-- Breaks down all metrics by ad_platform (Facebook, Instagram).
-- Reproduces the platform-level comparison across the two report pages.
-- =============================================================================

SELECT
    a.ad_platform,

    SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END) AS Impressions,
    SUM(CASE WHEN e.event_type = 'Click'      THEN 1 ELSE 0 END) AS Clicks,
    SUM(CASE WHEN e.event_type = 'Share'      THEN 1 ELSE 0 END) AS Shares,
    SUM(CASE WHEN e.event_type = 'Comment'    THEN 1 ELSE 0 END) AS Comments,
    SUM(CASE WHEN e.event_type = 'Purchase'   THEN 1 ELSE 0 END) AS Purchases,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement,

    -- CTR
    CAST(
        SUM(CASE WHEN e.event_type = 'Click' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS CTR,

    -- Engagement Rate
    CAST(
        SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS EngagementRate,

    -- Conversion Rate
    CAST(
        SUM(CASE WHEN e.event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS ConversionRate,

    -- Purchase Rate
    CAST(
        SUM(CASE WHEN e.event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS PurchaseRate

FROM ad_events AS e
INNER JOIN ads AS a ON e.ad_id = a.ad_id
GROUP BY a.ad_platform
ORDER BY a.ad_platform;


-- =============================================================================
-- 8. ENGAGEMENT BY GENDER
-- Reproduces the "Engagement By Gender" donut chart.
-- =============================================================================

SELECT
    u.user_gender,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement,
    CAST(
        SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1.0 ELSE 0 END)
        / NULLIF(
            (SELECT SUM(CASE WHEN event_type IN ('Click', 'Share', 'Comment') THEN 1.0 ELSE 0 END)
             FROM ad_events), 0
        )
        AS DECIMAL(10, 4)
    ) AS EngagementPct
FROM ad_events AS e
INNER JOIN users AS u ON e.user_id = u.user_id
WHERE e.event_type IN ('Click', 'Share', 'Comment')
GROUP BY u.user_gender
ORDER BY Engagement DESC;


-- =============================================================================
-- 9. ENGAGEMENT BY AGE
-- Reproduces the "Engagement by age" bar chart.
-- =============================================================================

SELECT
    u.user_age,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement
FROM ad_events AS e
INNER JOIN users AS u ON e.user_id = u.user_id
WHERE e.event_type IN ('Click', 'Share', 'Comment')
GROUP BY u.user_age
ORDER BY u.user_age;


-- =============================================================================
-- 10. ENGAGEMENT BY COUNTRY
-- Reproduces the "Engagement by Country" map visual.
-- =============================================================================

SELECT
    u.country,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement
FROM ad_events AS e
INNER JOIN users AS u ON e.user_id = u.user_id
WHERE e.event_type IN ('Click', 'Share', 'Comment')
GROUP BY u.country
ORDER BY Engagement DESC;


-- =============================================================================
-- 11. WEEKLY ENGAGEMENT TREND BY AD TYPE
-- Reproduces the "Weekly Engagement Trend" stacked bar chart.
-- =============================================================================

SELECT
    DATEPART(ISO_WEEK, CAST(e.[timestamp] AS DATE)) AS WeekNumber,
    a.ad_type,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement
FROM ad_events AS e
INNER JOIN ads AS a ON e.ad_id = a.ad_id
WHERE e.event_type IN ('Click', 'Share', 'Comment')
GROUP BY DATEPART(ISO_WEEK, CAST(e.[timestamp] AS DATE)), a.ad_type
ORDER BY WeekNumber, a.ad_type;


-- =============================================================================
-- 12. HOURLY ENGAGEMENT TREND
-- Reproduces the "Hourly Engagement Trend" line chart.
-- =============================================================================

SELECT
    DATEPART(HOUR, e.[timestamp]) AS EventHour,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement
FROM ad_events AS e
WHERE e.event_type IN ('Click', 'Share', 'Comment')
GROUP BY DATEPART(HOUR, e.[timestamp])
ORDER BY EventHour;


-- =============================================================================
-- 13. CALENDAR TABLE GENERATION
-- Creates a date dimension similar to the DAX CALENDAR(MIN, MAX) function.
-- Uses a recursive CTE to generate all dates between the earliest and latest
-- event dates.
-- =============================================================================

WITH DateRange AS (
    SELECT
        CAST(MIN(CAST([timestamp] AS DATE)) AS DATE) AS StartDate,
        CAST(MAX(CAST([timestamp] AS DATE)) AS DATE) AS EndDate
    FROM ad_events
),
DateSequence AS (
    SELECT StartDate AS [Date]
    FROM DateRange
    UNION ALL
    SELECT DATEADD(DAY, 1, ds.[Date])
    FROM DateSequence AS ds
    CROSS JOIN DateRange AS dr
    WHERE ds.[Date] < dr.EndDate
)
SELECT
    [Date],
    FORMAT([Date], 'MMM')      AS MonthName,
    MONTH([Date])              AS YearMonth_num,
    FORMAT([Date], 'ddd')      AS DayName,
    DAY([Date])                AS MonthDay_num,
    -- Monday = 1, Sunday = 7 (matches DAX WEEKDAY with argument 2)
    ((DATEPART(WEEKDAY, [Date]) + @@DATEFIRST - 2) % 7) + 1 AS WeekDay_num,
    DATEPART(ISO_WEEK, [Date]) AS YearWeek_num
FROM DateSequence
OPTION (MAXRECURSION 400);


-- =============================================================================
-- 14. ANALYSIS BY CAMPAIGN
-- Full performance breakdown per campaign including budget and all KPIs.
-- =============================================================================

SELECT
    c.name                AS CampaignName,
    c.total_budget        AS TotalBudget,
    c.start_date          AS StartDate,
    c.end_date            AS EndDate,
    c.duration_days       AS DurationDays,

    SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END) AS Impressions,
    SUM(CASE WHEN e.event_type = 'Click'      THEN 1 ELSE 0 END) AS Clicks,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1 ELSE 0 END) AS Engagement,
    SUM(CASE WHEN e.event_type = 'Purchase'   THEN 1 ELSE 0 END) AS Purchases,

    -- CTR
    CAST(
        SUM(CASE WHEN e.event_type = 'Click' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS CTR,

    -- Engagement Rate
    CAST(
        SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment') THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS EngagementRate,

    -- Conversion Rate
    CAST(
        SUM(CASE WHEN e.event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS ConversionRate,

    -- Purchase Rate
    CAST(
        SUM(CASE WHEN e.event_type = 'Purchase' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1.0 ELSE 0 END), 0)
        AS DECIMAL(10, 4)
    ) AS PurchaseRate

FROM ad_events AS e
INNER JOIN ads        AS a ON e.ad_id       = a.ad_id
INNER JOIN campaigns  AS c ON a.campaign_id = c.campaign_id
GROUP BY c.name, c.total_budget, c.start_date, c.end_date, c.duration_days
ORDER BY c.name;
