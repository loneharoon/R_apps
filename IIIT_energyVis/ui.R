# IIITD EnergyVIS application
library(shiny)
library(plotly)
rm(list = ls())
# Define UI for application that draws a histogram
#data_repo = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/datasets"
#data_list = list.files(data_repo, pattern= "*.csv", full.names = FALSE, recursive = FALSE)
#data_sources = data_list[1:length(data_list)]
shinyUI(fluidPage(
  titlePanel("IIIT EnergyVis"),
  fluidRow(
    column(3,
           helpText("Select the below mentioned items"),
           fileInput("infile",
                     label = "Provide CSV file",
                     accept= c(
                       'text/csv',
                       'text/comma-separated-values',
                       'text/tab-separated-values',
                       'text/plain',
                       '.csv',
                       '.tsv' )
           ),
            checkboxInput('plot_whole_data',
                          label = "Plot Entire File",
                          value = FALSE),
           # dateRangeInput("seldaterange",
           #                label = "Date Range",
           #                start = "2016-06-13",
           #                end = "2016-06-19",
           #                format = "yyyy-mm-dd"),
          sliderInput("seldaterange",
                         "Date Range",
                         min = as.Date("2013-07-01","%Y-%m-%d"),
                         max = as.Date("2017-07-31","%Y-%m-%d"),
                         value = c(as.Date("2013-08-01"),as.Date("2013-08-30")),
                         timeFormat="%Y-%m-%d",
                         step = 10,
                         dragRange = TRUE),
           checkboxInput('specdaterange',
                         label = "Plot data of above dates",
                         value = FALSE),
           dateInput("seldate",
                     label="Select Date",
                     value="2016-09-02"
           ),
           checkboxInput('specdate',
                         label = "Plot data with above Date",
                         value =FALSE),
           # checkboxInput('perform_clustering',
           #               label = "Perform Clustering",
           #               value = FALSE),
           # selectInput("distmethod", label = "Distance Method",
           #             choices = list("DTW" = "DTW", "Euclidean" = "euclidean"), 
           #             selected = "euclidean"),
           # selectInput("clusmethod", label = "Clustering Method",
           #             choices = list("PAM" = "PAM", "KMeans" = "Kmeans"), 
           #             selected = "PAM"),
           # numericInput("clusnumb", label = "Number of Clusters", value = 4),
           # checkboxInput('override_clusters',
           #               label = "Override Cluster#",
           #               value = FALSE),
           checkboxInput('selectstreams',
                         label = h5("Plot below selected Streams"),
                         value = FALSE),
           checkboxGroupInput('checkboxgp1',
                              label='Streams',
                              c("Power"="power", "Voltage"="voltage", "Current"="current", "Frequency"="frequency", "PowerFactor"="power_factor","Energy"="energy")
                  )),
    column(9,
           fluidRow(
             column(12,
                    textOutput("textoutput")
                    #plotlyOutput("lineplt1")
             )
           ),
           fluidRow(
             column(12,
                 #   textOutput("text1"),
                    plotlyOutput("lineplt1")
             )
           ), 
            fluidRow(
              column(12,
                     plotlyOutput("lineplt2")
                     #plotlyOutput("lineplt2")
              )
            )
           # fluidRow(
           #   column(12,
           #          #plotOutput("facetplt4")
           #          dataTableOutput("facetplt4")
           #   )),
           # fluidRow(
           #   column(12,
           #          plotlyOutput("lineplt5")
           #   )
           # )
           
    )
  )
)
)


