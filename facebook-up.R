install.packages("devtools")
library(devtools)


install_github("pablobarbera/Rfacebook", subdir="Rfacebook")
install.packages("httr")

library (Rfacebook)
library(httr)
library(jsonlite)
#----------------------------------------

#Option 1: connect via the facebook API
# need to set up access in the facebook first
# https://developers.facebook.com

app_id1<-"useYours"
app_secret1<-"useYous"

fb_oauth <- fbOAuth(app_id=app_id1, app_secret=app_secret1,extended_permissions = FALSE)

#Option 1 via httpr
#setup endpoints
facebook <- oauth_endpoint(
  authorize = 'https://www.facebook.com/dialog/oauth',
  access = 'https://graph.facebook.com/oauth/access_token')

>>> # Credentials you get from registering a new application
app_name<-"useR2018" #not used but good for organisation
client_id = app_id1
client_secret = app_secret1

>>> # OAuth endpoints given in the Facebook API documentation
  #authorization_base_url = 'https://www.facebook.com/dialog/oauth'
  #token_url = 'https://graph.facebook.com/oauth/access_token'
  #redirect_uri = 'http://localhost:1410/'     # Should match Site URL
  
myapp <- oauth_app(app_name, client_id, client_secret)


facebook_oauth<- oauth2.0_token(facebook, myapp)
save(facebook_oauth, file="fb_oauth")

load("fb_oauth")

token<-facebook_oauth$credentials$access_token

me <- getUsers("me",token=fb_oauth)

me2 <- getUsers("me",token=token)

#getUsers(c("barackobama", "donaldtrump"), token)
#getUsers(c("barackobama", "donaldtrump"), fb_oauth)

#Option 2: connect via the authentication token
#manually created 
#has less restrictions= more data.
#valid for 2 hours!!!!!
#create your token at https://developers.facebook.com/tools/explorer


#create your token and replace

new_token <- 'useYours'
token<-toString(new_token)

#get application token, no selection
token<-"useYours"
me <- getUsers("me", token, private_info=TRUE)

getUsers(c("barackobama", "donaldtrump"), token)


#---------------------------------
#Analysing profile information
#Analyzing your network of friends

my_friends <- getFriends(token, simplify = FALSE)
head(my_friends$id, n = 1) # get lowest user ID

my_friends_info <- getUsers(my_friends$id, token, private_info = TRUE)
table(my_friends_info$gender)  # gender
table(substr(my_friends_info$locale, 1, 2))  # language
table(substr(my_friends_info$locale, 4, 5))  # country
table(my_friends_info$relationship_status)  # relationship status

#likes
my_likes <- getLikes(user="me", token=new_token)

#Extract list of posts from a public Facebook page
fb_page <- getPage(page="facebook", token=token)
getPost(post=fb_page$id[1], token, n = 500, comments = TRUE)


#can specify timing for posting
page <- getPage(page="humansofnewyork", token=fb_oauth, n=1000,
                since='2013/01/01', until='2013/01/31')

#Analyzing network of friends
my_network <- getNetwork(token, format="adj.matrix")

install.packages("igraph")
library(igraph)
network <- graph.adjacency(mat, mode="undirected")
pdf("network_plot.pdf")
plot(network)
dev.off()

#identify singletons= friends who are friends with me alone
singletons <- rowSums(my_network)==0 

#remove the singletons to make the chart simpler
my_graph <- graph.adjacency(my_network[!singletons,!singletons])
layout <- layout.drl(my_graph,options=list(simmer.attraction=0))
plot(my_graph, vertex.size=2, 
     #vertex.label=NA, 
     vertex.label.cex=0.5,
     edge.arrow.size=0, edge.curved=TRUE,layout=layout)



