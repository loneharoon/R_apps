# kReSIT 
library(shiny)
library(data.table)
library(fasttime) #for fastPosixct
library(xts)
library(ggplot2)
library(fitdistrplus)
library(scales)
library(rwantshue) # for distint colors https://github.com/hoesler/rwantshue
library(RColorBrewer)# to increas
library(plotly)
#Sys.setenv(TZ="UTC")

options(shiny.maxRequestSize=100*1024^2)
Sys.setenv(TZ="Asia/Kolkata")
shinyServer(
  function(input, output) {
    dframe <- reactive( {
      inputfile <- input$infile
      validate(
        need(input$infile != "","Please select a data set")
      )
      dframe <- fread(input$infile$datapath, header = TRUE, sep = ",")
      dframe$timestamp <- fastPOSIXct(dframe$timestamp)-19800
      #   dframe <- dframe[ , which(!apply(dframe == 0, 2, all))] #only appliances which have data
      if(any(colnames(dframe) == "dataid")) {
        dframe <- subset(dframe, select = - dataid)
      }
      
      output$text1 <- renderText({
        paste("Input Dataset: FROM:", as.Date(dframe$timestamp[1],format="mm/dd/yy"), "TO", as.Date(dframe$timestamp[nrow(dframe)], format = "mm/dd/yy"),sep = "\t")
      })
      dframe
    } )
    
    df <- reactive( {
      dframe <- dframe()
      #str(dframe)
      if (input$specdate){
        start_date = input$seldate[1]
        end_date =input$seldate[2]
        validate(
          need((start_date >= as.Date(dframe$timestamp[1]) && end_date <= as.Date(dframe$timestamp[nrow(dframe)])),"Select dates within valid range")
        )
        dframe <- dframe[as.Date(dframe$timestamp) >= start_date & as.Date(dframe$timestamp) <= end_date,] #reduced frame
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
      g <- ggplot(df_long, aes(timestamp, value/1000, col = variable, group = variable))
      g <- g + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="power (kW)")
      #g <- g + scale_x_datetime(breaks = date_breaks("1 hour"), labels = date_format("%d %H:%M",tz="CDT")) # use scales package
      g <- g + theme(axis.text.x = element_text(angle = 90,hjust = 1))
 
      ggplotly(g)
    })
    
    # output$lineplt2 <- renderPlotly({
    #   output$text2 <- renderText({
    #     paste0("Zoom and Pan above window Plot :-) ")
    #   })
    #   #df()
    #   df_long <- reshape2::melt(df(),id.vars = "timestamp")
    #   colourCount = length(unique(df_long$variable))
    #   scheme <- iwanthue() # for distint colors
    #   getPalette = scheme$hex(colourCount)
    #  # getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
    #   p <- ggplot(df_long, aes(timestamp, value/1000, col = variable, group = variable))
    #   p <- p + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="power (kW)")
    #   p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) +
    #     coord_cartesian(xlim = ranges2$x, ylim = ranges2$y)
    #   ggplotly(p)
    # })
    
    output$lineplt3 <- renderPlotly({
      #  cat("sub")
      if (input$selectcolumns) {
        dframe <- as.data.frame(df())
        selectedNames <- input$ColumnNames
        dframe_selected <- dframe[,c("timestamp",selectedNames)]
        df_long <- reshape2::melt(dframe_selected,id.vars = "timestamp")
        colourCount = length(unique(df_long$variable))
        getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
        #scheme <- iwanthue() # for distint colors
        #getPalette = scheme$hex(colourCount)
        p <- ggplot(df_long, aes(timestamp, value/1000, col = variable, group = variable))
        p <- p + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="power (kW)")
        p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) 
        ggplotly(p)
        
      } })
    
    # output$lineplt4 <- renderPlotly({
    #   if (input$selectcolumns) {
    #     dframe <- as.data.frame(df())
    #     selectedNames <- input$ColumnNames
    #     dframe_selected <- dframe[,c("timestamp",selectedNames)]
    #     df_long <- reshape2::melt(dframe_selected,id.vars = "timestamp")
    #     colourCount = length(unique(df_long$variable))
    #     getPalette = colorRampPalette(brewer.pal(9, "Set1"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
    #    # scheme <- iwanthue() # for distint colors
    #   #  getPalette = scheme$hex(colourCount)
    #     p <- ggplot(df_long, aes(timestamp, value/1000, col = variable, group = variable))
    #     p <- p + geom_line() + scale_colour_manual(values = getPalette) + labs(y ="power (kW)")
    #     p <- p + theme(axis.text.x = element_text(angle=90,hjust=1)) 
    #     p <- p + coord_cartesian(xlim = ranges3$x, ylim = ranges3$y)
    #     ggplotly(p)
    #   }
    # })
    
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