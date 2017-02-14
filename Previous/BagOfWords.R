#BagofWords.r 
#This file is to flush out some algorithms for EMG comparision.

#objectives: 1. Increase the EMG accuracy for a single person 2. Increase cross EMG accuracy between people


#Approach: (In ASANA Mobile Computing > Project:Alphabet)

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
setwd('~/Google Drive/School/Research/Projects/Hand/Data/HealthSigns_01232016_Prajwal/')
logfilename <- paste( getwd(), '/crossvalidation_bothhands_',name_time, sep="" )
sink(logfilename, split = TRUE)


filenames_all <- list.files(pattern ="csv", full.names=TRUE)
number_of_signs <- length(filenames_all)

allmorning <- read.csv('./allmorning_145367627.csv')


for(file in filenames_all){
  print(file)
  

  
}