#5) Procedures/imaging orders

cleanprocedures <- function(procedurespath, master_revisit) {
        procedures <- read_csv(procedurespath)
        procedures <- filter(procedures, PAT_ENC_CSN_ID %in% master_revisit$PAT_ENC_CSN_ID)
        
        orders <- procedures$DESCRIPTION
        #recategorize into 8 categories, then bin the rest into 'otherimg'
        orders[grep('^ct head', orders, ignore.case = T)] <- 'headct'
        orders[grep('^cta|^ct', orders, ignore.case = T)] <- 'otherct'
        orders[grep('ekg', orders, ignore.case = T)] <- 'ekg'
        orders[grep('^xr chest|^cxr' , orders, ignore.case = T)] <- 'cxr'
        orders[grep('^xr|2V|3V|4V|view', orders, ignore.case = T)] <- 'otherxr'
        orders[grep('echo', orders, ignore.case = T)] <- 'echo'
        orders[grep('^us|ultrasound', orders, ignore.case = T)] <- 'otherus'
        orders[grep('^mri', orders, ignore.case = T)] <- 'mri'

        sum(head(summary(factor(orders)), 40))/nrow(procedures) #91.6% of all orders 
        
        #keep the top 40 orders
        toporders <- tail(names(sort(table(orders))), 40)
        
        #bin all other orders into 'otherorder'
        orders[!orders %in% toporders] <- 'otherorder'
        
        #ignore case, remove whitespace, add 'orders_' tag to all values
        orders <- gsub(' ', '', tolower(orders))
        orders <- paste0('orders_', orders)
        summary(factor(orders))
        procedures$DESCRIPTION <- orders
        procedures <- select(procedures, PAT_ENC_CSN_ID, DESCRIPTION)
        
        #cast into wide format, 1/0 for presence/absence of procedure (more natural since many orders are repeats)
        procedures_binary <- dcast(procedures, PAT_ENC_CSN_ID ~ DESCRIPTION, fun.aggregate = function(x) {
                as.numeric(length(x) > 0 )
        })
        procedures_binary
}

