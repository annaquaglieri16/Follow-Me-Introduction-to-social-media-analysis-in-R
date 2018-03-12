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