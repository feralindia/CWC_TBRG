## This script converts the x,y coordinates from a CSV file into area measured in cm2
## Note: the stage is taken from the timestamp on the WLR cx header.

## @knitr chunk1

for (i in 1:length(pyg.dir)){
    cat(paste("Processing", pyg.id[i], sep=" "), sep="\n")
    res <- as.data.frame(matrix(ncol = 7)) # 5 col matrix to hold final results
    tmp.res <- as.data.frame(matrix(ncol = 10)) # 8 col matrix to hold temporary results
    prf.res <- as.data.frame(matrix(ncol = 10)) # 8 col matrix to hold profile results
    ## give names to cols
    names(res) <- c("Sl.No.", "site", "obs.file", "method", "stage", "avg.disch","timestamp")
    names(tmp.res) <- c("Sl.No.", "site", "obs.file", "method", "stage", "cx.no", "cx.area", "avg.vel", "avg.disch","timestamp")
    names(prf.res) <- c("Sl.No.", "site", "obs.file", "method", "stage", "cx.no", "cx.area", "avg.vel", "avg.disch","timestamp")
    
    ## @knitr chunk2
    ## Ensure the cx.flst and cxx.fixflst have the same number of entries
    cx.flst <- list.files(path=cx.drlst[i], pattern=".csv$", ignore.case=TRUE)
    cx.fldirlst  <- list.files(path=cx.drlst[i], full.names=TRUE, pattern=".csv$", ignore.case=TRUE)
    cx.fixflst <- list.files(path=cxfix.drlst[i], pattern=".csv$", ignore.case=TRUE)
    cx.fixfldirlst  <- list.files(path=cxfix.drlst[i], full.names=TRUE, pattern=".csv$", ignore.case=TRUE)
    pyg.flst <- list.files(path=pyg.dir[i], pattern=".csv$", full.names=TRUE, ignore.case=TRUE)
    
    ## loop for profiles and velocities
    for (j in 1: length(cx.flst)){
        if(cx.flst[j]==cx.fixflst[j]){
            cat(paste("Processing file:", cx.flst[j], pyg.loc[i],  sep=" "), sep="\n")
        } else {
            stop(paste("File name mismatch, pygmy and cx file is", cx.flst[j], "but cx_sec file is", cx.fixflst[j]))
        }
        tmp <- read.csv(file=cx.fldirlst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        crd <- subset(tmp, select=c(Length, Depth)) # extract coordinates
        rw.crd <- nrow(crd)
        crd[rw.crd+1, ] <- c(0, 0) # close the polygon
        crd[ , 2] <- crd[ , 2]*-1 # covert y values to negative (depth)
        gpc.crd <- as(crd, "gpc.poly") # convert to a gpc.poly object
        ##---get the timestamp
        cxt <- read.csv(cx.fldirlst[j], header=FALSE)
        tmp$dt  <- cxt[2,2, drop=TRUE]
        tmp$tm  <- cxt[3,2, drop=TRUE]
        ## some entries have time in 24 hrs but with PM or AM next to it
        tmp$tm <- fix.time(tmp$tm)
        tmp$dt <- as.Date(tmp$dt, format="%d/%m/%y")
        tmp <- transform(tmp, dt.tm = paste(dt, tm, sep=' '))
        tmp$dt.tm <- as.POSIXct(tmp$dt.tm, format="%Y-%m-%d %I:%M:%S %p", tz="Asia/Kolkata") ## format converts from pm
        stn.obj <- paste(stn.id[i], ".stage", sep="") 
        stg <- get(stn.obj)
        stg$dt.tm <- as.POSIXct(stg$dt.tm, format="%Y-%m-%d %I:%M:%S %p", tz="Asia/Kolkata") ## not needed
        tmp.mrg <- merge(tmp, stg, by="dt.tm", all=FALSE)
        tmp.mrg <- tmp.mrg[1,] ## uncomment if you want only one row
        if (nrow(tmp.mrg) > 0){
            stage <- tmp.mrg$cal ##[[1]]
            timestamp <- tmp.mrg$dt.tm
        }  else {
            stage <- NA
            timestamp <- NA
        }
        ## @knitr chunk3
        ## initialise png dump for cx
        
        mn <- paste("Site: ", pyg.loc[i], "|| File: ",cx.flst[j], sep=" ") # create title
        figout <- paste(str_sub(cx.fldirlst[j], end = -5L), ".png", sep="") # output destination
        cx.fig <- paste(str_sub(cx.flst[j], end =-5L), ".png", sep="") # names for cross section output
        cx.figout <- paste(cx.pyg.res[i], cx.fig, sep="/")
        cx.csvout <- paste(cx.pyg.res[i], "/cx_results.csv", sep="")
        cx.shapeout <- paste(cx.shape[i], substrLeft(cx.flst[j],4), sep="/")
        ## postscript(figout, horizontal=TRUE, onefile=TRUE) # eps output parameters
        CairoPNG(filename=cx.figout, width=640, height=480, units="px", pointsize=12, onefile = TRUE) # png output parameters
        
        plot(gpc.crd, xlab="Stream Width (cm)", ylab="Stream Depth (cm)", main=mn, add = FALSE) # plot the cx
        tmp.pyg <- read.csv(file=pyg.flst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        names(tmp.pyg) <- c("Sl.No.", "Length", "Depth", "Measure.Depth", "vel.rd1", "vel.rd2", "vel.rd3")

        ## @knitr chunk4
        ## calculate the average velocities of the cross sectional profiles
        ## It is assumed that the number of stream profiles and velocity measures are the same
        ## Note: naming is alpha numerical such as a6, b6, a2, a8, b2, b8 where 6 is 60% height, 2 is 20% and 8, 80%
        
        vel6 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==6 | (substr(Sl.No.,2,2)=="")), select=c(vel.rd1, vel.rd2, vel.rd3)) ## changed 26Nov14
        vel2 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==2), select=c(vel.rd1, vel.rd2, vel.rd3))##### ## changed 26Nov14
        vel8 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==8), select=c(vel.rd1, vel.rd2, vel.rd3)) ## changed 26Nov14
        
        ## 1) averages are produced for three readings
        ## 2) we have variable number of reaches per stream each has specific cx and cx.area
        ## 3) stage for survey will be the same
        
        if(nrow(vel6)>0){ 
            avgvel6 <- apply(vel6, 1, mean)
        } else {vel6 <- NULL} 
        if(nrow(vel2)>0){ 
            vel28 <- (vel2 + vel8)/2
            avgvel28 <- apply(vel28, 1, mean) 
        } else {avgvel28 <- NULL} 
        ## sort according to names so sequence is correct ## changed 26Nov14
        avgvel <- c(avgvel6,avgvel28) 
        seq <- as.numeric(names(avgvel))
        seq.avgvel <- as.data.frame(cbind(seq,avgvel))
        sorted <- seq.avgvel[with(seq.avgvel, order(seq,avgvel)),]
        avgvel <- sorted$avgvel
        ## for manual cross sections (cxfix)
        tmp.cxfix <- read.csv(file=cx.fixfldirlst[j], header = T)
        n.rect.cxfix <- nrow(tmp.cxfix)

        shp.coords <- as.data.frame(matrix(ncol = 3, nrow=0))
        names(shp.coords) <- c("Id", "X", "Y")
        for (k in 1 : n.rect.cxfix){
            rect <- as.data.frame(matrix(ncol = 2)) 
            names(rect) <- c("x", "y")
            ## shpout <- paste(cx.shapeout, k, sep="_")
            min.x.rect <- tmp.cxfix$start[k]
            max.x.rect <- tmp.cxfix$end[k]
            min.y.rect <- min(crd$Depth)
            max.y.rect <- max(crd$Depth)

            rect[1,] <- c(min.x.rect, min.y.rect)
            rect[2,] <- c(min.x.rect, max.y.rect)
            rect[3,] <- c(max.x.rect, max.y.rect)
            rect[4,] <- c(max.x.rect, min.y.rect)
            rect[5,] <- c(min.x.rect, min.y.rect)
            
            gpc.rect <- as(rect, "gpc.poly") # convert to gpc polygon object
            plot(gpc.rect, poly.args = list(border = 1+k), add = TRUE) 
            ar.rect <- area.poly(gpc.rect) # area of rectangle
            ar.crd <- area.poly(gpc.crd) # area of cx
            intr <- intersect(gpc.crd,gpc.rect)
            ar.int <- area.poly(intr) 
            ## Get the coordinates to export to a shape file
            ptlist <- get.pts(intr)
            coord.int <- ldply(ptlist, data.frame)
            names(coord.int) <- c("X", "Y", "Id")
            coord.int <- coord.int[,c(3,1,2)]
            coord.int$Id <- k
            shp.coords <- rbind(shp.coords,coord.int)
            ## Get results for output tables
            tmp.res[k, 1] <- j
            tmp.res[k, 2] <- pyg.loc[i]
            tmp.res[k, 3] <- cx.flst[j]
            tmp.res[k, 4] <- "pygmy"
            tmp.res[k, 5] <- stage
            tmp.res[k, 6] <- k
            tmp.res[k, 7] <- ar.int/10000 
            tmp.res[k, 8] <- sorted[k, 2]
            tmp.res[k, 9] <- tmp.res[k, 7] * tmp.res[k, 8] ## stage into area
            tmp.res[k,10] <- timestamp
            rm(ptlist)
        }
        ids <- unique(shp.coords$Id)
        writeshape(shp.coords, cx.shapeout)
        
        dev.off() # dump the data into the png driver
        prf.res <- rbind(prf.res, tmp.res)
        res[j, 1] <- j
        res[j, 2] <- pyg.loc[i]
        res[j, 3] <- cx.flst[j]
        res[j, 4] <- "pygmy"
        res[j, 5] <- stage
        ## average out the reading for tmp.res to a single reading
        res[j, 6] <- sum(tmp.res$avg.disch) 
        res[j, 7] <-  timestamp
    }
    ## @knitr chunk5
    ## Dump results to fig and csv directories
    prf.res$timestamp <- as.POSIXct(prf.res$timestamp, , origin="1970-01-01", tz="Asia/Kolkata")
    prf.res <- na.omit(prf.res)
    resSDfile <- paste(csv.dr,"/", pyg.locnum[i],"_SD.csv", sep="") # location of csv result
    write.table(prf.res, file=cx.csvout, quote=FALSE, sep = ", ", row.names=FALSE, append=TRUE) # write it
    res$timestamp <- as.POSIXct(res$timestamp, origin="1970-01-01", tz="Asia/Kolkata")
    res <- na.omit(res)    
    write.table(res, file=resSDfile, quote=FALSE, sep = ",", row.names=FALSE, col.names=FALSE, append=TRUE) # write it  
    figfile <- paste(fig.dr,"/", pyg.locnum[i], ".png", sep="")
}

##  rm(tmp.res,tmp, tmp.mrg, tmp.pyg, crd, rw.crd, gpc.crd, mn, figout, max.xy, min.xy, max.x, min.y, step.x, step.y, cx.csv, cx.fig)
