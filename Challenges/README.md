Exercises - Follow Me: Introduction to social media analysis in R
================
Maria Prokofieva, Anna Quaglieri, Saskia Freytag
useR! July 2018

-   [1. Twitter challenge](#twitter-challenge)

For the last hour we want you to apply your new knowledge to your favourite social media platform. So pick one of the exercises and have fun!

1. Twitter challenge
--------------------

Compare tweets which mention Harry to tweets mentioning Meghan in the Royal 👑 Wedding time series. You can find the data in the folder `Twitter_Tutorial_data/combined_royal_time_series_all_words.csv` or `Twitter_Tutorial_data/combined_royal_time_series_all_tweets.csv` (you can also download them directly here: [combined\_royal\_time\_series\_all\_words.csv](https://drive.google.com/file/d/12Zk6wT9Z94cNPWY_0SznwjAJxuTQ97J6/view?usp=sharing) and [combined\_royal\_time\_series\_all\_tweets.csv](https://drive.google.com/file/d/1wYOKXf5AaPwEa5RXlcxPsfxXUByttF6L/view?usp=sharing)).

Produce a plot that showcases your findings and post it to twitter using the hashtags \#useR2018, \#rstats and \#socialmediachallenge. Extra points for being able to upload your results trough R!

The data provided is exactly the same as the `all_words` data frame created during the tutorial (replicated tweets are removed)

``` r
library(tidyverse)
```

Here are some hints for the analysis to detect `Harry` and `Meghan` words within the tweets:

``` r
mutate(Harry = str_detect(string = text ,pattern = "harry"),
    Meghan = str_detect(string = text ,pattern = "meghan|megan|markle")) %>%
mutate(Harry_Meghan = case_when(Harry & !Meghan ~ "Harry",
                                  Meghan & !Harry ~ "Meghan",
                                  Harry & Meghan ~ "Harry_Meghan",
                                  TRUE ~ "none"))
```

-   wordcloud
-   sentiment analysis
-   timeseries
-   <https://www.tidytextmining.com/twitter.html>

Here are some hints for uploading through R:

-   `twitteR::updateStatus`
-   <https://blog.rladies.org/post/deployment/>
