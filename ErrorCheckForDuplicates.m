let
    // Input table to check for duplicates. Replace _Source with your actual source table.
    _InputTable = _Source,
    
    // Count the number of rows in the original table.
    _CountRows1 = Table.RowCount(_InputTable),
    
    // Remove duplicate rows based on a specific column. Replace "COLUMN_NAME" with the column you want to check for duplicates.
    #"Removed Duplicates" = Table.Distinct(_InputTable, {"COLUMN_NAME"}),
    
    // Count the number of rows after removing duplicates.
    _CountRows2 = Table.RowCount(#"Removed Duplicates"),
    
    // Define the error to be raised if duplicates are found.
    _Error = 
    error [ 
        Reason = "DuplicateRecords", 
        Message = "Duplicate records", 
        Detail = "Duplicate records found in the data" 
    ],
    
    // Output the original table if no duplicates are found; otherwise, raise the error.
    _Output = if _CountRows2 = _CountRows1 then _InputTable else _Error
in
    _Output
