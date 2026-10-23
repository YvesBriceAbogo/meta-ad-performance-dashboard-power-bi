// =============================================================================
// Table: campaigns
// Description: Imports the campaigns reference table from CSV.
//              Handles decimal separator conversion for the budget column.
// Source file: campaigns.csv
// Dependency: Path parameter (folder path to CSV files)
// =============================================================================

let
    // -------------------------------------------------------------------------
    // Step 1 — Import CSV file using the Path parameter
    // -------------------------------------------------------------------------
    Source = Csv.Document(
        File.Contents(Path & "\campaigns.csv"),
        [
            Delimiter  = ",",
            Columns    = 6,
            Encoding   = 1252,
            QuoteStyle = QuoteStyle.None
        ]
    ),

    // -------------------------------------------------------------------------
    // Step 2 — Promote first row to column headers
    // -------------------------------------------------------------------------
    PromotedHeaders = Table.PromoteHeaders(
        Source,
        [PromoteAllScalars = true]
    ),

    // -------------------------------------------------------------------------
    // Step 3 — Set initial column data types
    //   - total_budget is typed as text first because the decimal separator
    //     needs to be converted before casting to number.
    // -------------------------------------------------------------------------
    InitialTypes = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"campaign_id",   Int64.Type},
            {"name",          type text},
            {"start_date",    type date},
            {"end_date",      type date},
            {"duration_days", Int64.Type},
            {"total_budget",  type text}
        }
    ),

    // -------------------------------------------------------------------------
    // Step 4 — Replace decimal separator in total_budget ("." → ",")
    //   This ensures correct number parsing on systems using comma as
    //   the decimal separator.
    // -------------------------------------------------------------------------
    FixedDecimalSeparator = Table.ReplaceValue(
        InitialTypes,
        ".",
        ",",
        Replacer.ReplaceText,
        {"total_budget"}
    ),

    // -------------------------------------------------------------------------
    // Step 5 — Cast total_budget to number after decimal fix
    // -------------------------------------------------------------------------
    FinalTypes = Table.TransformColumnTypes(
        FixedDecimalSeparator,
        {{"total_budget", type number}}
    )

in
    FinalTypes
