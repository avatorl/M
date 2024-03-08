//M function to call OpenAI API
//Open AI API Docs: https://platform.openai.com/docs/api-reference/
//Get your API Key at https://platform.openai.com/api-keys
//Do not trust robots!

(prompt as text, optional prefix as text, optional model as text) =>

let

    //ENDPOINT v1/assistants and /v1/chat/completions
    //gpt-4-turbo-preview
    //gpt-4-vision-preview
    //gpt-4
    //gpt-3.5-turbo

    //ENDPOINT v1/images/generations
    //dall-e-3

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
        ""content"": """ & _prefix & prompt & """
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
  
    content = Table.SelectRows(Record.ToTable(Source[choices]{0}[message]), each ([Name] = "content"))[Value]{0},
    reason = Table.SelectRows(Record.ToTable(Source[choices]{0}), each ([Name] = "finish_reason"))[Value]{0},
    Result = {content,reason}
in
    Result
