# Karan app
library(shiny)
library(data.table)
library(fasttime) #for fastPosixct
library(ggplot2)
library(scales)
suppressWarnings(library(plotly))
options(shiny.maxRequestSize=100*1024^2)
rm(list=ls())
Sys.setenv(TZ="Asia/Kolkata")
shinyServer(
  
  function(input, output) {
    
    dframe <- reactive( {
      #inputfile <- input$infilepower
       validate(
         need(input$infilepower != "","Please select a data set")
       )
       
      dframe <- fread(input$infilepower$datapath, header = TRUE, sep = ",")
      dframe$timestamp <- fastPOSIXct(dframe$timestamp)-19800
     # dframe_xts <- xts(dframe$power,dframe$timestamp)
      dframe
    } )
    
    df <- reactive( {
      dframe <- dframe()
      if (input$specdaterange| input$specdate){
        if(input$specdaterange) {
          start_date = input$seldaterange[1]
          end_date =input$seldaterange[2]
          startdate <- fastPOSIXct(paste0(start_date,' ',"00:00:00"))-19800
          enddate <- fastPOSIXct(paste0(end_date,' ',"23:59:59"))-19800
        } else {
          datex = input$seldate
          startdate <- fastPOSIXct(paste0(datex,' ',"00:00:00"))-19800
          enddate <- fastPOSIXct(paste0(datex,' ',"23:59:59"))-19800
        }
        dframe <- dframe[dframe$timestamp >= startdate & dframe$timestamp <= enddate,] #reduced
      }
      dfs <- dframe
      dfs
    } )
    
    # this function calls df()[it keeps check on time range for displaying] which in turn call dframe[this function loads intially data from file]
    output$lineplt1 <- renderPlotly({
      df_sub <- df()
      colnames(df_sub) <- c("timestamp","Power")
      g <- ggplot(df_sub, aes(timestamp, Power))
      g <- g + geom_line() + labs(x = "", y ="power (Watts)")
      g <- g + scale_x_datetime(labels = date_format("%Y-%d-%b %H:%M",tz="Asia/Kolkata")) # use scales package
      g <- g + theme(axis.text.x = element_text(angle = 90,hjust = 1))
      ggplotly(g)
      #g
    })
    


    

    
  } )