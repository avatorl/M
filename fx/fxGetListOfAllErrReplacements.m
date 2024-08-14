// Build a list of all table columns for Table.ReplaceErrorValues()
// Output: {{"Column1", null}, {"Column2", null}}

let 
    // Function to generate the list of column names paired with null values for error replacement
    GetListOfAllErrReplacements = (_table as table) =>
    let
        // Get the list of all column names in the input table
        _AllColumns = Table.ColumnNames(_table),

        // Convert the list of column names into a single-column table
        #"Converted to Table" = Table.FromList(_AllColumns, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

        // Add a new column with null values, corresponding to each column name
        #"Added Custom1" = Table.AddColumn(#"Converted to Table", "Custom1", each null),

        // Combine each column name and its corresponding null value into a list (e.g., {"Column1", null})
        #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Custom2", each {[Column1], [Custom1]}),

        // Remove the intermediate columns, leaving only the combined column-name-null-value pairs
        #"Removed Columns" = Table.RemoveColumns(#"Added Custom2", {"Column1", "Custom1"}),

        // Extract the list of all column-name-null-value pairs
        _ListOfAllReplacements = #"Removed Columns"[Custom2]
    in 
        _ListOfAllReplacements
in
    GetListOfAllErrReplacements
