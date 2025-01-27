## Master script, unique for each site to call on routines
## Load required libraries
library(stringr) # to manipulate strings
library(timeSeries) # for aggregation
library(ggplot2) # for plotting
library(scales) ## for manipulating dates on ggplot2
## Set directory locations - fix for your system
rdata.dr <- "/home/udumbu/rsb/GitHub/CWC/WLR/"
csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/csv/"
figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/fig/"
site <- "agnashini."
wlrdatadir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/raw/" # raw data
dir_calib_wlr<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/calib/"  # calibration
dir_calib_res<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/calibres/" # calibration results
wlr.nulldir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/null/" # null dir location
## num_wlr <- c("020a")
 ##num_wlr<- "003"   ## c("001","002", "003")
num_wlr <- c("001","002","003","004","005","006","010","011","020","021","01b","01c", "01d", "03b", "03b", "03c", "04b", "05b", "06b", "020a")
loggers <- paste("wlr_", num_wlr, sep="")
tabname <- paste(site, loggers, sep="") # name of pg wlr table
tabonemin <- paste(tabname, "_1_minute", sep="")
setwd(rdata.dr) # set the working directory
## set the financial centre
setRmetricsOptions(myFinCenter = "Asia/Calcutta")
## ---- read in the routines
source("wlr_calib.R", echo=TRUE) # calculate calibration for the WLRs. Only run when needed
source("wlr_import.R", echo=TRUE) # import, calibrate and gap fill data
source("wlr_null.R", echo=TRUE) # insert null values from error logs
source("wlr_mergenull.R", echo=TRUE) # merge the nulls with the calibrated values
source("wlr_aggreg.R", echo=TRUE) # aggregate and output the data



