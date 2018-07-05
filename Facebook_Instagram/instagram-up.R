install.packages("httpuv")
install.packages("httr")
install.packages("jsonlite")
install.packages("RCurl")

require(httr) 
require(jsonlite)
require(RCurl)


full_url <- oauth_callback()
full_url <- gsub("(.*localhost:[0-9]{1,5}/).*", x=full_url, replacement="\\1")
print(full_url)

#http://localhost:1410/

#register your client in Instagram
#Parameters to use
  
  
#define 4 variables
#get the first 3 from the instagram setup  
app_name <- "useYour"
client_id <- "useYour"
client_secret <- "useYour"

#set the type of access
scope = "public_content"
  
#set access points for authorization
#https://www.instagram.com/developer/endpoints/users/
instagram <- oauth_endpoint(
  authorize = "https://api.instagram.com/oauth/authorize",
  access = "https://api.instagram.com/oauth/access_token")

#the application that will be used to access Ig
myapp <- oauth_app(app_name, client_id, client_secret)

#authentication

#ig_oauth <- oauth2.0_token(instagram, myapp,scope="basic",  type = "application/x-www-form-urlencoded",cache=FALSE)

ig_oauth <- oauth2.0_token(instagram, myapp,scope="basic")


save(ig_oauth, file="ig_oauth")
load("ig_oauth")

token<-ig_oauth$credentials$access_token


#ANALYSIS - own profile
#Instagram is very restrictive when it comes to sandbox apps 
#they don´t return any other data than the data from your own profile.

#get data
user_info <- fromJSON(getURL(paste('https://api.instagram.com/v1/users/self/?access_token=',token,sep="")))
#get profile id
received_profile <- user_info$data$id
#get first 20 entries
media <- fromJSON(getURL(paste('https://api.instagram.com/v1/users/self/media/recent/?access_token=',token, sep="")))
class (media)

df = data.frame(no = 1:length(media$data))
media$data[[1]]$comments
media$data$comments$count[[1]]
media$data$id[[1]]

for(i in 1:length(media$data))
{
  #media id for further access
  df$id[i] <-media$data$id[[i]]
  
  #comments
  df$comments[i] <-media$data$comments$count[[i]]

  #likes:
  df$likes[i] <-media$data$likes$count[[i]]
  
  #date
  df$date[i] <- toString(as.POSIXct(as.numeric(media$data$created_time[[i]]), origin="1970-01-01"))
}
#get comments

comm <- fromJSON(getURL(url1))

df$id[i]

url1<-paste("https://api.instagram.com/v1/media/", df$id[1], "/comments?access_token=", token, sep="")

#get tags - no longer allowed under "common access"
tagName<-"nike"
url1<-paste("https://api.instagram.com/v1/tags/", tagName, "/?access_token=", token, sep="")

tag1 <- fromJSON(getURL(url1))
#[1] "This request requires scope=public_content, but this access token is not authorized with this scope. The user must re-authorize your application with scope=public_content to be granted this permissions."

url1<-paste("https://api.instagram.com/v1/tags/search?q=snowy&access_token=", token, sep="")

tag1 <- fromJSON(getURL(url1))


#-----------------------------------
#Visualization

https://api.instagram.com/v1/media/{media-id}/comments?access_token=ACCESS-TOKEN
install.packages("rCharts")
require(rCharts)

m1 <- mPlot(x = "date", y = c("likes", "comments"), type = "Line", data = df)