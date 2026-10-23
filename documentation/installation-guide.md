# Installation Guide

## Prerequisites

- **Power BI Desktop** (latest version recommended).
- Windows operating system (Power BI Desktop is Windows-only).
- Approximately 100 MB of disk space for the CSV files and the .pbix file.

## Steps

### 1. Download the Repository

1. On the GitHub repository page, click **Code** → **Download ZIP**.
2. Extract the ZIP file to a location of your choice.

### 2. Place the Data Files

1. Create the folder `C:\Data\meta-ad-performance\` (or any folder you prefer).
2. Copy the four CSV files from the `data/` folder of the extracted repository into this folder:
   - `ad_events.csv`
   - `ads.csv`
   - `campaigns.csv`
   - `users.csv`

### 3. Open the Report

1. Navigate to the `power-bi/` folder in the extracted repository.
2. Double-click `meta-ad-performance-dashboard.pbix` to open it in Power BI Desktop.

### 4. Update the Path Parameter (if necessary)

If you placed the CSV files in a folder other than `C:\Data\meta-ad-performance\`:

1. In Power BI Desktop, click **Home → Transform Data**.
2. In Power Query Editor, click **Manage Parameters** in the ribbon.
3. Update the `Path` parameter to match your folder path (without trailing backslash).
4. Click **OK**, then **Close & Apply**.

### 5. Verify the Data

After the data loads, verify these control values:

| Metric | Expected Value |
|---|---:|
| Impressions | ~216K |
| Clicks | ~25K |
| Engagement | ~29.3K |
| Total Budget | ~2.54M |
| Avg Budget per Campaign | ~50.72K |
| CTR | ~11.76% |

> Values are approximate and may vary slightly depending on the exact dataset version.

### 6. Explore the Report

- **Page 1 — Facebook:** shows all KPIs and breakdowns for the Facebook platform.
- **Page 2 — Instagram:** shows the same layout filtered on Instagram.
- Use the **Select Dynamic Measure** slicer to change the measure displayed in the dynamic visuals.
- Use **Campaign Name** and **Target Interest** slicers to drill down.
- Use the **Month Name** slicer in the calendar matrix to change the displayed month.
