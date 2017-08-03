# ARAVALI APPLICATION
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
options(shiny.maxRequestSize=100*1024^2)
rm(list=ls())
Sys.setenv(TZ="Asia/Kolkata")
source("./Support_functions.R")
shinyServer(

  function(input, output) {
    
    dframe <- reactive( {
      inputfile <- input$infile
      validate(
        need(input$infile != "","Please select a data set")
      )
      dframe <- fread(input$infile$datapath, header = TRUE, sep = ",")
      dframe$timestamp <- fastPOSIXct(dframe$timestamp)-19800
      output$text1 <- renderText({
        paste("Input Dataset: FROM:", as.Date(dframe$timestamp[1],format="mm/dd/yy"), "TO", as.Date(dframe$timestamp[nrow(dframe)], format = "mm/dd/yy"),sep = "\t")
      })
      dframe
    } )
    
    df <- reactive( {
      dframe <- dframe()
      #str(dframe)
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
        # validate(
        #   need((start_date >= as.Date(dframe$timestamp[1]) && end_date <= as.Date(dframe$timestamp[nrow(dframe)])),"Select dates within valid range")
        # )
      #  dframe <- dframe[as.Date(dframe$timestamp) >= start_date & as.Date(dframe$timestamp) <= end_date,] #reduced frame
        dframe <- dframe[dframe$timestamp >= startdate & dframe$timestamp <= enddate,] #reduced
      }
      #if(input$timetype=="Default Sampling"){
      dfs <- dframe
      dfs
    } )
    
    output$lineplt1 <- renderPlotly({
      # df()
      df_long <- reshape2::melt(df(),id.vars = "timestamp")
      colourCount = length(unique(df_long$variable))
      
      #getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
      scheme <- iwanthue() # for distint colors
      getPalette = scheme$hex(colourCount)
     # browser()
      g <- ggplot(df_long, aes(timestamp, value, col = variable, group = variable))
      g <- g + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="power (W)")
      #g <- g + scale_x_datetime(breaks = date_breaks("1 hour"), labels = date_format("%d %H:%M",tz="CDT")) # use scales package
      g <- g + theme(axis.text.x = element_text(angle = 90,hjust = 1))
    ggplotly(g)
      #g
    })
  
    output$facetplt2 <- renderPlotly({
      if(input$perform_clustering){
        #cat("in clustering")
        distance_method <- input$distmethod
        clustering_method <- input$clusmethod
        no_clusters <- input$clusnumb
        override_cluster <- input$override_clusters
     #   if(override_cluster) {
      #    override_cluster <- TRUE
      #  } else{
      #    override_cluster <- FALSE
      #  }
      listob <- clustering_for_flats_withSurvey(df(),distance_method,clustering_method,no_clusters,override_cluster)
      h <- view_clusters_in_FACETS_decreasingorder(listob$returnob,listob$labels)
      ggplotly(h)
      }
      })
    
    output$facetplt4 <- renderDataTable({
      if(input$perform_clustering){
        distance_method <- input$distmethod
        clustering_method <- input$clusmethod
        no_of_clusters <- input$clusnumb
        override_cluster <- input$override_clusters
        listob <- clustering_for_flats_withSurvey(df(),distance_method,clustering_method,no_of_clusters,override_cluster)
        h <- view_energy_contribution(listob$returnob,listob$labels,listob$sframe)
        h
      }
    })
    
    output$lineplt5 <- renderPlotly({
      #  cat("sub")
      if (input$selectflats) {
        dframe <- as.data.frame(df())
        selectedNames <- input$checkboxgp1
        dframe_selected <- dframe[,c("timestamp",selectedNames)]
        df_long <- reshape2::melt(dframe_selected,id.vars = "timestamp")
        colourCount = length(unique(df_long$variable))
        getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
        #scheme <- iwanthue() # for distint colors
        #getPalette = scheme$hex(colourCount)
        p <- ggplot(df_long, aes(timestamp, value, col = variable, group = variable))
        p <- p + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="power (W)")
        p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) 
        ggplotly(p)
        
      } })
    
  } )