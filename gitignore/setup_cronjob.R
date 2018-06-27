library(tidyverse)
library(RCurl)
library(ROAuth)
library(RJSONIO)
library(devtools)
library(twitteR)

# Cronjob to download Royal Tweets
options(httr_oob_default = TRUE)
setwd("~/RLadies/Royal-Twitter-Workshop-useR-2018/")

# Download tweets
Hashtags <- read_csv("Hashtags.csv", col_names = FALSE)

api_key<-'O3G4prQHtVY8mV6XH0BbDFqwy'
api_secret<- "nGqAZNnPaqqztuGlQnVYvOoLfmXjuZssMu4JhG2SZiKnQsDhqA"
token<-"766200832140468224-5PUgnHme5ftycJasL9SPxJbVgiFz9Ex"
token_secret<- "MGqeEdHIrgc9xPD8nyjSjMvbwfBIcKsuJFsdDHlJlbO9o"
setup_twitter_oauth(api_key, api_secret, token, token_secret)

# Search tweets
rla_tweet <- searchTwitter(paste0(Hashtags$X1,collapse=" OR "), 
                           n=3000, lang="en")

# recode lists to vectors to save it into CSV
rla_tweet <- twitteR::twListToDF(rla_tweet)

write.csv(rla_tweet, paste0("Twitter_Data/", Sys.Date(), ".csv"))


