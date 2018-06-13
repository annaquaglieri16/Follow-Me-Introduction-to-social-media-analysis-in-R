library(tidyverse)
library(tidytext)
library(purrr)
library(lubridate)

data <- list.files(path = file.path("Twitter_Data"),pattern = ".csv",full.names = TRUE)


tweets <- lapply(data,function(tweets){
  data_tweets <- read_csv(tweets)
  return(data_tweets)
})

bind_tweets <- do.call(rbind,tweets) %>% mutate(timestamp = ymd_hms(created))

# Cleaning
unnest_reg <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
replace_reg <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https" # remove retwtees for now
tidy_tweets <- bind_tweets %>% 
  mutate(tweetID = X1) %>% 
  select(-X1) %>%
  mutate(RT = str_extract(string = text,pattern = "^RT @(\\w+)")) %>%
  mutate(RT = str_replace_all(RT,"^RT ","")) %>%
  mutate(text = str_replace_all(text, replace_reg, "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
  filter(!word %in% stop_words$word,str_detect(word, "[a-z]")) %>%
  filter(!(word == RT)) 

# Now we have the tweet ID, one per tweet, we removed duplicates tweet, we know what is a retweet of what and removed stop words

# 1. Check most tweeted hastags
Hashtags <- read_csv("Hashtags.csv")

our_hash <- tidy_tweets %>% 
  mutate(OurTweets = word %in% str_to_lower(Hashtags$Hashtags)) %>%
  filter(OurTweets) %>%
  group_by(word) %>%
  count() %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x=word,y=n)) + geom_bar(stat= "identity")+coord_flip()+ggtitle("Our hashtags") + theme_bw()
our_hash

# 2. Frequency of all the hastags
all_hash <- tidy_tweets %>% 
  filter(!(word %in% str_to_lower(Hashtags$Hashtags))) %>%
  filter(str_detect(string = word,pattern = "#")) %>%
  group_by(word) %>%
  count() %>%
  filter(n > 80) %>%
  ungroup() %>%
 mutate(word = reorder(word,n)) %>%
  arrange(desc(word))

ggplot(data = all_hash, aes(x=word,y=n)) + geom_bar(stat= "identity")+coord_flip()+ggtitle("Our hashtags") + theme_bw()

# Alternative to barplot Wordcloud
library(wordcloud)
wordcloud::wordcloud(all_hash$word, all_hash$n, max.words = 100, colors = brewer.pal(8, "Dark2"))

# Retweet has wordcloud for
ret_hash <- tidy_tweets %>% 
  filter(!(word %in% str_to_lower(Hashtags$Hashtags))) %>%
  filter(str_detect(string = word,pattern = "#")) %>%
  filter(isRetweet) %>%
  group_by(word) %>%
  count() %>%
  filter(n > 80) %>%
ungroup() %>%
  mutate(word = reorder(word,n)) %>%
  arrange(desc(word))

wordcloud::wordcloud(ret_hash$word, ret_hash$n, max.words = 100, colors = brewer.pal(8, "Dark2"))


# time series of tweets
# Tweets per day
# 4. What hastags were more popular across time?

# I know what words belong to retweet from the RT column
# From the below plot we track the most rewteeted/tweeted hastags across time

commonTweetedHash <- tidy_tweets %>% 
  separate(timestamp,into=c("Day","Time"),remove=FALSE,sep=" ") %>%
  filter(str_detect(string = word,pattern = "#")) %>% # only keep hastags that on one day have at least 50 tweets
  group_by(Day,word) %>%
  count() %>%
  ungroup() %>%
  filter(n > 100) %>% select(word) 

tweetsDay <- tidy_tweets %>% 
  separate(timestamp,into=c("Day","Time"),remove=FALSE,sep=" ") %>%
  filter(str_detect(string = word,pattern = "#")) %>% # only keep hastags
  filter(word %in% commonTweetedHash$word) %>%
  group_by(Day,word) %>%
  count() 

  ggplot(tweetsDay,aes(x=Day,y=n,colour=word,group=word)) + geom_line() + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  geom_vline(xintercept = c(36), linetype = "dotted")

library(plotly)
p1 <- tweetsDay + theme(legend.position = "none")
ggplotly(p1)


# 23rd may Meghan Markle and Prince Harry join royals at garden party in first appearance as married couple
# 26th may was supposed to bethe real one

# 1. Harry vs Megan
# 1. Column that identifies harry's only tweets
# 2. Column that identifies meghan's only tweets

tidy_tweets <- bind_tweets %>% 
  mutate(tweetID = X1) %>% 
  select(-X1) %>%
  mutate(RT = str_extract(string = text,pattern = "^RT @(\\w+)")) %>% # detect which ones are RT
  mutate(RT = str_replace_all(RT,"^RT ","")) %>%
  mutate(text = str_replace_all(text, replace_reg, "")) %>%
  mutate(text = str_replace_all(text, "\'", "")) %>%
  mutate(text = str_to_lower(text)) %>%
  mutate(Harry = str_detect(string = text ,pattern = "harry"),
         Meghan = str_detect(string = text ,pattern = "meghan|megan|markle")) %>%
  mutate(Harry_Meghan = case_when(Harry & !Meghan ~ "Harry",
                                  Meghan & !Harry ~ "Meghan",
                                  Harry & Meghan ~ "Harry_Meghan",
                                  TRUE ~ "none")) %>%
  unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
  filter(!word %in% stop_words$word,str_detect(word, "[a-z]")) 

table(tidy_tweets$Harry_Meghan)

# Frequency of words which are specific for harry and meghan

words_HM <- tidy_tweets %>% 
 # filter(is.na(RT)) %>% # remove retweets, only keep non retweets
  filter(!str_detect(word, "^@")) %>%
  count(word,Harry_Meghan) %>% # every word appeared n times into a tweet that has either Meghan/Harry or both
  filter(n > 10) %>%
  filter(!(word %in% c(str_to_lower(Hashtags$Hashtags),"meghan","markles","meganmarkle","harry","harries","megan"))) %>%
  spread(key = Harry_Meghan,value = n,fill=0) %>%
  mutate(total = Harry+Harry_Meghan+Meghan+none) %>%
  mutate(ratio_occurrence = log(((Harry + 1)/(total +1))/((Meghan+1)/(total +1)))) %>%
  arrange(desc(ratio_occurrence))


words_HM %>%
  group_by(ratio_occurrence < 0) %>%
  top_n(15, abs(ratio_occurrence)) %>%
  ungroup() %>%
  mutate(word = reorder(word, ratio_occurrence)) %>%
  ggplot(aes(word, ratio_occurrence, fill = ratio_occurrence < 0)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  ylab("log odds ratio (Harry/Meghan)") +
  scale_fill_discrete(name = "", labels = c("Harry", "Meghan")) + theme_bw()


# Geo-Mapping Twitter Users
require(twitteR)
require(data.table)
require(RJSONIO)
require(leaflet)

screen_names <- bind_tweets %>% 
  mutate(tweetID = X1) %>% 
  select(-X1) %>%
  mutate(RT = str_extract(string = text,pattern = "^RT @(\\w+)")) %>% # detect which ones are RT
  mutate(RT = str_replace_all(RT,"^RT ","")) %>%
  group_by(RT) %>% count() %>% arrange(desc(n)) %>%
  filter(!is.na(RT))

topName <- screen_names[1:100,1]

screen_names <- unique(as.character(topName$value))

# Wrapper for lookupUsers
user_infos <- twitteR::lookupUsers(gsub("@","",screen_names), includeNA = FALSE)
user_infosToDF <- twitteR::twListToDF(user_infos)


