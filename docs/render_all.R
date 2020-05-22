if(!nzchar(Sys.getenv("RSTUDIO_PANDOC"))){
  cat("Pre-setting 'RSTUDIO_PANDOC' environmental variable to this R-session...\n\n")
  Sys.setenv("RSTUDIO_PANDOC" = "C:/Program Files/RStudio/bin/pandoc")
  msg<- paste0("Environmental variable for Pandoc set at: ", Sys.getenv("RSTUDIO_PANDOC"), ".\n\n")
  cat(msg)
}

if(length(grep("(?i)Git//bin", Sys.getenv("PATH"))) == 0) 
  Sys.setenv(PATH=paste0(Sys.getenv("PATH"),";C://Program Files//Git//bin"))

# install.packages
pkgs <- c("shiny", "rmarkdown")
for(pkg in pkgs){
  if(!nzchar(system.file(package = pkg))) install.packages(pkg, repos="http://cran.utstat.utoronto.ca/") # if not in sys -> install
}
rm(pkg,pkgs)

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
