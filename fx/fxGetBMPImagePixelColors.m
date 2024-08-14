// Get pixel colors from BMP file (binary => table)
// Note: Simplified version that works with square images only (where width = height)
// BMP file format reference: https://en.wikipedia.org/wiki/BMP_file_format
(bmp as binary) =>
let
    // Convert binary data to a hexadecimal string representation
    Source = Binary.ToText(bmp, BinaryEncoding.Hex),

    // Extract the size of the image (width and height in pixels)
    // The size is stored at bytes 18-21 in the BMP header
    _Size = fxHexToDec(Text.Range(Source, 20*2, 2) & Text.Range(Source, 18*2, 2)),

    // Calculate the offset (starting address) where the pixel array begins in the file
    // The offset is stored at bytes 10-13 in the BMP header
    _Offset = fxHexToDec(Text.Range(Source, 10*2+3*2, 2) & Text.Range(Source, 10*2+2*2, 2) & Text.Range(Source, 10*2+1*2, 2) & Text.Range(Source, 10*2+0*2, 2)),

    // Extract the pixel array as a hexadecimal string starting from the calculated offset
    // Each pixel is represented by 3 bytes (6 hex characters), and there are _Size * _Size pixels in total
    #"Extracted Text Range" = Text.Range(Source, _Offset*2, 3*2*_Size*_Size),

    // Convert the extracted pixel data into a table with a single column
    #"Converted to Table" = #table(1, {{#"Extracted Text Range"}}),

    // Split the hexadecimal string into individual pixels (6 hex characters per pixel)
    #"Split Column by Position" = Table.ExpandListColumn(
        Table.TransformColumns(#"Converted to Table", 
        {{"Column1", Splitter.SplitTextByRepeatedLengths(6), let itemType = (type nullable text) meta [Serialized.Text = true] in type {itemType}}}), "Column1"),

    // Rename the column containing pixel data to "Pixel"
    #"Renamed Columns" = Table.RenameColumns(#"Split Column by Position", {{"Column1", "Pixel"}}),

    // Add an index column to keep track of the order of pixels
    #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Index", 0, 1, Int64.Type),

    // Calculate the column index for each pixel (position within the row)
    #"Added Custom" = Table.AddColumn(#"Added Index", "Column", each Number.RoundDown([Index]/_Size, 0)),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom", {{"Column", Int64.Type}}),

    // Calculate the row index for each pixel
    #"Added Custom1" = Table.AddColumn(#"Changed Type", "Row", each [Index] - [Column] * _Size),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom1", {{"Row", Int64.Type}}),

    // Convert pixel color from #BBGGRR format (BMP default) to #RRGGBB format (standard)
    #"Added Custom2" = Table.AddColumn(#"Changed Type1", "Color", each "#" & Text.Middle([Pixel], 4, 2) & Text.Middle([Pixel], 2, 2) & Text.Middle([Pixel], 0, 2)),

    // Remove the original "Pixel" column, retaining only the reformatted "Color" column
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom2", {"Pixel"}),

    // Ensure the "Color" column is treated as text
    #"Changed Type2" = Table.TransformColumnTypes(#"Removed Columns", {{"Color", type text}})
in
    #"Changed Type2"
