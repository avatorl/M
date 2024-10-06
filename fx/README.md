# M language functions for Power Query

### [fxOpenAI.m](https://github.com/avatorl/M/blob/master/fx/fxOpenAI.m)
Call Open AI API from Power Query. Supports structured output. [Read more...](https://www.powerofbi.org/2024/10/06/m-language-function-to-call-open-ai-api-from-power-query/)

### [fxErrorCheckForDuplicates.m](https://github.com/avatorl/M/blob/master/fx/fxErrorCheckForDuplicates.m)
Check if the specified column in the InputTable contains duplicate values. Returns the InputTable if no duplicates are found; otherwise, raises an error. Can be used for data validation.

### [fxGetListOfAllErrReplacements.m](https://github.com/avatorl/M/blob/master/fx/fxGetListOfAllErrReplacements.m)
Build a list of all table columns for Table.ReplaceErrorValues()
Output: {{"Column1", null}, {"Column2", null}}
Usage: Table.ReplaceErrorValues(table as table, errorReplacement as list) as table

### [fxSplitAndProperCaseColumnName.m](https://github.com/avatorl/M/blob/master/fx/fxSplitAndProperCaseColumnName.m)
Function to convert a column name from 'thiIsColumnName' format to 'This Is Column Name' format

### [fxHex2Dec.m](https://github.com/avatorl/M/blob/master/fx/fxHex2Dec.m)
Convert a hexadecimal value (as text) to a decimal value

## Images and Colors

### [fxColorHSVToHSL.m](https://github.com/avatorl/M/blob/master/fx/fxColorHSVToHSL.m)
Convert HSV (Hue, Saturation, Value) color into HSL (Hue, Saturation, Lightness) color

### [fxColorRGBToHSV.m](https://github.com/avatorl/M/blob/master/fx/fxColorRGBToHSV.m)
Convert RGB (Red, Green, Blue) color into HSV (Hue, Saturation, Value) color

### [fxGetBMPImagePixelColors.m](https://github.com/avatorl/M/blob/master/fx/fxGetBMPImagePixelColors.m)
Get pixel colors from BMP file (binary => table)
