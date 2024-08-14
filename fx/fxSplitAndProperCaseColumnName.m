// Function to convert a column name from 'thiIsColumnName' format to 'This Is Column Name' format
= (_ColumnName as text) =>

let
    // Convert the column name string into a list of individual characters
    #"Added Custom" = Text.ToList(_ColumnName),
    
    // Convert the list of characters into a table format
    #"Converted to Table" = Table.FromList(#"Added Custom", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    
    // Rename the single column of the table to 'ListOfCharacters' for clarity
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table", {{"Column1", "ListOfCharacters"}}),
    
    // Add a new column 'Numbers' containing the ASCII number for each character
    #"Added Custom1" = Table.AddColumn(#"Renamed Columns", "Numbers", each Character.ToNumber([ListOfCharacters])),
    
    // Add a new column 'NewCharacter', prefixing uppercase letters with a '/'
    // This step helps in identifying word boundaries by detecting capital letters
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "NewCharacter", each (if [Numbers] > 64 and [Numbers] < 91 then "/" else "") & Character.FromNumber([Numbers])),
    
    // Remove unnecessary columns to keep only 'NewCharacter'
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom2", {"ListOfCharacters", "Numbers"}),
    
    // Add a constant column 'One' with value 1 to use for grouping in the next step
    #"Added Custom3" = Table.AddColumn(#"Removed Columns", "One", each 1),
    
    // Group the rows to concatenate the 'NewCharacter' column into a single text string
    #"Grouped Rows" = Table.Group(#"Added Custom3", {"One"}, {{"NewName", each Text.Combine([NewCharacter]), type text}}),
    
    // Replace the '/' characters (used to mark word boundaries) with spaces
    #"Replaced Value" = Table.ReplaceValue(#"Grouped Rows", "/", " ", Replacer.ReplaceText, {"NewName"}),
    
    // Capitalize the first letter of each word in the newly formed name
    #"Capitalized Each Word" = Table.TransformColumns(#"Replaced Value", {{"NewName", Text.Proper, type text}}),
    
    // Extract the final column name from the table and return it
    NewName = Table.RemoveColumns(#"Capitalized Each Word", {"One"})[NewName]{0}
in
    NewName
