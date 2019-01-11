# Get response vector from master dataframe where:
# revisit beyond 9 days/no return = 0
# revisit within 3 days = 1
# revisit between 3 to 9 days = 2

library(dplyr)

makerevisitdf <- function(df, master) {
        df <- select(df, PAT_MRN_ID, PAT_ENC_CSN_ID, arrivaltime, disposition)
        #order it
        df <- df[order(df$PAT_MRN_ID, df$PAT_ENC_CSN_ID, df$arrivaltime),]
        #create empty column
        df$revisit <- NA
        
        #get response variable for each visit
        df2 <- df %>% group_by(PAT_MRN_ID) %>% do(get_responsevector(.))
        df2 <- ungroup(df2)
        responsevector <- select(df2, PAT_ENC_CSN_ID, revisit)
        
        #join the response variable to our original dataframe
        master_revisit <- left_join(master, responsevector)
        master_revisit$revisit <- factor(master_revisit$revisit, levels = c("noacuterevisit", "within3days", "btw3and9days"))
        
        #crop study end period to ensure 9 day followup for all visits
        enddate <- max(master_revisit$arrivaltime) - 9 * 24 * 60 * 60
        master_revisit <- filter(master_revisit, arrivaltime < enddate)
        
        #exclude visits that did not end in discharge
        master_revisit <- master_revisit %>% filter(!is.na(revisit))
        
        master_revisit
        
}

get_responsevector <- function(df) {
        #no revisit by definition for patients with only 1 visit within study period
        #will crop study period to end 9 days before 7/1 to ensure 9 day look-forward period for all visits
        if (nrow(df) == 1) {
                if (!is.na(df$disposition) & df$disposition == 'Discharge') {
                        df$revisit <- 'noacuterevisit'
                }
        }
        #for those with more than 1 visits, for each visit that ended in discharge,
        #calculate number of days to the next visit, then assign values based on cutoffs.
        if (nrow(df) > 1) {
                for (i in 1:(nrow(df) - 1)) {
                        if (!is.na(df$disposition[i]) & df$disposition[i] == 'Discharge') {
                                day_from_previous <- as.numeric(difftime(df$arrivaltime[i+1],df$arrivaltime[i],
                                                                         units = 'days'))
                                if (day_from_previous <= 3) {
                                        df$revisit[i] <- 'within3days'
                                } else if (day_from_previous <= 9) {
                                        df$revisit[i] <- 'btw3and9days'
                                } else {
                                        df$revisit[i] <- 'noacuterevisit'
                                }
                        }
                } 
                if (!is.na(df$disposition[nrow(df)]) & df$disposition[nrow(df)] == 'Discharge') {
                        df$revisit[nrow(df)] <- 'noacuterevisit'
                }
                
        }
        
        df
}
