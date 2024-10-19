library(shiny)
library(ggplot2)
library(dplyr)
library(caret)
library(lubridate)
library(readxl)

# Load the training dataset
training_data <- data.frame(
  Month = rep(seq(as.Date("2020-01-01"), by = "month", length.out = 24), 6),
  Sales = c(
    rnorm(24, mean = 200, sd = 50),   # Company A
    rnorm(24, mean = 150, sd = 40),   # Company B
    rnorm(24, mean = 300, sd = 60),   # Amazon
    rnorm(24, mean = 250, sd = 50),   # Google
    rnorm(24, mean = 350, sd = 70),   # Netflix
    rnorm(24, mean = 180, sd = 30)     # IBM
  ),
  Company = rep(c("Company A", "Company B", "Amazon", "Google", "Netflix", "IBM"), each = 24)
)

# Prepare training data
training_data$MonthAsNumeric <- month(training_data$Month)

# Define UI
ui <- fluidPage(
  titlePanel("Sales Prediction from User Data"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload Your Excel File", accept = c(".xlsx")),
      actionButton("predict", "Predict Sales")
    ),
    mainPanel(
      plotOutput("salesPlot"),
      tableOutput("predictionsTable")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  user_data <- reactiveVal()
  
  observeEvent(input$file, {
    req(input$file)  # Ensure a file is uploaded
    # Read the Excel file
    data <- read_excel(input$file$datapath)
    
    # Ensure Month is in Date format
    if ("Month" %in% colnames(data)) {
      data$Month <- as.Date(data$Month, format = "%d-%m-%Y")  # Use the correct format
    } else {
      stop("The column 'Month' is not found in the uploaded data.")
    }
    
    # Prepare numeric month variable
    data$MonthAsNumeric <- month(data$Month)  # Use month() to get month as numeric
    
    # Store the data in the reactive variable
    user_data(data)
  })
  
  observeEvent(input$predict, {
    req(user_data())  # Ensure data is available
    data <- user_data()
    
    # Train a model for each company using the training dataset
    model_list <- training_data %>%
      group_by(Company) %>%
      summarize(model = list(lm(Sales ~ MonthAsNumeric, data = cur_data()))) %>%
      ungroup()
    
    # Future months for prediction
    future_months <- data.frame(
      Month = seq(max(data$Month) + months(1), by = "month", length.out = 12),
      MonthAsNumeric = month(seq(max(data$Month) + months(1), by = "month", length.out = 12))
    )
    
    # Create an empty data frame for predictions
    predictions <- data.frame(Company = character(),
                              Month = as.Date(character()),
                              Predicted_Sales = numeric(),
                              stringsAsFactors = FALSE)
    
    # Predict future sales for each company in the uploaded data
    for (company in unique(data$Company)) {
      if (company %in% model_list$Company) {
        model <- model_list$model[[which(model_list$Company == company)]]
        company_predictions <- data.frame(
          Company = company,
          Month = future_months$Month,
          Predicted_Sales = predict(model, newdata = future_months)
        )
        predictions <- rbind(predictions, company_predictions)
      } else {
        warning(paste("No model found for", company))
      }
    }
    
    # Format Month for display
    predictions$Month <- format(predictions$Month, "%Y-%m")
    
    # Output the predictions and plot
    output$predictionsTable <- renderTable(predictions)
    
    output$salesPlot <- renderPlot({
      ggplot(predictions, aes(x = Month, y = Predicted_Sales, color = Company, group = Company)) +
        geom_line() +
        labs(title = "Future Sales Predictions for Companies", x = "Month", y = "Predicted Sales") +
        theme_minimal()
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
