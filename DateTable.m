//============================================
//Date table (calendar and fiscal periods)
//Useful Links:
//  https://gorilla.bi/power-query/create-iso-week-and-iso-year/
//============================================
let

//CONFIG

    //Start date (manual entry)
    //_Date_Start = #date(2024, 1, 1),
    //End date (manual entry)
    //_Date_End = #date(2024, 12, 31),

    //First day of week
    _FirstDayOfWeek = Day.Monday,
    //First month of fiscal year (number)
    _FirstMonthOfFiscalYear = 7,

    //Fact table date column (or any other list that defines lits of required dates)
    Source = Financials[Month],
    ListDistinct = List.Buffer(List.Distinct(Source)),

    //Start date (from the source)
    _Date_Start = Date.StartOfYear(List.Min(ListDistinct)),
    //End date (from the source)
    _Date_End = Date.EndOfYear(List.Max(ListDistinct)),

//CONFIG-END    

    //Complete list of dates (From January 1st of the first year to the December 31st of the last year)
    List_Dates = List.Dates(_Date_Start, Number.From(_Date_End)-Number.From(_Date_Start)+1,#duration(1,0,0,0)),

    Table_From_List = Table.FromList(List_Dates, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),    
    Changed_Type_Date = Table.TransformColumnTypes(Table_From_List,{{"Date", type date}}),

    Add_DateNumber = Table.AddColumn(Changed_Type_Date, "Date Number", each Number.From([Date]), Int64.Type),

    //YEAR
    
    Add_YYYYMMDD_Number = Table.AddColumn(Add_DateNumber, "YYYYMMDD Number", each Number.From(Date.ToText([Date], "yyyyMMdd")), Int64.Type),
    Add_YearNumber = Table.AddColumn(Add_YYYYMMDD_Number, "Year Number", each Date.Year([Date]), Int64.Type),
    Add_YYYY_MM = Table.AddColumn(Add_YearNumber, "YYYY-MM", each Date.ToText([Date], "yyyy-MM"), type text),

    //MONTH
    
    AddMonthNumber = Table.AddColumn(Add_YYYY_MM, "Month Number", each Date.Month([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddMonthNumber, "Month Long", each Date.MonthName([Date], "EN-us"), type text),
    AddMonthNameShort = Table.AddColumn(AddMonthName, "Month Short", each Date.ToText([Date], "MMM", "EN-us"), type text),
    AddMonthStart = Table.AddColumn(AddMonthNameShort, "Start of Month", each Date.StartOfMonth([Date]), type date),
    AddMonthEnd = Table.AddColumn(AddMonthStart, "End of Month", each Date.EndOfMonth([Date]), type date),
    AddDaysInMonth = Table.AddColumn(AddMonthEnd, "Days in Month", each Date.DaysInMonth([Date]), Int64.Type),

    //ISO WEEK
    
    AddISOWeek = Table.AddColumn(AddDaysInMonth, "ISO Week Number", each let
        CurrentThursday = Date.AddDays([Date], 3-Date.DayOfWeek([Date], Day.Monday)),
        YearCurrentThursday = Date.Year(CurrentThursday),
        FirstThursdayOfYear = Date.AddDays(#date(YearCurrentThursday,1,7),-Date.DayOfWeek(#date(YearCurrentThursday,1,1), Day.Friday)),
        AddISOWeek = Duration.Days(CurrentThursday-FirstThursdayOfYear)/7+1
    in AddISOWeek, Int64.Type),
    AddISOYear = Table.AddColumn(AddISOWeek, "ISO Year", each Date.Year(Date.AddDays([Date], 26-[ISO Week Number])), Int64.Type),
    AddISOYear_Week = Table.AddColumn(AddISOYear, "ISO Year-Week", each Text.From([ISO Year]) & "-W" & Number.ToText([ISO Week Number], "00"), type text),

    //WEEK
    
    AddWeekStart = Table.AddColumn(AddISOYear_Week, "Start of Week", each Date.StartOfWeek([Date], _FirstDayOfWeek), type date),
    AddWeekEnd = Table.AddColumn(AddWeekStart, "End of Week", each Date.EndOfWeek([Date], _FirstDayOfWeek), type date),
    AddDayOfWeekNumber = Table.AddColumn(AddWeekEnd, "Day of Week Number", each Date.DayOfWeek([Date], _FirstDayOfWeek), Int64.Type),
    AddIsWeekend = Table.AddColumn(AddDayOfWeekNumber, "Is Weekend", each if Date.DayOfWeek([Date])>=5 then 1 else 0, Int64.Type),
    AddIsWeekday = Table.AddColumn(AddIsWeekend, "Is Weekday", each if Date.DayOfWeek([Date])<5 then 1 else 0, Int64.Type),
    AddWeekNumber = Table.AddColumn(AddIsWeekday, "Week Number", each Date.WeekOfYear([Date], _FirstDayOfWeek), Int64.Type),
    AddYear_Week = Table.AddColumn(AddWeekNumber, "Year-Week", each Text.From([Year Number]) & "-W" & Number.ToText([Week Number], "00"), type text),
    AddDayOfWeekLong = Table.AddColumn(AddYear_Week, "Day of Week Long", each Date.DayOfWeekName([Date], "EN-us"), type text),
    AddDayOfWeekShort3 = Table.AddColumn(AddDayOfWeekLong, "Day of Week Short 3", each Date.ToText([Date], "ddd", "EN-us"), type text),
    AddDayOfWeekShort2 = Table.AddColumn(AddDayOfWeekShort3, "Day of Week Short 2", each Text.Start([Day of Week Short 3], 2), type text),

    //DAY
    
    AddDayOfYear = Table.AddColumn(AddDayOfWeekShort2, "Day of Year", each Date.DayOfYear([Date]), Int64.Type),
    AddDayOfMonth = Table.AddColumn(AddDayOfYear, "Day of Month", each Date.Day([Date]), Int64.Type),

    //QUARTER
    
    AddQuarterNumber = Table.AddColumn(AddDayOfMonth, "Quarter Number", each Date.QuarterOfYear([Date]), Int64.Type),
    AddQuarter = Table.AddColumn(AddQuarterNumber, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddYearQuarter = Table.AddColumn(AddQuarter, "Year-Quarter", each Text.From(Date.Year([Date])) & "-Q" & Text.From( Date.QuarterOfYear([Date])), type text),

    //Simple fiscal year. Edit _FirstMonthOfFiscalYear in the CONFIG section to change first month of the fiscal year 

    AddFY_YYYY = Table.AddColumn(AddYearQuarter, "FY-YYYY", each "FY-" & Date.ToText(Date.AddMonths(#date(Date.Year([Date])+1,Date.Month([Date]),1),-_FirstMonthOfFiscalYear+1), "yyyy", "EN-us"), type text),
    AddFY_YY = Table.AddColumn(AddFY_YYYY, "FY-YY", each "FY-" & Date.ToText(Date.AddMonths(#date(Date.Year([Date])+1,Date.Month([Date]),1),-_FirstMonthOfFiscalYear+1), "yy", "EN-us"), type text)
in
    AddFY_YY
