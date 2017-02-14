require(graphics)
require(zoo)
require(stats)
library(ggplot2)

#setwd('~/Development/gitRepos/Hands/Rcodes/')
#this is to get an easy way to compute energy probably won't apply. 

#Source this to get the list of features by 
#source('Alphabet.R')


#Current Issues (Features not accurate)

#setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Prajwal_01282016/Alphabets/features/')
setwd(paste(working_directory, "/features", sep=""))

#This program will take a feature list of alphabets, select the top k features and for every alphabet in the corpus, it returns a score for a given test alphabet
#Then at the end, it will give a cross-validation accuracy for all alphabets
#define the confusion matrix 



confusion_matrix_alphabets <- data.frame(matrix(0, nrow=26, ncol=26))
rownames(confusion_matrix_alphabets) <- letters
colnames(confusion_matrix_alphabets) <- letters

#this is what decides how many features to base the ranking on 

feature_data_frame_written <- FALSE

feature_dataframe <- data.frame(matrix(0, nrow=26, ncol=(maximum_features_to_use+1)))

getStats <- function (this_data){
  this_data$X = NULL
  this_matrix <- as.matrix(this_data)
    
  return(sum(diag(this_matrix)/sum(this_matrix)))
  
  
  
}


#all alphabets, builds a confusion matrix
isAlphabet <- function(test_sign){
  #test for all letters 
  alphabet_now1 <- Sys.time()
  test_sign_alphabet <- strsplit(test_sign[1], "_")[[1]][2]
  row_number_matrix <- match(test_sign_alphabet, letters)
  column_number_matrix <- 0
  feature_dataframe_counter <- 1
  vote_vector <- c()
  for (mletter in letters){
    #TODO subset for this 
    column_number_matrix <- column_number_matrix + 1
    feature_dataframe[feature_dataframe_counter,][1] <- mletter
    
    
    
    this_alphabet_in_features <- paste('alphabet_', mletter, sep='')
    print(this_alphabet_in_features)
    print(test_sign[1])
    subset_for_this <- this_features_metrics[which(sapply(this_features_metrics[,2], function(x) any(grepl(this_alphabet_in_features, x)))),]
    features_to_use <- subset_for_this[order(subset_for_this$normalized_weight, decreasing=TRUE),][1:maximum_features_to_use,]
    
    feature_dataframe[feature_dataframe_counter,][2:(maximum_features_to_use+1)] <- features_to_use$Features
    feature_dataframe_counter <- feature_dataframe_counter + 1
    
    feature_index <- 0
    this_prob_vote <- c()
    this_vote_index <- 1
    for(this_feature_name in features_to_use$Features){
      #print(this_feature_name)
      feature_index<-feature_index+1
      #(test_sign[,this_feature_name] <= features_to_use$Threshold_upper[feature_index]) && (test_sign[,this_feature_name] >= features_to_use$Threshold_lower[feature_index])
      if ((test_sign[this_feature_name] <= features_to_use$Threshold_upper[feature_index]) && (test_sign[this_feature_name] >= features_to_use$Threshold_lower[feature_index])){
        this_prob_vote[this_vote_index] <- features_to_use$normalized_weight[feature_index]
        this_vote_index = this_vote_index + 1
      }
    }
    print(this_prob_vote)
    print(sum(this_prob_vote))
    vote_vector[column_number_matrix] <- sum(this_prob_vote)
  }
  #which max 
  confusion_matrix_alphabets[row_number_matrix,which.max(vote_vector)] <<- confusion_matrix_alphabets[row_number_matrix,which.max(vote_vector)] + 1
  if(feature_data_frame_written == FALSE) {
    feature_filename <- paste("alphabet_features", format(Sys.time(), "%Y%m%d_%H%M%s"), ".csv", sep="")
    write.csv(feature_dataframe, file=feature_filename)
    #update the global scope and not declare 
    feature_data_frame_written <<- TRUE
  }
  alphabet_now2 <- Sys.time()
  print(paste('diff:', as.numeric(alphabet_now2- alphabet_now1) ))
  return(sum(this_prob_vote))
}#end for all letters




this_features_metrics <- read.csv('feature_selection_working.csv')
this_features <- read.csv('features.csv')
this_features <- this_features[2:87]

#proof of concept
score_counter <- 1
#call this function for each iteration of . This function builds a confusion matrix of correct identifications
apply(this_features, 1, function(x) isAlphabet(x))

statistics <- getStats(confusion_matrix_alphabets)
outputfilename <- paste("confusion_matrix", Sys.Date(), "_Features_", maximum_features_to_use, "_Accuracy_", statistics,   ".csv", sep="_")

#write all features to one file 

write.csv(confusion_matrix_alphabets, file= outputfilename)


write.csv(statistics, file="statistics")





