# Publishing Guide — Power BI Service

This guide describes how the report was published to Power BI Service.

## Prerequisites

- A Power BI Pro or Premium Per User (PPU) license.
- Power BI Desktop with the report file open.
- An active internet connection.

## Steps

### 1. Sign In

1. In Power BI Desktop, click **Home → Publish**.
2. If not already signed in, enter your Microsoft 365 credentials.

### 2. Select a Workspace

1. In the dialog, select the target workspace (e.g., "My Workspace" or a dedicated workspace).
2. Click **Select**.

### 3. Wait for Publication

1. Power BI Desktop uploads the report and dataset to the service.
2. A confirmation message appears with a link to open the report in Power BI Service.

### 4. Verify

1. Click the link or navigate to [app.powerbi.com](https://app.powerbi.com).
2. Open the workspace and confirm both the **report** and the **dataset** are present.
3. Open the report and verify that all visuals render correctly.

## Notes

- Each time you click **Publish**, the existing report and dataset in the workspace are replaced.
- If the report uses a local data source (CSV files), a gateway must be configured before scheduled refresh can work. See [Gateway and Refresh Guide](gateway-and-refresh-guide.md).
