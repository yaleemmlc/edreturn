#2. Process current diagnoses

currentdiagnoses <- function(path, icd9path, master_revisit) {
        diagnoses <- read_csv(path)
        #only use encounters in our master df
        diagnoses <- filter(diagnoses, PAT_ENC_CSN_ID %in% master_revisit$PAT_ENC_CSN_ID)
        
        test <- filter(diagnoses, PRIMARY_DX_YN =='Y')
        # length(unique(test$PAT_ENC_CSN_ID))/nrow(master_revisit) #about 86% of visits have primary dx
        #Conclusion: going to treat all diagnoses (primary or not) as equal. 
        
        # PART1: read in ccs dictionary
        icd9cm <- read_csv(icd9path, 
                           col_types = cols(`'CCS CATEGORY'` = col_number()), 
                           skip = 1)
        
        # clean diagnoses df by removing periods in icd9 code
        diagnoses$icd9 <- gsub("\\.", "", diagnoses$CURRENT_ICD9_LIST)
        
        # if there are more than 1 code value in the cell, take the first one
        # and left justify so that there are 5 characters exactly for each element
        # (this is the format of icd9 codes in the dictionary)
        
        y <- gsub("\\,.*","", diagnoses$icd9)
        y[!is.na(y)] <- ifelse(nchar(y[!is.na(y)]) > 5, 
                               NA, 
                               paste0(y[!is.na(y)], sapply(nchar(y[!is.na(y)]), 
                                                           function(x) paste(rep(' ', abs(5 - x)), collapse = ""))))
        
        
        diagnoses$icd9 <- y
        
        # PART2: CLEAN icd9 -> ccs dictionary
        # clean the ccs dictionary by subsetting the icd9 and the ccs label
        # then removing the quotes from the icd9 and punctuations from the labels
        ccs <- icd9cm[,c(1,3)]
        names(ccs) <- c('icd9', 'ccs')
        ccs$icd9 <- gsub("\\'", "", ccs$icd9)
        ccs$ccs <- tolower(gsub("[[:punct:]]| ", "", ccs$ccs))
        # remove nodx row
        ccs <- ccs[-1,]
        
        # 3) MERGE: left_join appropriate CCS category
        diagnoses <- left_join(diagnoses, ccs, by = 'icd9')
        
        diagnoses_vertical <- select(diagnoses, PAT_ENC_CSN_ID, ccs)
        diagnoses_vertical$ccs <- paste0('dx_', diagnoses_vertical$ccs)
        # note here that ccs category of 650+ = psych conditions, 2600+ = accidents/unspecified
        
        # 4) cast the dataframe such that we have a df where each row is an encounter 
        # and each column a CCS category. Value will take 1 or 0 depending on presence/absence
        diagnoses_binary <- dcast(diagnoses_vertical, PAT_ENC_CSN_ID ~ ccs, fun.aggregate = function(x) {
                as.numeric(length(x) > 0 )
        })
        #ignore NA valued ccs
        diagnoses_binary$'NA' <- NULL
        
        diagnoses_binary
        
        
}


