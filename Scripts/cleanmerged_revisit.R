## Cleans variables in the merged df (ED return project)

cleanmerged_revisit <- function(df) {
        names(df) <- tolower(names(df))
        names(df) <- gsub(' ','', names(df))
        
        #age - remove outliers
        summary(df$age)
        df$age[df$age > 110] <- NA
        #take most recent esi
        df$esi <- factor(ifelse(is.na(df$second_esi), df$esi, df$second_esi))
        # remove second_esi
        df$second_esi <- NULL
        
        #remove dispo (given that all visits are discharges)
        df$disposition <- NULL
        
        #filter to ensure 1 year lookback (9 day look forward period has already been cropped), age limit >=18
        df <- filter(df, as.Date(df$arrivaltime) >= as.Date('2014-03-01')) %>%
                filter(age >= 18 | is.na(age))
        
        df$esi <- factor(df$esi)
        
        #remove MRN
        df$pat_mrn_id <- NULL
        
        #remove PAT_ENC_CSN_ID
        df$pat_enc_csn_id <- NULL
        #dep_name
        summary(df$dep_name)
        
        #remove transfer_dep_name
        df$transfer_dep_name <- NULL
        
        #gender - Binary (Male, Female)
        df$gender <- factor(as.character(df$gender))
        
        #ethnicity - Binary (Hispanic or Latino, Non-Hispanic)
        summary(df$ethnicity)
        
        #race - Categorical (White or Caucasian, Black or African American, Asian, Other)
        summary(df$race)
        df$race[df$race == ''] <- NA
        df$race <- factor(df$race)
        summary(df$race)
        
        #language - Binary (English, Other)
        summary(df$lang)
        df$lang[df$lang != 'English'] <- 'Other'
        df$lang <- factor(df$lang)
        summary(df$lang)
        
        #religion - Categorical (top 12, force others into other)
        sort(summary(df$religion))
        topreligion <- tail(names(sort(summary(df$religion))), 12)
        df$religion[!df$religion %in% topreligion] <- 'Other'
        
        df$religion <- factor(df$religion)
        summary(df$religion)
        
        #maritalstatus - Categorical
        summary(df$maritalstatus)
        
        #employstatus - Categorical (Disabled, Full Time, Part Time, Not Employed, Student)
        summary(df$employstatus)
        
        #insurance_status - Categorical
        summary(df$insurance_status)
        
        #arrivalmode (formerly NAME) - Categorical
        df <- dplyr::rename(df, arrivalmode = name)
        levels(df$arrivalmode)
        sort(summary(df$arrivalmode))
        # bin all emergency transport
        emergency <- grep('EMS|Fire|Ambulance|AMR|VAC|Hospital|Critical|Sky|Flight',levels(df$arrivalmode), value = T)
        x <- as.character(df$arrivalmode)
        x[x %in% emergency] <- 'ambulance'
        x[x == ''] <- NA
        x[x %in% c('Assist From Vehicle')] <- 'Wheelchair'
        x[x %in% c('Taxi')] <- 'Car'
        
        x <- factor(x)
        levels(x)
        summary(x)
        df$arrivalmode <- x
        summary(df$arrivalmode)
        
        #arrivaltime 
        
        df$arrivaltime <- NULL
        df$roomtime <- NULL
        df$arrivalhour <- NULL
        
        df$arrivalday <- factor(df$arrivalday)
        df$arrivalmonth <- factor(df$arrivalmonth)
        
        #previousdispo - replace NAs w/ "No previous dispo"
        df$previousdispo[is.na(df$previousdispo)] <- 'No previous dispo'
        df$previousdispo <- factor(df$previousdispo)
        
        ############## PMH variables
        # we are going to replace NAs with 0 (no disease)
        start <- which(names(df) == '2ndarymalig')
        end <- which(names(df) == 'whtblooddx')
        pmh <- select(df,start: end)
        pmh[is.na(pmh)] <- 0
        df[,start:end] <- pmh
        
        #n_edvisits
        summary(df$n_edvisits)
        
        ############## Categorical labs
        # we are going to replace NAs with 0 (no lab ordered)
        start <- which(names(df) == 'bloodua_last')
        end <- which(names(df) == 'urineculture,routine_count')
        catlabs <- select(df,start: end)
        catlabs[is.na(catlabs)] <- 0
        df[,start:end] <- catlabs
        
        ####### Medication
        # we are going to replace NAs with 0
        start <- which(names(df) == 'meds_analgesicandantihistaminecombination')
        end <- which(names(df) == 'meds_vitamins')
        meds <- select(df,start: end)
        meds[is.na(meds)] <- 0
        df[,start:end] <- meds
        
        ######PSH
        df$n_surgeries[is.na(df$n_surgeries)] <- 0
        
        ######Clean up diphtheria edmeds (this order was duplicated)
        diphth_vars <- grep('diphth',names(df),ignore.case = T)
        df[,diphth_vars[1]] <- rowSums(df[,diphth_vars])
        df[,diphth_vars[2:4]] <- NULL
        df
}
