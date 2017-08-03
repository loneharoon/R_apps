library(shiny)
library(plotly)

# Define UI for application that draws a histogram
#data_repo = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/datasets"
#data_list = list.files(data_repo, pattern= "*.csv", full.names = FALSE, recursive = FALSE)
#data_sources = data_list[1:length(data_list)]
shinyUI(fluidPage(
  titlePanel("Weather Visualization!"),
  fluidRow(
    column(4,
      fileInput("infile",
                label = "Choose data file",
                accept= c(
                  'text/csv',
                  'text/comma-separated-values',
                  'text/tab-separated-values',
                  'text/plain',
                  '.csv',
                  '.tsv' )
      ),
        dateRangeInput("seldate",
                     label="Date Range",
                     start= Sys.Date()-30,
                     end = Sys.Date(),
                     format="yyyy-mm-dd"
      ),
      checkboxInput('specdate',
                    label = "Plot data with above dates",
                    value = FALSE),
      selectInput("timetype",
                  label = "Time divison",
                  choices = list("Hourly","Daily","Monthly","Default Sampling"),
                  selected = "Default Sampling"),
      br(),
      selectInput("plottype",
                  label = "Plot Type",
                  choices = list("Normal Line Plot","Box Plot"),
                  selected = "Normal Line Plot")
      
      #img(src = "iiitd-logo.jpg",height= 150, width =300)            
    ),
    column(8,
           fluidRow(
             column(10,
      textOutput("text1"),
     plotlyOutput("lineplt1"
                ))
          ) )
#     fluidRow(
#        column(10,
#        plotOutput("lineplt2")
 
 #    )
#)
    )
  )
)


