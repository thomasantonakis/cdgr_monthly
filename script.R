######################################################
############ MONTHLY MARKETING REPORT ################
######################################################
ptm <- proc.time()
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


startdate='2015-01-01' ##Start Date#########
enddate='2015-01-31' ####End Date###########

# startdate<- format(ymd(paste(year.rep,month.rep,"01" ,sep="/")), format = "%Y-%m-%d")

# Check how to set the final day of selected month
# enddate<- format(ymd(paste(year.rep,month.rep,"31" ,sep="/")), format = "%Y-%m-%d")

website<-get_ga(25764841, start.date = startdate, end.date = enddate,
             
             metrics = "
                        ga:sessions,
                        ga:Users,
                        ga:pageViews,
                        ga:avgSessionDuration
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
                        ga:Users,
                        ga:screenviews,
                        ga:avgSessionDuration
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
                        ga:Users,
                        ga:screenviews,
                        ga:avgSessionDuration
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


#########################################
################ mySQL ##################
#########################################

#########################################
# Verified Users From mySQL
#########################################

# Load package
library(RMySQL)
# Set timer
proc.time() - ptm
# Establish connection
con <- dbConnect(RMySQL::MySQL(), host = 'db.clickdelivery.gr', port = 3307, dbname = "beta",
                 user = "tantonakis", password = "2secret4usAll!")
# Send query
rs <- dbSendQuery(con,"
                  
                  SELECT COUNT(*) AS VERIFIED_USERS,
                  `user_master`.`referal_source` AS SOURCE,
                  `city_detail`.`city_name` AS CITY, 
                  `prefecture_detail`.`prefecture_name` AS PREFECTURE
                  
                  FROM `user_master`
                  LEFT JOIN `user_address`
                  ON (`user_address`.`is_default` = 'Y' AND `user_address`.`user_id` = `user_master`.`user_id`)
                  LEFT JOIN `city_master`
                  ON (`user_address`.`city_id` = `city_master`.`city_id`)
                  LEFT JOIN `city_detail`
                  ON (`city_detail`.`language_id` = '2' AND `city_master`.`city_id` = `city_detail`.`city_id`)
                  LEFT JOIN `prefecture_detail`
                  ON (`prefecture_detail`.`language_id` = '2' AND `city_master`.`prefecture_id` = `prefecture_detail`.`prefecture_id`)
                  
                  WHERE `user_master`.`verification_date` >= UNIX_TIMESTAMP('2015-01-01')
                  AND `user_master`.`verification_date` < UNIX_TIMESTAMP('2015-02-01')
                  AND `user_master`.`status` = 'VERIFIED'
                  AND `user_master`.`is_deleted` = 'N'
                  GROUP BY `user_master`.`referal_source`, `city_master`.`city_id`
                  
                  ")
# Fetch query results (n=-1) means all results
verified_src <- dbFetch(rs, n=-1) 

# close connection
dbDisconnect(con)
# Stop timer
proc.time() - ptm


#########################################
# Registered Users From mySQL
#########################################

# Establish connection
con <- dbConnect(RMySQL::MySQL(), host = 'db.clickdelivery.gr', port = 3307, dbname = "beta",
                 user = "tantonakis", password = "2secret4usAll!")
# Send query
rs <- dbSendQuery(con,"
                  
                  SELECT COUNT(*) AS REGISTERED_USERS, `user_master`.`status`, `user_master`.`referal_source` AS SOURCE
                  FROM `user_master`
                  WHERE `user_master`.`i_date` >= UNIX_TIMESTAMP('2015-01-01')
                  AND `user_master`.`i_date` < UNIX_TIMESTAMP('2015-02-01')
                  AND `user_master`.`is_deleted` = 'N'
                  GROUP BY `user_master`.`status`, `user_master`.`referal_source`
                  
                  ")
# Fetch query results (n=-1) means all results
registered_src <- dbFetch(rs, n=-1) 

# close connection
dbDisconnect(con)
# Stop timer
proc.time() - ptm


#########################################
# Orders From mySQL
#########################################

# Establish connection
con <- dbConnect(RMySQL::MySQL(), host = 'db.clickdelivery.gr', port = 3307, dbname = "beta",
                 user = "tantonakis", password = "2secret4usAll!")
# Send query
rs <- dbSendQuery(con,"
                  
                  SELECT COUNT(*) AS VERIFIED_ORDERS, 
                  `order_master`.`order_referal` AS SOURCE, 
                  `city_detail`.`city_name` AS CITY, 
                  `prefecture_detail`.`prefecture_name` AS PREFECTURE, 
                  SUM(`order_master`.`order_amt`) AS ORDER_VALUE, 
                  SUM(`order_master`.`order_commission`) AS COMMISSION
                  FROM `order_master`
                  JOIN `user_address`
                  ON (`order_master`.`deliveryaddress_id` = `user_address`.`address_id`)
                  JOIN `city_master`
                  ON (`user_address`.`city_id` = `city_master`.`city_id`)
                  JOIN `city_detail`
                  ON (`city_detail`.`language_id` = '2' AND `user_address`.`city_id` = `city_detail`.`city_id`)
                  JOIN `prefecture_detail`
                  ON (`prefecture_detail`.`language_id` = '2' AND `city_master`.`prefecture_id` = `prefecture_detail`.`prefecture_id`)
                  WHERE `order_master`.`i_date` >= UNIX_TIMESTAMP('2015-01-01')
                  AND `order_master`.`i_date` < UNIX_TIMESTAMP('2015-02-01')
                  AND `order_master`.`status` IN ('VERIFIED', 'REJECTED')
                  AND `order_master`.`is_deleted` = 'N'
                  GROUP BY `order_master`.`status`, `order_master`.`order_referal`, `city_detail`.`city_id`
                  
                  ")
# Fetch query results (n=-1) means all results
orders_src <- dbFetch(rs, n=-1) 
# close connection
dbDisconnect(con)
# Stop timer
proc.time() - ptm

# Refine and Categorize
registered_src$status<-NULL
verified_src$CITY<-NULL
verified_src$PREFECTURE<-NULL
orders_src$COMMISSION<-NULL
orders_src$ORDER_VALUE<-NULL
orders_src$PREFECTURE<-NULL
orders_src$CITY<-NULL

registered_src$cat<-""
verified_src$cat<-""
orders_src$cat<-""

# Android
registered_src$cat[registered_src$SOURCE == "Android"]<-"android"
verified_src$cat[verified_src$SOURCE == "Android"]<-"android"
orders_src$cat[orders_src$SOURCE == "Android"]<-"android"
# iOS
registered_src$cat[registered_src$SOURCE == "IOS"]<-"ios"
verified_src$cat[verified_src$SOURCE == "IOS"]<-"ios"
orders_src$cat[orders_src$SOURCE == "IOS"]<-"ios"
# Organic
## Google
registered_src$cat[grep("google", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
verified_src$cat[grep("google", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
orders_src$cat[grep("google", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
## Yahoo
registered_src$cat[grep("yahoo", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
verified_src$cat[grep("yahoo", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
orders_src$cat[grep("yahoo", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
## Bing
registered_src$cat[grep("bing", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
verified_src$cat[grep("bing", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
orders_src$cat[grep("bing", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
## Search
registered_src$cat[grep("search", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
verified_src$cat[grep("search", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"
orders_src$cat[grep("search", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic"

## Remarketing
registered_src$cat[grep("remarketing", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"remarketing"
verified_src$cat[grep("remarketing", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"remarketing"
orders_src$cat[grep("remarketing", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"remarketing"

# Newsletter
registered_src$cat[grep("newsletter", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"newsletter"
verified_src$cat[grep("newsletter", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"newsletter"
orders_src$cat[grep("newsletter", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"newsletter"

# Facebook
registered_src$cat[grep("facebook", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"facebook"
verified_src$cat[grep("facebook", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"facebook"
orders_src$cat[grep("facebook", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"facebook"

# Affiliate
registered_src$cat[grep("linkwise", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"affiliate"
verified_src$cat[grep("linkwise", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"affiliate"
orders_src$cat[grep("linkwise", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"affiliate"

# Direct 
registered_src$cat[registered_src$cat == ""]<-"direct"
verified_src$cat[verified_src$cat == ""]<-"direct"
orders_src$cat[orders_src$cat == ""]<-"direct"

# Adwords
registered_src$cat[grep("google|cpc", registered_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"adwords"
verified_src$cat[grep("google|cpc", verified_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"adwords"
orders_src$cat[grep("google|cpc", orders_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"adwords"


library(plyr)
reg<-ddply(registered_src,("cat"), summarize, registration=sum(REGISTERED_USERS))
ver<-ddply(verified_src,("cat"), summarize, verifications=sum(VERIFIED_USERS))
ord<-ddply(orders_src,("cat"), summarize, orders=sum(VERIFIED_ORDERS))

reg$metric<-'registrations'
ver$metric<-'verifications'
ord$metric<-'orders'

names(reg)<- c("cat","number","metric")
names(ver)<- c("cat","number","metric")
names(ord)<- c("cat","number","metric")

report<-rbind(reg,ver,ord)
tbadded<-data.frame("cat" ='ios',"number" = ios$sessions[1],"metric"= 'sessions')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='ios',"number" = ios$Users[1],"metric"= 'users')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='ios',"number" = ios$screenviews[1],"metric"= 'pageviews')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='ios',"number" = ios$avgSessionDuration[1],"metric"= 'sesdur')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='android',"number" = android$sessions[1],"metric"= 'sessions')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='android',"number" = android$Users[1],"metric"= 'users')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='android',"number" = android$screenviews[1],"metric"= 'pageviews')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='android',"number" = android$avgSessionDuration[1],"metric"= 'sesdur')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='website',"number" = website$sessions[1],"metric"= 'sessions')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='website',"number" = website$Users[1],"metric"= 'users')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='website',"number" = website$pageViews[1],"metric"= 'pageviews')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='website',"number" = website$avgSessionDuration[1],"metric"= 'sesdur')
report<-rbind(report,tbadded)



# Stop timer
proc.time() - ptm

######################################################
############# KEY METRICS & SEO ######################
######################################################

# +INT(seconds/60)+MOD(seconds;60)/100

segment<-get_ga(25764841, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:sessions,
                        ga:Users,
                        ga:pageViews,
                        ga:avgSessionDuration,
                        ga:goal1Completions,
                        ga:goal6Completions
                ",
                
                dimensions = '
                        ga:channelGrouping
',
                sort = NULL, 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token,
                verbose = getOption("rga.verbose")
)

tbadded<-data.frame("cat" ='organic',"number" = segment$sessions[segment$channelGrouping == 'Organic Search'],"metric"= 'sessions')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='organic',"number" = segment$Users[segment$channelGrouping == 'Organic Search'],"metric"= 'users')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='organic',"number" = segment$pageViews[segment$channelGrouping == 'Organic Search'],"metric"= 'pageviews')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='organic',"number" = segment$avgSessionDuration[segment$channelGrouping == 'Organic Search'],"metric"= 'sesdur')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='direct',"number" = segment$sessions[segment$channelGrouping == 'Direct'],"metric"= 'sessions')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='direct',"number" = segment$Users[segment$channelGrouping == 'Direct'],"metric"= 'users')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='direct',"number" = segment$pageViews[segment$channelGrouping == 'Direct'],"metric"= 'pageviews')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='direct',"number" = segment$avgSessionDuration[segment$channelGrouping == 'Direct'],"metric"= 'sesdur')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='direct',"number" = segment$goal1Completions[segment$channelGrouping == 'Direct'],"metric"= 'orders_Analytics')
report<-rbind(report,tbadded)
tbadded<-data.frame("cat" ='organic',"number" = segment$goal1Completions[segment$channelGrouping == 'Organic Search'],"metric"= 'orders_Analytics')
report<-rbind(report,tbadded)

newusers_android<-get_ga(81060646, start.date = startdate, end.date = enddate,
                
                metrics = "
                ga:goal1Completions, 
                ga:newUsers
                ",
                
                dimensions = "ga:medium",
                sort ="-ga:newUsers" ,
                filters =  "ga:medium == cpc",
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token,
                verbose = getOption("rga.verbose")
)

tbadded<-data.frame("cat" ='android',"number" = newusers_android$newUsers[1],"metric"= 'apps')
report<-rbind(report,tbadded)

impr_cli<-get_ga(25764841, start.date = startdate, end.date = enddate,
                 
                 metrics = "
                 ga:impressions,
                 ga:adClicks,
                 ga:adCost
                 ",
                 
                 dimensions = "
                 ga:campaign
                 ",
                 sort = NULL, 
                 filters = NULL,
                 segment = NULL, 
                 sampling.level = NULL,
                 start.index = NULL, 
                 max.results = NULL, 
                 ga_token,
                 verbose = getOption("rga.verbose")
)

impr_cli$cat<-0
impr_cli$cat[grep("Remarketing", impr_cli$campaign , ignore.case=FALSE, fixed=FALSE)]<-"remarketing"
impr_cli$cat[impr_cli$campaign == 'App. Android-Text']<-"android"
impr_cli$cat[impr_cli$campaign == 'App. iOS-Text']<-"ios"
impr_cli$cat[impr_cli$cat == 0]<-"adwords"
impr<-ddply(impr_cli,("cat"), summarize, impressions=sum(impressions))
clicks<-ddply(impr_cli,("cat"), summarize, impressions=sum(adClicks))
cost<-ddply(impr_cli,("cat"), summarize, impressions=sum(adCost))

impr$metric<-'impressions'
clicks$metric<-'clicks'
cost$metric<-'cost'

names(impr)<- c("cat","number","metric")
names(clicks)<- c("cat","number","metric")
names(cost)<- c("cat","number","metric")

report<-rbind(report,impr,clicks,cost)


write.xlsx(x = report, file = "Working.xlsx", row.names = FALSE)
######################################################
################# DIGITAL TOTAL ######################
######################################################
proc.time() - ptm
