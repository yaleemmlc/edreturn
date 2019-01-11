# PCP info: Flag for whether the patient in the encounter has a primary care provider listed in the EHR

cleanpcp <- function(pcppath) {
        pcp <- read_csv(pcppath)
        pcp$pcp_yn <- ifelse(pcp$pcp_yn == 'Y', 1, 0)
        
        pcp <- pcp %>% rename(pcp_yes = pcp_yn)
        
        pcp <- distinct(pcp, PAT_ENC_CSN_ID, .keep_all = T)
        
        pcp
}



