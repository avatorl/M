//============================================
// Date Table (Calendar and Fiscal Periods)
// Useful Links:
//   https://gorilla.bi/power-query/create-iso-week-and-iso-year/
//   https://www.sqlbi.com/articles/reference-date-table-in-dax-and-power-bi/
//============================================
let

// CONFIGURATION

    // Start date. Uncomment for manual entry.
    //_Date_Start = #date(2024, 8, 14),
    // End date. Uncomment for manual entry.
    //_Date_End = #date(2024, 8, 14),

    // First day of the week: Day.Monday .. Day.Sunday
    _FirstDayOfWeek = Day.Monday,
    // First month of the fiscal year (numeric)
    _FirstMonthOfFiscalYear = 7,

    // Fact table date column (or any other list of dates)
    Source = Financials[Month],
    // Distinct list of dates, buffered for performance.
    ListDistinct = List.Buffer(List.Distinct(Source)),

    // Start date (from the source). Comment if using manual entry.
    _Date_Start = Date.StartOfYear(List.Min(ListDistinct)),
    // End date (from the source). Comment if using manual entry.
    _Date_End = Date.EndOfYear(List.Max(ListDistinct)),

// END CONFIGURATION    

    // Complete list of dates (All days from January 1st of the first year to December 31st of the last year)
    List_Dates = List.Dates(_Date_Start, Number.From(_Date_End)-Number.From(_Date_Start)+1, #duration(1,0,0,0)),

    // Convert list of dates to a table
    Table_From_List = Table.FromList(List_Dates, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),   
    // Set the data type for the Date column
    Changed_Type_Date = Table.TransformColumnTypes(Table_From_List, {{"Date", type date}}),

    // Add day number (days since midnight of 1989-12-30)
    Add_DayNumber = Table.AddColumn(Changed_Type_Date, "Day Number", each Number.From([Date]), Int64.Type),

    // Add relative day number (days from today)
    Add_RelativeDays = Table.AddColumn(Add_DayNumber, "Relative Days from Today", each Number.From([Date])-Number.From(DateTime.Date(DateTime.FixedLocalNow())), Int64.Type),

    // Add YYYYMMDD integer (e.g., 20240814)
    Add_YYYYMMDD_Number = Table.AddColumn(Add_RelativeDays, "YYYYMMDD Number", each Number.From(Date.ToText([Date], "yyyyMMdd")), Int64.Type),

    // Add day of the year (1..366)
    AddDayOfYear = Table.AddColumn(Add_YYYYMMDD_Number, "Day of Year", each Date.DayOfYear([Date]), Int64.Type),
    // Add day of the month (1..31)
    AddDayOfMonth = Table.AddColumn(AddDayOfYear, "Day of Month", each Date.Day([Date]), Int64.Type),
    // Add year as an integer (e.g., 2024)
    Add_YearNumber = Table.AddColumn(AddDayOfMonth, "Year Number", each Date.Year([Date]), Int64.Type),    
    // Add the first day of the year
    AddYearStart = Table.AddColumn(Add_YearNumber, "Start of Year", each Date.StartOfYear([Date]), type date),
    // Add the last day of the year
    AddYearEnd = Table.AddColumn(AddYearStart, "End of Year", each Date.EndOfYear([Date]), type date),
    // Add year-month (e.g., 2024-08)
    Add_YYYY_MM = Table.AddColumn(AddYearEnd, "YYYY-MM", each Date.ToText([Date], "yyyy-MM"), type text),
    // Add month as an integer (1..12)
    AddMonthNumber = Table.AddColumn(Add_YYYY_MM, "Month Number", each Date.Month([Date]), Int64.Type),
    // Add full month name (e.g., August)
    AddMonthName = Table.AddColumn(AddMonthNumber, "Month Long", each Date.MonthName([Date], "EN-us"), type text),
    // Add short month name (3 characters, e.g., Aug)
    AddMonthNameShort = Table.AddColumn(AddMonthName, "Month Short", each Date.ToText([Date], "MMM", "EN-us"), type text),
    // Add the first day of the month
    AddMonthStart = Table.AddColumn(AddMonthNameShort, "Start of Month", each Date.StartOfMonth([Date]), type date),
    // Add the last day of the month
    AddMonthEnd = Table.AddColumn(AddMonthStart, "End of Month", each Date.EndOfMonth([Date]), type date),
    // Add the number of days in the month
    AddDaysInMonth = Table.AddColumn(AddMonthEnd, "Days in Month", each Date.DaysInMonth([Date]), Int64.Type),
    // Add ISO week number
    AddISOWeek = Table.AddColumn(AddDaysInMonth, "ISO Week Number", each let
        CurrentThursday = Date.AddDays([Date], 3 - Date.DayOfWeek([Date], Day.Monday)),
        YearCurrentThursday = Date.Year(CurrentThursday),
        FirstThursdayOfYear = Date.AddDays(#date(YearCurrentThursday, 1, 7), -Date.DayOfWeek(#date(YearCurrentThursday, 1, 1), Day.Friday)),
        ISOWeek = Duration.Days(CurrentThursday - FirstThursdayOfYear) / 7 + 1
    in ISOWeek, Int64.Type),
    // Add ISO year as an integer
    AddISOYear = Table.AddColumn(AddISOWeek, "ISO Year", each Date.Year(Date.AddDays([Date], 26 - [ISO Week Number])), Int64.Type),
    // Add ISO year and week (e.g., 2024-W33)
    AddISOYear_Week = Table.AddColumn(AddISOYear, "ISO Year-Week", each Text.From([ISO Year]) & "-W" & Number.ToText([ISO Week Number], "00"), type text),
    // Add the first day of the week (based on _FirstDayOfWeek)
    AddWeekStart = Table.AddColumn(AddISOYear_Week, "Start of Week", each Date.StartOfWeek([Date], _FirstDayOfWeek), type date),
    // Add the last day of the week (based on _FirstDayOfWeek)
    AddWeekEnd = Table.AddColumn(AddWeekStart, "End of Week", each Date.EndOfWeek([Date], _FirstDayOfWeek), type date),
    // Add day of the week as an integer (based on _FirstDayOfWeek)
    AddDayOfWeekNumber = Table.AddColumn(AddWeekEnd, "Day of Week Number", each Date.DayOfWeek([Date], _FirstDayOfWeek), Int64.Type),
    // Add a flag for weekends (1 if Saturday or Sunday, else 0)
    AddIsWeekend = Table.AddColumn(AddDayOfWeekNumber, "Is Weekend", each if Date.DayOfWeek([Date], Day.Monday) >= 5 then 1 else 0, Int64.Type),
    // Add a flag for weekdays (1 if Monday-Friday, else 0)
    AddIsWeekday = Table.AddColumn(AddIsWeekend, "Is Weekday", each if Date.DayOfWeek([Date], Day.Monday) < 5 then 1 else 0, Int64.Type),
    // Add week number as an integer
    AddWeekNumber = Table.AddColumn(AddIsWeekday, "Week Number", each Date.WeekOfYear([Date], _FirstDayOfWeek), Int64.Type),
    // Add year-week (e.g., 2024-W33)
    AddYear_Week = Table.AddColumn(AddWeekNumber, "Year-Week", each Text.From([Year Number]) & "-W" & Number.ToText([Week Number], "00"), type text),
    // Add full day of the week name (e.g., Wednesday)
    AddDayOfWeekLong = Table.AddColumn(AddYear_Week, "Day of Week Long", each Date.DayOfWeekName([Date], "EN-us"), type text),
    // Add short day of the week name (3 characters, e.g., Wed)
    AddDayOfWeekShort3 = Table.AddColumn(AddDayOfWeekLong, "Day of Week Short 3", each Date.ToText([Date], "ddd", "EN-us"), type text),
    // Add 2-character day of the week name (e.g., We)
    AddDayOfWeekShort2 = Table.AddColumn(AddDayOfWeekShort3, "Day of Week Short 2", each Text.Start([Day of Week Short 3], 2), type text),
    // Add quarter number as an integer (1..4)
    AddQuarterNumber = Table.AddColumn(AddDayOfWeekShort2, "Quarter Number", each Date.QuarterOfYear([Date]), Int64.Type),
    // Add quarter (e.g., Q3)
    AddQuarter = Table.AddColumn(AddQuarterNumber, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    // Add year and quarter (e.g., 2024-Q3)
    AddYearQuarter = Table.AddColumn(AddQuarter, "Year-Quarter", each Text.From(Date.Year([Date])) & "-Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    // Add fiscal year (e.g., FY2025). Adjust _FirstMonthOfFiscalYear to change the first month of the fiscal year.
    AddFY_YYYY = Table.AddColumn(AddYearQuarter, "FY-YYYY", each "FY-" & Date.ToText(Date.AddMonths(#date(Date.Year([Date]) + 1, Date.Month([Date]), 1), -_FirstMonthOfFiscalYear + 1), "yyyy", "EN-us"), type text),
    // Add fiscal year (e.g., FY25). Adjust _FirstMonthOfFiscalYear to change the first month of the fiscal year.
    AddFY_YY = Table.AddColumn(AddFY_YYYY, "FY-YY", each "FY-" & Date.ToText(Date.AddMonths(#date(Date.Year([Date]) + 1, Date.Month([Date]), 1), -_FirstMonthOfFiscalYear + 1), "yy", "EN-us"), type text),
    // Add fiscal month number. Adjust _FirstMonthOfFiscalYear to change the first month of the fiscal year.
    AddFiscalMonthNumber = Table.AddColumn(AddFY_YY, "Fiscal Month Number", each if [Month Number] >= _FirstMonthOfFiscalYear then [Month Number] - _FirstMonthOfFiscalYear + 1 else [Month Number] + _FirstMonthOfFiscalYear - 1, Int64.Type)

in
    AddFiscalMonthNumber
