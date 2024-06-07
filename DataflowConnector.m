let
  //Dataflow connector
  Source = PowerPlatform.Dataflows([]),
  //Workspace Id
  _Workspace = "<id>",
  //Dataflow Id
  _Dataflow = "<id>",
  //Entity (table) name
  _Entity = "<name>",
  //
  Workspaces = Source{[Id = "Workspaces"]}[Data],
  Workspace = Workspaces{[workspaceId = _Workspace]}[Data],
  Dataflow = Workspace{[dataflowId = _Dataflow]}[Data],
  TableData = Dataflow{[entity = _Entity, version = ""]}[Data]
in
  TableData
