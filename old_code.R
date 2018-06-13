# Old scripts

# Method 1
names_of_lists <- names(sapply(rla_rweet,typeof))[which(sapply(rla_rweet,typeof) %in% "list")]
rla_rweet_lists_removed <- rla_rweet[,!(colnames(rla_rweet) %in% names_of_lists)]
rla_rweet_lists <- rla_rweet[,colnames(rla_rweet) %in% names_of_lists]

rla_tweets_list_recoded  <- apply(rla_rweet_lists,2, # for every column list
                                  function(recode_list){
                                    sapply(recode_list,
                                           function(entry_list) {paste(entry_list,collapse=",")})
                                  })

rla_rweet2 <- cbind(rla_rweet,rla_tweets_list_recoded)


dir.create(file.path("twitter_data"),showWarnings = FALSE)
write.csv(rla_tweet, file=file.path("twitter_data",paste0("RoyalWedding_search_tweets_",Sys.Date(),".csv")),row.names = FALSE)


#############################################
# create google sheet token - to do only once
#############################################

# token <- gs_auth(cache = FALSE)
# gd_token()
# saveRDS(token, file = "googlesheets_token.rds")


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
# 
# 


extract_hash <- str_extract_all(text,"#\\w+ | #\\w+[[:punct:]]",simplify = TRUE)
extract_hash <- gsub(" ","",extract_hash)
extract_hash <- tolower(gsub("[[:punct:]]","",extract_hash))
extract_hash <- extract_hash[extract_hash != ""]

extract_hash <- str_extract_all(text,"#\\w+ | #\\w+[[:punct:]]",simplify = TRUE)
extract_hash <- gsub(" ","",extract_hash)
extract_hash <- tolower(gsub("[[:punct:]]","",extract_hash))
tweetsDay <- data.frame(extract_hash,
                        day = tweetsDay$Day,
                        isretweet = tweetsDay$isRetweet)

tweetsDay_long <-  tweetsDay %>% gather(nothing,tweet,X1:X14) %>%
  filter(tweet != "") %>%
  group_by(day,tweet) %>%
  summarise(Ntweet = length(nothing),Nretweet=sum(isretweet)) %>%
  arrange(desc(Ntweet))
