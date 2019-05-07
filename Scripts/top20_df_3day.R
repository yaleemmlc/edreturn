# Top 20 variables for 72 hour return

top20_df_3day <- function(df) {
        x <- select(df, n_edvisits, alcoholrelateddisorders, n_admissions, ekg_count, headct_count,
                    socialadmin, cxr_count, temp_min, pulse_max, sbp_min, 
                    sodium_max, dx_alcoholrelateddisorders, schizophreniaandotherpsychoticdisorde, otherxr_count, glucoseua_count,
                    spo2_min, resp_min, ed_vital_temp_mean, substancerelateddisorders, gender,
                    revisit)
        x
}
