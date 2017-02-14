#This file calls all the other files in order they need to be invoked in a folder that contains 



rm(list = ls())
parent.folder <- '/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/AlphabetData'
sub.folders <- list.dirs(parent.folder, recursive=FALSE)

timer_dataframe <- data.frame(matrix(0, nrow=50, ncol=6))
colnames(timer_dataframe) <- c('path', 'number_of_features_used', 'training_time', 'total_test_time', 'test_time_individual', 'is_parallel')
timer_index <- 1
number_in_database <- 133
is_parallel <- FALSE
# Run scripts in sub-folders 
for(sub.folder in sub.folders) {
  working_directory <- sub.folder 
  setwd('~/Development/gitRepos/Hands/Rcodes/')
  train_now1 <- Sys.time() 
  source('alphabet_aggregator.R')
  setwd('~/Development/gitRepos/Hands/Rcodes/')
  source('Alphabet.R')
  train_now2 <- Sys.time()
  total_training_time <- as.numeric(train_now2 - train_now1)
  maximum_features_to_use <- 5
  for (counter in 1:9){
  
  setwd('~/Development/gitRepos/Hands/Rcodes/')
  now1 <- Sys.time()
  source('AlphabetMatcher_A_working.R')
  now2 <- Sys.time()
  time_diff <- as.numeric(now2 - now1)
  timer_dataframe[timer_index,][1] <- sub.folder 
  timer_dataframe[timer_index,][2] <- maximum_features_to_use
  timer_dataframe[timer_index,][3]<- total_training_time
  timer_dataframe[timer_index,][4]<- time_diff
  timer_dataframe[timer_index,][5]<- time_diff/number_in_database
  timer_dataframe[timer_index,][6] <- is_parallel
  maximum_features_to_use = maximum_features_to_use + 10
  timer_index = timer_index + 1
  }
  
}

setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/AlphabetData')

#maximum_features_to_use <- maximum_features_to_use + 5
write.csv(timer_dataframe, file =paste(as.numeric(Sys.time(), "time_info.csv", sep="")))
