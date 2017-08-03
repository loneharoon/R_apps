# kReSIT 
library(shiny)
library(plotly)
# Define UI for application that draws a histogram
#data_repo = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/datasets"
#data_list = list.files(data_repo, pattern= "*.csv", full.names = FALSE, recursive = FALSE)
#data_sources = data_list[1:length(data_list)]
shinyUI(fluidPage(
  titlePanel("KReSIT USAGE!"),
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
           # dateRangeInput("seldate",
           #                label = "Date Range",
           #                start = Sys.Date()-30,
           #                end = Sys.Date(),
           #                format = "yyyy-mm-dd"
           # ),
           dateRangeInput("seldate",
                          label = "Date Range",
                          start = "2016-01-01",
                          end = "2016-05-31",
                          format = "yyyy-mm-dd"),
           checkboxInput('specdate',
                         label = "Plot data with above dates",
                         value = FALSE),
           ##helpText("Plot selected column"),
           checkboxInput('selectcolumns',
                         label = h5("Plot below selected columns"),
                         value = FALSE),
           # checkboxGroupInput("ColumnNames", "columnNames:",
           #                    c("k_m" = "k_m","k_a" = "k_a", "k_p" = "k_p", "k_l" = "k_l",
           #                      "k_wc_a" = "k_wc_a", "k_wc_l" = "k_wc_l", "k_wc_p" = "k_wc_p","k_wc" = "k_wc",
           #                      "k_f2_a" = "k_f2_a", "k_f2_l" = "k_f2_l", "k_f2_p" = "k_f2_p","k_f2" = "k_f2",
           #                      "k_yc_a" =  "k_yc_a", "k_yc_p" = "k_yc_p","k_yc" = "k_yc",
           #                      "k_sr_a" = "k_sr_a", "k_sr_p" = "k_sr_p","k_sr" = "k_sr",
           #                      "k_erts_a" = "k_erts_a", "k_erts_l" = "k_erts_l", "k_erts_p" = "k_erts_p", "k_erts" = "k_erts",
           #                      "k_fck_a" = "k_fck_a", "k_fck_l" = "k_fck_l", "k_fck" = "k_fck",
           #                      "k_ch_a" = "k_ch_a", "k_ch_p1" = "k_ch_p1", "k_ch_p2" =  "k_ch_p2","k_ch" = "k_ch",
           #                      "k_dil_a" = "k_dil_a", "k_dil_l" = "k_dil_l", "k_dil_p" = "k_dil_p","k_dil" = "k_dil",
           #                      "k_meterL" = "k_meter3","k_meterP" = "k_meter2","k_meterAC" = "k_meter1", "k_meter" = "meter",
           #                       "temp" = "temp"
           #                       ),inline = TRUE)
           checkboxGroupInput("ColumnNames", "columnNames:",
                              c("M" = "k_m","A" = "k_a", "P" = "k_p", "L" = "k_l","WC" = "k_wc","F2" = "k_f2","YC" = "k_yc","SR" = "k_sr",
                                "ERTS" = "k_erts","FCK" = "k_fck","OFF" = "k_off", "CR" = "k_cr","CH" = "k_ch","DIL" = "k_dil","CLSRM" = "k_clsrm","LAB-OD" = "k_lab_od","SEIL" = "k_meter", 
                                
                                "wc_a" = "k_wc_a","f2_a" = "k_f2_a", "yc_a" =  "k_yc_a","sr_a" = "k_sr_a","erts_a" = "k_erts_a",
                                "fck_a" = "k_fck_a","off_a" = "k_off_a","cr_a1" = "k_cr_a1","cr_2" = "k_cr_a2","dil_a" = "k_dil_a","clsrm_ac1" = "k_clsrm_ac1","clsrm_ac2" = "k_clsrm_ac2","clsrm_ac3" = "k_clsrm_ac3","ch_a" = "k_ch_a",
                                "lab-od1" = "k_lab_od1","lab-od2" = "k_lab_od2","lab-od3" = "k_lab_od3", "meterAC" = "k_meter1",
                                
                                "wc_l" = "k_wc_l","f2_l" = "k_f2_l","erts_l" = "k_erts_l","fck_l" = "k_fck_l","off_l" = "k_off_l",  "dil_l" = "k_dil_l","meterL" = "k_meter3",
                                
                                "wc_p" = "k_wc_p","f2_p" = "k_f2_p", "yc_p" = "k_yc_p","sr_p" = "k_sr_p","erts_p" = "k_erts_p", 
                                 "ch_p1" = "k_ch_p1", "ch_p2" = "k_ch_p2","dil_p" = "k_dil_p",
                                "meterP" = "k_meter2"
                                
                              ),inline = TRUE)
    ),
    column(9,
           fluidRow(
             column(12,
                    textOutput("text1"),
                    #plotOutput("plot1")
                    # plotOutput("lineplt1")
                    plotlyOutput("lineplt1"
                              # brush = brushOpts(
                              # id = "lineplt1_brush",
                              # resetOnNew = TRUE
                               ))
             ) ,
           # fluidRow(
           #   column(12,
           #          textOutput("text2"),
           #          plotlyOutput("lineplt2")
           #          
           #   ) ),
           fluidRow(
             column(12,
                    plotlyOutput("lineplt3"
                             #  brush = brushOpts(
                            #     id = "lineplt3_brush",
                            #     resetOnNew = TRUE
                               ))
                    
             ) 
           # fluidRow(
           #   column(12,
           #          plotlyOutput("lineplt4")
           #          
           #   ) )
    )
  )
)
)
