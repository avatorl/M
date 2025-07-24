(endpoint as text, optional from as text, optional to as text) =>
    let
        _keyword = "querytest",
        _from = if from = null then "" else Text.From(from),
        _to = if to = null then "" else Text.From(to),

                // Headers
                Headers = [
                    #"Content-Type" = "application/json",
                    #"x-api-key" = "API_KEY_TEST"
                ],
                // HTTP request
                Response = Web.Contents(
                   "***.free.beeceptor.com",
                    [
                        Headers = Headers,
                        RelativePath = endpoint,
                        Query = [test = _keyword, from = _from, to = _to]
                    ]
                )               
    in
        Response
