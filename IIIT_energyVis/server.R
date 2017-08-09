# IIITD EnergyVIS application
library(shiny)
library(data.table)
library(fasttime) #for fastPosixct
library(xts)
library(ggplot2)
library(scales)
library(rwantshue) # for distint colors https://github.com/hoesler/rwantshue
library(RColorBrewer)# to increas
suppressWarnings(library(plotly))
library(cluster)
options(shiny.maxRequestSize=500*1024^2)
rm(list=ls())
Sys.setenv(TZ="Asia/Kolkata")
#source("./Support_functions.R")
shinyServer(
  
  function(input, output) {
    
    dframe <- reactive( {
      inputfile <- input$infile
      validate(
        need(input$infile != "","Please select a data set")
      )
      dframe <- fread(input$infile$datapath, header = TRUE, sep = ",",showProgress = FALSE)
      print("data was read again")
      dframe$timestamp <- fastPOSIXct(dframe$timestamp)-19800
      dframe
    } )
    
    df <- reactive( {
      dframe <- dframe()
      #str(dframe)
      if (input$specdaterange| input$specdate){
        if(input$specdaterange) {
          start_date = input$seldaterange[1]
          end_date = input$seldaterange[2]
          print(start_date)
          print(end_date)
          startdate <- fastPOSIXct(paste0(start_date,' ',"00:00:00"))-19800
          enddate <- fastPOSIXct(paste0(end_date,' ',"23:59:59"))-19800
        }else {
          datex = input$seldate
          startdate <- fastPOSIXct(paste0(datex,' ',"00:00:00"))-19800
          enddate <- fastPOSIXct(paste0(datex,' ',"23:59:59"))-19800
        }
        dframe <- dframe[dframe$timestamp >= startdate & dframe$timestamp <= enddate,] #reduced
      }
      dfs <- dframe
      dfs
    } )
    
    output$lineplt2 <- renderPlotly({
      #  cat("sub")
      if (input$selectstreams) {
        dframe <- as.data.frame(df())
        selectedNames <- input$checkboxgp1
        dframe_selected <- dframe[,c("timestamp",selectedNames)]
        df_long <- reshape2::melt(dframe_selected,id.vars = "timestamp")
        colourCount = length(unique(df_long$variable))
        getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
        p <- ggplot(df_long, aes(timestamp, value, col = variable, group = variable))
        p <- p + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="Value")
        p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) 
        p
        ggplotly(p)
        
      } })
    
    output$textoutput <- renderPrint({
      df <- dframe()
      present_features <- colnames(df)
      cat(
        paste("Dataset FROM:", as.character(as.Date(df$timestamp[1])), "TO", as.character(as.Date(df$timestamp[nrow(df)]),sep = " ")),
        paste0(present_features)
        # #print(present_features)
        ,sep=";")
    })
    
    output$lineplt1 <- renderPlotly({
      if(input$plot_whole_data) {
        df_long <- reshape2::melt(df(),id.vars = "timestamp")
        colourCount = length(unique(df_long$variable))
        scheme <- iwanthue() # for distint colors
        getPalette = scheme$hex(colourCount)
        # browser()
        g <- ggplot(df_long, aes(timestamp, value, col = variable, group = variable))
        g <- g + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="Value")
        #g <- g + scale_x_datetime(breaks = date_breaks("1 hour"), labels = date_format("%d %H:%M",tz="CDT")) # use scales package
        g <- g + theme(axis.text.x = element_text(angle = 90,hjust = 1))
        # g
        ggplotly(g)
      } 
      
      # else if(input$specdaterange| input$specdate){
      #   df_long <- reshape2::melt(df(),id.vars = "timestamp")
      #   colourCount = length(unique(df_long$variable))
      #   scheme <- iwanthue() # for distint colors
      #   getPalette = scheme$hex(colourCount)
      #   # browser()
      #   g <- ggplot(df_long, aes(timestamp, value, col = variable, group = variable))
      #   g <- g + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="Value")
      #   #g <- g + scale_x_datetime(breaks = date_breaks("1 hour"), labels = date_format("%d %H:%M",tz="CDT")) # use scales package
      #   g <- g + theme(axis.text.x = element_text(angle = 90,hjust = 1))
      #   ggplotly(g)
      #   # g
      # }
    })
    
    
 

    
  } )