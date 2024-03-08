//Do not trust robots!

(prompt as text, optional prefix as text, optional model as text) =>

let
    _model = if model = null then "gpt-3.5-turbo" else model,
    _prefix =if prefix = null then "" else prefix,

    _api_key = "<API_KEY>",
    _url_base = "https://api.openai.com/",
    _url_rel = "v1/chat/completions",

    ContentJSON ="{
    ""model"": """ & _model & """,
    ""messages"": [
      {
        ""role"": ""system"",
        ""content"": ""You are a helpful linguistic assistant""
      },
      {
        ""role"": ""user"",
        ""content"": """ & prefix & prompt & "!""
      }
    ]
  }",

    ContentBinary =  Text.ToBinary(ContentJSON),

    Source = Json.Document(
        Web.Contents(
            _url_base, 
            [
                RelativePath=_url_rel,
                Headers=[
                    #"Content-Type"="application/json", 
                    #"Authorization"="Bearer " & _api_key
                ],
                Content=ContentBinary
            ]
        )
    ),
  
    Result = Table.SelectRows(Record.ToTable(Source[choices]{0}[message]), each ([Name] = "content"))[Value]{0}
in
    Result
