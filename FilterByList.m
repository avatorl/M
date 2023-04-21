= Table.AddColumn(Previous_step, "New Filter Column", each List.Contains(List.Buffer(ListOfItems),[ColumnToFilterBy]), type logical)
