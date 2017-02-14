#This file is a features_extractor file. 
#Input: csv with features vectors as columns, annotated by the feature name as filename, 
#Output: A single csv with with column ( name, ID, aggregated_feature_like_mean,.....aggregated_features_for_subsection, ...) 
#Set #segmentation length as appropriate to get more features (a signal with frequency of 50 will give five segments)
#copyright @prwl_nght 2016

#remove tempdata
if (!exists("segmentation_length")) segmentation_length = 10 
print(segmentation_length)

#data_directory <- '/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Shibani_0212016/'
#data_directory <- '/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Shweta_02112016/'
setwd(working_directory)
#this is where to loop 

filenames_all <- list.files(pattern ="csv", full.names=TRUE)
#read a file to get info
test0 <- read.csv(filenames_all[1])
#features already read
number_of_features_in_file = ncol(test0)
features_in_file <- c("EMGO", "EMG1", "EMG2", "EMG3", "EMG4", "EMG5", "EMG6", "EMG7", "ACCLX","ACCLY", "ACCLZ", "GYR1", "GYR2", "GYR3", "ORN1", "ORN2", "ORN3" )
#number of segmentations depends on the number of datapoints and the number of desired segmentations
segmentations = nrow(test0)/segmentation_length

#moments to compute
moments_to_compute <- c('mean', 'max', 'min', 'stdev', 'total_energy')
#moments_to_compute <- c('total_energy')
#the total number of features desired. The plus 2 is for name of signal and the id number 
number_of_feature_columns <- number_of_features_in_file*length(moments_to_compute) + segmentations*number_of_features_in_file*length(moments_to_compute) + 1
feature_row_names  <- c()
feature_column_names <- c()
feature_column_names[1] <- "Name"
i=0;j=0; 
feature_column_counter <- 1
for (j in 0:segmentations){
  for (i in 1:length(moments_to_compute)){
  for (feature_name_index in 1:length(features_in_file )){
  this_column_name <- paste(features_in_file[feature_name_index], "_", moments_to_compute[i], "_", j, sep="")
  feature_column_counter <- feature_column_counter + 1
  feature_column_names[feature_column_counter] <- this_column_name
  
  
  }
}
}
#initialize the dataframe 
features_extracted <- data.frame(matrix(vector(), length(filenames_all),number_of_feature_columns))

# this_colnames <- c(paste('means', index, sep="_"), paste('maxs', index, sep="_"), paste('mins', index, sep="_"), paste('stdevs', index, sep="_"),paste('total_energy', index, sep="_"))
# new_colnames <- c(previous_colnames, this_colnames)
# colnames(features_extracted) <<- column_names

#debug marker

compute_moments <- function(this_block, index){
  #features
  this_means <- colMeans(this_block)
  this_maxs <-  apply(this_block, 2, max)
  this_mins <- apply(this_block, 2, min)
  this_stdevs <- apply(this_block, 2, sd)
  this_total_energy <- colSums(this_block^2)
  
  all_features <- c(this_means, this_maxs, this_mins, this_stdevs, this_total_energy)
  #fixing colnames
  return(all_features)
}

for (file_index in 1: length(filenames_all)){
  
test1 <- read.csv(filenames_all[file_index])

#set column names #specific to single hand alphabet recognition 
#column_names <- c('EMG0', 'EMG1',  'EMG2',  'EMG3',  'EMG4',  'EMG5',  'EMG6',  'EMG7',  'ACCLX', 'ACCLY',  'ACCLZ',  'GYR_A', 'GYR_B', 'GYR_C', 'ORN_A', 'ORN_B', 'ORN_C')

#read overall corpus moments (mean, max, min)

#featurecolnames(test1) <- column_names


this_file <- filenames_all[file_index]
split_this <- strsplit(this_file, "_")[[1]]
this_file_id <- strsplit(split_this, "/")[[1]][2]
this_file_name <- paste(split_this[2], "_", split_this[3], sep="")

#the loop will build a vector that it will place in the file_index^th row

this_sign_moments <- c()
this_sign_moments[1] <- this_file_name
#populate the first item as the name of the signal and the second as a combination of name and id for easier access later
feature_row_names[file_index] <- paste(this_file_name, this_file_id, sep="")
#this computes the overall moments
this_sign_moments <- c(this_sign_moments, compute_moments (test1, 0))
#insert this into 

#this computes the moments for the individual segments. 
for (i in 1:segmentations){
  start_index <- ((i-1)*segmentation_length+1)
  stop_index <- i*segmentation_length
  segmented_block <- test1[start_index:stop_index,]
  this_sign_moments <- c(this_sign_moments, compute_moments(segmented_block, i))
  #insert into 
  
}

#write to the dataframe
features_extracted[file_index,] <- this_sign_moments
#remove the temp variable
remove(this_sign_moments)
#write features file with gesture name and identity of gesture. 


}
rownames(features_extracted) <- feature_row_names
colnames(features_extracted) <- feature_column_names

#write all features to one file 
outputfilename <- paste("features", '.csv', sep = "")
outputfilepath <- paste(getwd(), '/features/', outputfilename, sep="")
mainDir <- getwd()
subDir <- "features"

if (!file.exists(subDir)) dir.create(file.path(mainDir, subDir))

write.csv(features_extracted, file= outputfilepath)

