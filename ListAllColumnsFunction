//List All table columns
//To be used with Table.TransformColumns

_ColumnNames = Table.ColumnNames(Source),
_ColumnCount = List.Count(_ColumnNames),
_AllColumnsFunctionType = Table.ToRows(Table.FromColumns({_ColumnNames, List.Repeat({Text.Trim}, _ColumnCount ), List.Repeat({type text}, _ColumnCount )}))

   FilterNullAndWhitespace = each List.Select(_, each _ <> null and (not (_ is text) or Text.Trim(_) <> "")),
    #"Removed Blank Columns" = Table.SelectColumns(#"PME ARC Maintained_sheet", List.Select(Table.ColumnNames(#"PME ARC Maintained_sheet"), each try not List.IsEmpty(FilterNullAndWhitespace(Table.Column(#"PME ARC Maintained_sheet", _))) otherwise true)),
    #"Removed Blank Rows" = Table.SelectRows(#"Removed Blank Columns", each not List.IsEmpty(FilterNullAndWhitespace(Record.FieldValues(_)))),

//remove all blank columns and rows, convert all columns to text, trim and clean all columns
    _ColumnNames = Table.ColumnNames(#"Removed Blank Rows"),
    _ColumnCount = List.Count(_ColumnNames),
    _AllColumnsTypeText = Table.ToRows(Table.FromColumns({_ColumnNames, List.Repeat({type text}, _ColumnCount )})),
    _AllColumnsTextTrim = Table.ToRows(Table.FromColumns({_ColumnNames, List.Repeat({Text.Trim}, _ColumnCount ), List.Repeat({type text}, _ColumnCount )})),
    _AllColumnsTextClean = Table.ToRows(Table.FromColumns({_ColumnNames, List.Repeat({Text.Clean}, _ColumnCount ), List.Repeat({type text}, _ColumnCount )})),
    #"Changed Type1" = Table.TransformColumnTypes( #"Removed Blank Rows", _AllColumnsTypeText) ,
    #"Trimmed Text" = Table.TransformColumns( #"Changed Type1", _AllColumnsTextTrim ),
    #"Cleaned Text" = Table.TransformColumns( #"Trimmed Text", _AllColumnsTextClean ),
