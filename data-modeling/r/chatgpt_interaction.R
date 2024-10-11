# Load required libraries
library(httr)
library(jsonlite)

# Set your OpenAI API key
api_key <- Sys.getenv("OPENAI_API_KEY")  # Access from environment variable

# Function to get response from ChatGPT
get_chatgpt_response <- function(user_message) {
    # Create the API endpoint URL
    url <- "https://api.openai.com/v1/chat/completions"

    # Prepare the request body
    body <- list(
        model = "gpt-3.5-turbo",  # or "gpt-4" if you have access
        messages = list(
            list(role = "user", content = user_message)
        )
    )

    # Make the API request
    response <- POST(
        url,
        add_headers(Authorization = paste("Bearer", api_key)),
        body = toJSON(body),
        encode = "json"
    )

    # Check for errors
    if (status_code(response) != 200) {
        stop("Error: ", content(response, "text"), call. = FALSE)
    }

    # Parse the response
    result <- content(response, "parsed")
    return(result$choices[[1]]$message$content)
}

# Example usage
args <- commandArgs(trailingOnly = TRUE)
user_input <- args[1]  # Get user input from command line

# Get the response from ChatGPT
chatgpt_reply <- get_chatgpt_response(user_input)

# Print the response
cat(chatgpt_reply)
