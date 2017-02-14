


indexFirstNonZero <- function(mlist){
  for(i in 1:nrow(mlist)){
    
    if (mlist[i,1] != 0) return (i)
    
  }
  return(0) 
}

 


energy_calculator <- function (file){

  temp_adjusted <- list()
  firstNonZeroIndex <- c()  
  for (counter_nonZero in 1:ncol(temp)){
    firstNonZeroIndex[counter_nonZero] <- indexFirstNonZero(temp[counter_nonZero])
  }
  
  
sum_of_energies_emg<- 0
sum_of_energies_accl<- 0
sum_of_energies_gyr <- 0
sum_of_energies_orient  <- 0
for ( energy_counter in 1:(ncol(file))){
  temp_adjusted[energy_counter] <- file[energy_counter] - file[energy_counter][firstNonZeroIndex[energy_counter], 1]
  #TODO emg energy has to be adjusted based on which first one is detected and substract only that from others. 
  #temp_adjusted[energy_counter] <- temp[energy_counter]
  if ( energy_counter <= 8 ) sum_of_energies_emg <- sum_of_energies_emg + sum(temp_adjusted[[energy_counter]]^2)
  else if (energy_counter > 8 && energy_counter <= 11) sum_of_energies_accl <- sum_of_energies_accl + sum(temp_adjusted[[energy_counter]]^2) 
  else if (energy_counter > 11 && energy_counter <=14) sum_of_energies_gyr <- sum_of_energies_gyr + sum(temp_adjusted[[energy_counter]]^2) 
  else sum_of_energies_orient <- sum_of_energies_orient + sum(temp_adjusted[[energy_counter]]^2)
}
 to_return <- list(sum_of_energies_emg, sum_of_energies_accl, sum_of_energies_gyr, sum_of_energies_orient)
  return (to_return)
}