# Karan app
library(shiny)
library(plotly)
rm(list = ls())

shinyUI(fluidPage(
  titlePanel("ENERGY"),
  fluidRow(
    column(3,
           helpText("Select the below mentioned items"),
           fileInput("infilepower",
                     label = "Read Energy data",
                     accept= c(
                       'text/csv',
                       'text/comma-separated-values',
                       'text/tab-separated-values',
                       'text/plain',
                       '.csv',
                       '.tsv' )
           ),
           dateRangeInput("seldaterange",
                          label = "Date Range",
                          start = "2016-06-13",
                          end = "2016-06-19",
                          format = "yyyy-mm-dd"),
           checkboxInput('specdaterange',
                         label = "Visualize usage in above dates",
                         value = FALSE),
           dateInput("seldate",
                     label="Select Date",
                     value="2016-09-02"
           ),
           checkboxInput('specdate',
                         label = "Visualize Usage on above Date",
                         value =FALSE)

    ),
    column(9,
           fluidRow(
             column(12,
                  #  textOutput("text1"),
                    plotlyOutput("lineplt1")
             )
           ) 

           
    )
  )
)
)

