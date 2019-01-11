#Pipeline to create master dataframe for ED revisit project
setwd('~/ED_Return/')

library(dplyr)
library(readr)
library(reshape2)
library(stringr)

# load master dataframe from admission prediction project
load('./Results/master.RData')

#1) create df with a response vector 'revisit' with levels: "noacuterevisit", "within3days", "btw3and9days"
source('./Scripts/1_makerevisitdf.R')
master_revisit <- makerevisitdf(master, master)
#load('./Results/master_revisit.RData')

print(paste(Sys.time(), 'Response variable processing complete'))

#2) Process diagnoses given during current visit
source('./Scripts/2_currentdiagnoses.R')
diagnosespath <- './Data/diagnoses.csv'
icd9path <- './Web_data/$dxref 2015_2.csv'
master_revisit <- left_join(master_revisit, currentdiagnoses(diagnosespath, icd9path, master_revisit))

print(paste(Sys.time(), 'ED diagnoses processing complete'))

#3) Process meds given during current visit
source('./Scripts/3_edmeds.R')
edmedspath <- './Data/ed_meds.csv'
master_revisit <- left_join(master_revisit, cleanedmeds(edmedspath, master_revisit))

print(paste(Sys.time(), 'ED meds processing complete'))

#4) Process labs drawn during current visit
source('./Scripts/4_cleanlabs.R') #same script as 6_cleanlabs.R from admission project
labspath <- './Data/past_labs.csv'
master_revisit <- left_join(master_revisit, cleanlabs(labspath, master_revisit))

print(paste(Sys.time(), 'ED Labs processing complete'))

#5) Process procedures/imaging ordered during current visit
source('./Scripts/5_procedures.R')
procedurespath <- './Data/procedures_imaging.csv'
master_revisit <- left_join(master_revisit, cleanprocedures(procedurespath, master_revisit))

print(paste(Sys.time(), 'ED orders processing complete'))

#6) Process current ED vitals
source('./Scripts/6_edvitalsclean.R')
source('./Scripts/7_currentvitals.R')
vitalspath <- './Data/ed_vitals.csv'
master_revisit <- left_join(master_revisit, 
                            getedvitals(cleanvitals(vitalspath, master_revisit), master_revisit))

print(paste(Sys.time(), 'ED vitals processing complete'))

#7) Process PCP information
source('./Scripts/8_cleanpcp.R')
pcppath <- './Data/pcp.csv'
master_revisit <- left_join(master_revisit, cleanpcp(pcppath))

print(paste(Sys.time(), 'PCP processing complete'))


#save result for analysis
save(master_revisit, file = './Results/master_revisit_full.RData')
