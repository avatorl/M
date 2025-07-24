// Check if the specified column in the InputTable contains duplicate values.
// Returns the InputTable if no duplicates are found; otherwise, raises an error.
(
    InputTable as table,  // Parameter for the input table
    ColumnName as text    // Parameter for the column name to check for duplicates
) =>
let
    // Count the number of rows in the original table
    _CountRows1 = Table.RowCount(InputTable),
    
    // Remove duplicate rows based on the specified column
    #"Removed Duplicates" = Table.Distinct(InputTable, {ColumnName}),
    
    // Count the number of rows after removing duplicates
    _CountRows2 = Table.RowCount(#"Removed Duplicates"),
    
    // Define the error to be raised if duplicates are found
    _Error = 
    error [ 
        Reason = "DuplicateRecords",     
        Message = "Duplicate records", 
        Detail = "Duplicate records found in the data (in column '" & ColumnName & "')"
    ],
    
    // Output the original table if no duplicates are found; otherwise, raise the error
    _Output = if _CountRows2 = _CountRows1 then InputTable else _Error
in
    _Output
