#Pipeline for XGBoost model tuning (ED revisit - 72 hours, administrative data)
setwd('~/ED_Return/')

library(readr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)

registerDoMC(5) #for parallelization

load('./Results/cleandf_revisit.RData')

#use only administrative data + PMH
source('./Scripts/baseline_df.R')
df <- baseline_df(df)

#Re-encode dataframe into design matrix x and response y
source("./Scripts/makematrix_revisit.R")
dataset <- makematrix_revisit(df, nineday = F)
save(dataset, file = './Results/sparseMatrix_revisit_baseline_3day.RData') #save for future use


load('./Results/indeces_revisit.RData')
# load('./Results/sparseMatrix_revisit.RData')
x <- dataset$x
y <- dataset$y
rm(dataset)



#prepare matrices for XGBoost
x_train <- x[indeces$i_train,]
y_train <- y[indeces$i_train]
x_dev <- x[indeces$i_dev,]
y_dev <- y[indeces$i_dev]
rm(x); rm(y)

for (depth in c(10,15,20,25)) {
        bst <- xgboost(data = x_train, label = y_train,
                       max_depth = depth, eta = 0.3,
                       nthread = 5, nrounds = 20,
                       eval_metric = 'auc',
                       objective = "binary:logistic",
                       colsample_bylevel = 0.03)
        print(bst)
        # save(bst, file = './Results/bst_model.RData')
        auc_train <- as.numeric(bst$evaluation_log$train_auc[length(bst$evaluation_log$train_auc)])
        
        #7) Predict on dev
        y_hat_dev <- predict(bst, x_dev)
        auc_dev <- as.numeric(auc(y_dev, y_hat_dev))
        
        print('3day return AUC')
        print(c(auc_train,auc_dev))
}