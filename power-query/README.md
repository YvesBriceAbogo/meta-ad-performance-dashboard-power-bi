# Power Query Scripts

This folder contains the M (Power Query) scripts for each table in the data model.

## Parameter

All scripts reference a `Path` parameter that stores the folder path to the CSV files.
Set this parameter in Power BI Desktop under **Home → Manage Parameters**.

**Default value:** `C:\Data\meta-ad-performance`

## Scripts

| File | Target Table | Description |
|---|---|---|
| `ad-events.m` | `ad_events` | Imports ad interaction events, promotes headers, types columns, extracts Date and Event Hour from timestamp |
| `ads.m` | `ads` | Imports ad reference data, promotes headers, types columns |
| `campaigns.m` | `campaigns` | Imports campaign data, fixes decimal separator, types budget as number |
| `users.m` | `users` | Imports user demographics, promotes headers, types columns |

## How to Apply

1. Open the `.pbix` file in Power BI Desktop.
2. Go to **Home → Transform Data** to open Power Query Editor.
3. Select a table in the left panel.
4. Click **View → Advanced Editor**.
5. Replace the existing code with the corresponding `.m` script from this folder.
6. Click **Done**, then **Close & Apply**.
