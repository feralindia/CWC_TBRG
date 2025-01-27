## Aggregate tbrg output into various periods
print(paste("Aggregating data for TBRG No.", num_tbrg[i], sep=" "))
charvec <- tbrg.merged$dt.tm
tbrg.merged <- subset(tbrg.merged, select=c("tips", "mm"))
ts.tbrg <- timeSeries(data=tbrg.merged, charvec=charvec)
start.ts.tbrg <- "2012-08-15 00:00:00"
agg <- c("1 min","15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day", "15 day", "1 month")
gg.data <- data.frame(raw=numeric(0), cal=numeric(0), date_time=numeric(0), dt=numeric(), agg=character())
## setRmetricsOptions(myFinCenter = "GMT") ## Need to do this or timeSequence will mess up
for (j in 1: length(agg)){
    csvout <- paste(csvdir, tbrgtab,"_", agg[j], ".csv", sep="")
    by <- timeSequence(from=start.ts.tbrg, to=end(ts.tbrg), by=agg[j]) ##, FinCenter = "Asia/Calcutta"
    ## note, by changed from start(ts.tbrg) to fixed date/time for standardisation
    data <- aggregate(ts.tbrg, by, sum)
    data$dt.tm<-row.names(data)
    data <- as.data.frame(data)
    row.names(data) <- NULL
    data$dt.tm<-  as.POSIXct(data$dt.tm, tz="Asia/Kolkata", origin="1970-01-01") # add timestamp back to dataframe
    ## data$dt.tm <- data$dt.tm + 19800 ## add five and half hours to make it IST
    write.csv(data, file=csvout)
    data$dt <- as.Date(data$dt.tm, "%Y-%m-%d")
    data$agg <- agg[j]
    gg.data <- rbind(gg.data, data)
}
gg.data$agg <- factor(gg.data$agg, levels = c("1 min", "15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day", "15 day", "1 month"))
plot.new()
tbrgplot <- ggplot( data = gg.data, aes( dt, mm )) + geom_line()  +
    facet_wrap(~agg, scales = "free_y") + ggtitle(tbrgtab) +
    labs(x="Date", y="Sum rainfall in mm") +
    theme(axis.title=element_text(size=10,face="bold"),
          axis.text=element_text(size=8))
pngfile <- paste(figdir, tbrgtab, ".png", sep="")
epsfile <- paste(figdir, tbrgtab, ".eps", sep="")
pdffile <- paste(figdir, tbrgtab, ".pdf", sep="")
ggsave(tbrgplot, filename=pngfile, width=397, height=210, units="mm")
ggsave(tbrgplot, filename=epsfile, width=297, height=210, units="mm")
ggsave(tbrgplot, filename=pdffile, width=297, height=210, units="mm")
tbrgplot
print(paste("Finished aggregating data for TBRG No.", num_tbrg[i], sep=" "))
