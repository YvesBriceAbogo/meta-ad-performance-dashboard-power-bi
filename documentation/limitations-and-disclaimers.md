# Limitations and Disclaimers

## Data Limitations

1. **Unknown data source.** The CSV files were obtained from a publicly available source on the internet. The exact origin and original license are unknown.
2. **Likely synthetic data.** The data patterns suggest the dataset is synthetic (generated for educational purposes). Findings should not be interpreted as real-world business results.
3. **Limited time range.** The data covers approximately two months (June–July). No year-over-year comparison is possible.
4. **"All" gender category.** Some users and targeting records have gender set to "All". It is unclear whether this represents missing data, non-binary identity, or a broad targeting choice.
5. **Budget granularity.** Budget figures are available at the campaign level only. There is no cost-per-event or cost-per-click data, so ROI calculations are not possible at the ad level.

## Technical Limitations

6. **No real-time refresh.** The scheduled refresh runs twice daily (11:30 AM and 5:00 PM, South Africa time). Data is not updated in real time.
7. **Local file dependency.** The data source is local CSV files accessed via an on-premises gateway. If the gateway machine is offline, refresh will fail.
8. **No row-level security.** The report does not implement RLS. All users with access see the same data.
9. **Field parameter limitation.** The dynamic measure slicer controls only the visuals configured to use the field parameter. KPI cards display fixed measures.

## Disclaimers

10. **Educational purpose.** This project is created for portfolio demonstration and educational purposes. It is not intended for commercial use.
11. **No warranty.** The analysis is provided "as is" without any warranty of accuracy or completeness.
12. **Data licensing.** The MIT license applies to the code and documentation only. The data files are not covered. See [`data/README.md`](../data/README.md).
