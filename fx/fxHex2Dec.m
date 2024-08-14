// Convert a hexadecimal value (as text) to a decimal value
let 
    Hex2Dec = (input as text) =>

    let
        // Function to convert a single hex digit (0-9, A-F) to its decimal equivalent
        convertHexDigit = (digit) =>
        let
            // Mapping of hex digits to their corresponding decimal values
            values = {
                {"0", 0}, {"1", 1}, {"2", 2}, {"3", 3}, {"4", 4}, {"5", 5}, {"6", 6},
                {"7", 7}, {"8", 8}, {"9", 9}, {"A", 10}, {"B", 11}, {"C", 12}, 
                {"D", 13}, {"E", 14}, {"F", 15}
            },

            // Select the decimal value that corresponds to the input hex digit
            Result = Value.ReplaceType(
                {List.First(List.Select(values, each _{0} = digit)){1}},
                type {number}
            )
        in
            Result,

        // Convert the input hex string to uppercase and reverse it for easier processing
        Reverse = List.Reverse(Text.ToList(Text.Upper(input))),

        // Generate a list of numbers representing the position of each hex digit (0, 1, 2, ...)
        noDigits = List.Numbers(0, List.Count(Reverse)),

        // Convert each hex digit to decimal and multiply by the appropriate power of 16
        DecimalValues = List.Transform(noDigits, each List.First(convertHexDigit(Reverse{_})) * Number.Power(16, _)),

        // Sum all the decimal values to get the final result
        Return = List.Sum(DecimalValues)
    in
        Return

in
    Hex2Dec
