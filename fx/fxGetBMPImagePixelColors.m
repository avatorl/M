//Get pixel colors from BMP file (binary => table)
//Note: simplified version, works with square images only (width = height)
//BMP file format: https://en.wikipedia.org/wiki/BMP_file_format
(bmp as binary) =>
let
    //binary => HEX
    Source = Binary.ToText(bmp,BinaryEncoding.Hex),
    //size (width and height in pixels)
    _Size = fxHexToDec(Text.Range(Source, 20*2, 2)&Text.Range(Source, 18*2, 2)),
    //starting address, of the byte where the bitmap image data (pixel array) can be found
    _Offset = fxHexToDec(Text.Range(Source, 10*2+3*2, 2)&Text.Range(Source, 10*2+2*2, 2)&Text.Range(Source, 10*2+1*2, 2)&Text.Range(Source, 10*2+0*2, 2)),
    //extract pixel array
    #"Extracted Text Range" = Text.Range(Source, _Offset*2, 3*2*_Size*_Size),
    #"Converted to Table" = #table(1, {{#"Extracted Text Range"}}),
    #"Split Column by Position" = Table.ExpandListColumn(Table.TransformColumns(#"Converted to Table", {{"Column1", Splitter.SplitTextByRepeatedLengths(6), let itemType = (type nullable text) meta [Serialized.Text = true] in type {itemType}}}), "Column1"),
    #"Renamed Columns" = Table.RenameColumns(#"Split Column by Position",{{"Column1", "Pixel"}}),
    #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Index", 0, 1, Int64.Type),
    //add column id
    #"Added Custom" = Table.AddColumn(#"Added Index", "Column", each Number.RoundDown([Index]/_Size,0)),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"Column", Int64.Type}}),
    //add row id
    #"Added Custom1" = Table.AddColumn(#"Changed Type", "Row", each [Index]-[Column]*_Size),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom1",{{"Row", Int64.Type}}),
    //#BBGGRR => #RRGGBB
    #"Added Custom2" = Table.AddColumn(#"Changed Type1", "Color", each "#"&Text.Middle([Pixel],4,2)&Text.Middle([Pixel],2,2)&Text.Middle([Pixel],0,2)),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom2",{"Pixel"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Removed Columns",{{"Color", type text}})
in
    #"Changed Type2"
