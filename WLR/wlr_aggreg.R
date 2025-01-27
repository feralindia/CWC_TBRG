##----- aggregate the data and dump to csv and plots.----------------##

## foreach(i=1:length(num_wlr)) %dopar% {
for(i in 1:length(num_wlr)){
    cat(paste("Aggregating data for WLR station", num_wlr[i], sep=" "), sep="\n")
    wlr.merged.onemin<-paste("wlr_", num_wlr[i],"merged", sep="")
    wlr.merged <- get(wlr.merged.onemin)
    wlr.merged$date_time<-as.POSIXct(wlr.merged$date_time, tz="Asia/Kolkata")
    charvec <- wlr.merged$date_time
    wlr.raw.cal <- subset(wlr.merged, select=c("raw", "cal"))
    ts.wlrm <- timeSeries(data=wlr.raw.cal, charvec=charvec) 
    ## Start the aggregation
    agg <- c("1 min", "15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day", "15 day", "1 month")
    ## Organise data for ggplot
    gg.data <- data.frame(raw=numeric(0), cal=numeric(0), date_time=numeric(0), dt=numeric(), agg=character())
    for (j in 1: length(agg)){
        csvout <- paste(csvdir, loggers[i] ,"_", agg[j], ".csv", sep="")
        by <- timeSequence(from=start(ts.wlrm), to=end(ts.wlrm), by=agg[j]) ## , FinCenter="Asia/Calcutta")
        data <- aggregate(ts.wlrm, by, mean)
        data$date_time<-row.names(data)
        data <- as.data.frame(data)
        row.names(data) <- NULL
        data$date_time<-  as.POSIXct(data$date_time, tz="Asia/Kolkata", origin="1970-01-01") # add timestamp back to dataframe
        ## data <- data[-1,] 
        data$dt <- as.Date(data$date_time, "%Y-%m-%d")
        write.csv(data, file=csvout)
        data$agg <- agg[j]
        gg.data <- rbind(gg.data, data)
    }
    gg.data$agg <- factor(gg.data$agg, levels = c("1 min", "15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day", "15 day", "1 month"))
    plot.new()
    ## gg.data <- gg.data[!is.na(gg.data$cal),] ## remove NAs throws errors
    
    wlrplot <- ggplot( data = gg.data, aes( dt, cal )) + geom_line()  +
        scale_x_date(labels = date_format("%d-%b-%Y")) + ##breaks = "1 week", minor_breaks = "1 day", 
        facet_wrap(~agg, scales = "free_y", shrink=FALSE) + ggtitle(loggers[i]) +
            labs(x="Date", y="Average stage in m") +
                theme(axis.title=element_text(size=10,face="bold"),
                      axis.text=element_text(size=8),
                      axis.text.x=element_text(angle=90, vjust=0.5, size=8))
    pngfile <- paste(figdir, loggers[i], ".png", sep="")
    epsfile <- paste(figdir, loggers[i], ".eps", sep="")
    ggsave(wlrplot, filename=pngfile, width=297, height=210, units="mm")
    ggsave(wlrplot, filename=epsfile, width=297, height=210, units="mm")
    wlrplot
    cat(paste("WLR station", num_wlr[i], "processed", sep=" "), sep="\n")
}
