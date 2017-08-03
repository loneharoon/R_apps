# ARAVALI
library(shiny)
library(plotly)
rm(list = ls())
# Define UI for application that draws a histogram
#data_repo = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/datasets"
#data_list = list.files(data_repo, pattern= "*.csv", full.names = FALSE, recursive = FALSE)
#data_sources = data_list[1:length(data_list)]
shinyUI(fluidPage(
  titlePanel("ARAVALI!!!"),
  fluidRow(
    column(3,
           helpText("Select the below mentioned items"),
           fileInput("infile",
                     label = "Choose CSV file",
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
                         label = "Plot data with above dates",
                         value = FALSE),
           dateInput("seldate",
                     label="Select Date",
                     value="2016-09-02"
           ),
           checkboxInput('specdate',
                         label = "Plot data with above Date",
                         value =FALSE),
           checkboxInput('perform_clustering',
                         label = "Perform Clustering",
                         value = FALSE),
           selectInput("distmethod", label = "Distance Method",
                       choices = list("DTW" = "DTW", "Euclidean" = "euclidean"), 
                       selected = "euclidean"),
           selectInput("clusmethod", label = "Clustering Method",
                       choices = list("PAM" = "PAM", "KMeans" = "Kmeans"), 
                       selected = "PAM"),
           numericInput("clusnumb", label = "Number of Clusters", value = 4),
           checkboxInput('override_clusters',
                         label = "Override Cluster#",
                         value = FALSE),
           checkboxInput('selectflats',
                         label = h5("Plot below selected Flats"),
                         value = FALSE),
           checkboxGroupInput('checkboxgp1',
                              label='Flats',
                              c("F11"="F11", "F207"="F207", "F208"="F208", "F209"="F209", "F210"="F210", 
                                "F211"="F211", "F212"="F212", "F214"="F214", "F216"="F216", "F217"="F217", 
                                "F218"="F218", "F219"="F219", "F220"="F220", "F221"="F221", "F222"="F222", 
                                "F223"="F223", "F224"="F224", "F225"="F225", "F226"="F226", "F227"="F227", 
                                "F228"="F228", "F229"="F229", "F231"="F231", "F232"="F232", "F233"="F233", 
                                "F234"="F234", "F235"="F235", "F236"="F236", "F237"="F237", "F238"="F238", 
                                "F239"="F239", "F240"="F240", "F241"="F241", "F242"="F242", "F243"="F243", 
                                "F244"="F244", "F245"="F245", "F246"="F246", "F247"="F247", "F248"="F248", 
                                "F249"="F249", "F250"="F250", "F251"="F251", "F252"="F252", "F253"="F253", 
                                "F254"="F254", "F255"="F255", "F256"="F256", "F257"="F257", "F258"="F258", 
                                "F259"="F259", "F260"="F260", "F261"="F261", "F262"="F262", "F263"="F263", 
                                "F264"="F264", "F265"="F265", "F266"="F266", "F267"="F267", "F3"="F3"))
    ),
    column(9,
           fluidRow(
             column(12,
                    textOutput("text1"),
                    plotlyOutput("lineplt1")
             )
           ) ,
           fluidRow(
             column(12,
                    plotlyOutput("facetplt2")
             )
           ),
           fluidRow(
             column(12,
                    #plotOutput("facetplt4")
                    dataTableOutput("facetplt4")
             )),
           fluidRow(
             column(12,
                    plotlyOutput("lineplt5")
             )
           )
           
    )
  )
)
)

