library(shiny)

# Define UI for application that draws a histogram
#data_repo = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/datasets"
#data_list = list.files(data_repo, pattern= "*.csv", full.names = FALSE, recursive = FALSE)
#data_sources = data_list[1:length(data_list)]
shinyUI(fluidPage(
  titlePanel("Power Breakdown!"),
  fluidRow(
    column(4,
      helpText("Select the below mentioned items, otherwise enjoy defaults"),
      #       selectInput("datasource",
      #                   label="Smart Meter",
      #                   choices = data_sources,
      #                   selected = data_sources[1]),
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
#       checkboxInput('header',
#                     label="header",
#                     value=TRUE),
#       radioButtons("sep",
#                    label = "Separator",
#                    choices = c(
#                      Comma=',',
#                      Semicolon=';',
#                      Tab='\t'),
#                    selected = ','),
#       radioButtons('quote', label='Quote',
#                    choices= c(None='',
#                               'Double Quote'='"',
#                               'Single Quote'="'"),
#                    selected= ''),
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
      #plotOutput("plot1")
     # plotOutput("lineplt1")
     plotOutput("lineplt1",
                brush = brushOpts(
                  id = "lineplt1_brush",
                  resetOnNew = TRUE
                ))
          ) ),
     fluidRow(
        column(10,
        plotOutput("lineplt2")
 
     )
)
    )
  )
)
)

