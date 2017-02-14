#ProcessGesture.R copied
#This file is a cross-validation test and report for training and testing data. 
# run : setwd('~/Development/gitRepos/Hands/Data/EMGData')

#next steps 

#I have energy count for each test file 
#Use energy count and #figure out a metric to rank accl vs. eMG

#Do an either or approach to testing. 
#includes
require(graphics)
require(zoo)
library(dtw)
library(ggplot2)

rm(list = ls())

setwd('~/Development/gitRepos/Hands/Rcodes/')
source('req_energy_calculator.R')
#source('CombineHands.R')

#logging output to file 
name_time <- format(.POSIXct(Sys.time(),tz="GMT"), "%H%M%S")
setwd('~/Google Drive/School/Research/Projects/Hand/Data/DemoSigns_02102016_Prajwal/')
logfilename <- paste( getwd(), '/crossvalidation_bothhands_',name_time, sep="" )
sink(logfilename, split = TRUE)
#logging output to file end

#system_variables
diff <- list()
test_gesture_names <- c()
recognized_gestures_names_all <- c()
recognized_gestures_names_accl <- c()
recognized_gestures_names_emg <- c()
recognized_gestures_names_orient <- c()
recognized_gestures_names_accl_plus_emg <- c()
recognized_gestures_names_orient_plus_emg <- c()
recognized_gestures_names_accl_plus_orient <- c()

#features being tested: normalized square distance, total distance, mean distance, minimum distance 
number_correct <- list(0, 0, 0, 0, 0, 0, 0, 0)
list_of_algorithms <- c("all", 
                        "emg", "accl", "orient", 
                        "accl_emg", "accl_orient", "emg_orient")

#primary hand and secondary hand

primary_hand <- 'right'
secondary_hand <- 'left'

filenames_all <- list.files(pattern ="csv", full.names=TRUE)
number_of_signs <- length(filenames_all)

#length of files
n <- length(filenames_all)

filename_index <- 0 

#this returns the top 'n' number of signs 
getTopSigns <- function(full_list, max_number){
  unique_list <- list() 
  unique_list_counter = 0
  for (names_counter in 1:length(names(full_list))){
    
    if (unique_list_counter >= max_number) break
    if (names_counter ==1 ) {
      unique_list_counter = unique_list_counter + 1
      unique_list[unique_list_counter] <- names(full_list)[names_counter]
    }
    
    else {
      if (!(names(full_list)[names_counter] %in% unique_list)){
        unique_list_counter = unique_list_counter + 1
        unique_list[unique_list_counter] <- names(full_list)[names_counter] 
      }
    }
  }
  return(unique_list)
}


test_matrices <- list()

train_matrices <- list()


normalize <- function(X){
  
  if(diff(range(X))!=0) return(round((X-min(X))/diff(range(X)), digits =6)) else return(X/X) 
}

#printinfo also calculates accuracy
printInfo <- function(this_sorted_distance,  gesture_name, index){
  
  #print(this_sorted_distance)
 # print (paste("Based on", list_of_algorithms[index] , gesture_name, "is a ", names(this_sorted_distance)[1]))
  is_correct <- grepl(names(this_sorted_distance)[1], gesture_name )
  if(is_correct){
    number_correct[[index]] <<-  number_correct[[index]] + 1
    #if correct then check confidence, if confidence was bad 0.5 
  } 
 # print(paste("number_correct", number_correct[[index]]))
}

m_scale <- function(this_m_data){
  return(apply(this_m_data, MARGIN = 2, FUN = function(X)(X- min(this_m_data))/diff(range(this_m_data))))
}

start_time <- Sys.time()
#begin cross validation
for (file in filenames_all){
  filename_index = filename_index + 1
  
  # 2. Pick 1st file as test file, everything else is a train file 
  print (file) 
  filenames_process_test <- file
  filenames_process_train <- filenames_all[-filename_index]
  #filenames_process_test <- newList
  mdata <- list()
  #uncomment this for first 20 IUI data
  #recognized_gestures <- c("day", "home", "hot", "pizza", "mom", "happy", "wash", "shirt", "hurt", "large", "bird", "blue", "cat", "dollar", "goodnight", "horse", "orange", "please", "cost", "gold")
  #uncomment this for first 10 IUI custom gestures
  #recognized_gestures <- c("fist", "wave_left", "wave_right", "double_tap", "twist", "mom", "home", "day", "hot", "green")
  #uncomment this for first round of medical data
  #recognized_gestures <- c("allmorning", "cantsleep", "coldrunnynose", "continuouslyforanhou", "everymorning", "everynight", "headache", "monthly", "notfeelgood", "soreness", "swelling", "takeliquidmedicine", "thatsterrible", "tired", "upsetstomach")
  ##uncomment this for first round of medical data Paul
  recognized_gestures <- c("allmorning", "cantsleep", "coldrunnynose", "continuouslyforanhour", "everymorning", 
                           "everynight", "headache", "monthly", "itching", "notfeelgood", "swelling", 
                           "takeliquidmedicine", "thatsterrible", "tired", "upsetstomach")
  MAX = 50
  MIN = 50
  
  #make 17 * 2 test matrices
  for ( matrix_creation_index in 1:34){
    test_matrices[[matrix_creation_index]] <- matrix(nrow = MIN, ncol = 0)
    train_matrices[[matrix_creation_index]] <- matrix(nrow = MIN, ncol = 0)
  }
  
  col_names <- c()
  counter =0
  test_gesture_name <- c()
  for(file in filenames_process_test){
    counter = counter +1;
    temp <- read.csv(file)
    
    #temp  <- apply(temp, MARGIN = 2, FUN = function(X) normalize(X))
    temp <- temp[2:35]
    if(nrow(temp) < (MIN-1) ) next; 
    
    for (name in recognized_gestures) {
      if (grepl(name, file)) test_gesture_name[length(test_gesture_name)+1] <-  paste("test_", name, sep="")
    }
    
    test_gesture_names[length(test_gesture_names) + 1] <- file
    
    temp <- temp[1:MIN,]
    #put it in the matrix list
    for (test_matrix_population_index in 1:34){
      test_matrices[[test_matrix_population_index]] <- cbind(test_matrices[[test_matrix_population_index]], temp[,test_matrix_population_index])
    }
  }
  mat_all_distances_matrices <- list()
  mat_emg_distances_matrices_right <- list()
  mat_emg_distances_matrices_left <- list()
  energy_accl_left <- list()
  energy_accl_right <- list()
  energy_orient_left<- list()
  energy_orient_right<- list()
  energy_emg_left<- list()
  energy_emg_right<- list()
  
  for (setup_counter in 1: ncol(test_matrices[[1]])){
    mat_all_distances_matrices[[setup_counter]] <- matrix(nrow=34, ncol= 0)
    mat_emg_distances_matrices_right[[setup_counter]] <- matrix(nrow=8, ncol=0)
    mat_emg_distances_matrices_left[[setup_counter]] <- matrix(nrow=8, ncol=0)
  }
  
  #iterate through all the test files and load them in a different matrix for each axis
  counter = 0
  for(file in filenames_process_train){
    test_counter = 0
    counter = counter +1;
    temp <- read.csv(file)
    #normalize
    #temp  <- apply(temp, MARGIN = 2, FUN = function(X) normalize(X))
    temp <- temp[2:35]
    if(nrow(temp) < (MIN) ) next; 
    for (name in recognized_gestures) {
      if (grepl(name, file)) col_names[[length(col_names)+1]] <- name
    }
    #if temp has more rows than our matrix, truncate, otherwise truncate the matrix
    temp <- temp[1:MIN,]
    for (train_matrix_population_index in 1:34){
      train_matrices[[train_matrix_population_index]] <- cbind(train_matrices[[train_matrix_population_index]], temp[,train_matrix_population_index])
    }
    all_distances <- c()  
    energy_accl_left <- c()
    energy_accl_right <- c()
    energy_orient_left<- c()
    energy_orient_right<- c()
    energy_emg_left<- c()
    energy_emg_right<- c()
    for (distance_iterator in 1: ncol(test_matrices[[1]])){
      test_counter= test_counter+1
      for (distance_counter in 1:34){
        all_distances[distance_counter] <- abs(sum(train_matrices[[distance_counter]][,counter]^2) -  sum(test_matrices[[distance_counter]][,test_counter]^2))
        #separation
        {#energy right
        if(distance_counter >= 1 && distance_counter <=8 ) 
          energy_emg_right[distance_counter] <- abs(sum(train_matrices[[distance_counter]][counter]^2) -  sum(test_matrices[[distance_counter]][test_counter]^2))
        #energy left
        else if(distance_counter >= 18 && distance_counter <=25 )
          energy_emg_left[distance_counter+1-18] <- abs(sum(train_matrices[[distance_counter]][counter]^2) -  sum(test_matrices[[distance_counter]][test_counter]^2))
        #accl right
        else if(distance_counter >= 9 && distance_counter <=11 )  
          energy_accl_right[distance_counter+1-9] <- abs(sum(train_matrices[[distance_counter]][counter]^2) -  sum(test_matrices[[distance_counter]][test_counter]^2))
        #accl left 
        else if(distance_counter >= 26 && distance_counter <=28 )    
          energy_accl_left[distance_counter+1-26] <- abs(sum(train_matrices[[distance_counter]][counter]^2) -  sum(test_matrices[[distance_counter]][test_counter]^2))
        #orientation right
        else if(distance_counter >= 15 && distance_counter <=17 )   
          energy_orient_right[distance_counter+1-15] <- abs(sum(train_matrices[[distance_counter]][counter]^2) -  sum(test_matrices[[distance_counter]][test_counter]^2))
        #orientation left
        else if(distance_counter >= 32 && distance_counter <=34 )   
          energy_orient_left[distance_counter+1-32] <- abs(sum(train_matrices[[distance_counter]][counter]^2) -  sum(test_matrices[[distance_counter]][test_counter]^2))
        }
      }
      mat_all_distances_matrices[[test_counter]] <- cbind(mat_all_distances_matrices[[test_counter]], all_distances)
      colnames(mat_all_distances_matrices[[test_counter]]) <- col_names 
    }  
  }
  #to match column_names
  for (naming_counter in 1:34){
    colnames(test_matrices[[naming_counter]]) <- test_gesture_name
    colnames(train_matrices[[naming_counter]]) <- col_names
  }
  
  
  sorter=0
  for(x in mat_all_distances_matrices){
    sorter = sorter+1
    colnames(x) <- col_names

    #right 
    emg_right_portion <- x[1:8,]
    accl_right_portion <- x[9:11,]
    orient_right_portion <- x[15:17,]
    
    #left
    emg_left_portion <- x[18:25,]
    accl_left_portion <- x[26:28,]
    orient_left_portion<- x[32:34,]

    sorted_all_distance <- sort(colSums(x))
    
    emg_combined <- emg_right_portion + emg_left_portion
    sorted_emg_left_portion <- sort(colSums(emg_left_portion))
    sorted_emg_right_portion <- sort(colSums(emg_right_portion))
    sorted_emg_combined <- sort(colSums(emg_combined))
    
    accl_combined <- accl_right_portion + accl_left_portion
    sorted_accl_right_portion <- sort(colSums(accl_right_portion))
    sorted_accl_left_portion <- sort(colSums(accl_left_portion))
    sorted_accl_combined <- sort(colSums(accl_combined))
    
    orient_combined <- orient_right_portion + orient_left_portion
    sorted_orient_right_portion <- sort(colSums(orient_right_portion))
    sorted_orient_left_portion <- sort(colSums(orient_left_portion))
    sorted_orient_combined <- sort(colSums(orient_combined))
    
    scaled_accl_combined <- m_scale(accl_combined)
    scaled_emg_combined <- m_scale(emg_combined)
    scaled_orient_combined <- m_scale(orient_combined)
    
    
    sorted_accl_and_emg <- sort((colSums(scaled_accl_combined)*8+colSums(scaled_emg_combined)*3)/24)
    sorted_accl_and_orient <- sort(colSums(scaled_accl_combined+scaled_orient_combined))
    sorted_orient_and_emg <- sort((colSums(scaled_orient_combined)*8+colSums(scaled_emg_combined)*3)/24)
    
    #uncomment this to get details
    printInfo(sorted_all_distance, test_gesture_name[sorter], 1)
    printInfo(sorted_emg_combined, test_gesture_name[sorter], 2)
    printInfo(sorted_accl_combined, test_gesture_name[sorter], 3)
    printInfo(sorted_orient_combined,  test_gesture_name[sorter], 4)
    printInfo(sorted_accl_and_emg, test_gesture_name[sorter], 5)
    printInfo(sorted_accl_and_orient, test_gesture_name[sorter], 6)
    printInfo(sorted_orient_and_emg, test_gesture_name[sorter], 7)
    
    recognized_gestures_names_all[length(recognized_gestures_names_all)+1] <- names(sorted_all_distance)[1]
    recognized_gestures_names_accl[length(recognized_gestures_names_accl)+1] <- names(sorted_accl_combined)[1]
    recognized_gestures_names_emg[length(recognized_gestures_names_emg)+1] <- names(sorted_emg_combined)[1]
    recognized_gestures_names_orient[length(recognized_gestures_names_orient)+1] <- names(sorted_orient_combined)[1]
    recognized_gestures_names_accl_plus_emg[length(recognized_gestures_names_accl_plus_emg)+1] <- names(sorted_accl_and_emg)[1]
    recognized_gestures_names_orient_plus_emg[length(recognized_gestures_names_orient_plus_emg)+1] <- names(sorted_orient_and_emg)[1]
    recognized_gestures_names_accl_plus_orient[length(recognized_gestures_names_accl_plus_orient)+1] <- names(sorted_accl_and_orient)[1]
    
    
  }
  
  print('------------------------------------------------------------------------------------------------------------------------------------------')
}

for( printIndex in 1:(length(list_of_algorithms))){
  print(paste("Algorithm", list_of_algorithms[printIndex] , ":" , "Number of Correct", number_correct[[printIndex]], "and Accuracy of: ", number_correct[[printIndex]]/number_of_signs*100, "percent"))
}

print('------------------------------------------------------------------------------------------------------------------------------------------')


end_time <- Sys.time() 
duration <- end_time - start_time
time_per_gesture <- duration / number_of_signs #milliseconds
print(paste('It took ', duration, ' seconds ', 'to process ', number_of_signs, ' at the rate of ', time_per_gesture, ' milliseconds per gesture' ))

print('test_gesture_names')
print(test_gesture_names)

print( 'recognized_gestures_names_all')
print( recognized_gestures_names_all)

print( 'recognized_gestures_names_accl')
print( recognized_gestures_names_accl)

print( 'recognized_gestures_names_emg')
print( recognized_gestures_names_emg)

print( 'recognized_gestures_names_orient')
print( recognized_gestures_names_orient)

print( 'recognized_gestures_names_accl_plus_emg')
print( recognized_gestures_names_accl_plus_emg)

print( 'recognized_gestures_names_orient_plus_emg')
print( recognized_gestures_names_orient_plus_emg)

print( 'recognized_gestures_names_accl_plus_orient')
print( recognized_gestures_names_accl_plus_orient)
#plots
## 1. Number of Training Examples vs. Accuracy
height_table1 <- c(97.52, 97.31, 88, 85)
table1_cols <- rgb(runif(3), runif(3), runif(3))
barplot(height_table1, names.arg = c(4,3,2,1), col = table1_cols , ylim = c(0, 100))

## 2. Features used vs. Accuracy
table2_cols <- rgb(runif(5), runif(5), runif(5))
height_table2 <- c(97.72, 88.64, 81.81, 93.18, 90.90, 94.42, 95.45)
table2.args <- list_of_algorithms
k = barplot(height_table2, density=c(5,35,10,45,7,30,15 ), angle = c(0,90, 45, 90, 0, 30, 20), names.arg = table2.args, ylim = c(0,100), col= table2_cols)
text(k,height_table2, labels = height_table2, pos =2 )

## Features used vs. Accuracy (Less Training Examples)
table3_cols <- rgb(runif(5), runif(5), runif(5))
height_table3 <- c(85, 70, 70, 80, 80, 80, 85)
table3.args <- list_of_algorithms
barplot(height_table3, names.arg = table3.args, ylim = c(0,100), col= table2_cols)

#time analysis chart
x_time_limits <- c(5, 15, 25, 35, 45, 55, 65)
y_time_limits <- c(0.059, 0.1244, 0.21, 0.29, 0.374, 0.459, 0.552)
plot(x_time_limits, y_time_limits, type="o", xlab="Number of Training Gestures",ylab="Time(Seconds)", xlim = c(0, 70), ylim <- c(0,.6) ) 
lines(x_time_limits, y_time_limits, type = 'o')


#chart 
