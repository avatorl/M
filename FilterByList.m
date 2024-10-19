// This code adds a logical column to check if each value in [ColumnToFilterBy] exists in Table[Column], filters the rows where this condition is true, and then removes the helper column.
// To be used when filtering an SQL table by a list of hardcoded (in another query) values (or values coming from a non-folding source).
// © Andrzej Leszkiewicz

// Instructions for Replacing Placeholders
//  PreviousStep: Replace this with the name of your previous query step or source table. This is the table you want to filter.
//  [ColumnToFilterBy]: Replace this with the name of the column in PreviousStep that you want to check against another table.
//  Table[Column]: Replace Table with the name of the table you're comparing against, and Column with the specific column in that table.

// Step 1: Add a logical column that checks if each [ColumnToFilterBy] value exists in Table[Column]
AddColumn_Is_ColumnToFilterBy_InTheList = Table.AddColumn(
    PreviousStep,
    "Is_ColumnToFilterBy_InTheList",
    each List.Contains(List.Buffer(Table[Column]), [ColumnToFilterBy]),
    type logical
),

// Step 2: Filter rows where the new logical column is true
FilterBy_Is_ColumnToFilterBy_InTheList = Table.SelectRows(
    AddColumn_Is_ColumnToFilterBy_InTheList,
    each [Is_ColumnToFilterBy_InTheList] = true
),

// Step 3: Remove the helper logical column as it's no longer needed
Remove_Is_ColumnToFilterBy_InTheList = Table.RemoveColumns(
    FilterBy_Is_ColumnToFilterBy_InTheList,
    {"Is_ColumnToFilterBy_InTheList"}
),

/*
// Step 1 will folded into the following SQL code
case
  when [_].[ColumnToFilterBy] in ('Item1', 'Item2', 'Item3')
  then 1
  when not ([_].[ColumnToFilterBy] in ('Item1', 'Item2', 'Item3'))
  then 0
  else null
end as [Is_ColumnToFilterBy_InTheList],
*/
