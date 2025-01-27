## Import and merge hygrochron dataset, write to csv and plot
library("timeSeries")
library("scales")
library("ggplot2")
library("reshape2")

hyg.raw.path <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hygch/raw"
hyg.res.path <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hygch/csv"
hyg.raw.dirs <- dir(path=hyg.raw.path, full.names=TRUE)
hyg.csv.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hygch/csv/"
hyg.raw.fl.nme <- dir(path=hyg.raw.path, full.names=FALSE)
hyg.csv.fl.nme <- gsub("raw", "csv", hyg.raw.fl.nme)
hyg.csv.nme <- gsub(pattern=".csv", replacement="", x=hyg.csv.fl.nme)
hyg.csv.temp.fl.nme <- paste("temp_",hyg.csv.fl.nme, ".csv", sep="")
hyg.csv.humi.fl.nme <- paste("humi_",hyg.csv.fl.nme, ".csv",  sep="")
hyg.csv.fl.nme <- paste(hyg.csv.fl.nme, ".csv",  sep="")
hyg.temp.path <- paste(hyg.raw.dirs, "/temp", sep="")
hyg.humi.path <- paste(hyg.raw.dirs, "/humi", sep="")

merge.names <- c("Timestamp", "Temp_C", "RH_prec")
 merge.bs.tabs <- function(x, y, names){
        res <- merge(x, y, by="Date.Time", all=TRUE)
        res <- subset(res, select=c("Date.Time", "Value.x", "Value.y"))
        res <- res[complete.cases(res),]
        names(res) <- names
        return(res)
 }
    for(i in 1:length(hyg.temp.path)){
        hyg.temp.fl.nme <- list.files(path=hyg.temp.path[i], full.names=FALSE)
        hyg.humi.fl.nme <- list.files(path=hyg.humi.path[i], full.names=FALSE)
        hyg.temp.fl.path <- list.files(path=hyg.temp.path[i], full.names=TRUE)
        hyg.humi.fl.path <- list.files(path=hyg.humi.path[i], full.names=TRUE)
        for(j in 1:length(hyg.temp.fl.path)){
            assign(hyg.temp.fl.nme[j], read.csv(hyg.temp.fl.path[j], skip=19))
        }
        for(j in 1:length(hyg.humi.fl.path)){
            assign(hyg.humi.fl.nme[j], read.csv(hyg.humi.fl.path[j], skip=19))
        }
        temp <- do.call("rbind", lapply(hyg.temp.fl.nme, get))
        humi <- do.call("rbind", lapply(hyg.humi.fl.nme, get))
        temp$Date.Time <- as.POSIXct(temp$Date.Time, tz="Asia/Kolkata", format="%m/%d/%y %r")
        temp <- temp[order(temp$Date.Time),]
        temp <- temp[!duplicated(temp$Date.Time),]
        humi$Date.Time <- as.POSIXct(humi$Date.Time, tz="Asia/Kolkata", format="%m/%d/%y %r")
        humi <- humi[order(humi$Date.Time),]
        humi <- humi[!duplicated(humi$Date.Time),]
        temp.humi <- merge.bs.tabs(temp, humi, merge.names)
        temp.humi$Timestamp <- as.POSIXlt(round(as.numeric(temp.humi$Timestamp)/(15*60))*(15*60),
                                          tz="Asia/Kolkata", origin='1970-01-01') 
        ts.temp.humi <- as.timeSeries(temp.humi)
        write.csv(ts.temp.humi, "~/tmp/ts_todel.csv")
        ts.temp.humi$dt.tm<- row.names(ts.temp.humi)
        todel<-as.data.frame(ts.temp.humi)
        row.names(temp.humi)<- NULL
            
    
        ## assign(hyg.csv.nme[i], temp.humi) ## write to r object
        ## assign(hyg.csv.humi.fl.nme[i], humi) ## write to r object
        ## write.csv(file=paste(hyg.csv.dir, hyg.csv.temp.fl.nme[i], sep=""), temp) ## write to disk
        ## write.csv(file=paste(hyg.csv.dir, hyg.csv.humi.fl.nme[i], sep=""), humi) ## write to disk
       ##  write.csv(file=paste(hyg.csv.dir, hyg.csv.fl.nme[i], sep=""), temp.humi) ## write to disk
       ##  rm(humi, temp, temp.humi)
        ## rm(list=hyg.humi.fl.nme)
        ## rm(list=hyg.temp.fl.nme)
    }

ts.start.2014 <- as.POSIXct("2014-01-01 00:00:00", tz="Asia/Kolkata")
ts.end.2014 <- as.POSIXct("2014-04-30 23:59:59", tz="Asia/Kolkata")
ts.start.2015 <- as.POSIXct("2015-01-01 00:00:00", tz="Asia/Kolkata")
ts.end.2015 <- as.POSIXct("2015-04-30 23:59:59", tz="Asia/Kolkata")


##plot.temp <- function(x, ts.years, unit.name, data.type){
    ## for(n in 1:nrow(ts.years)){
        ## n <- 2
        ##yr <- ts.years$year[n]
        ##s.start <- ts.years$start[n]
        ##ts.end <- ts.years$end[n]
        x <- bs_101
        x <- subset(x, subset=(x$Timestamp >=ts.start.2014 & x$Timestamp <= ts.end.2014),
                    select=c("Timestamp","Temp_C","RH_prec"))
        gg.x <- melt(x, id.vars="Timestamp", measure.vars=c("Temp_C","RH_prec"),
                     variable.name="sensor", value.name="value")
        gg.x$Timestamp <- as.POSIXct(gg.x$Timestamp, tz="Asia/Kolkata")#, origin="1970-01-01")
        gg.x$dt <- as.Date(gg.x$Timestamp, format="%d-%b-%Y")

        plt.nm <- paste("plot_", yr, sep="")

        plt.nm <- ggplot( data = gg.x, aes(x=Timestamp, y=value, color=sensor)) +
            geom_line(size=2)+
           #  scale_x_date(labels = date_format("%d-%b-%Y")) +
            labs(x="Date", y="Daily T and RH in Catchment", color="Parameter") +
            theme_light()+
            
            theme(axis.title=element_text(size=10,face="bold"),
                  axis.text=element_text(size=8),
                  axis.text.x=element_text(angle=90, vjust=0.5, size=8),

                  panel.background = element_rect(fill = "transparent",colour = NA), # or theme_blank()
                                        #panel.grid.minor = element_blank(), 
                                        #panel.grid.major = element_blank(),
                  legend.background = element_rect(fill = "transparent",colour = NA),
                  plot.background = element_rect(fill = "transparent",colour = NA)
                  )
       plt.nm
       ##  return(plt.nm)
   ##  }
##}
