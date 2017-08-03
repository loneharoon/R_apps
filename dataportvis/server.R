# DATAPORT VISUALIZATION
#setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/apps")
library(shiny)
library(data.table)
library(fasttime) #for fastPosixct
library(xts)
library(ggplot2)
suppressWarnings(library(plotly))
library(fitdistrplus)
library(scales)
library(RColorBrewer)# to increas
#Sys.setenv(TZ="UTC")

options(shiny.maxRequestSize=100*1024^2)
#Sys.setenv(TZ="Asia/Kolkata")
shinyServer(
  function(input, output) {
    dframe <- reactive( {
      inputfile <- input$infile
      validate(
        need(input$infile != "","Please select a data set")
      )
      dframe <- fread(input$infile$datapath, header = TRUE, sep = ",")
      dframe$localminute <- fastPOSIXct(dframe$localminute)-19800 # TIMEZONE OF AUSTIN : CDT
   #   dframe <- dframe[ , which(!apply(dframe == 0, 2, all))] #only appliances which have data
      if(any(colnames(dframe) == "dataid")) {
        dframe <- subset(dframe, select = - dataid)
      }
      
      output$text1 <- renderText({
        paste("Input Dataset: FROM:", as.Date(dframe$localminute[1],format="mm/dd/yy"), "TO", as.Date(dframe$localminute[nrow(dframe)], format = "mm/dd/yy"),sep = "\t")
      })
      dframe
    } )
    ######## new one#######
    df <- reactive( {
      dframe <- dframe()
      #str(dframe)
      if (input$specdaterange| input$specdate){
       # browser()
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
        dframe <- dframe[dframe$localminute >= startdate & dframe$localminute <= enddate,] #reduced
      }
      dfs <- dframe
      dfs
    } )
    ######## end new one#####
    
    # df <- reactive( {
    #   dframe <- dframe()
    #   #str(dframe)
    #   if (input$specdate){
    #     start_date = input$seldate[1]
    #     end_date =input$seldate[2]
    #     validate(
    #       need((start_date >= as.Date(dframe$localminute[1]) && end_date <= as.Date(dframe$localminute[nrow(dframe)])),"Select dates within valid range")
    #     )
    #     dframe <- dframe[as.Date(dframe$localminute) >= start_date & as.Date(dframe$localminute) <= end_date,] #reduced frame
    #   }
    #   #if(input$timetype=="Default Sampling"){
    #   dfs <- dframe
    #   dfs
    # } )
    
    output$lineplt1 <- renderPlotly({
     # df()
      df_long <- reshape2::melt(df(),id.vars = "localminute")
      colourCount = length(unique(df_long$variable))
      getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
      g <- ggplot(df_long, aes(localminute, value, col = variable, group = variable))
      g <- g + geom_line() + scale_colour_manual(values = getPalette)
      #g <- g + scale_x_datetime(breaks = date_breaks("1 hour"), labels = date_format("%d %H:%M",tz="CDT")) # use scales package
      g <- g + theme(axis.text.x = element_text(angle = 90,hjust = 1))
      ggplotly(g) 
      
    })
    
    output$lineplt2 <- renderPlot({
      output$text2 <- renderText({
        paste0("Zoom and Pan above window Plot :-) ")
      })
      #df()
      df_long <- reshape2::melt(df(),id.vars = "localminute")
      colourCount = length(unique(df_long$variable))
      getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
      p <- ggplot(df_long, aes(localminute, value, col = variable, group = variable))
      p <- p + geom_line() + scale_colour_manual(values = getPalette)
      p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) +
        coord_cartesian(xlim = ranges2$x, ylim = ranges2$y)
      p
    })
    
    output$lineplt3 <- renderPlotly({
      #  cat("sub")
      if (input$selectcolumns) {
        dframe <- as.data.frame(df())
        selectedNames <- input$ColumnNames
        dframe_selected <- dframe[,c("localminute",selectedNames)]
        df_long <- reshape2::melt(dframe_selected,id.vars = "localminute")
        colourCount = length(unique(df_long$variable))
        getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
        p <- ggplot(df_long, aes(localminute, value, col = variable, group = variable))
        p <- p + geom_line() + scale_colour_manual(values = getPalette)
        p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) 
        ggplotly(p)
      } })
    
    output$lineplt4 <- renderPlot({
      if (input$selectcolumns) {
        dframe <- as.data.frame(df())
        selectedNames <- input$ColumnNames
        dframe_selected <- dframe[,c("localminute",selectedNames)]
        df_long <- reshape2::melt(dframe_selected,id.vars = "localminute")
        colourCount = length(unique(df_long$variable))
        getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
        p <- ggplot(df_long, aes(localminute, value, col = variable, group = variable))
        p <- p + geom_line() + scale_colour_manual(values = getPalette)
        p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) 
        p <- p + coord_cartesian(xlim = ranges3$x, ylim = ranges3$y)
        p
      }
    })
    
    ranges2 <- reactiveValues( x = NULL, y = NULL)
    ranges3 <- reactiveValues( x = NULL, y = NULL)
    
    observe( {
      brush <- input$lineplt1_brush
      if (!is.null(brush)) {
        ranges2$x <- c(as.POSIXct(brush$xmin,origin="1970-01-01"), as.POSIXct(brush$xmax,origin="1970-01-01"))
        # print(as.POSIXct(brush$xmin,origin="1970-01-01"))
        #print(as.POSIXct(brush$xmax,origin="1970-01-01"))
        ranges2$y <- c(brush$ymin, brush$ymax)
      } else {
        ranges2$x <- NULL
        ranges2$y <- NULL
      }
    })
    
    observe( {
      brush2 <- input$lineplt3_brush
      if (!is.null(brush2)) {
        ranges3$x <- c(as.POSIXct(brush2$xmin,origin="1970-01-01"), as.POSIXct(brush2$xmax,origin="1970-01-01"))
        #  print(as.POSIXct(brush2$xmin,origin="1970-01-01"))
        # print(as.POSIXct(brush2$xmax,origin="1970-01-01"))
        ranges3$y <- c(brush2$ymin, brush2$ymax)
      } else {
        ranges3$x <- NULL
        ranges3$y <- NULL
      } } )
    
    
  } )