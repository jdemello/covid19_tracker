## plot all figures in one single script, call the other scrips

  # load libraries
pkgs <- c("data.table", "plotly", "ggplot2")
for(pkg in pkgs){
  if(!nzchar(system.file(package = pkg))) install.packages(pkg, repos = "http://cran.utstat.utoronto.ca/"); library(pkg, character.only = TRUE)
}
rm(pkg, pkgs)

  # need these pkgs --> install them if necessary
pkgs <- c("ggsci", "lubridate", "scales")
for(pkg in pkgs){
  if(!nzchar(system.file(package = pkg))) install.packages(pkg, repos="http://cran.utstat.utoronto.ca/") # if not in sys -> install
}
rm(pkg,pkgs)

# load data
source("data/data_extraction.R")

# load helpers
source("R/zzz.R")

# parameters 
  # object with list of countries
cntrys <- c("Australia", "Brazil", "Belgium", "Canada", "Chile", "Colombia", "France", "Germany", "India", 
            "Italy", "Japan", "Netherlands", "South Korea", "Spain", "Sweden", "Portugal", "United Kingdom", "US")
  # date
maxDate <- format(data[, max(date,na.rm=TRUE)], "%B %d, %Y")

# run all scripts
scripts <- dir("figures/", pattern = "R$", full.names = TRUE)
scripts <- grep(x=scripts, pattern="figures/(?!plot)", value=TRUE, perl = TRUE)

for(script in scripts){
  cat(paste0("Running: ", script, "...\n\n"))
  source(script)
}
