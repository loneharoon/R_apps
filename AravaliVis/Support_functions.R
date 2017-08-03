view_profiles_in_FACETS_decreasingorder <- function (df,labels) {
  # this function plots the representative/generalized clusters in facet form. We plot profiles in decreasing order
  #rm(list=ls())
  #browser()
  cat("step6")
  df_form <- data.frame(timestamp = index(df),coredata(df))
  df_long <- reshape2::melt(df_form,id.vars = "timestamp")
  df_long$cluslabel <- rep(labels, each = dim(df)[1])
  unique_labels <- gtools::mixedsort(unique(labels))
  suppressWarnings(rm("return_df"))
  cat("step6A")
  for (h in 1:length(unique_labels)) { 
    tt <- df_long[df_long$cluslabel == unique_labels[h],]
    
    tt <- subset(tt, select = - cluslabel)
    temp <- reshape2::dcast(tt, timestamp ~ variable)
    temp_xts <- xts(data.frame(temp[, 2:dim(temp)[2]]), fastPOSIXct(temp[,1]) - 19800)
    if(!exists("return_df")) {
      return_df <- xts(data.frame(power = rowMeans(temp_xts, na.rm = TRUE), cluster =  as.numeric(unique_labels[h])),index(temp_xts))
    } else {
      tempob <- xts(data.frame(power = rowMeans(temp_xts, na.rm = TRUE), cluster =  as.numeric(unique_labels[h])),index(temp_xts))
      return_df <- rbind(return_df,tempob)
    } 
  }
  stopifnot(length(unique(lubridate::day(return_df)))==1)
  df_frame <- data.frame(timestamp = index(return_df),coredata(return_df) )
  # Arrange cluster labels accroding to decreasing order with respect to cluster population size
  clusterorder <- order(table(labels), decreasing = TRUE)
  df_frame$cluster <- factor(df_frame$cluster,levels = clusterorder)
  elem_count <- sort(table(labels),decreasing = TRUE)
  #browser()
  g <- ggplot(df_frame, aes(timestamp, power)) + facet_wrap(~ cluster,nrow=2)
  g <- g + geom_line()  + labs(y ="Power (Watts)",x="Hour of day")
  g <- g + scale_x_datetime(breaks = date_breaks("2 hour"), labels = date_format("%H",tz="Asia/Kolkata")) # use scales package
  g <- g + annotate("text",x = df_frame$timestamp[11] ,y = max(df_frame$power)-100, label = elem_count,color="red",size=6)
  return(g)
}

view_clusters_in_FACETS_decreasingorder <- function (df,labels) {
  # this function plots the representative/generalized clusters in facet form. We plot profiles in decreasing order
  df_form <- data.frame(timestamp = index(df),coredata(df))
  df_long <- reshape2::melt(df_form,id.vars = "timestamp")
  df_long$cluslabel <- rep(labels, each = dim(df)[1])
  
  
  clusterorder <- order(table(labels), decreasing = TRUE)
  df_long$cluslabel <- factor(df_long$cluslabel,levels = clusterorder)
  elem_count <- sort(table(labels),decreasing = TRUE)
  
  
  g <- ggplot(df_long, aes(timestamp, value,color=cluslabel,group=variable)) + facet_wrap(~ cluslabel,nrow=2)
  g <- g + geom_line()  + labs(y ="Power (W)",x="Hour of day")
  g <- g + scale_x_datetime(breaks = date_breaks("2 hour"), labels = date_format("%H",tz="Asia/Kolkata")) # use scales package
  g <- g + annotate("text",x = df_long$timestamp[11] ,y = max(df_long$value)-100, label = elem_count,color="red",size=6)
  g
  #g <- g + annotate("text",x = df_frame$timestamp[11] ,y = max(df_frame$power)-100, label = elem_count,color="red",size=6)
  return(g)
}

clustering_for_flats_withSurvey <- function(df,distance_method,clustering_method,no_clusters,override_cluster) {
  library(dtw)
  library(fpc)
  cat(override_cluster)
  #cat(dim(df))
  dfs <-  xts(df[,2:dim(df)[2]],fastPOSIXct(df$timestamp)-19800)
  
  surfile <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/aravali_iitb/surveydata.csv"
  sfile <- read.csv(surfile)
  #colnames(sfile)
  sframe <- sfile[,c(8,1,3,4,5)]
  sframe$flatId <- paste0('F',sframe$flatId)
  sframe$total <- rowSums(sframe[,2:5])
  sframe <- sframe[order(sframe[,1]),]
  #pdf("survey.pdf",height = 14,width=9)
  #gridExtra::grid.table(sframe,rows=NULL)
  #dev.off()
  
  #table(duplicated(sframe$flatId))
  # Keep only those homes for which we have survey data
  drop_homes <- c("F209","F239","F216")
  dfs <- dfs[,!colnames(dfs) %in% drop_homes]
  cat(paste0("Dropped ",drop_homes))
  subset2 <- dfs[,colnames(dfs) %in% sframe$flatId]
  cat("step2")
  # browser()
  suppressWarnings(rm("returnob"))
  for (i in 1:dim(subset2)[2]) {
    # 1: compute mean across all days and REMEMBER time is set to first day of series
    # 2: Combine all meters in matrix form
    # cat(i)
    sub <- split.xts(subset2[,i], f = "days", k = 1)
    sub_mean <- rowMeans(sapply(sub, function(y) return(coredata(y))),na.rm = TRUE)
    sub_xts <- xts(round(sub_mean,2),index(sub[[1]]))
    
    if(!exists("returnob")) {
      returnob <- sub_xts
    } else {
      returnob<- cbind(returnob,sub_xts) 
    }
  }
  # browser()
  colnames(returnob) <- colnames(subset2)
  # view_data(returnob)
  set.seed(123)
  # customized scaling:  http://stackoverflow.com/a/15364319/3317829 
  scaled_ob <- apply(returnob,2,function(y) (y-mean(y))/sd(y)^as.logical(sd(y)))
  if(override_cluster){
    no_of_clusters <- no_clusters
  } else{
    no_of_clusters <- pamk(t(scaled_ob))$nc
    if(no_of_clusters > 3)
      no_of_clusters = 3
  }
  distmat <- dist(t(scaled_ob),method = distance_method)
  
  if(clustering_method=="PAM"){
    clusob <- pam(distmat,no_of_clusters)
  } else{
    clusob <- kmeans(distmat,no_of_clusters)
  }
  
  labels <- as.factor(clusob$cluster)
  # add cluster no. to each row in sframe
  sframe$cluster <- clusob$cluster[sframe$flatId]
  # view_clustering_result(returnob,labels)
  #  view_distriubtion_bands(returnob,labels)
  # create profiles
  # view_profiles_in_FACETS_decreasingorder(returnob,labels)
  #view_energy_contribution(returnob,labels,sframe)
  #cat("step4")
  return(list(returnob=returnob,labels=labels,sframe=sframe))
}

view_energy_contribution <- function(df,labels, sframe) {
  #this function shows consumption of each cluster and a table with statistics
  df_form <- data.frame(timestamp = index(df),coredata(df))
  df_long <- reshape2::melt(df_form,id.vars = "timestamp")
  df_long$cluslabel <- rep(labels, each = dim(df)[1])
  
  # Let us  construct a table which will show the %age of energy consumed by a cluster against 
  # the aggregate
  agg_consump <- xts(rowSums(df,na.rm = FALSE),index(df))
  clusters <- gtools::mixedsort(unique(df_long$cluslabel))
  # st_features = list(meanf=vector(),sdf= vector(),skewf=vector(),kurtf= vector())
  st_features = list(meanf=vector(),sdf= vector())
  
  for(i in 1:length(clusters)) {
    #browser()
    dat <- df_long[df_long$cluslabel==as.factor(clusters[i]),]
    temp <- reshape2::dcast(dat,timestamp~variable)
    temp_data <- subset(temp,select = -timestamp)
    #temp_xts <- xts(temp_data,temp$timestamp)
    temp_xts <- xts(rowSums(temp_data,na.rm = FALSE),temp$timestamp)
    agg_consump <- cbind(agg_consump,temp_xts)
    st_features$meanf[i] <- mean(as.matrix(temp_data),na.rm = TRUE)
    st_features$sdf[i] <- sd(as.matrix(temp_data),na.rm = TRUE)
    #st_features$skewf[i] <- moments::skewness(as.matrix(temp_data),na.rm = TRUE)
    #st_features$kurtf[i] <- moments::kurtosis(as.matrix(temp_data),na.rm = TRUE)
  }
  colnames(agg_consump) <- c("Aggregate",c(1:length(clusters)))
  #percentage energy consumed by each cluster against the total consumption of building
  per_contribuion <- apply(agg_consump[,2:dim(agg_consump)[2]],2,function(x) mean(x/agg_consump[,1])*100)
  tab_stat <- data.frame(table(labels),round(per_contribuion,2),round(st_features$meanf,2),round(st_features$sdf,2)) 
  #tab_stat <- data.frame(table(labels),round(per_contribuion,2),round(st_features$meanf,2),round(st_features$sdf,2))
  
  #colnames(tab_stat) <- c("Cluster#","Apartments","Energy_Consumed(%)","Mean","SD","SKew","Kurt")
  colnames(tab_stat) <- c("Cluster#","Apartments","Energy_Consumed(%)","Mean","SD")
  
  # Add no. of people to each residing in each cluster
  sframe$cluster <- as.factor(sframe$cluster)
  clnames <- gtools::mixedsort(unique(labels))
  tab_stat$people <- sapply(clnames,function(x) {
    colSums(sframe[sframe$cluster == x,]["total"],na.rm = TRUE)
  })
  member <- lapply(clusters, function(x) {
    mems = as.list(na.omit(sframe[sframe$cluster==x,]$flatId))
    mems <- do.call(paste,mems)
    #temp[temp$`Cluster#`==x,]$members = mems
  })
  #browser()
  tab_stat$member <- member
  # tbl <- tableGrob(tab_stat,rows = NULL,theme=ttheme_default(base_size = 8,padding = unit(c(3, 3), "mm")))
  # tbl <- tableGrob(tab_stat,rows = NULL)
  #return(tbl)
  #  tab <- knitr::kable(temp)
  return(tab_stat)
  #library(gridExtra)
  #return(arrangeGrob(g,tbl,as.table=FALSE,nrow=2,heights = c(4,4),widths=c(8,3)))
}

PREV_view_energy_contribution <- function(df,labels, sframe) {
  #this function shows consumption of each cluster and a table with statistics
  df_form <- data.frame(timestamp = index(df),coredata(df))
  df_long <- reshape2::melt(df_form,id.vars = "timestamp")
  df_long$cluslabel <- rep(labels, each = dim(df)[1])
  
  # Let us  construct a table which will show the %age of energy consumed by a cluster against 
  # the aggregate
  agg_consump <- xts(rowSums(df,na.rm = FALSE),index(df))
  clusters <- gtools::mixedsort(unique(df_long$cluslabel))
  for(i in 1:length(clusters)) {
    dat <- df_long[df_long$cluslabel==as.factor(clusters[i]),]
    temp <- reshape2::dcast(dat,timestamp~variable)
    temp_data <- subset(temp,select = -timestamp)
    #temp_xts <- xts(temp_data,temp$timestamp)
    temp_xts <- xts(rowSums(temp_data,na.rm = FALSE),temp$timestamp)
    agg_consump <- cbind(agg_consump,temp_xts)
  }
  colnames(agg_consump) <- c("Aggregate",c(1:length(clusters)))
  #percentage energy consumed by each home against the total consumption of building
  per_contribuion <- apply(agg_consump[,2:dim(agg_consump)[2]],2,function(x) mean(x/agg_consump[,1])*100)
  tab_stat <- data.frame(table(labels),round(per_contribuion,2)) 
  colnames(tab_stat) <- c("Cluster#","Apartments","Energy_Consumed(%)")
  
  # Add no. of people to each residing in each cluster
  sframe$cluster <- as.factor(sframe$cluster)
  clnames <- gtools::mixedsort(unique(labels))
  tab_stat$people <- sapply(clnames,function(x) {
    colSums(sframe[sframe$cluster == x,]["total"],na.rm = TRUE)
  })
  member <- lapply(clusters, function(x) {
    mems = as.list(na.omit(sframe[sframe$cluster==x,]$flatId))
    mems <- do.call(paste,mems)
    #temp[temp$`Cluster#`==x,]$members = mems
  })
  #browser()
  tab_stat$member <- member
  # tbl <- tableGrob(tab_stat,rows = NULL,theme=ttheme_default(base_size = 8,padding = unit(c(3, 3), "mm")))
  # tbl <- tableGrob(tab_stat,rows = NULL)
  #return(tbl)
  #  tab <- knitr::kable(temp)
  return(tab_stat)
  #library(gridExtra)
  #return(arrangeGrob(g,tbl,as.table=FALSE,nrow=2,heights = c(4,4),widths=c(8,3)))
}

