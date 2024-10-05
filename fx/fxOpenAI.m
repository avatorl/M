// Power Query M function to call the OpenAI API
// Blog post: https://www.powerofbi.org/2024/10/06/m-language-function-to-call-open-ai-api-from-power-query/
// OpenAI API Documentation: https://platform.openai.com/docs/api-reference/
//      Create chat completion: https://platform.openai.com/docs/api-reference/chat/create
//      API errors: https://platform.openai.com/docs/guides/error-codes/api-errors
// Get your API Key at https://platform.openai.com/api-keys

// Function parameters:
// - user (required): The user prompt to send to the OpenAI API
// - system (optional): Optional system message to provide additional instructions to the model
// - model (optional): Specify the model to use (e.g., gpt-4, gpt-4o-mini, gpt-4o etc.)

(user as text, optional system as text, optional model as text) =>

let

    // Replace <OPENAI_API_KEY> with your actual API key
    _api_key = "<OPENAI_API_KEY>",

    // Determine the model to use, defaulting to "gpt-4o-mini" if none is provided
    _model = model ?? "gpt-4o-mini",

    // Determine the system message, defaulting to "You're a helpful assistant" if none is provided
    _system = system ?? "You're a helpful assistant",

    // Set to true to enable structured output (JSON format of the GPT response)
    structured_output = false,    

    // Define the expected JSON schema for structured output
    _response_format = [
        type = "json_schema",        
        json_schema = [
            name = "response_json_schema",
            description = "JSON format of the response",
            strict = true,
            schema = [
            type = "object",
            properties = [
                response = [type = "string", description = "put response here"]
            ],     
            required = {"response"},
            additionalProperties = false
        ]
    ]
],

    // Define the base URL and relative path for the API endpoint
    _url_base = "https://api.openai.com",
    _url_rel = "v1/chat/completions",

    // Create the JSON body for the API request, including the user message and system message
    requestDataBase = [
        model = _model,
        messages = {
            [
                role    = "system",
                content = _system
            ],
            [
                role = "user",
                content = user
            ]            
        }
    ],

    // Conditionally include the response_format field if structured output is enabled
    requestData = if structured_output then
        Record.AddField(requestDataBase, "response_format", _response_format)
    else
        requestDataBase,

    // Make the API call using Web.Contents and capture the response
    response =
        Web.Contents(
            _url_base,
            [
                RelativePath = _url_rel,
                Headers = [
                    #"Content-Type" = "application/json",
                    #"Authorization" = "Bearer " & _api_key
                ],
                Content = Json.FromValue( requestData ),
                ManualStatusHandling = {400, 401, 403, 404, 429, 500, 503} // List of status codes to handle
            ]
        ),
    
    // Extract metadata from the response
    responseMetadata = Value.Metadata(response),
    responseCode = responseMetadata[Response.Status],
    responseHeaders = responseMetadata[Headers],
    responseText = Text.FromBinary(response),


    
    // Check the response code and handle errors
    responseJSON = if responseCode <> 200 then
        let
            // Parse the error response JSON
            errorResponse = Json.Document(responseText),
            // Extract the error message from the response
            errorMessage = if 
                Record.HasFields(errorResponse, "error") and 
                Record.HasFields(errorResponse[error], "message")
            then
                errorResponse[error][message]
            else
                "An unknown error occurred.",
            // Raise an error with the appropriate details
            errorRecord = Error.Record(
                "Error", 
                Text.From(responseCode) & " " & errorMessage, 
                errorResponse
            )
        in
            // Raise an error with the appropriate details
            error errorRecord
    else
        // Parse the successful response JSON
        Json.Document(responseText), 

    // Extract the first choice from the API response
    choice = responseJSON[choices]{0},

    // Retrieve the generated content and finish reason
    content = choice[message][content],
    reason = choice[finish_reason],

  // If structured output is enabled, parse the content as JSON
    finalContent = if structured_output then
        Json.Document(content)
    else
        content,    

    // Return both the content and the finish reason as the result
    Result = [
        Content = finalContent, 
        FinishReason = reason,
        FullResponse = responseJSON
    ]

in
    Result
