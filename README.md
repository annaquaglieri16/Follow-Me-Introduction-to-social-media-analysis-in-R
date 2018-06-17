Twitter setup - useR! 2018
================
Anna Quaglieri & Saskia Freytag
11th Feb 2018

-   [Reference material for the following tutorial](#reference-material-for-the-following-tutorial)
-   [Getting started: Setup a Twitter account and create an App](#getting-started-setup-a-twitter-account-and-create-an-app)
-   [Connect your R session with Twitter](#connect-your-r-session-with-twitter)
    -   [Setup your R session to download Twitter data with the `twitteR` package](#setup-your-r-session-to-download-twitter-data-with-the-twitter-package)
    -   [Setup your R session to download Twitter data with the `rtweet` package](#setup-your-r-session-to-download-twitter-data-with-the-rtweet-package)
-   [Analyse Twitter data](#analyse-twitter-data)
-   [Step 1: Tidy up your tweets!](#step-1-tidy-up-your-tweets)
    -   [Convert to tidy text format: `unnest_token`](#convert-to-tidy-text-format-unnest_token)
-   [Time series of Royal 👑 Hastags](#time-series-of-royal-hastags)

Reference material for the following tutorial
=============================================

-   [Setting up the Twitter R package for text analytics](https://www.r-bloggers.com/setting-up-the-twitter-r-package-for-text-analytics/)
-   [Obtaining and using access tokens](https://cran.r-project.org/web/packages/rtweet/vignettes/auth.html)
-   [Text mining with R](https://www.tidytextmining.com/index.html)

Getting started: Setup a Twitter account and create an App
==========================================================

1.  Setup your `username` and `password` at <https://twitter.com/>.
2.  Go to <https://apps.twitter.com/> and sign in with your `username` and `password`
3.  Click on `Create a new App`

<img src="TwitteR_tutorial_files/figure-markdown_github/CreateAnApp-1.png" alt="Create a Twitter app at https://apps.twitter.com/."  />
<p class="caption">
Create a Twitter app at <https://apps.twitter.com/>.
</p>

1.  Fill in with you App name, brief description and a website. Ideally this website is where people can find more information about your app. However, if you don't have one just insert a valid link to a web page.

2.  As `callback URL` set: <http://127.0.0.1:1410>

<img src="TwitteR_tutorial_files/figure-markdown_github/RladiesApp-1.png" alt="Setup your app information andcallback URL."  />
<p class="caption">
Setup your app information andcallback URL.
</p>

1.  Once you click on `Create your Twitter Application` you will be re-directed to your application page. You're almost there! Go to the `Keys and Access Tokens` tab and at the bootom of this page click on `Create my access token`. Your access token will appear at the bottom of the page.

``` r
> img <- readPNG(file.path("TwitteR_tutorial_data/Figures/acessToken.png"))
> grid.raster(img)
```

<img src="TwitteR_tutorial_files/figure-markdown_github/AccessToken-1.png" alt="Create access token to connect R with Twitter."  />
<p class="caption">
Create access token to connect R with Twitter.
</p>

1.  Now you have everything you need to connect `R` with Twitter! From your application page you need **four** things:

-   API key
-   API secret
-   Token
-   Token secret

<img src="TwitteR_tutorial_files/figure-markdown_github/key_and_token_example-1.png" alt="Create access token to connect R with Twitter."  />
<p class="caption">
Create access token to connect R with Twitter.
</p>

Connect your R session with Twitter
===================================

There are two well-known packages used to collect data from Twitter directly into R:

-   `twitteR` <https://cran.r-project.org/web/packages/twitteR/README.html>
-   `rtweet` <https://cran.r-project.org/web/packages/rtweet/index.html>

Setup your R session to download Twitter data with the `twitteR` package
------------------------------------------------------------------------

The function `twitteR::searchTwitter` will return a list of tweets which you can easily coherce to standard `data.frame` with the function `twitteR::twListToDF`.

``` r
> api_key <- "your_api_key"
> api_secret <- "your_api_secret"
> token <- "your_token"
> token_secret <- "your_token_secret"
> 
> setup_twitter_oauth(api_key, api_secret, token, token_secret)
> 
> # Search tweets
> MyTweets <- searchTwitter("#MyChosenHastags", lang = "en")
```

Setup your R session to download Twitter data with the `rtweet` package
-----------------------------------------------------------------------

**Note**: Remember to set `set_renv=FALSE` when you run the `rtweet::create_token()` function. The default should be set to `FALSE` as mentioned in the help page `?rtweet` but it is instead set to `TRUE`. If `set_renv=TRUE` it will save a hidden token named `.rtweet_token.rds` which will be used as the default evironemnt twietter token variable.

More information about this can be found at [Obtaining and using access tokens](https://cran.r-project.org/web/packages/rtweet/vignettes/auth.html).

The function `rtweet::search_tweets` returns tweets already as a data frame.

``` r
> appname <- "Rladies_app"
> api_key <- "your_api_key"
> api_secret <- "your_api_secret"
> 
> setup_twitter_oauth(api_key, api_secret, token, token_secret)
> 
> ## create token named 'twitter_token'
> twitter_token <- create_token(app = appname, consumer_key = key, consumer_secret = secret)
> 
> MyTweet <- search_tweets("#MyChosenHastags", lang = "en", token = twitter_token)
```

Analyse Twitter data
====================

Step 1: Tidy up your tweets!
============================

-   Load the tidy tools 📦.

``` r
> library(tidyverse)
> library(tidytext)
> library(lubridate)
```

-   Load the time series of royal 👑 tweets.

This step involves loading the `.csv` files containing tweets downloaded weekly and cohercing them into a `data.frame`. Every `.csv` file was downloaded with the `twitteR` 📦 and saved using the code below:

``` r
> # Download tweets
> Hashtags <- read_csv("Hashtags.csv", col_names = FALSE)
> 
> api_key <- "your_api_key"
> api_secret <- "your_api_secret"
> token <- "your_token"
> token_secret <- "your_token_secret"
> setup_twitter_oauth(api_key, api_secret, token, token_secret)
> 
> # Search tweets
> rla_tweet <- twitteR::searchTwitter(paste0(Hashtags$X1, collapse = " OR "), 
+     n = 3000, lang = "en")
> 
> # recode lists to vectors to save it into CSV
> rla_tweet <- twitteR::twListToDF(rla_tweet)
> 
> write.csv(rla_tweet, paste0("Twitter_Data/", Sys.Date(), ".csv"))
```

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

The `tidytext` 📦 philosophy of the tidy text format, extensively explained in [Text mining with R](https://www.tidytextmining.com/tidytext.html), consist of having a table with **one-token-per-row**. A **token** is defined a meaningful unit of text, unit of your textual analysis. In the simplest way it will be a single word but it can also be pairs/triplets of consecutive words and so on.

Convert to tidy text format: `unnest_token`
-------------------------------------------

The main `tidytext` 📦 function which will do this for us is `unnest_token`. Let's look at a quick example to see how it works!

**Create one-token-per-row data frame**

``` r
> all_tweets %>% filter(!duplicated(all_tweets)) %>% mutate(tweetID = X1) %>% 
+     unnest_tokens(output = word, input = text, token = "words") %>% select(tweetID, 
+     word) %>% count(word)
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

There is a lot of useless text in here 🤢 !!

**Create one-token-per-row where token are two consecutive words**

``` r
> all_tweets %>% filter(!duplicated(all_tweets)) %>% mutate(tweetID = X1) %>% 
+     unnest_tokens(output = word, input = text, token = "ngrams", n = 2) %>% 
+     select(tweetID, word)
```

    ## # A tibble: 1,801,795 x 2
    ##    tweetID word                         
    ##      <int> <chr>                        
    ##  1       1 akaov_ but                   
    ##  2       1 but there                    
    ##  3       1 there was                    
    ##  4       1 was a                        
    ##  5       1 a royalwedding               
    ##  6       1 foreignoffice antonioguterres
    ##  7       1 antonioguterres borisjohnson 
    ##  8       1 borisjohnson un              
    ##  9       1 un royalfamily               
    ## 10       1 royalfamily ukparliament     
    ## # ... with 1,801,785 more rows

Still a lot of useless stuff in here 😱 !!

We would like to convert our 70K tweets into a more useful 👌 structure that could be `%>%` and processed with the `tidyverse` tools ⛏!

With the code below we first create a new column in the data frame `all_tweets` called `rewteet_from` using `mutate(RT = str_extract(string = text,pattern = "^RT @(\\w+)"))` which contains the Twitter handle of every user that was retweeted. This is accomplished by using the `str_extract` function from the `stringr` 📦 which extract the pattern `RT @user_handle` from every tweet that contains a retweet using the regular expression `^RT @(\\w+)`. Then, `mutate(RT = str_replace_all(RT,"^RT ",""))` will replace every `RT` with nothing so that only the user handle is left in the `RT`column.

``` r
> reg_retweets <- "^RT @(\\w+)"
> all_tweets <- all_tweets %>% mutate(retweet_from = str_extract(text, reg_retweets)) %>% 
+     mutate(retweet_from = str_replace_all(retweet_from, "^RT ", ""))
```

Now let's convert everything to the one-token-per-row format 🌟!

The code below will take the data frame `all_tweets` and convert it into a tidy text format. At this stage we do not filter out retweets but we will know which words come from a retweeted tweet thanks to the column `retweet_from` created in the chunk above. The following is a breakdown of the steps performed by the chunk below:

-   Take the `all_tweets` data frame;
-   `filter(!duplicated(all_tweets))` to filter duplicated tweets;
-   `mutate(tweetID = X1)` will create a `tweetID` which will identify uniquely each tweet;
-   `mutate(RT = str_extract(string = text,pattern = "^RT @(\\w+)"))` creates a column called `RT` which contains the Twitter handle of every user that was retweeted. This is accomplished by using the `str_extract` function from the `stringr` 📦 which extract the pattern `RT @user_handle` from every tweet that contains a retweet. Then, `mutate(RT = str_replace_all(RT,"^RT ",""))` will replace every `RT` with nothing so that only the user handle is left in the `RT`column.
-   `mutate(text = str_replace_all(text, replace_reg, ""))` will clean up the text from all unnecessary signs and language elements that are not meaningful text.
-   `unnest_tokens(word, text, token = "regex", pattern = unnest_reg)` is the key part of this step and this is when the 💫 tidy text ✨ will happen!! Here we used a regular expression as our `token`. This is a very useful trick that we borrowed from [Text mining with R](https://www.tidytextmining.com/tidytext.html) 📕 and allows us to keep `#` and `@` from Twitter text.
-   We then remove stop words using the `stop_words` data frame provided with `tidytext` 📦 and we filter out any word that contains the handle of the user whose tweet was retweeted: `filter(!(word==retweet_from))`. Keeping these words would overestimate the number of times that a user was mentioned since the actual handle wasn't part of the actual tweet but is appears in our search by default.

``` r
> replace_reg <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
> unnest_reg <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
> all_words <- all_tweets %>% 
+   filter(!duplicated(all_tweets)) %>% 
+   mutate(tweetID = X1) %>% 
+   select(-X1) %>% # remove column X1 substituted with tweetID
+   mutate(text = str_replace_all(text, replace_reg, "")) %>%
+   unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
+   filter(!word %in% stop_words$word,
+          str_detect(word, "[a-z]")) %>% 
+   filter(!(word==retweet_from))
```

Time series of Royal 👑 Hastags
==============================

``` r
> library(plotly)
> 
> commonTweetedHash <- all_words %>% 
+   separate(created,into=c("Day","Time"),remove=FALSE,sep=" ") %>%
+   filter(str_detect(string = word,pattern = "#")) %>% # only keep hastags that on one day have at least 50 tweets
+   group_by(Day,word) %>%
+   count() %>%
+   ungroup() %>%
+   filter(n > 100) %>% select(word) 
> 
> tweetsDay <- all_words %>% 
+   separate(created,into=c("Day","Time"),remove=FALSE,sep=" ") %>%
+   filter(str_detect(string = word,pattern = "#")) %>% # only keep hastags
+   filter(word %in% commonTweetedHash$word) %>%
+   group_by(Day,word) %>%
+   count() 
> 
> plot_tweetsDay <- ggplot(tweetsDay,aes(x=Day,y=n,colour=word,group=word)) + geom_line() + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
+   geom_vline(xintercept = c(36), linetype = "dotted")
```

``` r
> p1 <- plot_tweetsDay + theme(legend.position = "none")
> ggplotly(p1)
```
