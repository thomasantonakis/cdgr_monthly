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
startdate<- format(dmy(paste("01",month.rep,year.rep, sep="/")), format = "%d-%m-%Y")
startdate<- format(ymd(paste(year.rep,month.rep,"01" ,sep="/")), format = "%Y-%m-%d")

# Check how to set the final day of selected month
enddate<- format(ymd(paste(year.rep,month.rep,"31" ,sep="/")), format = "%Y-%m-%d")

website<-get_ga(25764841, start.date = startdate, end.date = enddate,
             
             metrics = "
                        ga:sessions,
                        ga:Users
                ",
             
             dimensions = NULL,
             sort = NULL, 
             filters = NULL,
             segment = NULL, 
             sampling.level = NULL,
             start.index = NULL, 
             max.results = NULL, 
             ga_token,
             verbose = getOption("rga.verbose")
)

android<-get_ga(81060646, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:sessions,
                        ga:Users
                ",
                
                dimensions = NULL,
                sort = NULL, 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token,
                verbose = getOption("rga.verbose")
)


ios<-get_ga(81074931, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:sessions,
                        ga:Users
                ",
                
                dimensions = NULL,
                sort = NULL, 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token,
                verbose = getOption("rga.verbose")
)

# load up from Admin Orders per source per month

orders<-read.xlsx("orders_per_source_at_month.xlsx", sheetIndex=1,
                  startRow = 1, header=TRUE,stringsAsFactors=FALSE)
verified<-read.xlsx("verified_users_per_source_at_month.xlsx", sheetIndex=1,
                    startRow = 1, header=TRUE,stringsAsFactors=FALSE)
registered<-read.xlsx("registered_users_per_source_at_month.xlsx", sheetIndex=1,
                      startRow = 1, header=TRUE,stringsAsFactors=FALSE)

# Start categorizing 
ios$registration <- sum(registered$REGISTERED_USERS[registered$SOURCE == "IOS"], na.rm = TRUE)
ios$verification <- sum(verified$VERIFIED_USERS[verified$SOURCE == "IOS"], na.rm = TRUE)
ios$order <- sum(orders$VERIFIED_ORDERS[orders$SOURCE == "IOS"], na.rm = TRUE)
android$registration <- sum(registered$REGISTERED_USERS[registered$SOURCE == "Android"], na.rm = TRUE)
android$verification <- sum(verified$VERIFIED_USERS[verified$SOURCE == "Android"], na.rm = TRUE)
android$order <- sum(orders$VERIFIED_ORDERS[orders$SOURCE == "Android"], na.rm = TRUE)
website$registration <- sum(registered$REGISTERED_USERS)-android$registration[1]-ios$registration[1]
website$verification <- sum(verified$VERIFIED_USERS)-android$verification[1]-ios$verification[1]
website$order <- sum(orders$VERIFIED_ORDERS)-android$order[1]-ios$order[1]

######################################################
############# KEY METRICS & SEO ######################
######################################################

######################################################
################# DIGITAL TOTAL ######################
######################################################
