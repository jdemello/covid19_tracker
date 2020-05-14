if(length(grep("(?i)Git//bin", Sys.getenv("PATH"))) == 0) 
  Sys.setenv(PATH=paste0(Sys.getenv("PATH"),";C://Program Files//Git//bin"))

# update plots
source("figures/plot_all.R")
rm(list=ls()) # remove all objects

source("tables/mortality_table.R")

# render all .Rmd scripts
rmdFiles <- dir("docs/", pattern = "\\.Rmd$", full.names = TRUE)

# render all
for(rmdFile in rmdFiles) rmarkdown::render(rmdFile)

rm(rmdFile, rmdFiles)

# shell("bash --login -i -c \"./lazygit.sh\"")
