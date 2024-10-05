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

    // Determine the system message, defaulting to "You're a helpful assistant" if none is provided
    _system = system ?? "You're a helpful assistant",

    // Define the OpenAI API key (replace <OPENAI_API_KEY> with your actual key)
    _api_key = "<OPENAI_API_KEY>",

    // Define the base URL and relative path for the API endpoint
    _url_base = "https://api.openai.com",
    _url_rel = "v1/chat/completions",

    // Create the JSON body for the API request, including the user message and system message
    requestData = [
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

    // Retrieve the generated content and finish reason
    content = choice[message][content],
    reason = choice[finish_reason],

    // Return both the content and the finish reason as the result
    Result = [Content = content, FinishReason = reason]

in
    Result
