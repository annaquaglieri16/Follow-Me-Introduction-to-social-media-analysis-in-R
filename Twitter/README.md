
-   [Packages to install](#packages-to-install)
-   [Reference material for the following tutorial](#reference-material-for-the-following-tutorial)
-   [Downloading tweets with `twitteR`](#downloading-tweets-with-twitter)
-   [Downloading tweets for a time series](#downloading-tweets-for-a-time-series)
-   [Analyse the 👑 tweets!](#analyse-the-tweets)
    -   [Step 1: Load tweets into R](#step-1-load-tweets-into-r)
    -   [Step 2: Convert tweets to the tidy text format: `tidytext::unnest_token`](#step-2-convert-tweets-to-the-tidy-text-format-tidytextunnest_token)
    -   [Hashtag frequency](#hashtag-frequency)
    -   [Find popular accounts and tweets](#find-popular-accounts-and-tweets)
    -   [Time series of Royal 👑 Hastags](#time-series-of-royal-hastags)

Packages to install
===================

``` r
install.packages("twitteR")
install.packages("wordcloud2")
install.packages("tidyverse")
install.packages("tidytext")
install.packages("knitr")
install.packages("plotly")
devtools::install_github("ropenscilabs/icon") # to insert icons
devtools::install_github("hadley/emo") # to insert emoji
```

``` r
library(knitr)
library(magick)
```

    ## Linking to ImageMagick 6.9.9.39
    ## Enabled features: cairo, fontconfig, freetype, lcms, pango, rsvg, webp
    ## Disabled features: fftw, ghostscript, x11

``` r
library(png)
library(grid)
library(emo)
library(icon)
library(twitteR)
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 2.2.1     ✔ purrr   0.2.5
    ## ✔ tibble  1.4.2     ✔ dplyr   0.7.5
    ## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ## ✔ readr   1.1.1     ✔ forcats 0.3.0

    ## ── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter()   masks stats::filter()
    ## ✖ dplyr::id()       masks twitteR::id()
    ## ✖ dplyr::lag()      masks stats::lag()
    ## ✖ dplyr::location() masks twitteR::location()

Reference material for the following tutorial
=============================================

-   [Setting up the Twitter R package for text analytics](https://www.r-bloggers.com/setting-up-the-twitter-r-package-for-text-analytics/)
-   [Obtaining and using access tokens](https://cran.r-project.org/web/packages/rtweet/vignettes/auth.html)
-   [Text mining with R](https://www.tidytextmining.com/index.html)

-   **Refer to `Social_Media_Setup_APIs.Rmd` to setup your Twitter API and connect your R session with Twitter**

Downloading tweets with `twitteR`
=================================

Once you have connected to twitter <!--html_preserve--><i class="fab  fa-twitter "></i><!--/html_preserve--> and accessed your API, you are ready to download tweets. Let's try to return the 3 most recent tweets that contain the \#useR2018 hashtag.

``` r
> useR_tweets <- searchTwitter("#useR2018", n = 3, resultType = "recent")
> useR_tweets <- twListToDF(useR_tweets)
> # kable(useR_tweets[,1:3])
```

The `searchTwitter` function will return a `status` object of 10 most recent tweets that contain \#useR2018 and their properties. This `status` object can be changed into a user-friendly `data.frame` with the function `twListToDF`. This `data.frame` contains the following columns:

-   `$text`: The text of the tweet
-   `$favorited`: Whether you liked it
-   `$favoriteCount`: How many users liked it
-   `$screenName`: Screen name of the user who posted this tweet
-   `$id`: ID of this status (every tweet has an unique ID)
-   `$replyToSN`: Screen name of the user this is in reply to
-   `$replyToUID`: ID of the user this was in reply to
-   `$statusSource`: Source user agent for this tweet
-   `$created`: When this tweet was created
-   `$truncated`: Whether this tweet was truncated
-   `$favorited`: Whether this tweet has been favorited
-   `$retweeted`: TRUE if this tweet has been retweeted
-   `$retweetCount`: The number of times this status has been retweeted

This is a very simple search. Like any search engine, twitter <!--html_preserve--><i class="fab  fa-twitter "></i><!--/html_preserve--> allows much more complicated searches using Boolean logic. For example, we can look for tweets containing \#useR2018 hashtag as well as mentioning \#rstats. If you are unsure whether your query will work, you can try it in the twitter browser.

``` r
> useR_rstats_tweets <- searchTwitter("#useR2018 AND #rstats", n = 10, resultType = "recent")
> useR_rstats_tweets <- twListToDF(useR_rstats_tweets)
> kable(useR_rstats_tweets[3:5, ])
```

Here are some common examples of twitter search queries (none of these are case sensitive):

| Search Query         | Tweets ...                              |
|----------------------|-----------------------------------------|
| from:thomasp85       | sent from Thomas Lin Pedersen           |
| to:thomasp85         | sent to Thomas Lin Pedersen             |
| \`R rules\`          | containing exact phrase                 |
| \#rstats -\#useR2018 | containing \#rstats but not \#useR2018  |
| \#best OR \#useR2018 | containing \#best or \#useR2018 or both |
|                      |                                         |

The `searchTwitter` function also allows you to specify some further restrictions on your searches:

-   `lang`: restricts tweets to a given language, i.e. `"EN"`
-   `geocode`: returns tweets by users located within a given radius of the given latitude/longitude
-   `sinceID`: returns tweets with IDs greater (ie newer) than the specified ID
-   `maxID`: returns tweets with IDs smaller (ie older) than the specified ID
-   `since`: restricts tweets to those since the given date
-   `until`: restricts tweets to those up until the given date

Note that the time restrictions only work for time restrictions within the last two weeks, when you are connecting through a standard API (see discussion in the next section).

<img src="TwitteR_tutorial_files/figure-markdown_github/mike_kearney-1.png" style="display: block; margin: auto;" />

It is important to document your data collection process clearly, so it can be reproduced by other people. Mike Kearney, the author of the `rtweet` 📦, recently published a minimum list of information required to reproduce data collection from twitter. We have slightly modified his list here 😉:

-   Source of twitter data: standard, premium or enterprise API
-   The R 📦 you are using
-   The specific function
-   Your search query and any filters (restrictions)

Downloading tweets for a time series
====================================

With a standard API twitter limits users to downloading tweets from the last two weeks. Furthermore, the twitter rate limits cap the number of search results returned to 18,000 every 15 minutes. When you are trying to collect large datasets of tweets or tweets from a longer time period, this poses a problem. One way around this limitation is to set automatic downloads using the `cronjob` 📦 for Linux/Unix or the `scheduler` 📦 for Windows.

We wanted to download tweets relating to the Royal Wedding 👑 of Meghan Markle 👰 and Prince Harry 🤵, held on the 19th of May 2018 in Windsor Castle, UK. In order to obtain representative tweets from before, around, and after the time of the wedding we collected 3,000 tweets every week beginning at the 15th of March to the 31st of May (Thursday mornings, Australian time). We also collected 3,000 tweet every day for 12 days beginning from the 17th of May and ending on the 28th of May. We only collected tweets containing any of the following hashtags:

``` r
> Hashtags <- read_csv("Hashtags.csv", col_names = TRUE)
> kable(Hashtags)
```

| Hashtags          |
|:------------------|
| \#MeghanMarkle    |
| \#TheRoyalWedding |
| \#PrinceHarry     |
| \#HarryAndMeghan  |
| \#MeghanAndHarry  |
| \#RoyalWedding    |

The following was the exact search query we used in our cronjob (we are only going to explain how to work with `cronjob` here 😞). Note that we are no longer requesting the most recent tweets but instead are requesting to be returned a mix of real time and most popular tweets.

``` r
> rla_tweet <- searchTwitter(paste0(Hashtags$Hashtags, collapse = " OR "), n = 3000, 
+     lang = "en")
```

For the cronjob to work, we needed to setup a R script with the all authentication details, the hashtags, the query as well as saving the tweets into a .csv file, which we labled with the date of collection. This R script can then be scheduled to run as often as you like through the cronjob add-in. Just click on the add-in button in RStudio and find cronjob, where you can interactively schedule your script to run:

<img src="TwitteR_tutorial_files/figure-markdown_github/cronjob-1.png" style="display: block; margin: auto;" />

Analyse the 👑 tweets!
=====================

Step 1: Load tweets into R
--------------------------

-   Load the tidy tools 📦.

``` r
> library(tidyverse)
> library(tidytext)
```

-   Load the time series of royal 👑 tweets.

Here we load the `.csv` files containing the royal tweets downloaded weekly and cohercing them into a `data.frame`. Every `.csv` file was downloaded with the `twitteR` 📦 and saved using the code shown above.

The `Twitter_Data` 📁 contains the time series of royal 👑 tweets:

``` r
> data <- list.files(path = file.path("Twitter_Data"), pattern = ".csv", full.names = TRUE)
> data
```

    ##  [1] "Twitter_Data/2018-03-15.csv"     "Twitter_Data/2018-03-22.csv"    
    ##  [3] "Twitter_Data/2018-03-29.csv"     "Twitter_Data/2018-04-05.csv"    
    ##  [5] "Twitter_Data/2018-04-12.csv"     "Twitter_Data/2018-04-19.csv"    
    ##  [7] "Twitter_Data/2018-04-26.csv"     "Twitter_Data/2018-05-03.csv"    
    ##  [9] "Twitter_Data/2018-05-10.csv"     "Twitter_Data/2018-05-17_day.csv"
    ## [11] "Twitter_Data/2018-05-17.csv"     "Twitter_Data/2018-05-18_day.csv"
    ## [13] "Twitter_Data/2018-05-19_day.csv" "Twitter_Data/2018-05-20_day.csv"
    ## [15] "Twitter_Data/2018-05-21_day.csv" "Twitter_Data/2018-05-22_day.csv"
    ## [17] "Twitter_Data/2018-05-23_day.csv" "Twitter_Data/2018-05-24_day.csv"
    ## [19] "Twitter_Data/2018-05-24.csv"     "Twitter_Data/2018-05-25_day.csv"
    ## [21] "Twitter_Data/2018-05-26_day.csv" "Twitter_Data/2018-05-27_day.csv"
    ## [23] "Twitter_Data/2018-05-28_day.csv" "Twitter_Data/2018-05-29_day.csv"
    ## [25] "Twitter_Data/2018-05-31.csv"

We first load every `.csv` file and save them as argument of the list `tweets` and then combine them into a data.frame.

``` r
> # Read into R all the .csv file and save each of them as an argument of a
> # list
> all_tweets <- lapply(data, function(tweets) {
+     data_tweets <- read_csv(tweets)
+     return(data_tweets)
+ })
> 
> # Combine the .csv file into a data.frame
> all_tweets <- do.call(rbind, all_tweets)
> head(all_tweets)[, c(2:5)]
```

    ## # A tibble: 6 x 4
    ##   text                                   favorited favoriteCount replyToSN
    ##   <chr>                                  <lgl>             <int> <chr>    
    ## 1 RT @acpfonline: This is a wind up sur… FALSE                 0 <NA>     
    ## 2 RT @esricanada: Discover details abou… FALSE                 0 <NA>     
    ## 3 RT @chrisshipitv: While the Royal Fam… FALSE                 0 <NA>     
    ## 4 There should be no taxpayer funding f… FALSE                 0 <NA>     
    ## 5 Doing some homework for the #RoyalWed… FALSE                 0 <NA>     
    ## 6 #AndForWhatItsWorth I<U+2019>m still … FALSE                 0 <NA>

Tweets were downloaded from 2018-03-08 14:01:12 to 2018-05-31 01:45:37.

Now tweets are stored into the column `text` of data frame `all_tweets` and they are stored as a character vector.

The `tidytext` 📦 philosophy, extensively explained in [Text mining with R](https://www.tidytextmining.com/tidytext.html), consist of having a table with **one-token-per-row**. A **token** is defined as a meaningful unit of text. In the simplest way it will be a single word but it can also be pairs/triplets of consecutive words and so on.

Step 2: Convert tweets to the tidy text format: `tidytext::unnest_token`
------------------------------------------------------------------------

The main `tidytext` 📦 function which will do this for us is `unnest_token`. Let's look at a quick example to see how it works!

**Create one-token-per-row data frame**

``` r
> all_tweets %>%
+   filter(!duplicated(all_tweets)) %>% # remove duplicated tweets
+   mutate(tweetID = 1:n()) %>% # set a TweetID column, X1 was too generic
+   select(-X1) %>%
+   unnest_tokens(output = word, input = text, token = "words") %>% # convert tweet in the text column to token = words
+   select(tweetID,word) %>%
+   count(word)
```

    ## # A tibble: 57,332 x 2
    ##    word                                      n
    ##    <chr>                                 <int>
    ##  1 ____                                      3
    ##  2 _____                                     1
    ##  3 ______________                           12
    ##  4 ___________________                       1
    ##  5 _____________________                     3
    ##  6 _____________________________________     1
    ##  7 ___fittaymuu                              2
    ##  8 ___mkc___                                 5
    ##  9 ___q__                                    1
    ## 10 __christan                                3
    ## # ... with 57,322 more rows

There is a lot of useless text in here 😱 !!

**Create one-token-per-row where token are two consecutive words**

``` r
> all_tweets %>% filter(!duplicated(all_tweets)) %>% mutate(tweetID = 1:n()) %>% 
+     select(-X1) %>% unnest_tokens(output = word, input = text, token = "ngrams", 
+     n = 2) %>% select(tweetID, word)
```

    ## # A tibble: 1,801,795 x 2
    ##    tweetID word       
    ##      <int> <chr>      
    ##  1   72068 _ajayv omg 
    ##  2   72068 omg the    
    ##  3   72068 the wedding
    ##  4   72068 wedding in 
    ##  5   72068 in this    
    ##  6   72068 this video 
    ##  7   72068 video was  
    ##  8   72068 was better 
    ##  9   72068 better than
    ## 10   72068 than the   
    ## # ... with 1,801,785 more rows

Looks better but we will do some more tweaks to make it more usable later!

------------------------------------------------------------------------

With the code below, we first create a new column `retweet_from` in the data frame `all_tweets` using `mutate(RT = str_extract(string = text,pattern = "^RT @(\\w+)"))`. In each row, this column will contain the Twitter handle of the user that was retweeted. This is accomplished by using the `str_extract` function from the `stringr` 📦 which extract the pattern "RT @user\_handle" from every retweet (in regular expression form `^RT @(\\w+)`). Finally, `mutate(RT = str_replace_all(RT,"^RT ",""))` will replace every `RT` occurence with nothing so that only the user handle is left in the `retweet_from`column.

``` r
> reg_retweets <- "^RT @(\\w+)"
> all_tweets <- all_tweets %>% mutate(tweetID = 1:n()) %>% select(-X1) %>% mutate(retweet_from = str_extract(text, 
+     reg_retweets)) %>% mutate(retweet_from = str_replace_all(retweet_from, "^RT ", 
+     ""))
> all_tweets[, c("tweetID", "retweet_from", "isRetweet")]
```

    ## # A tibble: 75,000 x 3
    ##    tweetID retweet_from     isRetweet
    ##      <int> <chr>            <lgl>    
    ##  1       1 @acpfonline      TRUE     
    ##  2       2 @esricanada      TRUE     
    ##  3       3 @chrisshipitv    TRUE     
    ##  4       4 <NA>             FALSE    
    ##  5       5 <NA>             FALSE    
    ##  6       6 <NA>             FALSE    
    ##  7       7 @chrisshipitv    TRUE     
    ##  8       8 @chrisshipitv    TRUE     
    ##  9       9 @Raine_Miller    TRUE     
    ## 10      10 @Nova_Magazine17 TRUE     
    ## # ... with 74,990 more rows

Now let's convert everything to the one-token-per-row format 🌟!

The code below will take the data frame `all_tweets` and convert it into a tidy text format. At this stage we do not filter out retweets but we will know which words come from a retweeted tweet and who was retweeted thanks to the columns `isRetweet` and `retweet_from`. The following is a breakdown of the steps performed by the chunk below:

-   Take the `all_tweets` data frame;
-   `filter(!duplicated(all_tweets))` to filter duplicated tweets;
-   `mutate(text = str_replace_all(text, replace_reg, ""))` will clean up the text from all unnecessary signs and language elements that are not meaningful text (summarised in the regular expression `replace_reg`);
-   `unnest_tokens(word, text, token = "regex", pattern = unnest_reg)` is the key part of this step and this is when the 💫 tidy text ✨ will happen!! Here we used a regular expression as our `token`. This is a very useful trick that we borrowed from [Text mining with R](https://www.tidytextmining.com/tidytext.html) 📕 and allows us to keep `#` and `@` from Twitter text.
-   We then remove stop words using the `stop_words` data frame provided with `tidytext` 📦 and we filter out, for any retweet, any word that contains the handle of the user retweeted: `filter(!(word==retweet_from))`. Keeping these words would overestimate the number of times that a user was mentioned since the handle wasn't part of the actual tweet but is appears in retweeted tweets by default.

``` r
> replace_reg <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
> unnest_reg <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
> all_words <- all_tweets %>% #
+   filter(!duplicated(all_tweets)) %>% #
+   mutate(text = str_replace_all(text, replace_reg, "")) %>%
+   unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
+   filter(!word %in% stop_words$word,str_detect(word, "[a-z]")) %>% 
+   filter(!(word==retweet_from))
```

**Save dataset**

``` r
> dir.create("Twitter_Tutorial_data", showWarnings = FALSE)
> write_csv(all_words, path = "Twitter_Tutorial_data/combined_royal_time_series.csv")
```

Hashtag frequency
-----------------

At the time when we set up our cronjob, it wasn't clear which hashtag would be used to refer to the Royal Wedding. So first let's investigate which hashtag of the ones we searched for was the most popular.

``` r
> our_hash <- all_words %>% mutate(OurTweets = word %in% str_to_lower(Hashtags$Hashtags)) %>% 
+     filter(OurTweets) %>% group_by(word) %>% count() %>% ungroup() %>% mutate(word = reorder(word, 
+     n)) %>% ggplot(aes(x = word, y = n)) + geom_bar(stat = "identity") + coord_flip() + 
+     ggtitle("Our hashtags") + theme_bw()
> 
> our_hash
```

<img src="TwitteR_tutorial_files/figure-markdown_github/unnamed-chunk-14-1.png" style="display: block; margin: auto;" />

Since hashtags are used to associate tweets to a topic/trend/theme it can be interesting to investigate, which other hashtags were used in co-occurance. Here we find all other hashtags that were used more than 80 times. We will plot these in a wordcloud using the `wordcloud2` 📦. A wordcloud gives greater prominence to words that appear more frequently in the source text by making them appear larger.

``` r
> library(wordcloud2)
> 
> all_hash <- all_words %>% filter(!(word %in% str_to_lower(Hashtags$Hashtags))) %>% 
+     filter(str_detect(string = word, pattern = "#")) %>% group_by(word) %>% 
+     count() %>% filter(n > 80) %>% ungroup() %>% mutate(word = reorder(word, 
+     n)) %>% arrange(desc(word)) %>% rename(freq = n)
> 
> wordcloud2(all_hash)
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-7706ff76958a135def0d">{"x":{"word":["#win","#competition","#winitwednesday","#royalwed","#champ","#royalwedding2018","#champagne","#r","#royal","#ro","#voxpop","#royalw","#anzacday","#meganmarkle","#royals","#suits","#windsor","#freebiefriday","#princewilliam","#meghanmarkle's","#duchessofsussex","#royalweddi","#roya","#royalwedd","#wedding","#royalwe","#windsorcastle","#royalfamily","#royalweddin","#princeharry's","#princessdiana","#chogm2018","#happy","#brexit","#birmingham","#meghan","#commonwealthday","#brooklyn99","#worldcup2018","#t","#uk","#aroyalromance","#sexualchocolate","#giveaway","#celebration","#etsy","#phone","#honor10","#weekend","#walkofamerica","#maheshb","#s","#qanon","#weddingcake","#icymi"],"freq":[1893,1610,644,616,609,525,519,384,366,334,281,279,251,247,233,220,178,175,167,160,160,135,129,128,127,127,125,125,122,119,117,116,114,109,105,102,102,102,100,95,93,91,90,90,90,88,87,87,86,86,85,84,83,81,81],"fontFamily":"Segoe UI","fontWeight":"bold","color":"random-dark","minSize":0,"weightFactor":0.0950871632329636,"backgroundColor":"white","gridSize":0,"minRotation":-0.785398163397448,"maxRotation":0.785398163397448,"shuffle":true,"rotateRatio":0.4,"shape":"circle","ellipticity":0.65,"figBase64":null,"hover":null},"evals":[],"jsHooks":{"render":[{"code":"function(el,x){\n                        console.log(123);\n                        if(!iii){\n                          window.location.reload();\n                          iii = False;\n\n                        }\n  }","data":null}]}}</script>
<!--/html_preserve-->
![](Twitter_tutorial_figures/wordcloud1.png)

We can also make a wordcloud in the shape of a crown 👑. However for this to look good we need to also use words with lower frequency.

``` r
> # make wordcloud with more words and in the shape of a crown
> all_hash_more <- all_words %>% filter(!(word %in% str_to_lower(Hashtags$Hashtags))) %>% 
+     filter(str_detect(string = word, pattern = "#")) %>% group_by(word) %>% 
+     count() %>% ungroup() %>% mutate(word = reorder(word, n)) %>% arrange(desc(word)) %>% 
+     rename(freq = n)
> 
> 
> crown_path <- "crown.jpeg"
> hw <- wordcloud2(all_hash_more, size = 1, figPath = crown_path)
> hw
```

![](Twitter_tutorial_figures/crown_wordcloud.png)

Interestingly, when we find a lot of hashtags referring to competitions, i.e. \#win, \#competition, \#WinItWednesday. This may be an artefact of collecting data on Thurdays, as there are lots of companies trying to entice users to retweet their content with giveaway competitions such as \#WinItWednesday:

![](Twitter_tutorial_figures/win.png)

Find popular accounts and tweets
--------------------------------

Next we turn our attention the accounts and tweets that did really well and gained lots of retweets. First let's find the account that had the most number of retweets in our sampled tweets. For this purpose we will combine number of retweets over distinct tweets by the same account.

``` r
> popular_accounts <- all_tweets %>% filter(isRetweet) %>% group_by(retweet_from) %>% 
+     count() %>% arrange(desc(n))
> 
> kable(popular_accounts[1:5, ])
```

| retweet\_from     |     n|
|:------------------|-----:|
| @KensingtonRoyal  |  1629|
| @giftsinternatio  |  1202|
| @MichaelDapaah    |   833|
| @kathleen\_hanley |   794|
| @HRHHenryWindsor  |   787|

Turns out this was @KensingtonRoyal, which is the offical account of the Kensington Palace and on the day was tweeting out important information like the designer of Meghan Markle's dress:

![](Twitter_tutorial_figures/kensington.png)

We might also be interested in the most popular tweet in terms of retweets that we sampled or general in the twitter universe.

``` r
> popular_sample <- all_tweets %>% group_by(text) %>% count() %>% arrange(desc(n))
> 
> popular_general <- all_tweets %>% filter(isRetweet) %>% filter(retweetCount == 
+     max(retweetCount)) %>% filter(row_number() == 1)
> 
> popular_sample$text[1]
```

    ## [1] "RT @MichaelDapaah: Big shaq get<U+2019>s invited to the Royal Wedding <ed><U+00A0><U+00BD><ed><U+00B1><U+00B0><ed><U+00A0><U+00BD><ed><U+00B1><U+0091><ed><U+00A0><U+00BD><ed><U+00B8><U+0085>\n--------------------------------------\n#RoyalWedding https://t.co/jadWP1<U+2026>"

``` r
> popular_general$text
```

    ## [1] "RT @LucySempey: One day you<U+2019>re 15 and posing outside Buckingham palace and 22 years later you<U+2019>re marrying the Prince. \n\nUnreal. \n\n#RoyalWed<U+2026>"

![](Twitter_tutorial_figures/lucy_sempey.png)

This is not the same tweet in our case 😮. When googling Lucy Sempey you indeed find that her tweet was the most retweeted during the 👑 Royal Wedding (<http://news.abs-cbn.com/trending/05/20/18/more-than-6m-tweets-on-harry-and-meghans-big-day>).

Time series of Royal 👑 Hastags
------------------------------

``` r
> library(plotly)
> 
> # Analyse only retweets
> commonTweetedHash <- all_words %>%
+   separate(created,into=c("Day","Time"),remove=FALSE,sep=" ") %>%
+   filter(str_detect(string = word,pattern = "#")) %>% 
+   filter(!is.na(retweet_from)) %>% # keep only retweets
+   group_by(Day,word) %>%
+   count() %>%
+   ungroup() %>%
+   group_by(word) %>%
+   summarise(MaxOneDay=max(n), # max number of mention in one signle day
+             SumMentions=sum(n)) %>% # sum of all the mentions for this tweets
+   arrange(desc(MaxOneDay))
> kable(head(commonTweetedHash))
```

| word             |  MaxOneDay|  SumMentions|
|:-----------------|----------:|------------:|
| \#royalwedding   |       3751|        33131|
| \#competition    |        963|         1610|
| \#win            |        963|         1893|
| \#champagne      |        482|          519|
| \#winitwednesday |        477|          644|
| \#champ          |        474|          609|

There are around 5K hashtags! We cannot follow them all across time.

Let's do some \# filtering... We will remove our searc \# and the super super popular ones (first 20 of the table abve)! Out of the remaining ones we will keep the most popular.

``` r
> tweetsDay_medium_popular <- all_words %>% 
+   filter(!is.na(retweet_from)) %>%
+   separate(created,into=c("Day","Time"),remove=FALSE,sep=" ") %>%
+   filter(str_detect(string = word,pattern = "#")) %>% # only keep hastags
+   filter(!(word %in% Hashtags$Hashtags) &  # remove our search hastags
+            !(word %in% tolower(Hashtags$Hashtags)) & 
+            !(word %in% commonTweetedHash$word[1:10])) %>%
+   group_by(Day,word) %>% 
+   count() %>%
+   arrange(desc(n))
> 
> # Only plot trends for medium popular hashtags
> tweetsDay <- all_words %>% 
+   separate(created,into=c("Day","Time"),remove=FALSE,sep=" ") %>%
+   filter(str_detect(string = word,pattern = "#")) %>% # only keep hastags
+   filter(word %in% tweetsDay_medium_popular$word[1:10]) %>%
+   group_by(Day,word) %>%
+   count() 
> 
> plot_tweetsDay <- ggplot(tweetsDay,aes(x=Day,y=n,colour=word,group=word)) + geom_line() + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
+   geom_vline(xintercept = c(36), linetype = "dotted")
> plot_tweetsDay
```

<img src="TwitteR_tutorial_files/figure-markdown_github/unnamed-chunk-16-1.png" style="display: block; margin: auto;" />

``` r
> p1 <- plot_tweetsDay + theme(legend.position = "none")
> ggplotly(p1)
```

-   Peak of tweets for `#royalwedding` on the 20th of May

-   **\#chogm2018**: Commonwealth Heads of Government Meeting 2018 16-19 April 2018

``` r
> chogm <- all_words[all_words$word %in% "#chogm2018", ]
> dim(chogm)
```

    ## [1] 116  18

``` r
> sort(table(chogm$retweet_from))
```

    ## 
    ## @AlexDEMitchell      @hannarrr_   @PScotlandCSG  @mmarklefancom 
    ##               1               1               1               2 
    ##        @The_ACU         @PlanUK    @RoyalDickie   @RE_DailyMail 
    ##               2               3               3             103

``` r
> chogm[chogm$retweet_from %in% "@RE_DailyMail", c("tweetID")]
```

    ## # A tibble: 103 x 1
    ##    tweetID
    ##      <int>
    ##  1   17515
    ##  2   17041
    ##  3   16333
    ##  4   16332
    ##  5   16328
    ##  6   16327
    ##  7   16326
    ##  8   16323
    ##  9   16321
    ## 10   16319
    ## # ... with 93 more rows

``` r
> all_tweets$text[all_tweets$tweetID %in% c("15052", "15054", "15119")]
```

    ## [1] "RT @RE_DailyMail: #PrinceHarry and #MeghanMarkle have arrived to speak to inspirational Commonwealth Youth leaders #CHOGM2018 https://t.co/<U+2026>"       
    ## [2] "RT @RE_DailyMail: Video: #PrinceHarry and #MeghanMarkle meet delegates at today<U+2019>s Commonwealth Youth Forum event #CHOGM2018 https://t.co/oH<U+2026>"
    ## [3] "RT @RE_DailyMail: #PrinceHarry and #MeghanMarkle have arrived to speak to inspirational Commonwealth Youth leaders #CHOGM2018 https://t.co/<U+2026>"

![](Twitter_tutorial_figures/chogm2018.png)
