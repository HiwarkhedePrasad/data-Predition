.libPaths(c("~/R/library", .libPaths())) 
library(httr)
library(jsonlite)

args <- commandArgs(trailingOnly = TRUE)
message <- args[1]

api_key <- Sys.getenv("OPENAI_API_KEY")

make_request <- function(message) {
    response <- POST(
        url = "https://api.openai.com/v1/chat/completions",
        add_headers(Authorization = paste("Bearer", api_key)),
        body = list(
            model = "gpt-3.5-turbo",
            messages = list(list(role = "user", content = message))
        ),
        encode = "json"
    )
    return(response)
}

max_attempts <- 5
attempt <- 1
response <- NULL

while (attempt <= max_attempts) {
    response <- make_request(message)

    if (status_code(response) == 200) {
        content <- content(response)
        cat(content$choices[[1]]$message$content)
        break
    } else if (status_code(response) == 429) {
        print(paste("Attempt:", attempt, "Rate limit hit; waiting..."))
        Sys.sleep(5 * attempt)  # Increase wait time between attempts
        attempt <- attempt + 1
    } else {
        stop("API request failed with status: ", status_code(response))
    }
}

if (attempt > max_attempts) {
    cat("Max attempts reached; please try again later.")
    stop("API request failed: Max attempts reached due to rate limits.")
}
