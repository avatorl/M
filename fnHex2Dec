//convert hex value (text) to dec value
let Hex2Dec = (input as text) =>

let
convertHexDigit = (digit) =>
let
values = {
{"0", 0},
{"1", 1},
{"2", 2},
{"3", 3},
{"4", 4},
{"5", 5},
{"6", 6},
{"7", 7},
{"8", 8},
{"9", 9},
{"A", 10},
{"B", 11},
{"C", 12},
{"D", 13},
{"E", 14},
{"F", 15}
},
Result = Value.ReplaceType(
{List.First(List.Select(values, each _{0} = digit)){1}},
type {number}
)
in
Result,

Reverse = List.Reverse(Text.ToList(Text.Upper(input))),
noDigits = List.Numbers(0, List.Count(Reverse)),
DecimalValues = List.Transform(noDigits, each List.First(convertHexDigit(Reverse{_})) * Number.Power(16, _)),
Return = List.Sum(DecimalValues)
in
Return

in
Hex2Dec
