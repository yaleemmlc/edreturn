#3. Process ED Meds
library(stringr)
cleanedmeds <- function(edmedspath, master_revisit) {
        edmeds <- read_csv(edmedspath) %>% filter(PAT_ENC_CSN_ID %in% master_revisit$PAT_ENC_CSN_ID)

        #take first word of each string (thus ignoring dosage and route of admin)
        edmeds$firstname <- tolower(word(edmeds$DESCRIPTION,1))
        
        #sum(tail(sort(table(firstname)), 100))/nrow(edmeds) #top 100 account for 93%
        
        topmeds <- tail(names(sort(table(edmeds$firstname))), 100)
        
        #bin all other orders into 'otherorder'
        edmeds$firstname[!edmeds$firstname %in% topmeds] <- 'othermeds'
        
        edmeds$firstname <- paste0('edmeds_',edmeds$firstname)
        summary(factor(edmeds$firstname))
        
        edmeds <- select(edmeds, PAT_ENC_CSN_ID, firstname)
        
        edmeds_wide <- dcast(edmeds, PAT_ENC_CSN_ID ~ firstname)
        
        edmeds_wide
        
}
