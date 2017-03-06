library(dplyr)
library(feather)
library(ggplot2)
library(lubridate)
library(shiny)

source("loadHealthData.R")

heartRateData <- loadHealthData() %>%
  filter(type == "HKQuantityTypeIdentifierHeartRate") %>%
  mutate(dayOnly = as.Date(format(endDate, "%Y-%m-%d")))

ui <- fluidPage(
  titlePanel("Plot Heart Rate"),
  sidebarLayout(
    sidebarPanel(
      helpText("View heart rate plot across a date range (granularity of 1 day)"),
      dateRangeInput("dateRange", label = "Date range",
                     min = min(heartRateData$dayOnly),
                     max = max(heartRateData$dayOnly),
                     start = max(heartRateData$dayOnly),
                     end = max(heartRateData$dayOnly))
    ),
    mainPanel(
      plotOutput("heartRate"),
      tableOutput("dataSummary")
    )
  )
)

server <- function(input, output) {
  heartRateDataForRange <- reactive({
    begin <- as.Date(input$dateRange[1])
    end <- as.Date(input$dateRange[2]) + days(1)
    heartRateData %>% filter(begin <= endDate & endDate < end)
  })
  output$heartRate <- renderPlot({
    heartRateDataForRange() %>%
      ggplot(aes(x = endDate, y = value)) + geom_line() +
      labs(x = "Date", y = "Heart rate (bpm)")
  })
  output$dataSummary <- renderTable({
    heartRateDataForRange() %>%
      summarize(
        earliestRecord = as.character(min(endDate)),
        latestRecord = as.character(max(endDate)),
        maxHeartRate = max(value),
        minHeartRate = min(value),
        numMeasurements = n()
      )
  })
}

shinyApp(ui = ui, server = server)
