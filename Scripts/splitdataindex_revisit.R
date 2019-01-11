#returns a list of indeces for a 80/10/10 split
splitdataindex <- function(df) {
        set.seed(3883)
        
        i_all <- as.numeric(rownames(df))
        i_test <- sample(i_all, nrow(df)%/%10) 
        i_traindev <- setdiff(i_all, i_test)
        i_dev <- sample(i_traindev, nrow(df)%/%10)
        i_train <- setdiff(i_traindev, i_dev)
        list(i_train = i_train, i_dev = i_dev, i_test = i_test)
}

