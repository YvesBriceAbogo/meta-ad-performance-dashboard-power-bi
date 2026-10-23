// =============================================================================
// Table: ads
// Description: Imports the ads reference table from CSV.
// Source file: ads.csv
// Dependency: Path parameter (folder path to CSV files)
// =============================================================================

let
    // -------------------------------------------------------------------------
    // Step 1 — Import CSV file using the Path parameter
    // -------------------------------------------------------------------------
    Source = Csv.Document(
        File.Contents(Path & "\ads.csv"),
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
    //   - ad_id            : whole number (Int64)
    //   - campaign_id      : whole number (Int64)
    //   - ad_platform      : text (Facebook, Instagram)
    //   - ad_type          : text (Carousel, Image, Stories, Video)
    //   - target_gender    : text
    //   - target_age_group : text
    //   - target_interests : text
    // -------------------------------------------------------------------------
    TypedColumns = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"ad_id",            Int64.Type},
            {"campaign_id",      Int64.Type},
            {"ad_platform",      type text},
            {"ad_type",          type text},
            {"target_gender",    type text},
            {"target_age_group", type text},
            {"target_interests", type text}
        }
    )

in
    TypedColumns
