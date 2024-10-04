// Power Query M function to call the OpenAI API
// OpenAI API Documentation: https://platform.openai.com/docs/api-reference/
// Get your API Key at https://platform.openai.com/api-keys

// Function parameters:
// - user (required): The user prompt to send to the OpenAI API
// - system (optional): Optional system message to provide additional instructions to the model
// - model (optional): Specify the model to use (e.g., gpt-4, gpt-4o-mini, gpt-4o etc.)

(user as text, optional system as text, optional model as text) =>

let
    // Determine the model to use, defaulting to "gpt-4o-mini" if none is provided
    _model = model ?? "gpt-4o-mini",

    // Include the system message if provided, otherwise leave it blank
    _system = system ?? [
        role    = "system",
        content = system
    ],

    // Define the OpenAI API key (replace <OPENAI_API_KEY> with your actual key)
    _api_key = "<OPENAI_API_KEY>",

    // Define the base URL and relative path for the API endpoint
    _url_base = "https://api.openai.com",
    _url_rel = "v1/chat/completions",

    // Create the JSON body for the API request, including the user message and optional system message
    requestData = [
        model = _model,
        messages = {
            _system,
            [
                role = "user",
                content = user
            ]
        }
    ],

    // Make the API call using Web.Contents and capture the response
    Source = Json.Document(
        Web.Contents(
            _url_base,
            [
                RelativePath = _url_rel,
                Headers = [
                    #"Content-Type" = "application/json",
                    #"Authorization" = "Bearer " & _api_key
                ],
                Content = Json.FromValue( requestData )
            ]
        )
    ),

    // Extract the first choice from the API response
    choice = Source[choices]{0},

    // Retrieve the generated content (text) from the API response
    content = Table.SelectRows(Record.ToTable(choice[message]), each [Name] = "content")[Value]{0},

    // Retrieve the finish reason, e.g., "stop" indicates the completion of the response
    reason = Table.SelectRows(Record.ToTable(choice), each [Name] = "finish_reason")[Value]{0},

    // Return both the content and the finish reason as the result
    Result = {content, reason}

in
    Result
