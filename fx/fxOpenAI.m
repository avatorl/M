// Power Query M function to call the OpenAI API
//      Supports structured output (JSON format of the GPT response)
// ================================================================================================
// GitHub: https://github.com/avatorl/M/blob/master/fx/fxOpenAI.m
// Blog post about this function: https://www.powerofbi.org/2024/10/06/m-language-function-to-call-open-ai-api-from-power-query/
//
// OpenAI API Documentation:
//      API Reference: https://platform.openai.com/docs/api-reference/
//      Models: https://platform.openai.com/docs/models
//      Create Chat Completion: https://platform.openai.com/docs/api-reference/chat/create
//      API Errors: https://platform.openai.com/docs/guides/error-codes/api-errors
//
// Get your API Key at https://platform.openai.com/api-keys
// ================================================================================================
// Function parameters:
// - user (required): The user prompt to send to the OpenAI API.
// - userData (optional): Optional data (text field) that will be concatenated with the user prompt.
// - system (optional): Optional system message to provide additional instructions to the model. Default: "You're a helpful assistant".
// - model (optional): Specify the model to use (e.g., gpt-4o-mini, gpt-4o, etc.). Default: "gpt-4o-mini".
// - structuredOutput (optional): Set to true to enable structured output (JSON format of the GPT response). Default: false.
//      Before enabling, edit _response_format to define the expected JSON schema for structured output.
// Usage examples:
//      fxOpenAI("Translate this text into French, Italian, and German. Text to translate: " & [Text])
//      fxOpenAI("Translate this text into French, Italian, and German. Text to translate:", [Text], null, null, true)
//      fxOpenAI("Translate this text into French, Italian, and German. Text to translate:", [Text], "You are a helpful linguist", "gpt-4o", true)
(
    user as text,
    optional userData as text,
    optional system as text,
    optional model as text,
    optional structuredOutput as logical
) =>
    let
        // CONFIGURATION ==================================================================================
        // Replace the API key below with your actual API key
        _api_key = "sk-proj-...SR8A",
        // Determine the model to use, defaulting to "gpt-4o-mini" if none is provided
        _model = model ?? "gpt-4o-mini",
        // Prepare user prompt: concatenate userData with user
        _user = user & " " & (userData ?? ""),
        // Determine the system message, defaulting to "You're a helpful assistant" if none is provided
        _system = system ?? "You're a helpful assistant",
        // What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic
        _temperature = 1,
        // An upper bound for the number of tokens that can be generated for a completion, including visible output tokens and reasoning tokens
        _max_completion_tokens = null,
        // Determine if structured output (JSON format of the GPT response) is enabled
        _structured_output = structuredOutput ?? false,
        // Structured output example:
        //      Function call: fxOpenAI("Translate this text into French, Italian, and German. Text to translate:",[Text],null,null,true), where [Text] = "I have an apple and 2 oranges"
        //      User prompt: "Translate this text into French, Italian, and German. Text to translate: I have an apple and 2 oranges"
        //      GPT response JSON: {"TranslationFR": "J'ai une pomme et 2 oranges", "TranslationIT": "Ho una mela e 2 arance", "TranslationDE": "Ich habe einen Apfel und 2 Orangen"}
        // STRUCTURED OUTPUT JSON SCHEMA ==================================================================
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
                        translationFR = [type = "string", description = "put French translation here"],
                        translationIT = [type = "string", description = "put Italian translation here"],
                        translationDE = [type = "string", description = "put German translation here"]
                    ],
                    required = {"translationFR", "translationIT", "translationDE"},
                    additionalProperties = false
                ]
            ]
        ],
        // ================================================================================================
        // Define the base URL for the API endpoint
        _url_base = "https://api.openai.com",
        // Define the relative path for the API endpoint
        _url_rel = "v1/chat/completions",
        //
        // Create the JSON body for the API request, including the user message and system message
        requestDataBase = [
            model = _model,
            // An upper bound for the number of tokens that can be generated for a completion, including visible output tokens and reasoning tokens
            max_completion_tokens = _max_completion_tokens,
            // What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic
            temperature = _temperature,
            messages = {[
                role = "system",
                content = _system
            ], [
                role = "user",
                content = _user
            ]}
        ],
        //
        // Conditionally include the response_format field if structured output is enabled
        requestData =
            if _structured_output then
                Record.AddField(requestDataBase, "response_format", _response_format)
            else
                requestDataBase,
        //
        // Make the API call using Web.Contents and capture the response
        response = Web.Contents(
            _url_base,
            [
                RelativePath = _url_rel,
                Headers = [
                    #"Content-Type" = "application/json",
                    #"Authorization" = "Bearer " & _api_key
                ],
                Content = Json.FromValue(requestData),
                ManualStatusHandling = {400, 401, 403, 404, 429, 500, 503}
                // List of status codes to handle
            ]
        ),
        //
        // Extract metadata from the response
        responseMetadata = Value.Metadata(response),
        responseCode = responseMetadata[Response.Status],
        responseHeaders = responseMetadata[Headers],
        responseText = Text.FromBinary(response),
        //
        // Check the response code and handle errors
        responseJSON =
            if responseCode <> 200 then
                let
                    // Parse the error response JSON
                    errorResponse = Json.Document(responseText),
                    // Extract the error message from the response
                    errorMessage =
                        if
                            Record.HasFields(errorResponse, "error")
                            and Record.HasFields(errorResponse[error], "message")
                        then
                            errorResponse[error][message]
                        else
                            "An unknown error occurred.",
                    // Raise an error with the appropriate details
                    errorRecord = Error.Record("Error", Text.From(responseCode) & " " & errorMessage, errorResponse)
                in
                    // Raise an error with the appropriate details
                    error errorRecord
            else
                // Parse the successful response JSON
                Json.Document(responseText),
        //
        // Extract the first choice from the API response
        choice = responseJSON[choices]{0},
        // Retrieve the generated content and finish reason
        content = choice[message][content],
        reason = choice[finish_reason],
        // If structured output is enabled, parse the content as JSON
        finalContent = if _structured_output then Json.Document(content) else content,
        // Return both the content and the finish reason as the result
        Result = [
            // Either text (structured output disabled) or record (structured output enabled)
            Content = finalContent,
            // "stop" - “stop” means the API returned the full chat completion generated by the model without running into any limits
            // "length" means the conversation was too long for the context window
            // "content_filter" means the content was filtered due to policy violations
            FinishReason = reason,
            // Detailed API response with metadata (including number of tokens used)
            FullResponse = responseJSON
        ]
    in
        Result
