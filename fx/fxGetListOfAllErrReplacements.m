// Build a list of all table columns for Table.ReplaceErrorValues()
// Output: {{"Column1", null}, {"Column2", null}}
// Usage: Table.ReplaceErrorValues(table as table, errorReplacement as list) as table

let 
    // Function to generate the list of column names paired with null values for error replacement
    ErrorReplacement = (_table as table) =>
    let
        // Get the list of all column names in the input table
        _AllColumns = Table.ColumnNames(_table),

        // Convert the list of column names into a single-column table
        #"Converted to Table" = Table.FromList(_AllColumns, Splitter.SplitByNothing(), {"ColumnName"}),

        // Add a new column with null values, corresponding to each column name
        #"Added Null Column" = Table.AddColumn(#"Converted to Table", "NullValue", each null),

        // Combine each column name and its corresponding null value into a list (e.g., {"Column1", null})
        #"Combined Columns" = Table.AddColumn(#"Added Null Column", "Replacement", each {[ColumnName], [NullValue]}),

        // Remove the intermediate columns, leaving only the combined column-name-null-value pairs
        #"Removed Intermediate Columns" = Table.RemoveColumns(#"Combined Columns", {"ColumnName", "NullValue"}),

        // Extract the list of all column-name-null-value pairs
        _ListOfAllReplacements = #"Removed Intermediate Columns"[Replacement]
    in 
        _ListOfAllReplacements
in
    ErrorReplacement
