# Top 20 variables for 9day return

top20_df <- function(df) {
        x <- select(df, n_edvisits, n_admissions, cxr_count, ekg_count, alcoholrelateddisorders,
                    headct_count, temp_min, proteinua_count, otherxr_count, socialadmin,
                    sbp_min, glucoseua_count, schizophreniaandotherpsychoticdisorde, pulse_max, dx_alcoholrelateddisorders,
                    resp_min, ketonesua_count, nitriteua_count, dbp_max, bloodua_count,
                    revisit)
        
        x
}
