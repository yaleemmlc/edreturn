# Variables included in administrative data (baseline model)

baseline_df <- function(df) {
        x <- select(df, age, gender, ethnicity, race, maritalstatus, lang, religion,
                    employstatus, insurance_status,
                    n_edvisits, n_admissions, n_surgeries, previousdispo, pcp_yes, revisit)
        
        start <- which(names(df) == '2ndarymalig')
        end <- which(names(df) == 'whtblooddx')
        pmh <- df[,start:end]
        
        bind_cols(x, pmh)
}
