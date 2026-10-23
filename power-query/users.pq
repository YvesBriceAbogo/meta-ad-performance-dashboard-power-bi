// =============================================================================
// Table: users
// Description: Imports the users demographics table from CSV.
// Source file: users.csv
// Dependency: Path parameter (folder path to CSV files)
// =============================================================================

let
    // -------------------------------------------------------------------------
    // Step 1 — Import CSV file using the Path parameter
    // -------------------------------------------------------------------------
    Source = Csv.Document(
        File.Contents(Path & "\users.csv"),
        [
            Delimiter  = ",",
            Columns    = 7,
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
    // Step 3 — Set column data types
    //   - user_id     : text (preserved as text for join consistency)
    //   - user_gender : text (Male, Female, All)
    //   - user_age    : whole number (Int64)
    //   - age_group   : text
    //   - country     : text
    //   - location    : text
    //   - interests   : text
    // -------------------------------------------------------------------------
    TypedColumns = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"user_id",     type text},
            {"user_gender", type text},
            {"user_age",    Int64.Type},
            {"age_group",   type text},
            {"country",     type text},
            {"location",    type text},
            {"interests",   type text}
        }
    )

in
    TypedColumns
