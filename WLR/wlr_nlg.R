## Master script, unique for each site to call on routines
## Load required libraries
library(stringr) # to manipulate strings
library(timeSeries) # for aggregation
library(ggplot2) # for plotting
library(scales) ## for manipulating dates on ggplot2
## Set directory locations - fix for your system
rdata.dr <- "/home/udumbu/rsb/GitHub/CWC/WLR/"
csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/fig/"
site <- "nilgiris."
wlrdatadir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/raw/" # raw data
dir_calib_wlr<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/calib/" # calibration
dir_calib_res<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/calibres/" # calibration results
wlr.nulldir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/null/" # null dir location
## --- set the wlr on which you want to run the script
num_wlr <- 115##, "103a", "104a", "105a", "106a", "108a") # wlr names WLR_105 removed
## num_wlr <- c(101:104, 106:115, "103a", "104a", "105a", "106a", "108a") # wlr names WLR_105 removed
## num_wlr <- 110
## NOTE WLR108a calibration yet to be sent
loggers <- paste("wlr_", num_wlr, sep="") # logger name
tabname <- paste(site, loggers, sep="") # name of pg wlr table
tabonemin <- paste(tabname, "_1_minute", sep="") # one minute file to be created
setwd(rdata.dr) # set the working directory
## set the financial centre
setRmetricsOptions(myFinCenter = "Asia/Calcutta")
## ---- read in the routines
source("wlr_calib.R", echo=TRUE) # calculate calibration for the WLRs. Only run when needed
source("wlr_import.R", echo=TRUE) # import, calibrate and gap fill data
source("wlr_null.R", echo=TRUE) # insert null values from error logs
source("wlr_mergenull.R", echo=TRUE) # merge the nulls with the calibrated values
source("wlr_aggreg.R", echo=TRUE) # aggregate and output the data
