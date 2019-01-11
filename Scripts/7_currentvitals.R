#7) Process current ED vitals
#extracts vitals taken after triage, outputs their mean, min and max values for each encounter.

getedvitals <- function(vitals, master_revisit) {
        # left_join to add a roomtime variable for each encounter
        # discard rows without a roomtime variable
        edvitals <- left_join(vitals, master_revisit[,c("PAT_ENC_CSN_ID", 'roomtime')], by = 'PAT_ENC_CSN_ID') %>%
                filter(!is.na(roomtime))
        
        # 5) filter dataframe by RECORDED_TIME <= roomtime for that PAT_ENC_CSN_ID
        edvitals <- filter(edvitals, RECORDED_TIME > roomtime)
        
        # 6) if more than one set of vitals were taken before pt was roomed,
        #   take their average value. 
        #  for o2_device, take the maximum factor level recorded
        # this will output 1 row / patient encounter id
        edvitals <- group_by(edvitals, PAT_ENC_CSN_ID) %>%
                summarize(ed_vital_hr_mean = mean(Pulse, na.rm = T),
                          ed_vital_sbp_mean = mean(sbp, na.rm = T),
                          ed_vital_dbp_mean = mean(dbp, na.rm = T),
                          ed_vital_rr_mean = mean(Resp, na.rm = T),
                          ed_vital_o2_mean = mean(SpO2, na.rm = T),
                          ed_vital_temp_mean = mean(Temp, na.rm = T),
                          ed_vital_hr_min = min(Pulse, na.rm = T),
                          ed_vital_sbp_min = min(sbp, na.rm = T),
                          ed_vital_dbp_min = min(dbp, na.rm = T),
                          ed_vital_rr_min = min(Resp, na.rm = T),
                          ed_vital_o2_min = min(SpO2, na.rm = T),
                          ed_vital_temp_min = min(Temp, na.rm = T),
                          ed_vital_hr_max = max(Pulse, na.rm = T),
                          ed_vital_sbp_max = max(sbp, na.rm = T),
                          ed_vital_dbp_max = max(dbp, na.rm = T),
                          ed_vital_rr_max = max(Resp, na.rm = T),
                          ed_vital_o2_max = max(SpO2, na.rm = T),
                          ed_vital_temp_max = max(Temp, na.rm = T),
                          ed_vital_o2_device_max = max(o2_device, na.rm = T))
        
        edvitals[,-1] <- lapply(edvitals[,-1], function(x) {
                replace(x, is.infinite(x) | is.nan(x),NA)
        })
        
        edvitals
}



