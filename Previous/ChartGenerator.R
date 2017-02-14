library(dtw)

setwd("~/Google Drive/School/Research/Projects/Hand/Data/HealthSigns_01232016_Prajwal/")
test1 <- read.csv('allmorning_145367627.csv')
test2 <- read.csv('allmorning_145367629.csv')
test3 <- read.csv("cantsleep_145367473.csv")

trial <- 3

#DTW Similarity

par(mfrow=c(3,1))
par(bg='white')
plot(test1[,11], type="l", col="red", ylab="Accl X", xlab= "All Morning Accl X")
plot(test2[,11], type="l", col="blue", ylab="Accl X", xlab = "All Morning Accl X")
plot(test3[,11], type="l", col="black", ylab="Accl X", xlab = "Can't Sleep Accl X")



#EMG no similarity 
par(mfrow=c(3,1))
plot(test1[,trial], type="l", col="red", ylab="EMG 1", xlab= paste("All Morning EMG 2 Energy:", sum(test1[, trial]^2)))
plot(test2[,trial], type="l", col="blue", ylab="EMG 2", xlab = paste("All Morning EMG 2 Energy:", sum(test2[, trial]^2)))
plot(test3[,trial], type="l", col="orange2", ylab="EMG 2", xlab = paste("Can't Sleep EMG 2 Energy:", sum(test3[, trial]^2)))
