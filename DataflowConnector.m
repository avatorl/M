let
    // Connect to the Power Platform Dataflows
    Source = PowerPlatform.Dataflows([]),
    
    // Specify the Workspace Id. Replace <id> with your actual Workspace Id
    _Workspace = "<id>",
    
    // Specify the Dataflow Id. Replace <id> with your actual Dataflow Id
    _Dataflow = "<id>",
    
    // Specify the Entity (table) name. Replace <name> with your actual entity name
    _Entity = "<name>",
    
    // Access the list of Workspaces from the Dataflows source
    Workspaces = Source{[Id = "Workspaces"]}[Data],
    
    // Retrieve the specific Workspace using its Id
    Workspace = Workspaces{[workspaceId = _Workspace]}[Data],
    
    // Access the Dataflow within the specified Workspace using its Id
    Dataflow = Workspace{[dataflowId = _Dataflow]}[Data],
    
    // Retrieve the specific table (entity) data from the Dataflow. If a version is not specified, it defaults to the latest version
    TableData = Dataflow{[entity = _Entity, version = ""]}[Data]
    
in
    TableData
