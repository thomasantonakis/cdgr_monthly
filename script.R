######################################################
############ MONTHLY MARKETING REPORT ################
######################################################

######################################################
################### SUMMARY ##########################
######################################################

setwd("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_monthly")

library(xlsx)
library(lubridate)
library(zoo)
library(RGA)


# Authenticate Google Analytics
client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'
ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"),
                    verbose = getOption("rga.verbose"))

#Set Dates
today <- Sys.Date()
month.rep<- month(today-1)-1+12*(month(today)==1)
year.rep<- year(today)- (month(today)==1)


#dmy(paste("01",month.rep,year.rep, sep="/"))

######################################################
############# KEY METRICS & SEO ######################
######################################################

######################################################
################# DIGITAL TOTAL ######################
######################################################
