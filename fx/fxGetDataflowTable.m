// =============================================
// Function: fxGetDataflowTable
// Description:
//   Retrieves data from a specified entity (table) within a dataflow in a Power BI workspace.
// Parameters:
//   - WorkspaceId (text): The unique identifier of the Power BI workspace.
//   - DataflowId (text): The unique identifier of the dataflow within the workspace.
//   - EntityName (text): The name of the entity (table) to retrieve data from.
// Returns:
//   - A table containing the data from the specified entity.
// =============================================

let
    GetDataflowTable = (WorkspaceId as text, DataflowId as text, EntityName as text) =>
    let
        // Connect to the Power Platform Dataflows
        Source = PowerPlatform.Dataflows([]),
        
        // Access the list of Workspaces from the Dataflows source
        Workspaces = Source{[Id = "Workspaces"]}[Data],
        
        // Retrieve the specific Workspace using its Id
        Workspace = Workspaces{[workspaceId = WorkspaceId]}[Data],
        
        // Access the Dataflow within the specified Workspace using its Id
        Dataflow = Workspace{[dataflowId = DataflowId]}[Data],
        
        // Retrieve the specific table (entity) data from the Dataflow
        TableData = Dataflow{[entity = EntityName, version = ""]}[Data]
    in
        TableData
in
    GetDataflowTable
