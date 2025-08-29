//============================================
// Date Table (Calendar and Fiscal Periods)
// Useful Links:
//      https://gorilla.bi/power-query/create-iso-week-and-iso-year/
//      https://www.sqlbi.com/articles/reference-date-table-in-dax-and-power-bi/
//      https://radacad.com/power-bi-date-or-calendar-table-best-method-dax-or-power-query
//      https://www.linkedin.com/posts/brianjuliusdc_stop-using-janky-black-box-dax-functions-activity-7083649958771347456-pUoN/
//============================================
let
    // CONFIGURATION
    // Choose between MANUAL ENTRY or PERIOD FROM DATA TABLES by uncommenting the appropriate section
    // MANUAL ENTRY PERIOD
    // Uncomment the following lines to manually set the start and end dates for the period
    // Start date (manually entered)
    _Date_Start = #date(2022, 1, 1),
    // End date (manually entered)
    _Date_End = #date(2025, 12, 31),
    // PERIOD FROM DATA TABLES
    // Uncomment the following lines if you want the period to be dynamically calculated based on the data in your tables
    // Fact table date column (replace Financials[Month] with your actual date column)
    //Source = Financials[Month],
    //Buffer the list of distinct dates for performance improvement
    //ListDistinct = List.Buffer(List.Distinct(Source)),
    // Start date (calculated from the minimum date in the data)
    //_Date_Start = Date.StartOfYear(List.Min(ListDistinct)),
    // End date (calculated from the maximum date in the data)
    //_Date_End = Date.EndOfYear(List.Max(ListDistinct)),
    // OTHER SETTINGS
    // First day of the week (set to Monday by default, can be changed to any day: Day.Monday to Day.Sunday)
    _FirstDayOfWeek = Day.Monday,
    // First month of the fiscal year (set to July by default, can be changed to any month, 1 = January, 12 = December)
    _FirstMonthOfFiscalYear = 7,
    // Today
    _Today = DateTime.Date(DateTime.FixedLocalNow()),
    // END CONFIGURATION
    // Complete list of dates (All days from January 1st of the first year to December 31st of the last year)
    List_Dates = List.Dates(_Date_Start, Number.From(_Date_End) - Number.From(_Date_Start) + 1, #duration(1, 0, 0, 0)),
    // Convert list of dates to a table
    Table_From_List = Table.FromList(List_Dates, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    // Set the data type for the Date column
    Changed_Type_Date = Table.TransformColumnTypes(Table_From_List, {{"Date", type date}}),
    // Add day number (days since 1989-12-30)
    Add_DayNumber = Table.AddColumn(Changed_Type_Date, "Days since 1899-12-30", each Number.From([Date]), Int64.Type),
    // Add relative day number (days from today)
    Add_RelativeDays = Table.AddColumn(
        Add_DayNumber, "Offset Days", each Number.From([Date]) - Number.From(_Today), Int64.Type
    ),
    // Add YYYYMMDD as an integer (e.g., 20240814)
    Add_YYYYMMDD_Number = Table.AddColumn(
        Add_RelativeDays, "YYYYMMDD Number", each Number.From(Date.ToText([Date], "yyyyMMdd")), Int64.Type
    ),
    // Add YYYY-MM-DD as text (e.g., 2024-08-14)
    Add_YYYYMMDD = Table.AddColumn(Add_YYYYMMDD_Number, "YYYY-MM-DD", each Date.ToText([Date], "yyyy-MM-dd"), type text),
    // Add day of the year (1..366)
    AddDayOfYear = Table.AddColumn(Add_YYYYMMDD, "Day of Year", each Date.DayOfYear([Date]), Int64.Type),
    // Add day of the month (1..31)
    AddDayOfMonth = Table.AddColumn(AddDayOfYear, "Day of Month", each Date.Day([Date]), Int64.Type),
    // Add year as an integer (e.g., 2024)
    Add_YearNumber = Table.AddColumn(AddDayOfMonth, "Year", each Date.Year([Date]), Int64.Type),
    // Add the first day of the year
    AddYearStart = Table.AddColumn(Add_YearNumber, "Start of Year", each Date.StartOfYear([Date]), type date),
    // Add the last day of the year
    AddYearEnd = Table.AddColumn(AddYearStart, "End of Year", each Date.EndOfYear([Date]), type date),
    // Add year-month number (e.g., 202408)
    Add_YYYY_MM_Number = Table.AddColumn(
        AddYearEnd, "YYYYMM Number", each Date.Year([Date]) * 100 + Date.Month([Date]), Int64.Type
    ),
    // Add year-month (e.g., 2024-08)
    Add_YYYY_MM = Table.AddColumn(Add_YYYY_MM_Number, "YYYY-MM", each Date.ToText([Date], "yyyy-MM"), type text),
    // Add month as an integer (1..12)
    AddMonthNumber = Table.AddColumn(Add_YYYY_MM, "Month Number", each Date.Month([Date]), Int64.Type),
    // Add full month name (e.g., August)
    AddMonthName = Table.AddColumn(AddMonthNumber, "Month Long", each Date.MonthName([Date], "EN-us"), type text),
    // Add short month name (e.g., Aug)
    AddMonthNameShort = Table.AddColumn(
        AddMonthName, "Month Short", each Date.ToText([Date], "MMM", "EN-us"), type text
    ),
    // Add the first day of the month
    AddMonthStart = Table.AddColumn(AddMonthNameShort, "Start of Month", each Date.StartOfMonth([Date]), type date),
    // Add the last day of the month
    AddMonthEnd = Table.AddColumn(AddMonthStart, "End of Month", each Date.EndOfMonth([Date]), type date),
    // Add number of days in the month
    AddDaysInMonth = Table.AddColumn(AddMonthEnd, "Days in Month", each Date.DaysInMonth([Date]), Int64.Type),
    // Add ISO week number
    AddISOWeek = Table.AddColumn(
        AddDaysInMonth,
        "ISO Week Number",
        each
            let
                CurrentThursday = Date.AddDays([Date], 3 - Date.DayOfWeek([Date], Day.Monday)),
                YearCurrentThursday = Date.Year(CurrentThursday),
                FirstThursdayOfYear = Date.AddDays(
                    #date(YearCurrentThursday, 1, 7), -Date.DayOfWeek(#date(YearCurrentThursday, 1, 1), Day.Friday)
                ),
                ISOWeek = Duration.Days(CurrentThursday - FirstThursdayOfYear) / 7 + 1
            in
                ISOWeek,
        Int64.Type
    ),
    // Add ISO year (integer)
    AddISOYear = Table.AddColumn(
        AddISOWeek, "ISO Year", each Date.Year(Date.AddDays([Date], 26 - [ISO Week Number])), Int64.Type
    ),
    // Add ISO year and week (number) (e.g., 202433)
    AddISOYear_WeekNumber = Table.AddColumn(
        AddISOYear, "ISO Year-Week Number", each [ISO Year] * 100 + [ISO Week Number], Int64.Type
    ),
    // Add ISO year and week (e.g., 2024-W33)
    AddISOYear_Week = Table.AddColumn(
        AddISOYear_WeekNumber,
        "ISO Year-Week",
        each Text.From([ISO Year]) & "-W" & Number.ToText([ISO Week Number], "00"),
        type text
    ),
    // Add the first day of the week (based on _FirstDayOfWeek)
    AddWeekStart = Table.AddColumn(
        AddISOYear_Week, "Start of Week", each Date.StartOfWeek([Date], _FirstDayOfWeek), type date
    ),
    // Add the last day of the week (based on _FirstDayOfWeek)
    AddWeekEnd = Table.AddColumn(
        AddWeekStart, "End of Week", each Date.EndOfWeek([Date], _FirstDayOfWeek), type date
    ),
    // Add day of the week number (1..7, based on _FirstDayOfWeek)
    AddDayOfWeekNumber = Table.AddColumn(
        AddWeekEnd, "Day of Week Number", each Date.DayOfWeek([Date], _FirstDayOfWeek), Int64.Type
    ),
    // Add a flag for weekends (1 for Saturday or Sunday, 0 for weekdays)
    AddIsWeekend = Table.AddColumn(
        AddDayOfWeekNumber, "Is Weekend", each if Date.DayOfWeek([Date], Day.Monday) >= 5 then 1 else 0, Int64.Type
    ),
    // Add a flag for weekdays (1 for Monday-Friday, 0 for weekends)
    AddIsWeekday = Table.AddColumn(
        AddIsWeekend, "Is Weekday", each if Date.DayOfWeek([Date], Day.Monday) < 5 then 1 else 0, Int64.Type
    ),
    // Add week number of the year
    AddWeekNumber = Table.AddColumn(
        AddIsWeekday, "Week Number", each Date.WeekOfYear([Date], _FirstDayOfWeek), Int64.Type
    ),
    // Add year-week (e.g., 202433)
    AddYearWeekNumber = Table.AddColumn(
        AddWeekNumber, "Year-Week Number", each [Year] * 100 + [Week Number], Int64.Type
    ),
    // Add year-week (e.g., 2024-W33)
    AddYear_Week = Table.AddColumn(
        AddYearWeekNumber, "Year-Week", each Text.From([Year]) & "-W" & Number.ToText([Week Number], "00"), type text
    ),
    // Add full day of the week name (e.g., Wednesday)
    AddDayOfWeekLong = Table.AddColumn(
        AddYear_Week, "Day of Week Long", each Date.DayOfWeekName([Date], "EN-us"), type text
    ),
    // Add short day of the week name (3 characters, e.g., Wed)
    AddDayOfWeekShort3 = Table.AddColumn(
        AddDayOfWeekLong, "Day of Week Short 3", each Date.ToText([Date], "ddd", "EN-us"), type text
    ),
    // Add 2-character day of the week name (e.g., We)
    AddDayOfWeekShort2 = Table.AddColumn(
        AddDayOfWeekShort3, "Day of Week Short 2", each Text.Start([Day of Week Short 3], 2), type text
    ),
    // Add quarter number (1..4)
    AddQuarterNumber = Table.AddColumn(
        AddDayOfWeekShort2, "Quarter Number", each Date.QuarterOfYear([Date]), Int64.Type
    ),
    // Add quarter (e.g., Q3)
    AddQuarter = Table.AddColumn(
        AddQuarterNumber, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text
    ),
    // Add year and quarter (e.g., 20243)
    AddYearQuarterNumber = Table.AddColumn(
        AddQuarter, "Year-Quarter Number", each Date.Year([Date]) * 10 + Date.QuarterOfYear([Date]), Int64.Type
    ),
    // Add year and quarter (e.g., 2024-Q3)
    AddYearQuarter = Table.AddColumn(
        AddYearQuarterNumber,
        "Year-Quarter",
        each Text.From(Date.Year([Date])) & "-Q" & Text.From(Date.QuarterOfYear([Date])),
        type text
    ),
    // Add Start of Quarter
    AddStartOfQuarter = Table.AddColumn(
        AddYearQuarter, "Start of Quarter", each Date.StartOfQuarter([Date]), type date
    ),
    // Add End of Quarter
    AddEndOfQuarter = Table.AddColumn(AddStartOfQuarter, "End of Quarter", each Date.EndOfQuarter([Date]), type date),
    // Add fiscal year (integer)
    AddFiscalYear = Table.AddColumn(
        AddEndOfQuarter,
        "Fiscal Year",
        each
            Date.Year(
                Date.AddMonths(#date(Date.Year([Date]) + 1, Date.Month([Date]), 1), -_FirstMonthOfFiscalYear + 1)
            ),
        Int64.Type
    ),
    // Add fiscal year (e.g., FY2025)
    AddFY_YYYY = Table.AddColumn(AddFiscalYear, "FY-YYYY", each "FY-" & Text.From([Fiscal Year]), type text),
    // Add fiscal year (e.g., FY25)
    AddFY_YY = Table.AddColumn(
        AddFY_YYYY,
        "FY-YY",
        each
            "FY-"
                & Date.ToText(
                    Date.AddMonths(#date(Date.Year([Date]) + 1, Date.Month([Date]), 1), -_FirstMonthOfFiscalYear + 1),
                    "yy",
                    "EN-us"
                ),
        type text
    ),
    // Add fiscal month number
    AddFiscalMonthNumber = Table.AddColumn(
        AddFY_YY,
        "Fiscal Month Number",
        each
            if [Month Number] >= _FirstMonthOfFiscalYear then
                [Month Number] - _FirstMonthOfFiscalYear + 1
            else
                [Month Number] + 12 - _FirstMonthOfFiscalYear + 1,
        Int64.Type
    ),
    // Add offset for this month (-1 = previous, 0 = current, 1 = next)
    AddOffsetMonth = Table.AddColumn(
        AddFiscalMonthNumber,
        "Offset Months",
        each ([Year] * 12 + [Month Number]) - (Date.Year(_Today) * 12 + Date.Month(_Today)),
        Int64.Type
    ),
    // Add offset for this quarter (-1 = previous, 0 = current, 1 = next)
    AddOffsetQuarter = Table.AddColumn(
        AddOffsetMonth,
        "Offset Quarters",
        each ([Year] * 4 + [Quarter Number]) - (Date.Year(_Today) * 4 + Date.QuarterOfYear(_Today)),
        Int64.Type
    ),
    // Add offset for this year (-1 = previous, 0 = current, 1 = next)
    AddOffsetYear = Table.AddColumn(AddOffsetQuarter, "Offset Years", each [Year] - Date.Year(_Today), Int64.Type),
    // Add offset for this fiscal year (-1 = previous, 0 = current, 1 = next)
    AddOffsetFiscalYear = Table.AddColumn(
        AddOffsetQuarter,
        "Offset Fiscal Years",
        each
            [Fiscal Year] - Date.Year(
                Date.AddMonths(#date(Date.Year(_Today) + 1, Date.Month(_Today), 1), -_FirstMonthOfFiscalYear + 1)
            ),
        Int64.Type
    ),
    // Add isAfterToday (1 = in the future, 0 = today or past)
    AddIsAfterToday = Table.AddColumn(
        AddOffsetFiscalYear, "isAfterToday", each if [Date] > _Today then 1 else 0, Int64.Type
    ),
    // Add offset for this week (1 = next week, -1 = previous week)
    AddWeekOffset = Table.AddColumn(
        AddIsAfterToday,
        "Offset Weeks",
        each Number.RoundDown(Duration.Days([Date] - Date.StartOfWeek(_Today, _FirstDayOfWeek)) / 7),
        Int64.Type
    )
in
    AddWeekOffset
