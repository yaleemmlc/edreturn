#Training model using optimized set of hyperparmeters and testing on test set (ED revisit - 72 hours, administrative)

setwd('~/ED_Return/')

library(readr)
library(plyr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)

registerDoMC(5) #for parallelization


load('./Results/indeces_revisit.RData')
load('./Results/sparseMatrix_revisit_baseline_3day.RData')
x <- dataset$x
y <- dataset$y
rm(dataset)



#prepare matrices for XGBoost
x_train <- x[-indeces$i_test,]
y_train <- y[-indeces$i_test]
x_test <- x[indeces$i_test,]
y_test <- y[indeces$i_test]
rm(x); rm(y)

bst <- xgboost(data = x_train, label = y_train,
                       max_depth = 15, eta = 0.3,
                       nthread = 5, nrounds = 20,
                       eval_metric = 'auc',
                       objective = "binary:logistic",
                       colsample_bylevel = 0.03)
print(bst)
# save(bst, file = './Results/bst_model.RData')
auc_train <- as.numeric(bst$evaluation_log$train_auc[length(bst$evaluation_log$train_auc)])
        
#7) Predict on test
y_hat_test <- predict(bst, x_test)
auc_test <- as.numeric(auc(y_test, y_hat_test))

print('3day return AUC')
print(c(auc_train,auc_test))

ci.auc(roc(y_test, y_hat_test), conf.level = 0.95)

#save for future use
y_hat_test_baseline_3day <- y_hat_test
save(y_hat_test_baseline_3day, file = './Results/y_hat_test_xgb_3day_baseline.RData')
