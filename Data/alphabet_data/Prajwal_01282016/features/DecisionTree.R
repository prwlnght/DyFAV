library(rpart)


function <- decision
this_data <- read.csv('features/decision_tree_01.csv')

fit <- rpart(Sign ~ EMGO_total_energy_0 + EMG1_total_energy_0 + EMG2_total_energy_0 + EMG3_total_energy_0 + EMG4_total_energy_0 + EMG5_total_energy_0  + EMG6_total_energy_0 + EMG7_total_energy_0 
             + EMGO_total_energy_1 + EMG1_total_energy_1 + EMG2_total_energy_1 + EMG3_total_energy_1 + EMG4_total_energy_1 + EMG5_total_energy_1  + EMG6_total_energy_1 
             + EMG7_total_energy_1 + EMGO_total_energy_2 + EMG1_total_energy_2 + EMG2_total_energy_2 + EMG3_total_energy_2 + EMG4_total_energy_2 + EMG5_total_energy_2  + EMG6_total_energy_2 + EMG7_total_energy_2 
             + EMGO_total_energy_3 + EMG1_total_energy_3 + EMG2_total_energy_3 + EMG3_total_energy_3 + EMG4_total_energy_3 + EMG5_total_energy_3  + EMG6_total_energy_3 + EMG7_total_energy_3 
             + EMGO_total_energy_4 + EMG1_total_energy_4 + EMG2_total_energy_4 + EMG3_total_energy_4 + EMG4_total_energy_4 + EMG5_total_energy_4  + EMG6_total_energy_4 + EMG7_total_energy_4, method='class', data=this_data )

printcp(this_tree)


#prunign the tree
# 
# pfit<- prune(fit, cp=   fit$cptable[which.min(fit$cptable[,"xerror"]),"CP"])
# 
# 
# plot(pfit, uniform=TRUE, 
#      main="Pruned Classification Tree for Kyphosis")
# text(pfit, use.n=TRUE, all=TRUE, cex=.8)
# post(pfit, file = "ptree.ps", 
#      title = "Pruned Classification Tree for Kyphosis")