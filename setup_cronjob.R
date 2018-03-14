library(tidyverse)
library(RCurl)
library(ROAuth)
library(RJSONIO)
library(devtools)
library(rtweet)

# Cronjob to download Royal Tweets

setwd("~/RLadies/Royal-Twitter-Workshop-useR-2018/")

# Download tweets
Hashtags <- read_csv("Hashtags.csv", col_names = FALSE)

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

write.csv(z, paste0("Twitter_Data/", Sys.time(), ".csv"))


