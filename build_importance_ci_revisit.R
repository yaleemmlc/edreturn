#Get mean information gain for each variable from 100 runs of XGBoost (9 days, full dataset)
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
load('./Results/sparseMatrix_revisit.RData')
x <- dataset$x
y <- dataset$y
rm(dataset)


#prepare matrices for XGBoost
x_train <- x[-indeces$i_test,]
y_train <- y[-indeces$i_test]
x_test <- x[indeces$i_test,]
y_test <- y[indeces$i_test]
rm(x); rm(y)


for (i in 1:100) {
        bst <- xgboost(data = x_train, label = y_train,
                       max_depth = 20, eta = 0.3,
                       nthread = 5, nrounds = 20,
                       eval_metric = 'auc',
                       objective = "binary:logistic",
                       colsample_bylevel = 0.03)
        # get importance table
        importance <- xgb.importance(feature_names = x_train@Dimnames[[2]], model = bst)
        #extract gain
        importance <- importance[,c(1,2)]
        #change name of column
        label <- paste0("Gain", i)
        names(importance)[2] <- label
        if (i == 1) {
                result <- importance
        } else {
                result <- left_join(result, importance, by = 'Feature')
        }
        print(paste("Finished iteration",i))
}

save(result, file = './Results/bst_importance_100_revisit.RData')
