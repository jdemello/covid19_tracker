# update plots
source("figures/plot_all.R")
rm(list=ls()) # remove all objects

# render all .Rmd scripts
rmdFiles <- dir("docs/", pattern = "\\.Rmd$", full.names = TRUE)

# render all
for(rmdFile in rmdFiles) rmarkdown::render(rmdFile)

rm(rmdFile, rmdFiles)