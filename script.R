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

# Ask for dates

#dmy(paste("01",month.rep,year.rep, sep="/"))
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

# Pick the numbers we need
ios$registration <- sum(registered$REGISTERED_USERS[registered$SOURCE == "IOS"], na.rm = TRUE)
ios$verification <- sum(verified$VERIFIED_USERS[verified$SOURCE == "IOS"], na.rm = TRUE)
ios$order <- sum(orders$VERIFIED_ORDERS[orders$SOURCE == "IOS"], na.rm = TRUE)
android$registration <- sum(registered$REGISTERED_USERS[registered$SOURCE == "Android"], na.rm = TRUE)
android$verification <- sum(verified$VERIFIED_USERS[verified$SOURCE == "Android"], na.rm = TRUE)
android$order <- sum(orders$VERIFIED_ORDERS[orders$SOURCE == "Android"], na.rm = TRUE)
website$registration <- sum(registered$REGISTERED_USERS)-android$registration[1]-ios$registration[1]
website$verification <- sum(verified$VERIFIED_USERS)-android$verification[1]-ios$verification[1]
website$order <- sum(orders$VERIFIED_ORDERS)-android$order[1]-ios$order[1]

# Start categorizing 

orders$src[orders$SOURCE == "IOS"]<-"ios"
orders$src[orders$SOURCE == "Android"]<-"Android"
verified$src[verified$SOURCE == "IOS"]<-"ios"
verified$src[verified$SOURCE == "Android"]<-"Android"
registered$src[registered$SOURCE == "IOS"]<-"ios"
registered$src[registered$SOURCE == "Android"]<-"Android"

# Organic

## Google
registered$src[grep("google", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
orders$src[grep("google", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
verified$src[grep("google", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"

## Yahoo
registered$src[grep("yahoo", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
orders$src[grep("yahoo", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
verified$src[grep("yahoo", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"

## Search
registered$src[grep("search", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
orders$src[grep("search", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
verified$src[grep("search", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"

## Bing
registered$src[grep("bing", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
orders$src[grep("google", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"
verified$src[grep("google", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Organic"



## Newsletter
registered$src[grep("newsletter", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Newsletter"
orders$src[grep("newsletter", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Newsletter"
verified$src[grep("newsletter", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Newsletter"

## Facebook
registered$src[grep("facebook", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Facebook"
orders$src[grep("facebook", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Facebook"
verified$src[grep("facebook", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Facebook"

# Remarketing
registered$src[grep("remaketing", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
orders$src[grep("remaketing", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
verified$src[grep("remaketing", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"

# Affiliate
registered$src[grep("linkwise", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Affiliate"
orders$src[grep("linkwise", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Affiliate"
verified$src[grep("linkwise", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Affiliate"


# Adwords
registered$src[grep("google|cpc", registered$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Adwords"
orders$src[grep("google|cpc", orders$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Adwords"
verified$src[grep("google|cpc", verified$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Adwords"


######################################################
############# KEY METRICS & SEO ######################
######################################################

######################################################
################# DIGITAL TOTAL ######################
######################################################
