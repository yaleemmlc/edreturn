#Pipeline for XGBoost model tuning (ED revisit - 9 days, Top 20 variables)
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

#Use only top 20 variables
source('./Scripts/top20_df.R')
df <- top20_df(df)

#Re-encode dataframe into design matrix x and response y
source("./Scripts/makematrix_revisit.R")
dataset <- makematrix_revisit(df, nineday = T)
save(dataset, file = './Results/sparseMatrix_revisit_top20.RData') #save for future use


load('./Results/indeces_revisit.RData')
#load('./Results/sparseMatrix_revisit_top20.RData')
x <- dataset$x
y <- dataset$y
rm(dataset)



#prepare matrices for XGBoost
x_train <- x[indeces$i_train,]
y_train <- y[indeces$i_train]
x_dev <- x[indeces$i_dev,]
y_dev <- y[indeces$i_dev]
rm(x); rm(y)

for (depth in c(5,10,15)) {
        bst <- xgboost(data = x_train, label = y_train,
                       max_depth = depth, eta = 0.3,
                       nthread = 5, nrounds = 20,
                       eval_metric = 'auc',
                       objective = "binary:logistic",
                       colsample_bylevel = 0.1)
        print(bst)
        # save(bst, file = './Results/bst_model.RData')
        auc_train <- as.numeric(bst$evaluation_log$train_auc[length(bst$evaluation_log$train_auc)])
        
        #7) Predict on dev
        y_hat_dev <- predict(bst, x_dev)
        auc_dev <- as.numeric(auc(y_dev, y_hat_dev))
        
        print('9day return AUC')
        print(c(auc_train,auc_dev))
}