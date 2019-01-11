#Training LR model (no tuning) and testing on test set (ED revisit - 72 hours, administrative)

setwd('~/ED_Return/')

library(readr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)
library(keras)

#1) create train/test split
load('./Results/sparseMatrix_revisit_baseline_3day.RData')
load('./Results/indeces_revisit.RData')
x <- as.matrix(dataset$x)
y <- dataset$y
rm(dataset)

x_test <- x[indeces$i_test,]
y_test <- y[indeces$i_test]


x_train <- x[-indeces$i_test,]
y_train <- y[-indeces$i_test]

rm(x); rm(y)

#4) impute dataset for keras
impute <- preProcess(x_train, method = c('range', 'medianImpute'))
x_train <- predict(impute, x_train)
x_test <- predict(impute, x_test)

#3) build keras on all data except test set
model <-keras_model_sequential()
model %>%
        layer_dense(units = 1, activation = 'sigmoid', input_shape = ncol(x_train)) %>%
        compile(
                loss = 'binary_crossentropy',
                optimizer = optimizer_rmsprop(lr = 0.001),
                metrics = c('accuracy')
        )
model %>% fit(x_train, y_train, epochs = 2, batch_size = 128)


keras_pred_test <- as.vector(predict(model, x_test))

summary(model)
print('LR AUC 72hour')
roc(y_test, keras_pred_test)
ci.auc(roc(y_test, keras_pred_test), conf.level = 0.95)
keras_pred_test_3day <- keras_pred_test
save(keras_pred_test_3day, file = "./Results/y_hat_test_lr_3day_baseline.RData")

