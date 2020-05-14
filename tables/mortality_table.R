# install pkgs if needed
pkgs <- c("data.table", "DT", "scales")

for(pkg in pkgs){if(!nzchar(system.file(package = pkg))) install.packages(pkg, repos="http://cran.utstat.utoronto.ca/")}

# load pkgs
pkgs <- c("data.table")
for(pkg in pkgs){if(sum(.packages() %in% pkg) == 0L) library(pkg, character.only = TRUE)}

# load data
data <- readRDS("data/data_extraction.RDS")

# get max date
out <- data[date == max(date, na.rm=TRUE)]

# reorg cols
out <- out[, .(country, date, pop, conf_count, death_count, conf_pm, mort_pm)]

# order data by confirmed cases
out <- out[order(-conf_count),]

# round per mil cols
cols <- grep(x=names(out), pattern="pm$", value=TRUE)
out[, (cols) := lapply(.SD, round, 2L), .SDcols=cols] 


# JS code, get subtotals
jsCallback <- readChar("tables/mortality_table_totals.js", 1e5)

out <- DT::datatable(out,caption = shiny::tags$caption("COVID-19 Mortality Data",
                                       style = "text-align: left;"),
              filter = "none",
              colnames = c("Country", "Date", "Population", "Confirmed\nCases",
                           "Total\nDeaths", "Confirmed\nCases (per million)",
                           "Total\nDeaths (per million)"),
                rownames = F,
                options = list(autoWidth = T, 
                               pageLength = 10, 
                               scrollCollapse = T,
                               dom = 'ltp', 
                               footerCallback = DT::JS(jsCallback),
                               columnDefs = list(list(
                                 className = "dt-center", targets = 1:6
                               ),
                               list(
                                 className = "dt-left", targets = 0
                               )))
  )

out <- DT::formatCurrency(out, 3:5, "", mark = " ", digits = 0)

saveRDS(out, "tables/mortality_table.RDS")
rm(list=ls())
