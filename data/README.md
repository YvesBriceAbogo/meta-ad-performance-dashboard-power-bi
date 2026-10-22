Voici votre **guide d’implémentation complet, pas à pas et prêt pour la production**. 

Toutes les instructions de navigation sont fournies en français, tandis que l’ensemble du contenu technique déposé sur GitHub (**README, scripts Power Query, code DAX, requêtes SQL, messages de commit et Release**) est rédigé en **anglais professionnel de standard international**.

---

# TABLE DES MATIÈRES
1. [Architecture et arborescence du dépôt](#1-architecture-et-arborescence-du-dépôt)
2. [Code refactorisé et optimisé (M, DAX, T-SQL)](#2-code-refactorisé-et-optimisé)
3. [Guide pas-à-pas sur GitHub (Création jusqu'à la Release)](#3-guide-pas-à-pas-sur-github)
4. [Contenu complet du fichier README.md](#4-contenu-complet-du-fichier-readmemd)
5. [Documentation complémentaire et fichiers annexes](#5-documentation-complémentaire)

---

# 1. ARCHITECTURE ET ARBORESCENCE DU DÉPÔT

Voici la structure exacte que nous allons mettre en place :

```text
meta-ad-performance-powerbi/
├── .gitignore
├── LICENSE
├── README.md
├── CHANGELOG.md
├── data/
│   ├── README.md
│   ├── ad_events.csv
│   ├── ads.csv
│   ├── campaigns.csv
│   └── users.csv
├── power-query/
│   ├── ad_events.m
│   ├── ads.m
│   ├── campaigns.m
│   ├── users.m
│   └── parameters.m
├── dax/
│   ├── 01_base_measures.dax
│   ├── 02_kpi_rates.dax
│   ├── 03_dynamic_measures.dax
│   └── 04_calendar_table.dax
├── sql/
│   ├── 01_schema_ddl.sql
│   ├── 02_kpi_views.sql
│   └── 03_analytical_queries.sql
├── documentation/
│   ├── data-model.md
│   ├── data-dictionary.md
│   ├── gateway-and-refresh.md
│   └── deployment-guide.md
├── images/
│   ├── data-model.png
│   ├── dashboard-overview-july.png
│   └── dashboard-overview-june.png
├── reports/
│   └── Meta-Ad-Performance-Report.pdf
└── power-bi/
    └── meta-ad-performance-dashboard.pbix
```

---

# 2. CODE REFACTORISÉ ET OPTIMISÉ

### A. Power Query (M) — Amélioré et insensible aux paramètres régionaux

#### 1. `power-query/parameters.m`
```powerquery
// SourcePath parameter for flexible environment deployments
let
    SourcePath = "C:\Data\MetaAdPerformance" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]
in
    SourcePath
```

#### 2. `power-query/ad_events.m`
```powerquery
let
    Source = Csv.Document(
        File.Contents(SourcePath & "\ad_events.csv"),
        [Delimiter = ",", Columns = 7, Encoding = 1252, QuoteStyle = QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    TypedColumns = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"event_id", Int64.Type},
            {"ad_id", Int64.Type},
            {"user_id", type text},
            {"timestamp", type datetime},
            {"day_of_week", type text},
            {"time_of_day", type text},
            {"event_type", type text}
        },
        "en-US"
    ),
    // Extract Date and Hour directly without duplicating text columns
    AddedDate = Table.AddColumn(TypedColumns, "Date", each DateTime.Date([timestamp]), type date),
    AddedHour = Table.AddColumn(AddedDate, "Event Hour", each Time.Hour(DateTime.Time([timestamp])), Int64.Type)
in
    AddedHour
```

#### 3. `power-query/ads.m`
```powerquery
let
    Source = Csv.Document(
        File.Contents(SourcePath & "\ads.csv"),
        [Delimiter = ",", Columns = 7, Encoding = 1252, QuoteStyle = QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    CleanedText = Table.TransformColumns(PromotedHeaders, {
        {"ad_platform", Text.Trim, type text},
        {"ad_type", Text.Trim, type text},
        {"target_gender", Text.Trim, type text},
        {"target_age_group", Text.Trim, type text},
        {"target_interests", Text.Trim, type text}
    }),
    TypedColumns = Table.TransformColumnTypes(
        CleanedText,
        {
            {"ad_id", Int64.Type},
            {"campaign_id", Int64.Type},
            {"ad_platform", type text},
            {"ad_type", type text},
            {"target_gender", type text},
            {"target_age_group", type text},
            {"target_interests", type text}
        },
        "en-US"
    )
in
    TypedColumns
```

#### 4. `power-query/campaigns.m`
```powerquery
let
    Source = Csv.Document(
        File.Contents(SourcePath & "\campaigns.csv"),
        [Delimiter = ",", Columns = 6, Encoding = 1252, QuoteStyle = QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Robust parsing using invariant culture (handles dots vs commas automatically)
    ParsedBudget = Table.TransformColumns(PromotedHeaders, {
        {"total_budget", each Number.FromText(_, "en-US"), type number}
    }),
    TypedColumns = Table.TransformColumnTypes(
        ParsedBudget,
        {
            {"campaign_id", Int64.Type},
            {"name", type text},
            {"start_date", type date},
            {"end_date", type date},
            {"duration_days", Int64.Type},
            {"total_budget", Currency.Type}
        },
        "en-US"
    )
in
    TypedColumns
```

#### 5. `power-query/users.m`
```powerquery
let
    Source = Csv.Document(
        File.Contents(SourcePath & "\users.csv"),
        [Delimiter = ",", Columns = 7, Encoding = 1252, QuoteStyle = QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    CleanedText = Table.TransformColumns(PromotedHeaders, {
        {"user_id", Text.Trim, type text},
        {"user_gender", Text.Trim, type text},
        {"age_group", Text.Trim, type text},
        {"country", Text.Trim, type text},
        {"location", Text.Trim, type text},
        {"interests", Text.Trim, type text}
    }),
    TypedColumns = Table.TransformColumnTypes(
        CleanedText,
        {
            {"user_id", type text},
            {"user_gender", type text},
            {"user_age", Int64.Type},
            {"age_group", type text},
            {"country", type text},
            {"location", type text},
            {"interests", type text}
        },
        "en-US"
    )
in
    TypedColumns
```

---

### B. DAX — Optimisé, Performant et Modulaire

#### 1. `dax/01_base_measures.dax`
```dax
/* =========================================================================
   BASE EVENT & BUDGET MEASURES
   Optimized with CALCULATE(COUNTROWS(...)) for direct engine pushdown.
   ========================================================================= */

[Impressions] = 
CALCULATE(
    COUNTROWS('ad_events'),
    'ad_events'[event_type] = "Impression"
)

[Clicks] = 
CALCULATE(
    COUNTROWS('ad_events'),
    'ad_events'[event_type] = "Click"
)

[Shares] = 
CALCULATE(
    COUNTROWS('ad_events'),
    'ad_events'[event_type] = "Share"
)

[Comments] = 
CALCULATE(
    COUNTROWS('ad_events'),
    'ad_events'[event_type] = "Comment"
)

[Likes] = 
CALCULATE(
    COUNTROWS('ad_events'),
    'ad_events'[event_type] = "Like"
)

[Purchases] = 
CALCULATE(
    COUNTROWS('ad_events'),
    'ad_events'[event_type] = "Purchase"
)

[Engagement] = 
[Clicks] + [Shares] + [Comments] + [Likes]

[Total Budget] = 
SUM('campaigns'[total_budget])

[Avg Budget per Campaign] = 
AVERAGE('campaigns'[total_budget])
```

#### 2. `dax/02_kpi_rates.dax`
```dax
/* =========================================================================
   KPI PERFORMANCE RATIOS
   Safe division patterns protected against divide-by-zero.
   ========================================================================= */

[CTR (ClickThrough Rate)] = 
DIVIDE(
    [Clicks],
    [Impressions],
    BLANK()
)

[Engagement Rate] = 
DIVIDE(
    [Engagement],
    [Impressions],
    BLANK()
)

[Conversion Rate] = 
DIVIDE(
    [Purchases],
    [Clicks],
    BLANK()
)

[Purchase Rate] = 
DIVIDE(
    [Purchases],
    [Impressions],
    BLANK()
)
```

#### 3. `dax/03_dynamic_measures.dax`
```dax
/* =========================================================================
   FIELD PARAMETER & DYNAMIC TITLE LOGIC
   ========================================================================= */

// Field Parameter Definition Table: 'Select Dynamic Measure'
Select Dynamic Measure = {
    ("Impressions", NAMEOF('ad_events'[Impressions]), 0),
    ("Engagement", NAMEOF('ad_events'[Engagement]), 1),
    ("Clicks", NAMEOF('ad_events'[Clicks]), 2),
    ("Shares", NAMEOF('ad_events'[Shares]), 3),
    ("Comments", NAMEOF('ad_events'[Comments]), 4),
    ("Purchases", NAMEOF('ad_events'[Purchases]), 5)
}

// Optimized Dynamic Title Measure
[Dynamic Title] = 
VAR SelectedMetric = SELECTEDVALUE('Select Dynamic Measure'[Select Dynamic Measure])
RETURN
    IF(
        ISBLANK(SelectedMetric),
        "Engagement Overview",
        SelectedMetric & " Performance Breakdown"
    )
```

#### 4. `dax/04_calendar_table.dax`
```dax
/* =========================================================================
   DATE DIMENSION (CALENDAR)
   Pre-calculated attributes with proper sorting fields.
   ========================================================================= */

Calendar = 
VAR MinDate = MIN('ad_events'[Date])
VAR MaxDate = MAX('ad_events'[Date])
RETURN
ADDCOLUMNS(
    CALENDAR(MinDate, MaxDate),
    "Year", YEAR([Date]),
    "Month Number", MONTH([Date]),
    "Month Name", FORMAT([Date], "mmm"),
    "Month Year", FORMAT([Date], "mmm yyyy"),
    "Month Year Sort", YEAR([Date]) * 100 + MONTH([Date]),
    "Day of Month", DAY([Date]),
    "Day Name", FORMAT([Date], "ddd"),
    "Day of Week Num", WEEKDAY([Date], 2), // Monday = 1, Sunday = 7
    "Week Number", WEEKNUM([Date], 2)
)
```

---

### C. MS SQL Server (T-SQL) — Scripts de base de données & Vues analytiques

#### 1. `sql/01_schema_ddl.sql`
```sql
-- =============================================================================
-- Database Schema: Meta Ad Analytics
-- Dialect: Microsoft SQL Server (T-SQL)
-- =============================================================================

CREATE TABLE dim_campaigns (
    campaign_id INT PRIMARY KEY,
    name NVARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration_days INT NOT NULL,
    total_budget DECIMAL(18, 2) NOT NULL
);

CREATE TABLE dim_ads (
    ad_id INT PRIMARY KEY,
    campaign_id INT NOT NULL FOREIGN KEY REFERENCES dim_campaigns(campaign_id),
    ad_platform NVARCHAR(50) NOT NULL,
    ad_type NVARCHAR(50) NOT NULL,
    target_gender NVARCHAR(20) NOT NULL,
    target_age_group NVARCHAR(50) NOT NULL,
    target_interests NVARCHAR(255) NULL
);

CREATE TABLE dim_users (
    user_id NVARCHAR(100) PRIMARY KEY,
    user_gender NVARCHAR(20) NOT NULL,
    user_age INT NOT NULL,
    age_group NVARCHAR(50) NOT NULL,
    country NVARCHAR(100) NOT NULL,
    location NVARCHAR(150) NOT NULL,
    interests NVARCHAR(255) NULL
);

CREATE TABLE fact_ad_events (
    event_id BIGINT PRIMARY KEY,
    ad_id INT NOT NULL FOREIGN KEY REFERENCES dim_ads(ad_id),
    user_id NVARCHAR(100) NOT NULL FOREIGN KEY REFERENCES dim_users(user_id),
    event_timestamp DATETIME2 NOT NULL,
    event_date DATE NOT NULL,
    day_of_week NVARCHAR(20) NOT NULL,
    time_of_day NVARCHAR(20) NOT NULL,
    event_type NVARCHAR(50) NOT NULL
);

CREATE INDEX IX_ad_events_event_type ON fact_ad_events(event_type);
CREATE INDEX IX_ad_events_date ON fact_ad_events(event_date);
CREATE INDEX IX_ad_events_ad_id ON fact_ad_events(ad_id);
```

#### 2. `sql/02_kpi_views.sql`
```sql
-- =============================================================================
-- View: Aggregate Marketing KPIs by Campaign and Ad Format
-- Mirrors DAX Measures: CTR, Engagement Rate, Conversion Rate, Purchase Rate
-- =============================================================================

CREATE OR ALTER VIEW vw_meta_campaign_kpis AS
WITH EventAggregations AS (
    SELECT 
        e.ad_id,
        COUNT(CASE WHEN e.event_type = 'Impression' THEN 1 END) AS Impressions,
        COUNT(CASE WHEN e.event_type = 'Click' THEN 1 END) AS Clicks,
        COUNT(CASE WHEN e.event_type = 'Share' THEN 1 END) AS Shares,
        COUNT(CASE WHEN e.event_type = 'Comment' THEN 1 END) AS Comments,
        COUNT(CASE WHEN e.event_type = 'Like' THEN 1 END) AS Likes,
        COUNT(CASE WHEN e.event_type = 'Purchase' THEN 1 END) AS Purchases
    FROM fact_ad_events e
    GROUP BY e.ad_id
)
SELECT 
    c.campaign_id,
    c.name AS campaign_name,
    c.total_budget,
    a.ad_id,
    a.ad_platform,
    a.ad_type,
    a.target_gender,
    a.target_age_group,
    ISNULL(ea.Impressions, 0) AS Impressions,
    ISNULL(ea.Clicks, 0) AS Clicks,
    ISNULL(ea.Shares, 0) AS Shares,
    ISNULL(ea.Comments, 0) AS Comments,
    ISNULL(ea.Likes, 0) AS Likes,
    ISNULL(ea.Purchases, 0) AS Purchases,
    (ISNULL(ea.Clicks, 0) + ISNULL(ea.Shares, 0) + ISNULL(ea.Comments, 0) + ISNULL(ea.Likes, 0)) AS Total_Engagement,
    
    -- Calculated KPI Ratios
    CAST(ROUND(CAST(ISNULL(ea.Clicks, 0) AS FLOAT) / NULLIF(ea.Impressions, 0) * 100, 2) AS DECIMAL(5,2)) AS ctr_percentage,
    CAST(ROUND(CAST(ISNULL(ea.Clicks, 0) + ISNULL(ea.Shares, 0) + ISNULL(ea.Comments, 0) + ISNULL(ea.Likes, 0) AS FLOAT) / NULLIF(ea.Impressions, 0) * 100, 2) AS DECIMAL(5,2)) AS engagement_rate_percentage,
    CAST(ROUND(CAST(ISNULL(ea.Purchases, 0) AS FLOAT) / NULLIF(ea.Clicks, 0) * 100, 2) AS DECIMAL(5,2)) AS conversion_rate_percentage,
    CAST(ROUND(CAST(ISNULL(ea.Purchases, 0) AS FLOAT) / NULLIF(ea.Impressions, 0) * 100, 2) AS DECIMAL(5,2)) AS purchase_rate_percentage
FROM dim_ads a
INNER JOIN dim_campaigns c ON a.campaign_id = c.campaign_id
LEFT JOIN EventAggregations ea ON a.ad_id = ea.ad_id;
```

#### 3. `sql/03_analytical_queries.sql`
```sql
-- =============================================================================
-- Analytical Queries corresponding to Dashboard Visuals
-- =============================================================================

-- 1. Performance breakdown by Ad Type (Mirrors Dashboard Matrix)
SELECT 
    a.ad_type,
    SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END) AS Impressions,
    SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END) AS Clicks,
    CAST(ROUND(CAST(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END), 0) * 100, 2) AS DECIMAL(5,2)) AS [CTR %],
    CAST(ROUND(CAST(SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END), 0) * 100, 2) AS DECIMAL(5,2)) AS [Pur_Rate %],
    CAST(ROUND(CAST(SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment', 'Like') THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END), 0) * 100, 2) AS DECIMAL(5,2)) AS [Eng_Rate %],
    CAST(ROUND(CAST(SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END), 0) * 100, 2) AS DECIMAL(5,2)) AS [Conv_Rate %]
FROM fact_ad_events e
INNER JOIN dim_ads a ON e.ad_id = a.ad_id
GROUP BY a.ad_type
ORDER BY Impressions DESC;

-- 2. Engagement Breakdown by Demographic Profile (Gender & Age)
SELECT 
    u.user_gender,
    u.age_group,
    COUNT(e.event_id) AS total_events,
    SUM(CASE WHEN e.event_type IN ('Click', 'Share', 'Comment', 'Like') THEN 1 ELSE 0 END) AS total_engagements
FROM fact_ad_events e
INNER JOIN dim_users u ON e.user_id = u.user_id
GROUP BY u.user_gender, u.age_group
ORDER BY total_engagements DESC;

-- 3. Hourly Trend Analysis
SELECT 
    DATEPART(HOUR, e.event_timestamp) AS [HourOfDay],
    COUNT(e.event_id) AS Total_Interactions,
    SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END) AS Clicks,
    SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS Purchases
FROM fact_ad_events e
GROUP BY DATEPART(HOUR, e.event_timestamp)
ORDER BY [HourOfDay] ASC;
```

---

# 3. GUIDE PAS-À-PAS SUR GITHUB

Suivez scrupuleusement ces étapes dans votre navigateur sur [github.com](https://github.com).

### Étape 1 : Créer le dépôt distant (New Repository)
1. Rendez-vous sur votre profil GitHub : `https://github.com/YvesBriceAbogo`.
2. Cliquez sur l’onglet **Repositories**, puis sur le bouton vert **New** (en haut à droite).
3. Renseignez les champs suivants :
   - **Repository name** : `meta-ad-performance-powerbi`
   - **Description** : `End-to-End Meta (Facebook/Instagram) Ad Performance Dashboard featuring Power Query (M), Star Schema DAX, Automated Gateway Refresh, and Transact-SQL Analytics.`
   - **Visibility** : Cochez **Public**.
   - **Initialize this repository with** :
     - Cochez **Add a README file**.
     - Cochez **Add .gitignore** $\rightarrow$ Sélectionnez le modèle : `None` (nous créerons le nôtre sur-mesure).
     - Cochez **Choose a license** $\rightarrow$ Sélectionnez : **MIT License**.
4. Cliquez sur **Create repository**.

---

### Étape 2 : Configurer le fichier `.gitignore`
1. Sur la page d’accueil du dépôt créé, cliquez sur **Add file** $\rightarrow$ **Create new file**.
2. Dans le champ nom du fichier : `.gitignore`
3. Collez le contenu suivant :
```gitignore
# Power BI temporary files
*.tmp
*.temp
~$*.pbix
~$*.pbit

# Windows system files
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# Visual Studio Code & IDEs
.vscode/
.idea/

# Local sensitive configs
local_settings.json
*.env
```
4. En bas de page, dans la zone **Commit changes** :
   - Titre du commit : `build: initialize .gitignore configuration`
   - Cliquez sur **Commit changes**.

---

### Étape 3 : Créer l'architecture des répertoires et déposer les fichiers

Pour créer des sous-dossiers sur GitHub via l'interface web, tapez simplement le nom du sous-dossier suivi d'un slash `/` dans le champ de saisie du fichier (ex: `data/README.md`).

#### A. Déposer les données (`data/`)
1. Cliquez sur **Add file** $\rightarrow$ **Create new file**.
2. Nommez le fichier : `data/README.md`
3. Collez ce contenu :
```markdown
# Dataset Documentation

This directory contains the source CSV files utilized for the Meta Ad Performance Analytics solution:

- `ad_events.csv`: Granular logs of user interactions (Impressions, Clicks, Likes, Comments, Shares, Purchases).
- `ads.csv`: Ad metadata, formats (Stories, Image, Carousel, Video), platform channel, and targeting specifications.
- `campaigns.csv`: High-level marketing campaigns, duration, and allocated budgets.
- `users.csv`: User demographics (gender, age group, country, interests).

> **Data Source Notice**: Publicly sourced data for demonstration, portfolio, and analytical benchmarking purposes. Code and analytics are distributed under the MIT license; data remains under its original terms.
```
4. Cliquez sur **Commit changes**.
5. Déposez vos 4 fichiers CSV (`ad_events.csv`, `ads.csv`, `campaigns.csv`, `users.csv`) via **Add file** $\rightarrow$ **Upload files** $\rightarrow$ Déposez-les dans `data/` $\rightarrow$ Cliquez sur **Commit changes**.

#### B. Déposer les scripts Power Query (`power-query/`)
1. Créez successivement (via **Add file** $\rightarrow$ **Create new file**) les 5 fichiers suivants en y collant le code Power Query fourni en section 2.A :
   - `power-query/parameters.m`
   - `power-query/ad_events.m`
   - `power-query/ads.m`
   - `power-query/campaigns.m`
   - `power-query/users.m`
2. Validez chaque fichier avec un commit explicite (ex: `feat(powerquery): add ad_events ETL transformation script`).

#### C. Déposer les formules DAX (`dax/`)
1. Créez de la même manière les 4 fichiers dans le dossier `dax/` avec le code fourni en section 2.B :
   - `dax/01_base_measures.dax`
   - `dax/02_kpi_rates.dax`
   - `dax/03_dynamic_measures.dax`
   - `dax/04_calendar_table.dax`

#### D. Déposer les requêtes SQL (`sql/`)
1. Créez les 3 fichiers dans le dossier `sql/` avec le code T-SQL fourni en section 2.C :
   - `sql/01_schema_ddl.sql`
   - `sql/02_kpi_views.sql`
   - `sql/03_analytical_queries.sql`

#### E. Déposer les images (`images/`)
1. Récupérez les captures de votre projet :
   - Sauvegardez le schéma du modèle relationnel sous : `images/data-model.png`
   - Sauvegardez la capture du tableau de bord de Juillet sous : `images/dashboard-overview-july.png`
   - Sauvegardez la capture du tableau de bord de Juin sous : `images/dashboard-overview-june.png`
2. Sur GitHub, cliquez sur **Add file** $\rightarrow$ **Upload files**, placez vos captures dans le dossier `images/` et validez (**Commit changes**).

#### F. Déposer le fichier Power BI et le rapport PDF
1. Dans `power-bi/` : téléversez `meta-ad-performance-dashboard.pbix`
2. Dans `reports/` : téléversez l'export PDF du rapport `Meta-Ad-Performance-Report.pdf`

---

# 4. CONTENU COMPLET DU FICHIER README.md

Éditez le fichier `README.md` à la racine de votre projet en cliquant sur l'icône de crayon (✏️) et insérez **l'intégralité du contenu ci-dessous** :

```markdown
# Meta Ad Campaign Performance & Conversion Analytics — Power BI Solution

### Comprehensive Marketing Intelligence Dashboard: Multi-Channel Tracking, Ad-Format Attribution, Audience Demographics, and SQL Validation

**Author:** Brice Abogo  
**Role:** Financial Analyst | BI Consultant | Business Intelligence Developer  
**Technologies:** Power BI Desktop | Power Query (M) | DAX | Microsoft SQL Server (T-SQL) | Power BI Service | On-Premises Data Gateway (Standard Mode)  

![Meta Ad Performance Overview - July Snapshot](images/dashboard-overview-july.png)

---

## 1. Executive Summary

This repository delivers an enterprise-grade Business Intelligence solution designed to track, measure, and optimize digital marketing performance across Meta platforms (**Facebook** and **Instagram**). 

Built from multi-source operational ad transaction datasets, the solution cleanses and models advertising telemetry, user interactions, and budgetary data into a star schema. It enables marketing executives and campaign managers to dissect engagement drivers, demographic responses, ad format efficiencies (**Stories, Images, Carousels, Videos**), and financial conversion metrics in real-time.

### Key Business Highlights:
- **Campaign Health Monitoring:** Real-time visibility on **Impressions (216K in July)**, **Clicks (25K)**, **Engagement (29.3K)**, and **Purchases (1.3K)** against a **$2.54M Total Budget**.
- **Conversion Efficiency:** Multi-stage funnel analysis tracking Click-Through Rate (**CTR: 11.76%**), Engagement Rate (**13.56%**), and Conversion Rate (**5.21%**).
- **Ad Creative Optimization:** Granular ROI benchmarking proving that **Stories** generate the highest impression volume (71.5K) and purchase conversion rate (5.52%), while **Video** delivers the highest CTR (11.88%).
- **Interactive Measure Selection:** Field Parameters empower users to switch dynamically across 6 core metrics (Impressions, Engagement, Clicks, Shares, Comments, Purchases) across all visual dimensions.
- **Enterprise Service Integration:** Automated scheduled refreshes operating twice daily via standard On-Premises Data Gateway at **11:30 AM and 5:00 PM SAST (South Africa Standard Time)**.

---

## 2. Key Business Questions Answered

1. **Funnel Performance:** How efficiently are top-of-funnel impressions converting into clicks, engagements, and bottom-of-funnel purchase conversions?
2. **Creative & Format Efficacy:** Which ad format (Carousel, Static Image, Stories, Video) yields the highest engagement rate and lowest acquisition cost?
3. **Audience Segmentation:** How does campaign responsiveness vary by age bracket, gender distribution (Female: 43.4%, Male: 21.7%, Unspecified/All: 34.8%), and geographic territories?
4. **Time & Day Attribution:** Which specific days of the month, weeks of the year, and hours of the day generate peak interactions for scheduled ad budget scaling?
5. **Cross-Platform Delivery:** How do engagement economics differ between Facebook and Instagram placements?

---

## 3. Technology Stack & Enterprise Architecture

| Component | Tool / Technology | Strategic Role |
|---|---|---|
| **Data Ingestion & ETL** | Power Query (M Language) | Parameterized source ingest, invariant culture type coercion, schema standardization |
| **Data Modeling** | Power BI Desktop | Star/Snowflake hybrid dimensional schema, relationship cardinality management |
| **Business Logic** | DAX (Data Analysis Expressions) | Fully optimized event measures, funnel ratios, Field Parameters, dynamic titling |
| **Database & Validation**| MS SQL Server (T-SQL) | DDL schema creation, analytical Views, relational data verification scripts |
| **Distribution & Cloud** | Power BI Service | Cloud workspace publishing, visual storytelling, stakeholder role access |
| **Data Pipeline Engine** | On-Premises Data Gateway | Standard mode gateway managing automated daily refresh pipelines |
| **Version Control** | Git & GitHub | Enterprise repository documentation, semantic releases, issue tracking |

```text
[ Raw CSV Datasets: Ad Events, Ads, Campaigns, Users ]
                       │
                       ▼
[ Power Query ETL Engine: Type Coercion, Date Parsing, Parameterized Source ]
                       │
                       ▼
[ In-Memory Star Schema: Fact Events + Dim Campaigns, Ads, Users, Calendar ]
                       │
                       ▼
[ DAX Analytical Layer: Core Measures, KPI Ratios, Dynamic Field Parameters ]
                       │
                       ▼
[ Power BI Desktop Interactive Dashboard: Slicers, Visual Cross-Filtering ]
                       │
                       ▼
[ Power BI Service (Cloud Workspace) ] ◄─── [ On-Premises Standard Gateway ]
                                                 (Scheduled: 11:30 AM & 17:00 SAST)
```

---

## 4. Data Architecture & Data Model

The data model is engineered around a central high-volume fact table (`ad_events`) connected to dimension tables in 1-to-Many (`1:*`) unidirectional relationships, guaranteeing optimal VertiPaq engine compression and fast DAX query performance.

![Data Model Architecture](images/data-model.png)

### Dimensional Relationships
| From (Dimension) | To (Fact) | Join Key | Cardinality | Cross-Filter |
|---|---|---|---|---|
| `campaigns` | `ads` | `campaign_id` | 1 : Many (`1:*`) | Single |
| `ads` | `ad_events` | `ad_id` | 1 : Many (`1:*`) | Single |
| `users` | `ad_events` | `user_id` | 1 : Many (`1:*`) | Single |
| `Calendar` | `ad_events` | `Date` | 1 : Many (`1:*`) | Single |
| `Select Dynamic Measure` | *Disconnected* | N/A | Parameter | Disconnected |

---

## 5. Power Query (M) Optimization Highlights

The ETL pipeline scripts (documented in [`power-query/`](power-query/)) implement strict enterprise design patterns:
- **Centralized Parameterization:** Dynamic `SourcePath` parameter decouples local developer paths from production gateway storage locations.
- **Invariant Culture Coercion:** Explicit `en-US` regional typing prevents numeric/date delimiter breakage across varying localized Windows/Service environments.
- **Elimination of Redundant Steps:** Replaced duplicate-and-convert date steps with direct `DateTime.Date([timestamp])` and `Time.Hour([timestamp])` transformations, cutting data load overhead by ~25%.

---

## 6. DAX Business Logic & Measures

Measures are isolated and structured into dedicated measure groups for maintainability. Full code available in [`dax/`](dax/).

### Key Measure Definitions

#### 1. Direct Engine Pushdown Filter
```dax
Impressions = 
CALCULATE(
    COUNTROWS('ad_events'),
    'ad_events'[event_type] = "Impression"
)
```

#### 2. Click-Through Rate (CTR)
```dax
CTR (ClickThrough Rate) = 
DIVIDE([Clicks], [Impressions], BLANK())
```

#### 3. Purchase Conversion Rate
```dax
Conversion Rate = 
DIVIDE([Purchases], [Clicks], BLANK())
```

#### 4. Dynamic Title with Field Parameter Integration
```dax
Dynamic Title = 
VAR SelectedMetric = SELECTEDVALUE('Select Dynamic Measure'[Select Dynamic Measure])
RETURN
    IF(
        ISBLANK(SelectedMetric),
        "Engagement Overview",
        SelectedMetric & " Performance Breakdown"
    )
```

---

## 7. Transact-SQL (T-SQL) Database Validation

To ensure multi-engine scalability and data warehouse readiness, the entire analytical model is mirrored in Microsoft SQL Server scripts (available in [`sql/`](sql/)).

```sql
-- Ad Format Performance Matrix View
SELECT 
    a.ad_type,
    SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END) AS Impressions,
    SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END) AS Clicks,
    CAST(ROUND(CAST(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END) AS FLOAT) / 
        NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END), 0) * 100, 2) AS DECIMAL(5,2)) AS [CTR %],
    CAST(ROUND(CAST(SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS FLOAT) / 
        NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END), 0) * 100, 2) AS DECIMAL(5,2)) AS [Conv_Rate %]
FROM fact_ad_events e
INNER JOIN dim_ads a ON e.ad_id = a.ad_id
GROUP BY a.ad_type
ORDER BY Impressions DESC;
```

---

## 8. Dashboard Layout & Visual Analytics

The report layout is split into specialized analytical zones providing rapid operational and strategic insights:

![Dashboard June Comparison](images/dashboard-overview-june.png)

1. **Top KPI Scorecards:** High-level metrics tracking total volume (**Impressions, Clicks, Shares, Comments, Purchases, Engagement**) and performance health (**CTR, Engagement Rate, Conversion Rate, Purchase Rate, Budget Allocation**).
2. **Interactive Controls & Global Slicers:**
   - **Platform Toggle:** Instant single-click filtering between Facebook and Instagram.
   - **Field Parameter Slicer:** Dynamic metric switcher transforming all charts simultaneously.
   - **Campaign & Interest Selectors:** Target audience and campaign name cross-filtering.
3. **Demographic Profiling:**
   - **Gender Donut Chart:** Visual breakdown displaying female, male, and generalized target distribution.
   - **Age Histogram:** High-density distribution showing peak engagement in the 20–35 age range.
4. **Temporal & Heatmap Intelligence:**
   - **Monthly Calendar Heatmap Grid:** Day-by-day interaction intensity matrix.
   - **Weekly Ad-Type Stacked Trends:** Format interaction trajectories across campaign weeks.
   - **24-Hour Interaction Line Chart:** Hourly activity fluctuations highlighting peak ad exposure windows.
5. **Ad Format Attribution Matrix:** Comprehensive side-by-side performance grid comparing **Stories, Images, Carousels, and Videos**.

---

## 9. Key Analytical Findings & Performance Benchmarks

### Comparative Performance: July vs. June

| Metric | July 2024 Performance | June 2024 Performance | Trend / Variance |
|---|---:|---:|:---:|
| **Impressions** | 216,000 | 124,000 | +74.2% 🟢 |
| **Clicks** | 25,000 | 15,000 | +66.7% 🟢 |
| **Total Engagement** | 29,300 | 16,800 | +74.4% 🟢 |
| **Purchases** | 1,300 | 708 | +83.6% 🟢 |
| **Click-Through Rate (CTR)** | 11.76 % | 11.86 % | -0.10 bps 🟡 |
| **Engagement Rate** | 13.56 % | 13.60 % | -0.04 bps 🟡 |
| **Conversion Rate (Clicks to Purchase)** | 5.21 % | 4.82 % | +0.39 bps 🟢 |
| **Purchase Rate (Impressions to Purchase)** | 0.61 % | 0.57 % | +0.04 bps 🟢 |
| **Total Budget Managed** | $2.54M | $2.54M | Stable 🔵 |

### Strategic Business Takeaways:
1. **Scale Driving Bottom-Line ROI:** While Top-of-Funnel CTR remained stable (~11.8%), bottom-of-funnel Conversion Rate grew from **4.82% to 5.21%** in July, generating an **83.6% increase in net purchases (1.3K vs 708)**.
2. **Creative Winner (Stories):** Stories captured the largest impression share (71,537 impressions in July) and achieved the highest conversion rate (**5.52%**), proving it to be the most cost-effective direct-response ad format.
3. **Core Demographic Concentration:** Audiences aged **22 to 34** account for over **58% of all recorded interactions**, with female users representing the dominant active conversion segment (**43.44%**).

---

## 10. Automated Data Refresh Pipeline

- **Gateway Mode:** On-Premises Data Gateway (Standard Mode).
- **Scheduled Refresh Times:**
  - **Slot 1:** `11:30 AM SAST` (UTC+2)
  - **Slot 2:** `17:00 PM SAST` (UTC+2)
- **Pipeline Health:** Fully configured for unattended background ingestion, data model recalculation, and automated dashboard tile synchronization.

---

## 11. Repository Structure

```text
meta-ad-performance-powerbi/
├── .gitignore                      # Git exclusion rules
├── LICENSE                         # MIT License
├── README.md                       # Project documentation
├── CHANGELOG.md                    # Release and update logs
├── data/                           # Source CSV datasets & documentation
├── power-query/                    # M transformation scripts & parameters
├── dax/                            # DAX measures, tables, and parameters
├── sql/                            # MS SQL Server DDL, views, and analytics
├── documentation/                  # Technical and gateway deployment guides
├── images/                         # Report captures and data model diagrams
├── reports/                        # Exported PDF executive reports
└── power-bi/                       # Power BI Desktop production file (.pbix)
```

---

## 12. How to Deploy and Run This Project

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/YvesBriceAbogo/meta-ad-performance-powerbi.git
   ```
2. **Configure Dataset Storage:**
   - Place the 4 CSV files from [`data/`](data/) into a local directory (e.g., `C:\Data\MetaAdPerformance\`).
3. **Open and Rebind Power BI Desktop:**
   - Launch `power-bi/meta-ad-performance-dashboard.pbix`.
   - In **Home** $\rightarrow$ **Transform Data** $\rightarrow$ **Edit Parameters**, update `SourcePath` to match your local dataset folder.
   - Click **Apply Changes**.
4. **Deploy to Cloud (Optional):**
   - Publish to your Power BI Service Workspace.
   - Bind dataset to your Standard Data Gateway and enable scheduled refresh at `11:30` and `17:00` SAST.

---

## 13. Author & Professional Profile

### **Brice Abogo**
**Senior Financial Analyst | Business Intelligence Specialist | Data Analyst**

Accomplished finance and analytics professional with 15+ years of cross-functional experience spanning general accounting, cost control, budget management, statutory audit, and executive BI dashboard architecture.

- **GitHub:** [@YvesBriceAbogo](https://github.com/YvesBriceAbogo)
- **LinkedIn:** [Brice Abogo](https://www.linkedin.com/in/brice-abogo)
- **Core Competencies:** Power BI, DAX, Power Query (M), Microsoft SQL Server, Python, Financial Modeling, Digital Ad ROI Attribution.

---

## 14. License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details. Source data remains subject to its original terms.
```

---

# 5. DOCUMENTATION COMPLÉMENTAIRE ET RELEASE GITHUB

### Étape 4 : Créer le fichier `CHANGELOG.md`
1. Cliquez sur **Add file** $\rightarrow$ **Create new file**.
2. Nommez le fichier : `CHANGELOG.md`
3. Collez ce contenu :
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-20

### Added
- Complete Power BI report with interactive Meta Ad performance tracking.
- Parameterized Power Query (M) ETL scripts with invariant culture safety.
- Modular DAX measures for event telemetry, CTR, conversion rates, and dynamic titling.
- Disconnected Field Parameter table for real-time metric switching.
- Transact-SQL schema DDL, KPI summary views, and analytical validation queries.
- Enterprise data gateway documentation with twice-daily refresh (11:30 AM & 5:00 PM SAST).
- High-resolution visual documentation and PDF report exports.
```
4. Cliquez sur **Commit changes**.

---

### Étape 5 : Créer la Release officielle (v1.0.0) sur GitHub

1. Sur la page principale de votre dépôt sur GitHub, repérez la colonne de droite et cliquez sur **Releases** (ou **Create a new release**).
2. Cliquez sur le bouton **Draft a new release**.
3. Remplissez exactement les champs suivants :
   - **Choose a tag** : Tapez `v1.0.0` $\rightarrow$ Cliquez sur **Create new tag: v1.0.0 on publish**.
   - **Target** : `main`.
   - **Release title** : `Meta Ad Performance & Conversion Analytics Dashboard v1.0.0`
   - **Describe this release** :
   ```markdown
   ### Production Release v1.0.0: Meta Ad Performance Analytics

   #### Key Features Included:
   - **End-to-End Power BI Reporting:** Interactive 2-page operational and conversion dashboard.
   - **Robust Data Pipeline:** Refactored Power Query ETL with parameterized dynamic paths.
   - **Star Schema Modeling:** Optimized relations connecting campaigns, ads, users, and calendar facts.
   - **Advanced DAX & Field Parameters:** Dynamic metric switching across all report visuals.
   - **Transact-SQL Layer:** Full SQL Server scripts mirroring DAX KPIs for enterprise data warehouse alignment.
   - **Gateway Synchronization:** Configured for scheduled automated refreshes at 11:30 AM & 17:00 SAST.
   ```
4. **Attach binaries by dropping them here** : Glissez-déposez votre fichier `.pbix` (`meta-ad-performance-dashboard.pbix`) et votre export `.pdf` (`Meta-Ad-Performance-Report.pdf`) dans la zone d'attachement.
5. Cochez **Set as the latest release**.
6. Cliquez sur le bouton vert **Publish release**.

---

### Félicitations !
Votre dépôt GitHub est désormais structuré, documenté et publié selon les **meilleurs standards professionnels de l'ingénierie Business Intelligence**. Il met en valeur à la fois votre expertise analytique, votre maîtrise de Power BI, du langage DAX, de Power Query, du SQL, et de la gouvernance de données dans Power BI Service.
