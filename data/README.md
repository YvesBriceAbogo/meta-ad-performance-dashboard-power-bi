# Data Files

This folder contains the source CSV files used by the Power BI report.

## Files

| File | Description | Rows (approx.) | Columns |
|---|---|---:|---:|
| `ad_events.csv` | Ad interaction events: impressions, clicks, shares, comments, purchases, likes | ~246 000 | 7 |
| `ads.csv` | Ad reference: platform, type, targeting attributes | ~200 | 7 |
| `campaigns.csv` | Campaign reference: name, dates, duration, budget | ~50 | 6 |
| `users.csv` | User demographics: gender, age, country, interests | ~2 000 | 7 |

> Row counts are approximate and based on the dataset used during development.

## Source

These files were obtained from a publicly available source on the internet. The exact origin and original license are **unknown**.

## License Disclaimer

The **MIT license** that covers this repository applies to the **code and documentation only**.

The data files in this folder are **not covered** by the MIT license. They are provided solely for educational and demonstrative purposes. If you are the original author of these data and wish to request removal or proper attribution, please open an issue on this repository.

## Usage

1. Place the four CSV files in a local folder (e.g., `C:\Data\meta-ad-performance\`).
2. Update the `Path` parameter in Power Query to point to that folder.
3. Refresh the data in Power BI Desktop.
