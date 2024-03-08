//Do not trust any math and factual data provided by AI. But it is amazing in understanding human language!

(prompt as text, optional model as text, optional max_tokens as number, optional temperature as number) =>

let
    _model = if model = null then "gpt-3.5-turbo" else model,
    _max_tokens = if max_tokens = null then 500 else max_tokens,
    _temperature = if temperature = null then 0.7 else temperature,
    
    //https://beta.openai.com/account/api-keys
    _api_key = "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",
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
        ""content"": """ & prompt & "!""
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
  
    Result = Table.SelectRows(Record.ToTable(Source[choices]{0}[message]), each ([Name] = "content"))[Value]
in
    Result
