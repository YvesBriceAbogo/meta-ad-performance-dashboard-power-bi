# Gateway and Scheduled Refresh Guide

This guide describes the on-premises data gateway setup and scheduled refresh configuration for this project.

## Architecture

```text
CSV files on local machine
        ↕
On-premises Data Gateway (standard mode)
        ↕
Power BI Service (cloud)
```

## 1. Install the On-Premises Data Gateway

1. Download the gateway installer from [Microsoft's gateway page](https://powerbi.microsoft.com/gateway/).
2. Choose **On-premises data gateway (recommended)** — this is the standard mode.
3. Run the installer and follow the setup wizard.
4. Sign in with the same Microsoft 365 account used for Power BI Service.
5. Name the gateway (e.g., `Gateway-LocalMachine`) and set a recovery key.
6. The gateway registers itself with Power BI Service.

## 2. Configure the Data Source in Power BI Service

1. Go to [app.powerbi.com](https://app.powerbi.com).
2. Click the **Settings** gear icon → **Manage connections and gateways**.
3. Click **+ New** to add a new data source.
4. Select the gateway cluster installed in step 1.
5. Data source type: **File**.
6. Path: the folder path on the local machine (e.g., `C:\Data\meta-ad-performance\`).
7. Authentication method: **Windows** (use the credentials of the local machine user).
8. Click **Create**.

## 3. Map the Dataset to the Gateway

1. In Power BI Service, navigate to the workspace.
2. Find the dataset and click the **three dots (…)** → **Settings**.
3. Expand **Gateway connection**.
4. Select the gateway and map each data source to the configured connection.
5. Click **Apply**.

## 4. Set Up Scheduled Refresh

1. In the same dataset settings page, expand **Scheduled refresh**.
2. Toggle **Keep your data up to date** to **On**.
3. Refresh frequency: **Daily**.
4. Time zone: **UTC+02:00 (South Africa Standard Time)**.
5. Add two time slots:
   - **11:30 AM**
   - **5:00 PM**
6. Click **Apply**.

## 5. Verify

1. Click **Refresh now** to test a manual refresh.
2. After completion, check the **Refresh history** to confirm success.
3. Open the report and verify the data is current.

## Troubleshooting

| Issue | Solution |
|---|---|
| Gateway offline | Ensure the gateway service is running on the local machine (Windows Services → On-premises data gateway service). |
| Credentials error | Re-enter credentials in the data source configuration. |
| File not found | Verify the file path matches the `Path` parameter in Power Query. |
| Refresh fails | Check the refresh history for detailed error messages. |
