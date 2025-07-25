(
    InputTable as table,
    // Parameter for the input table
    ColumnName as text,
    // Parameter for the column name to check for duplicates
    optional ErrorDetail as text
    // Additional custom error details
) =>
    let
        // Count the number of rows in the original table
        _CountRows1 = Table.RowCount(InputTable),
        _ErrorDetail = if ErrorDetail = null then "" else ErrorDetail,
        // Remove duplicate rows based on the specified column
        Removed_Duplicates = Table.Distinct(InputTable, {ColumnName}),
        // Count the number of rows after removing duplicates
        _CountRows2 = Table.RowCount(Removed_Duplicates),
        // Define the error to be raised if duplicates are found
        _Error = error
            [
                Reason = "DuplicateRecords",
                Message = "Duplicate Records Found",
                Detail = "Duplicate records found in the data (in column '" & ColumnName & "')." & " " & _ErrorDetail
            ],
        // Output the original table if no duplicates are found; otherwise, raise the error
        _Output = if _CountRows2 = _CountRows1 then InputTable else _Error
    in
        _Output
