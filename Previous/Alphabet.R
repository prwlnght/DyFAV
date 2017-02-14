#ProcessGesture.R copied
#This file is a cross-validation test and report for training and testing data. 
# run : setwd('~/Development/gitRepos/Hands/Data/EMGData')
 
#This file is a modification of CrossValidation_AllPods_BothHands to only do calculations for one hand. 
#includes
require(graphics)
require(zoo)
require(stats)
library(ggplot2)

setwd(working_directory)
#setwd('~/Development/gitRepos/Hands/Rcodes/')
#this is to get an easy way to compute energy probably won't apply. 

#source('req_energy_calculator.R')
#database folder <- obtain this from the python server
#setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Shweta_02112016/')


##################################################################################################################################################################
#DECS
#normalization on/off
normalization_which <- c(0, 0, 0, 0)
corpus <- letters 
filenames_all <- list.files(pattern ="csv", full.names=TRUE)
number_of_training_instances <- length(filenames_all)
#number_of_trainig_instances <- 133 #TODO get this dynamically 

##################################################################################################################################################################

#FUNCTIONS
##################################################################################################################################################################
normalize <- function(column_indices_to_normalize){

  for (column_in_dex in column_indices_to_normalize)  {
    this_max <- max(signed_features[column_in_dex] )
    this_min <- min(signed_features[column_in_dex] )
    signed_features[column_in_dex] <<- sapply(signed_features[column_in_dex], function (x) (x-this_min)/(this_max-this_min))
  }
}
store_features <- data.frame(matrix(nrow=510, ncol=7))

feature_selection <- function(dff){
  main_counter <- 0
   
  for (this_alphabet_number in 1:length(corpus)){
    this_alphabet <- corpus[this_alphabet_number]
    #for rownames that contain alphabet_this_alphabet assign to training corpus
    print(this_alphabet)
    to_test <- paste('alphabet_', this_alphabet, sep="" )
    #train_df <- dff[which(sapply(rownames(dff), function(x) any(grepl(to_test, x))))]
    #test_df <- dff[-(sapply(rownames(dff), function(x) any(grepl(to_test, x))))]
    
    #for f in feature
    for(feature_name_index in 1:length(colnames(dff))){
      main_counter <- main_counter + 1
      
      #sort the whole dataframe by this feature i.e. one feature at at ime
      sorted_list <- dff[order(dff[feature_name_index]),]
      #splice the df into another df that has only that feature_name
      this_dff <- sorted_list[feature_name_index]
      #calculates the relative range / number of iterations over 133 (worst possible)
      this_range <- range(which(sapply(rownames(this_dff), function(x) any(grepl(to_test, x)))))
      if (this_range[1] != 1) threshold_lower <- (this_dff[(this_range[1]-1),] + this_dff[this_range[1],] ) / 2 
      else threshold_lower <- this_dff[this_range[1],]
      if (this_range[2] != number_of_training_instances) threshold_upper <- (this_dff[this_range[2]+1,] + this_dff[(this_range[2]),]) / 2 
      else threshold_upper <- this_dff[this_range[2],]
      thresholds <- c(threshold_lower, threshold_upper)
      #get 5 and 133 dynamically TODO 
      if (diff(this_range) ==4 ) weight <- 3
      else weight <- abs(log((diff(this_range) - 4)/(133-4), base=10))
      store_features [main_counter,] <<-   c(to_test,  colnames(dff)[feature_name_index],  this_range, thresholds, weight)
      
    }
    
  }
}



piecewise_energy <- function (){
  #make a dataframe with to  EMG energies 
  no_energy_filer_emg <- which(!sapply(colnames(signed_features), function(x) any(grepl('EMG.*energy.', x))))
  #energy_filer_emg_energy <- which(sapply(energy_filer , function(x) any(grepl('EMG', x))))
  energy_dataframe <- signed_features[-no_energy_filer_emg]
  
  
  for(accessindex in 1:nrow(energy_dataframe)){
   difference_frame <- energy_dataframe[-accessindex,] - as.numeric(as.vector(energy_dataframe[accessindex,]))
   emg_total_0 <- difference_frame[1] + difference_frame[2] + difference_frame[3] + difference_frame[4] + difference_frame[5] + difference_frame[6] + difference_frame[7] 
   
   print('a')
  }
}

computeAccuracy_total<- function(){
  #read the file that has better data
  energy_features <<- read.csv("features/Energy_only.csv")
  
  for(energy_features_index in 1:nrow(energy_features)){
    train_data <- energy_features[energy_features_index,2:9]
    test_data <- energy_features[-energy_features_index,2:9]
    difference_energy <- sweep(test_data, 2, as.numeric(as.vector(train_data), "-"))
    rownames(difference_energy) <- energy_features[,1][-energy_features_index]
    sorted_difference_energy <- sort(abs(rowSums(difference_energy)))
    
    #if sorted_difference_energy_names[1] == train_data.name then correct = correct + 1
    
  }
  energy_features_index <- 0
}

character_wise_energy_analysis <- function(){
  #This function takes the total energy arrays (for entire pods) and prints average energy per pod per letter 
  
  #for instance 
  for (row_traverse_index in 1:nrow(signed_features)){
    pod_energy_a <<- vector(mode="numeric", length=8)
    pod_energy_b <<- vector(mode="numeric", length=8)
    this_rowname <- as.character(rownames(signed_features)[row_traverse_index])
    if(grepl("_a", this_rowname)){
      for (i in 1:8){
        #print(i)
        pod_energy_a[i] <<- pod_energy_a[i] + signed_features[1,][i]
      }
      }
    if(grepl("_b", this_rowname)){
      for (i in 1:8){
        #print(i)
        pod_energy_b[i] <<- pod_energy_b[i] + signed_features[1,][i]
      }
    
    }
  print(pod_energy_a)
  print(pod_energy_b)
  #rm(pod_energy_a, pod_energy_b) 
  
}

}
##################################################################################################################################################################
#PROCEDURE
##################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################
#read the file
signed_features <<- read.csv("features/features.csv")
feature_bases <- c('mean', 'max', 'min', 'stdev', 'total_energy')

#get id as the rownames
rownames(signed_features) <- signed_features[,1]

signed_features <- signed_features[-c(1,2)]

#normalize the features as dictated by normalize_which
#TODO get a list of features and optimize to call normalize with a definitive list 
if(normalization_which[1]) normalize(which(sapply(colnames(signed_features), function(x) any(grepl('EMG', x)))))
if(normalization_which[2]) normalize(which(sapply(colnames(signed_features), function(x) any(grepl('ACCL', x)))))
if(normalization_which[3]) normalize(which(sapply(colnames(signed_features), function(x) any(grepl('GYR', x)))))
if(normalization_which[4]) normalize(which(sapply(colnames(signed_features), function(x) any(grepl('ORN', x)))))


#this should result in a df? features, thresholds, weights for each alphabet

#obtain a list of features 


feature_selection(signed_features[1:85])
colnames(store_features) <- c("alphabet_name", "Features", "Range_Lower", "Range_Upper", "Threshold_lower", "Threshold_upper", "Weight")
temp_max <- as.numeric(max(store_features$Weight ))
temp_min <- as.numeric(min(store_features$Weight ))

normalized_weight <- ( as.numeric(as.vector(store_features$Weight)) - temp_min)/(temp_max - temp_min)
store_features <- cbind(store_features, normalized_weight)
outputfilepath_feature_selection  <- 'features/feature_selection_working.csv'
write.csv(store_features, file= outputfilepath_feature_selection) 

outputfilepath_feature_normalized  <- 'features/feature_normalized.csv'
write.csv(signed_features, file= outputfilepath_feature_normalized) 






#now 


