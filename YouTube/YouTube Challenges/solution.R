app_id = "667235664106-a5e6ng7pna0ptv7qoqnrsn0ldm1i68a8.apps.googleusercontent.com" 
app_secret = "8UV8kvt8cZ75EXg-ubOPBjDJ"

#connect
yt_oauth(app_id=app_id, app_secret=app_secret, token='', cache=FALSE)

channel_id<-"UCupvZG-5ko_eiXAupbDfxWw" #CNN
UCXIJgqnII2ZOINSWNOGFThA
channel_id<-"UCXIJgqnII2ZOINSWNOGFThA" #FoxNewsChannel
UCBi2mrWuNuyYy4gbM6fU18Q
channel_id<-"UCXIJgqnII2ZOINSWNOGFThA" #ABCNews
UCUMZ7gohGI9HcU9VNsr2FJQ
channel_id<-"UCUMZ7gohGI9HcU9VNsr2FJQ" #Bloomberg



stats<-get_channel_stats(channel_id=channel_id)
stats <- as.vector(stats$statistics)
Bloomberg<-do.call(rbind, stats)


#CNN, FoxNews, ABCNews, Bloomberg
newsChannelstats<-data.frame()

mode(datamatrix) = "numeric"
Bloomberg<-data.frame(Bloomberg)
test<-cbind(CNN, FoxNews, ABCNews, Bloomberg)
newsChannelstats<-test

write.csv(newsChannelstats, "newsChannelstats.csv", row.names=TRUE)

#Downloading videos stats

channel_id<-"UCBi2mrWuNuyYy4gbM6fU18Q"
videosABCNews= yt_search(term="", type="video", channel_id = channel_id)

videosABCNews$source<-NULL
videosFoxNews<-data.frame(read.csv("videosFoxNews.csv"))
videosCNN<-data.frame(read.csv("videosCNN.csv"))
videosBloomberg<-data.frame(read.csv("videosBloomberg.csv"))

test<-rbind(videosABCNews, videosFoxNews, videosCNN, videosBloomberg)
write.csv(test, "videoNewsAll.csv", row.names=FALSE)

#download video

videosStatsAll<-lapply(as.character(test$video_id), function(x){
  get_stats(video_id = x)
})
videosStatsAll_df = do.call(rbind.data.frame, videosStatsAll)

test<-rbindlist(videosStatsAll, fill=TRUE)
head(videosStatsAll_df)

#----------
videoStatsABCNews = lapply(as.character(videosABCNews$video_id), function(x){
  get_stats(video_id = x)
})
videoStatsABCNews_df = do.call(rbind.data.frame, videoStatsABCNews)
videoStatsABCNews_df<-rbindlist(videoStatsABCNews, fill=TRUE)

videoStatsABCNews_df$title = videosABCNews$title
videoStatsABCNews_df$date = videosABCNews$date
videoStatsABCNews_df$source = "ABCNews"

#----------
videoStatsFoxNews = lapply(as.character(videosFoxNews$video_id), function(x){
  get_stats(video_id = x)
})
videoStatsFoxNews_df = do.call(rbind.data.frame, videoStatsFoxNews)
videoStatsFoxNews_df$title = videosFoxNews$title
videoStatsFoxNews_df$date = videosFoxNews$date
videoStatsFoxNews_df$source = "FoxNews"

#----------
videoStatsBloomberg = lapply(as.character(videosBloomberg$video_id), function(x){
  get_stats(video_id = x)
})
videoStatsBloomberg_df = do.call(rbind.data.frame, videoStatsCNN)
videoStatsBloomberg_df$title = videosBloomberg$title
videoStatsBloomberg_df$date = videosBloomberg$date
videoStatsBloomberg_df$source = "Bloomberg"

#----------
videoStatsCNN = lapply(as.character(videosCNN$video_id), function(x){
  get_stats(video_id = x)
})
videoStatsCNN_df = do.call(rbind.data.frame, videoStatsCNN)
videoStatsCNN_df$title = videosCNN$title
videoStatsCNN_df$date = videosCNN$date
videoStatsCNN_df$source = "CNN"

write.csv(videoStatsCNN_df, "videoStatsCNN.csv", row.names=FALSE)
write.csv(videoStatsBloomberg_df, "videoStatsBloomberg.csv", row.names=FALSE)
write.csv(videoStatsFoxNews_df, "videoStatsFoxNews.csv", row.names=FALSE)
write.csv(videoStatsABCNews_df, "videoStatsABCNews.csv", row.names=FALSE)

#merge CNN and Fox
videoStatsFox_CNN<-rbind(videoStatsFoxNews_df, videoStatsCNN_df)
write.csv(videoStatsFox_CNN, "newsTitle.csv", row.names=FALSE)


kable(videosVS[1:4,1:5])