library(googlesheets)
library(twitteR)
library(tidyverse)
library(RCurl)
library(ROAuth)
library(RJSONIO)
library(devtools)
library(rtweet)

# Cronjob to download Royal Tweets

dir <- "/Users/quaglieri.a/Documents/varie/Rladies/useR_twitter_tutorial/Twitter_Workshop_useR2018/RoyalTwitterWorkshop"
setwd(dir)

#############################################
# create google sheet token - to do only once
#############################################

# token <- gs_auth(cache = FALSE)
# gd_token()
# saveRDS(token, file = "googlesheets_token.rds")


# Download tweets
Hashtags <- read_csv(file.path(dir,"Hashtags.csv"), col_names = FALSE)

## name of app you created
appname <- "SaskiaFreytag"

## api consumer
key <- 'O3G4prQHtVY8mV6XH0BbDFqwy'

## api comsumer secret 
secret <- "nGqAZNnPaqqztuGlQnVYvOoLfmXjuZssMu4JhG2SZiKnQsDhqA"

## create a token, storing it as object 'twitter_token'
twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret,set_renv=FALSE)

# Search tweets
rla_tweet <- search_tweets(paste0(Hashtags$X1,collapse=" OR ") , n = 3000, token = twitter_token, lang='en')

# recode lists to vectors to save it into CSV
names_of_lists <- names(sapply(rla_tweet,typeof))[which(sapply(rla_tweet,typeof) %in% "list")]

list_to_vector <- function(recode_list){
  sapply(recode_list,
         function(entry_list) {paste(entry_list,collapse=",")})
}

z <- rla_tweet %>%
  mutate_at(.vars = vars(names_of_lists), 
            .funs = funs(list_to_vector))

#######################
# Save to google sheets - load the token
######################

time <- Sys.Date()

gs_auth(token = "googlesheets_token.rds")

########################################################
# Initial sheet to which we will add all the new sheets - only once
########################################################

# initialise_tweet_spreadsheet <- gs_new("royal_tweets2018", ws_title = "royal_tweets2018", input = rla_tweet,
#                    trim = TRUE, verbose = FALSE)

# Recall spreadsheet already created
gs_tweet <- gs_title("royal_tweets2018")

# Add a new page to the spreadsheet
add_tweets <- gs_ws_new(gs_tweet, ws_title = paste0("royal_tweets2018_",Sys.time()),input=rla_tweet, verbose = FALSE, trim=FALSE)

# */5 * * * * /wehisan/general/system/bioinf-software/bioinfsoftware/R/R-3.4.2/lib64/R/bin/Rscript /home/users/allstaff/quaglieri.a/BioCAsia/test_cronjob.R


