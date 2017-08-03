
# WEATHER APPLICATION
library(shiny)
library(data.table)
library(fasttime) #for fastPosixct
library(xts)
library(ggplot2)
library(fitdistrplus)
library(scales)
library(plotly)
options(shiny.maxRequestSize=1000*1024^2)
Sys.setenv(TZ="Asia/Kolkata")
shinyServer(
  function(input, output) {
    
    
    dframe<- reactive({
      inputfile <- input$infile
      validate(
        need(input$infile != "","Please select a data set")
      )
      
      dframe<-fread(input$infile$datapath,header=TRUE, sep=",")
      dframe$timestamp <- fastPOSIXct(dframe$timestamp)-19800 #subtracting 5:30 hrs
      output$text1 <- renderText({
        paste("Input Dataset: FROM:", as.Date(dframe$timestamp[1],format="mm/dd/yy",tz="Asia/Kolkata"), "TO", as.Date(dframe$timestamp[nrow(dframe)],format="mm/dd/yy",tz="Asia/Kolkata"),sep="\t")
        
      })
      dframe
    })
    df <- reactive( {
      dframe <- dframe()
      #str(dframe)
      if(input$specdate) {
        start_date = input$seldate[1]
        end_date =input$seldate[2]
        validate(
          need((start_date >= as.Date(dframe$timestamp[1]) && end_date <= as.Date(dframe$timestamp[nrow(dframe)])),"Select dates within valid range")
        )
        dframe<- dframe[as.Date(dframe$timestamp) >=start_date & as.Date(dframe$timestamp)<=end_date,] #reduced frame
      }
      
      if(input$timetype=="Default Sampling"){
        dfs <- dframe
      }
      if(input$timetype=="Hourly"){ 
        # dfs<-setDT(dframe)[, list(power= mean(power)) ,(timestamp = cut(timestamp, 'hour'))]
        #  dfs$timestamp <- as.POSIXct(dfs$timestamp) 
        x <- xts(dframe$TemperatureC,dframe$timestamp)
        #pay attention to 3600*0.5 please refer to: http://goo.gl/1Q1Xod
        dfs <- period.apply(x, endpoints(index(x)-3600*0.5, "hours"), mean)
        dfs <- data.frame(timestamp=trunc(index(dfs),'hours'), TemperatureC=coredata(dfs)) 
      } 
      else if(input$timetype=="Daily"){ 
        x <- xts(dframe$TemperatureC,dframe$timestamp)
        dfs <- period.apply(x, endpoints(x, "days"), mean)
        dfs <- data.frame(timestamp=trunc(index(dfs),'days'), TemperatureC=coredata(dfs)) 
        #with data.table dfs<-setDT(dframe)[, list(power= mean(power)) ,(timestamp= as.POSIXct(cut(timestamp, 'day')))]
      }
      else if(input$timetype == "Monthly"){ #NOT IMPLEMENTED FULL TILL NOW
        x <- xts(dframe$TemperatureC,dframe$timestamp)
        dfs <- period.apply(x, endpoints(x, "months"), mean, na.rm=TRUE)
        dfs <- data.frame(timestamp=index(dfs), TemperatureC=coredata(dfs))
        
      }
      
      dfs
    })
    
    output$lineplt1 <- renderPlotly({
      
      if(input$timetype == "Default Sampling") {
        # this if class is introduced only to differentiate the missing data. issue highligted as
        # http://stackoverflow.com/q/40087340/3317829
        p <- ggplot(df(),aes(timestamp,TemperatureC,group = 1))+ theme_bw() + geom_line()+
          theme(axis.text.x = element_text(angle=90,hjust=1)) 
        p <- p+scale_x_datetime(labels = date_format("%d-%b %H")) #breaks="3 day"
      } else {
        datframe <- df()
        datframe$grp <- factor( c(0,cumsum(diff(datframe$timestamp) > 1) ) )
        p <- ggplot(datframe,aes(timestamp,TemperatureC,group = 1))+ theme_bw() 
        if(input$timetype == "Monthly") {
          p <- p + geom_line()
        } else {
          p <- p + geom_line(aes(group=grp))
        }
        p <-  p + theme(axis.text.x = element_text(angle=90,hjust=1)) 
        p <- p+scale_x_datetime(labels = date_format("%d-%b")) # breaks="3 day"
        # if(input$timetype == "Daily")
        # else
        # p <- p+scale_x_datetime(labels = date_format("%d-%b")) #breaks="3 day
      }
      
      ggplotly(p)
      
    })

    

  })