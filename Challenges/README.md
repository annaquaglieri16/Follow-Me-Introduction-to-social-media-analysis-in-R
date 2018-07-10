Exercises - Follow Me: Introduction to social media analysis in R
================
Maria Prokofieva, Anna Quaglieri, Saskia Freytag
useR! July 2018

-   [1. Twitter challenge](#twitter-challenge)
-   [2. YouTube challenge](#youtube-challenge)

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

2. YouTube challenge
--------------------

-   Download channel stats from the following channels:

CNN: UCupvZG-5ko\_eiXAupbDfxWw FoxNewsChannel: UCXIJgqnII2ZOINSWNOGFThA ABCNews: UCBi2mrWuNuyYy4gbM6fU18Q Bloomberg: UCUMZ7gohGI9HcU9VNsr2FJQ

You can download them using `get_channel_stats(channel_id=channel_id)` function

Produce a plot that showcases your findings to see which channel has the highest subscription, most views and highest number of video upload.

-   Download the list of videos from each channel and on each channel locate the videos with most views and most comments

-   Use the `newsTitle.csv` file and text analysis techniques we covered to calculate the length of each title (in words).

Identify the shortest and the longest title in the sample as well as each of the channels, FoxNews and CNN.

-   Use the same file `newsTitle.csv` and do sentiment analysis for FoxNews and CNN. Plot your results.

What can you say about the tone (sentiment) of each channel?
