# Dataport visualization
library(shiny)
library(plotly)
# Define UI for application that draws a histogram
#data_repo = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/datasets"
#data_list = list.files(data_repo, pattern= "*.csv", full.names = FALSE, recursive = FALSE)
#data_sources = data_list[1:length(data_list)]
shinyUI(fluidPage(
  titlePanel("Power Breakdown!"),
  fluidRow(
    column(3,
           helpText("Select the below mentioned items"),
           fileInput("infile",
                     label = "Choose Dataport file",
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
                          start = as.Date("2014-06-01"),
                          end = as.Date("2014-08-30"),
                          format = "yyyy-mm-dd"
           ),
           checkboxInput('specdaterange',
                         label = "Plot data with above dates",
                         value = FALSE),
           dateInput("seldate",
                     label="Select Date",
                     value="2014-06-02"
           ),
           checkboxInput('specdate',
                         label = "Plot data with above Date",
                         value =FALSE),
           ##helpText("Plot selected column"),
           checkboxInput('selectcolumns',
                         label = h5("Plot below selected columns"),
                         value = FALSE),
           checkboxGroupInput("ColumnNames", "columnNames:",
                              c("use" = "use", "air1"="air1", "air2"= "air2" ,"air3"= "air3" , "clotheswasher1"= "clotheswasher1",
                                "diningroom1"="diningroom1","diningroom2"="diningroom2","dishwasher1"="dishwasher1","disposal1"="disposal1","drye1"="drye1","dryg1"="dryg1","freezer1"="freezer1","furnace1"="furnace1","furnace2"="furnace2","garage1"="garage1","garage2"="garage2","heater1"="heater1","housefan1"="housefan1","icemaker1"="icemaker1","kitchen1"="kitchen1","kitchen2"="kitchen2","kitchenapp1"="kitchenapp1","kitchenapp2"="kitchenapp2","livingroom1"="livingroom1","livingroom2"="livingroom2","microwave1"="microwave1","office1"="office1","outsidelights_plugs1"="outsidelights_plugs1","outsidelights_plugs2"="outside_plugs2","oven1"="oven1","oven2"="oven2","pool1"="pool1","poollight1"="poolight1","poolpump1"="poolpump1","pump1"="pump1","range1"="range1","refrigerator1"="refrigerator1","refrigerator2"="refrigerator2","security1"="security1","shed1"="shed1","sprinkler1"="sprinkler1","utilityroom1"="utilityroom1","venthood1"="venthood1","waterheater1"="waterheater1","waterheater2"="waterheater2","winecooler1"="winecooler1"
                                ,"clotheswasher_dryg1"= "clotheswasher_dryg1","jacuzzi1"="jackuzzi1",
                                "lights_plugs1"="lights_plugs1","lights_plugs2"="lights_plugs2","lights_plugs3"="lights_plugs3","lights_plugs4"="lights_plugs4","lights_plugs5"="lights_plugs5","lights_plugs6"="lights_plugs6","grid"="grid","gen"="gen", "bathroom1" = "bathroom1"
                              ),inline = TRUE)
    ),
    column(9,
           fluidRow(
             column(12,
                    textOutput("text1"),
                    #plotOutput("plot1")
                    # plotOutput("lineplt1")
                    plotlyOutput("lineplt1")
                             
             ) ),
           fluidRow(
             column(12,
                    plotlyOutput("lineplt3")
                    
             ) )

    )
  )
)
)

