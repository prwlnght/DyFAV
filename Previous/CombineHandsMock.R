#This file combines all files with the same "timestamp" number into one file and stores it in the data folder


#set the working directory to the pending one

setwd('~/Google Drive/School/Research/Projects/Hand/Data/CombinedData/Pending')

combineFiles <- function(list_of_files_to_combine, this_file_name, this_file_id){  
  
  file1 <- read.csv(list_of_files_to_combine[1])
  file2 <- read.csv(list_of_files_to_combine[2])
  file3 <- cbind(file1, file2)
  name_to_write <- paste('../', this_file_name, '_', this_file_id, '.csv', sep = "")
  write.csv(file3, file = name_to_write)
}
#make a list of all files

filenames_all <- list.files(pattern ="csv", full.names=FALSE)

this_file_id <- ""
other_file_id <- ""
this_file_name <- ""
indexed_file_ids <- c()
for (file_index in 1: length(filenames_all)){
  
  this_file <- filenames_all[file_index]
  #other_files <- filenames_all[-file_index]
  split_this <- strsplit(this_file, "_")[[1]]
  this_file_id <<- split_this[1]
  this_file_name <<- split_this[2]
  
  combineFiles(c(this_file, this_file), this_file_name, this_file_name)
  
}


#for each file in the list, isolate the timestamp ID and find another file with the same timestamp id


#combine the two files. 