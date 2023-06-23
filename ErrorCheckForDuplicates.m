    //Chech if there are duplicate rows in the table. Return Error if any
    _InputTable = #"Removed Other Columns",
    _CountRows1 = Table.RowCount(_InputTable),
    #"Removed Duplicates" = Table.Distinct(#"Previous Step", {"COLUMN_NAME"}),
    _CountRows2 = Table.RowCount(#"Removed Duplicates"),
    _Error = 
    error [ 
        Reason = "DuplicateRecords", 
        Message = "Duplicate records", 
        Detail = "Duplicate records found in the data" 
    ],
    _Output = if _CountRows2 = _CountRows1 then _InputTable else _Error,
