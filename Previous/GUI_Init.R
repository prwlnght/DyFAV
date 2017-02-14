#Tryin out R-GUI
rm(list = ls())

#library(gWidgets)
#library(gWidgestcltk) 
 
this_initialize <- function(){
  print("initializing...")
  is_init <<- TRUE


#globals
constant_person_name <<- 'Prajwal'
constant_database_location <<- '/Users/lizard/Google\ Drive/School/Research/Projects/Hand/Data/DemoSigns_02102016_Prajwal/'

#init the matrix 
#Initialize the test_matrices as globals

#source('req_energy_calculator.R')
#source('CombineHands.R')

#logging output to file 
#set the database 
name_time <- format(.POSIXct(Sys.time(),tz="GMT"), "%H%M%S")
setwd(constant_database_location)
#logfilename <- paste( getwd(), '/demo_test_',name_time, sep="" )
#sink(logfilename, split = TRUE)
#logging output to file end

#system_variables
diff <- list()
recognized_gestures_names_all <- c()

#init the database
filenames_all <<- list.files(pattern ="csv", full.names=TRUE)
sorter_matrix <<- data.frame(matrix(ncol=length(filenames_all), nrow=1))
number_of_signs <<- length(filenames_all)
MAX = 50
MIN = 50

filename_index <<- 0 

test_matrices <<- list()

train_matrices <<- list()
all_distances_list <<- list()

recognized_gestures <<- c("allmorning", "cantsleep", "coldrunnynose", "continuouslyforanhour", "everymorning", 
                         "everynight", "headache", "monthly", "itching", "notfeelgood", "swelling", "soreness",
                         "takeliquidmedicine", "thatsterrible", "tired", "upsetstomach")

for ( matrix_creation_index in 1:34){
  test_matrices[[matrix_creation_index]] <<- matrix(nrow = MIN, ncol = 0)
  train_matrices[[matrix_creation_index]] <<- matrix(nrow = MIN, ncol = 0)
}

col_names <<- c()
final_distances <<- c()
#begin loading the train matrices
counter = 0
for (file in filenames_all){
  
  counter = counter +1;
  temp <- read.csv(file)
  temp <- temp[2:35]
  
  if(nrow(temp) < (MIN) ) next; 
  for (name in recognized_gestures) {
    if (grepl(name, file)) col_names[[length(col_names)+1]] <<- name
  }
  
  #if temp has more rows than our matrix, truncate, otherwise truncate the matrix
  temp <- temp[1:MIN,]
  for (train_matrix_population_index in 1:34){
    train_matrices[[train_matrix_population_index]] <<- cbind(train_matrices[[train_matrix_population_index]], temp[,train_matrix_population_index])
  }
  
  
}  


}
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

  
  #this function takes a testData (filename), loads it, transforms it then runs it through the already loaded test matrices
#then it shows results against the algorithm 'all' 
recognition_module <- function (testDataFile, this_sign){
  
  testData <- read.csv(testDataFile)
  #transform the test_data same as trianing data
  testData <- testData[2:35]
  #print(testData)
  
  #run recognition module on just this one instance
    for(trainIndex in 1:ncol(train_matrices[[1]])){
      all_distances <- c() 
      for (testIndex in 1: ncol(testData)){
      #put combined distance in a list 
      
      all_distances[testIndex] <- abs(sum(train_matrices[[testIndex]][,trainIndex]^2) -  sum(testData[,testIndex]^2))   
    } 
    all_distances_list [[trainIndex]] <<-  all_distances
  }
  
  for (final_distance_index in 1:length(all_distances_list)){  
    sorted_all_distance <- c()
    final_distances[final_distance_index] <<- sum(all_distances_list[[final_distance_index]])
  }
   
  sorter_matrix[1,] <<- final_distances
  colnames(sorter_matrix) <<- col_names
  
  #sort the matrix 
  
  #print the first rowname
  
  recognized_word <- colnames(sorter_matrix[order(sorter_matrix[1,])])[1]
  
  par(bg='blue4')
  plot(0)
  text(1,0, this_sign, col="white", cex=11)

  
}


for(trial_index in 1:10){  
  #call getDataRight.sh
  
  for(waitIndex in 1:2){
    m_message <- paste("Starting in", waitIndex, "seconds..")
    print(m_message)
    Sys.sleep(1)
  }
  #clear pending directory
  print("BEGIN...")
  #read the newest datafile into a temp
  system('ssh lizard@192.168.2.3 "rm -r /Users/Jack/Desktop/blackbox/HandsTemp/*.csv"')
  
  setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Pending/')
  system('rm -r *.csv')
  setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Combined/')
  system('rm -r *.csv')
  
  setwd('/Users/lizard/Development/gitRepos/Hands/Data/EMGData/')
  system('/Users/lizard/Development/gitRepos/Hands/Data/EMGData/gatherData.sh DemoData')
  
  #TODO change directory to something else in X code in the other mac (non google drive position)
  
  #TODO fix this code with the right ip and the correct path to the data and right filename ''
  #Error if filename not found 'filename can be hardcoded' 
  setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Pending/')
  #clear current
  system('scp lizard@192.168.2.3:~/Desktop/blackbox/HandsTemp/*.csv .')
  
  #combining the files into one file 
  #TODO better approach will be to have a synced database and check on each server, get results 
  setwd('~/Development/gitRepos/Hands/Rcodes/')
  source('CombineHands.R')
  
  #combine files 
  #setwd('/Users/lizard/Desktop/Hands/Data/Alphabet/Combined/')

  #gest all csv files but take only the last created one
  setwd('/Users/lizard/Google Drive/School/Research/Projects/Hand/Data/Alphabet/Combined/')
  test_file_names <- file.info(list.files(pattern="*.csv"))
  this_test_file <- tail(rownames(test_file_names), n=1)
  
  #uni testing
  #provide recognition module with an exisitng file (remove it temporarily from the database)
  this_test_file <- paste(getwd(), this_test_file, sep='/')
  
  
  if(!exists('is_init')) this_initialize()
  start_time <<- Sys.time()
  list_for_demo <- c('allmorning', 'coldrunnynose', 'everynight', 'upsetstomach', 'cantsleep', 'allmorning', 'headache', 'allmorning', 'coldrunnynose', 'everynight')
  
  
  recognition_module(this_test_file, list_for_demo[trial_index] )
  end_time <<- Sys.time()
  duration <<- start_time - end_time
  print(duration)
}




