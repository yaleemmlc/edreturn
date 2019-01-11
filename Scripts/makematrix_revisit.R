#21) converts cleaned dataframe into numeric matrix and a response vector 
# returns a list of y = vector of response, x = sparse matrix of predictors

makematrix_revisit <- function(df, nineday = T) {
        library(Matrix)

        
        if (nineday) {
                #response vector for 9-day return
                df$revisit <- ifelse(df$revisit == 'noacuterevisit', 0, 1)
        } else {
                #response vector for 72-hour return
                df$revisit <- ifelse(df$revisit == 'within3days', 1, 0)
        }
        #set this vector as our response
        response <- df$revisit
        #set the rest as our design matrix
        df <- select(df,-revisit)
        
        #dummify categorical variables and encode into matrix
        dmy <- dummyVars(" ~ .", data = df)
        
        df <- Matrix(predict(dmy, newdata = df), sparse = T)
        
        list(y = response, x = df)
}




