library(tidyverse)
library(lubridate)
library(stringr)
library(tidytext)
library(ggplot2)
library(wordcloud)

library(RCurl)
library(ROAuth)
library(RJSONIO)
library(devtools)
library(twitteR)
library(topicmodels)

setwd("~/Desktop/trashystats/2018/useR tutorial/")

dir <- list.files("Twitter_Data")
all_tweets <- lapply(dir, function (x) read_csv(paste0("Twitter_Data/", x)))
all_tweets <- Reduce(rbind, all_tweets) %>% mutate(timestamp = ymd_hms(created))

all_tweets <- all_tweets %>% mutate(tweet_id = X1) %>% select(-X1) %>% filter(!duplicated(all_tweets))

## Cleaning

reg_retweets <- "^RT @(\\w+)"
all_tweets <- all_tweets %>% mutate(retweet_from = str_extract(text, reg_retweets)) %>%
  mutate (retweet_from = str_replace_all(retweet_from, "^RT ", ""))

  
replace_reg <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
unnest_reg <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
all_words <- all_tweets %>% 
  mutate(text = str_replace_all(text, replace_reg, "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]")) %>% filter(!(word==retweet_from))


## Frequency of hashtags
our_hashtags <- read_csv("Hashtags.csv", col_names=FALSE)
our_hashtags <- our_hashtags %>% mutate (X1 = str_to_lower(X1)) 
                                         
all_words <- all_words %>% mutate(our_hashtag = word %in% our_hashtags$X1)

all_words %>% filter(our_hashtag) %>% group_by(word) %>%  count() %>% ungroup() %>%
  mutate (word = reorder(word, n)) %>% 
  ggplot(aes(x=word, y=n) )+ geom_col() + coord_flip() 

all_words %>% filter(!our_hashtag) %>% filter(
  str_detect(word, "#(\\w+)| #(\\w+)[[:punct:]]")) %>% group_by(word) %>% count() %>% ungroup() %>%
  mutate (word = reorder(word, n)) %>% filter(n > 80) %>%
  ggplot(aes(x=word, y=n) )+ geom_col() + coord_flip() 

extract_others_hashtags <- all_words %>% filter(isRetweet) %>% filter(!our_hashtag) %>% filter(
  str_detect(word, "#(\\w+)| #(\\w+)[[:punct:]]")) %>% group_by(word) %>% count() %>% ungroup() %>%
  mutate (word = reorder(word, n)) %>% filter(n > 80) 

wordcloud(extract_others_hashtags$word, extract_others_hashtags$n, max.words=100)

# Most retweets per account
all_tweets %>% filter(isRetweet) %>% group_by(retweet_from) %>% count() %>% arrange(desc(n))

id_important <- all_tweets %>% filter(isRetweet) %>% 
  group_by(retweet_from) %>% count() %>% arrange(desc(n)) 
id_important <- id_important[1,1]

# Most retweeted tweet in our sample
all_tweets %>% filter(isRetweet) %>% group_by(text) %>% count() %>% arrange(desc(n))

# Most retweeted tweet in twitterverse
all_tweets %>% filter(isRetweet) %>% 
  filter(retweetCount == max(retweetCount)) %>% 
  filter(row_number()==1) 

# Extract information on timeline from @KensingtonPalace
api_key<-'O3G4prQHtVY8mV6XH0BbDFqwy'
api_secret<- "nGqAZNnPaqqztuGlQnVYvOoLfmXjuZssMu4JhG2SZiKnQsDhqA"
token<-"766200832140468224-5PUgnHme5ftycJasL9SPxJbVgiFz9Ex"
token_secret<- "MGqeEdHIrgc9xPD8nyjSjMvbwfBIcKsuJFsdDHlJlbO9o"
setup_twitter_oauth(api_key, api_secret, token, token_secret)

timeline_important <- userTimeline(str_replace(id_important, "@", ""), n=100, )
timeline_important <- twListToDF(timeline_important)

timeline_important <- timeline_important %>%
  mutate(timestamp = ymd_hms(created)) %>% mutate(tweet_id=rownames(timeline_important))

replace_reg <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
unnest_reg <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
timeline_words <- timeline_important %>% 
  mutate(text = str_replace_all(text, replace_reg, "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]")) 

reg_source<- "Web Client|iPhone|Media Studio|Android|SnappyTV"
timeline_words <- timeline_words %>% mutate (statusSource= str_extract(statusSource, reg_source))

frequency <- timeline_words %>% group_by(statusSource) %>%
  count(word, sort = TRUE) %>%
  left_join(timeline_words %>% 
              group_by(statusSource) %>% 
              summarise(total = n())) %>%
  mutate(freq = n/total) %>% mutate(document = statusSource) 

timeline_dtm <- frequency %>%
  cast_dtm(document, word, n)

timeline_lda <- LDA(timeline_dtm, k = 5, control = list(seed = 1234))
timeline_topics <- tidy(timeline_lda, matrix = "beta")

top_terms <- timeline_topics %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms

top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

timeline_gamma <- tidy(timeline_lda, matrix = "gamma")
timeline_gamma

timeline_gamma %>%
  mutate(title = reorder(document, gamma * topic)) %>%
  ggplot(aes(factor(topic), gamma)) +
  geom_boxplot() +
  facet_wrap(~ document)


# Make map of twitter users
screen_names <- all_tweets %>% filter(isRetweet) %>%
  group_by(retweet_from) %>% count() %>% arrange(desc(n)) %>% ungroup() %>% 
  mutate(retweet_from=str_replace(retweet_from, "@", ""))

topName <- screen_names[1:100,1]

# Wrapper for lookupUsers
user_infos <- twitteR::lookupUsers(topName, includeNA = FALSE)
user_infos <- twitteR::twListToDF(user_infos)

# Left join
screen_names <- screen_names %>% 
  left_join(user_infos, by=c("retweet_from"="screenName"))

ggplot(screen_names, aes(x=n, y=followersCount)) + geom_point() + scale_y_log10()


