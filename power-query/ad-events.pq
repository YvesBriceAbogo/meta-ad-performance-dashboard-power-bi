// =============================================================================
// Table: ad_events
// Description: Imports ad interaction events from CSV and prepares the table
//              for the data model.
// Source file: ad_events.csv
// Dependency: Path parameter (folder path to CSV files)
// =============================================================================

let
    // -------------------------------------------------------------------------
    // Step 1 — Import CSV file using the Path parameter
    // -------------------------------------------------------------------------
    Source = Csv.Document(
        File.Contents(Path & "\ad_events.csv"),
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
    //   - event_id    : whole number (Int64)
    //   - ad_id       : whole number (Int64)
    //   - user_id     : text (kept as text to preserve leading zeros if any)
    //   - timestamp   : datetime
    //   - day_of_week : text
    //   - time_of_day : text
    //   - event_type  : text
    // -------------------------------------------------------------------------
    TypedColumns = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"event_id",    Int64.Type},
            {"ad_id",       Int64.Type},
            {"user_id",     type text},
            {"timestamp",   type datetime},
            {"day_of_week", type text},
            {"time_of_day", type text},
            {"event_type",  type text}
        }
    ),

    // -------------------------------------------------------------------------
    // Step 4 — Extract a Date column from the timestamp
    //   This column is used for the relationship with the Calendar table.
    // -------------------------------------------------------------------------
    AddedDateColumn = Table.AddColumn(
        TypedColumns,
        "Date",
        each DateTime.Date([timestamp]),
        type date
    ),

    // -------------------------------------------------------------------------
    // Step 5 — Extract the hour component for hourly trend analysis
    // -------------------------------------------------------------------------
    AddedHourColumn = Table.AddColumn(
        AddedDateColumn,
        "Event Hour",
        each Time.Hour(DateTime.Time([timestamp])),
        Int64.Type
    )

in
    AddedHourColumn
