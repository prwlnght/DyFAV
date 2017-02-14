require(graphics)
require(zoo)
require(stats)
library(ggplot2)

rm(list = ls())

setwd('~/Development/gitRepos/Hands/Rcodes/')
#this is to get an easy way to compute energy probably won't apply. 

#Source this to get the list of features by 
#source('Alphabet.R')


#Current Issues (Features not accurate)

setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Prajwal_01282016/Alphabets/features/')

#This program will take a feature list of alphabets, select the top k features and for every alphabet in the corpus, it returns a score for a given test alphabet
#Then at the end, it will give a cross-validation accuracy for all alphabets

#proof of concept, this will be generalized
isA <- function(test_sign){
  #TODO subset for this alphabet
  print(test_sign[1])
  subset_for_a <- this_features_metrics[which(sapply(this_features_metrics[,2], function(x) any(grepl('alphabet_a', x)))),]
  features_to_use <- subset_for_a[order(subset_for_a$normalized_weight, decreasing=TRUE),][1:10,]
  feature_index <- 0
  this_prob_vote <- c()
  this_vote_index <- 1
  for(this_feature_name in features_to_use$Features){
    #print(this_feature_name)
    feature_index<-feature_index+1
    #(test_sign[,this_feature_name] <= features_to_use$Threshold_upper[feature_index]) && (test_sign[,this_feature_name] >= features_to_use$Threshold_lower[feature_index])
    if ((test_sign[,this_feature_name] <= features_to_use$Threshold_upper[feature_index]) && (test_sign[,this_feature_name] >= features_to_use$Threshold_lower[feature_index])){
      this_prob_vote[this_vote_index] <- features_to_use$normalized_weight[feature_index]
      this_vote_index = this_vote_index + 1
    }
  }
  print(this_prob_vote)
  print(sum(this_prob_vote))
  return(sum(this_prob_vote))
}

this_features_metrics <<- read.csv('feature_selection_working.csv')
this_features <<- read.csv('features.csv')
this_features <<- this_features[2:87]

#proof of concept
score_counter <- 1
for(i in 1:26){
A_score <- isA(this_features[score_counter,])
score_counter <- score_counter + 5

}

