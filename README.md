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
