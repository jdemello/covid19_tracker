# data extraction script
  # pull data from sources and manipulate
    # output: tape with data

# load libs if necessary ----
pkgs <- c("data.table")
for(pkg in pkgs){if(sum(.packages() %in% pkg) == 0) library(pkg, character.only = TRUE)}
rm(pkg, pkgs)

# time series: confirmed cases ----
url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
confirmed <- data.table::fread(url, drop = c("Lat", "Long"))

# melt 
cols <- grep(x=names(confirmed), pattern = "^\\d", value=TRUE)
confirmed <- data.table::melt(confirmed, measure.vars=cols, 
                          variable.name="date",
                          value.factor=FALSE, variable.factor=FALSE)

# # cummulative confirmed cases by country
# aggregate confirmed count by day by country, some countries have province breakdown
confirmed <- confirmed[, .(value = sum(value, na.rm=TRUE)), by = c("Country/Region", "date")]

# time series: deaths ----
url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
deaths <- data.table::fread(url, drop = c("Lat", "Long"))

# melt 
cols <- grep(x=names(deaths), pattern = "^\\d", value=TRUE)
deaths <- data.table::melt(deaths, measure.vars=cols, 
                          variable.name="date",
                          value.factor=FALSE, variable.factor=FALSE)

# cummulative death cases by country
# aggregate death count by day by country, some countries have province breakdown
deaths <- deaths[, .(value = sum(value, na.rm=TRUE)), by = c("Country/Region", "date")]

# time series: recovered ----
  #### DEPRECATED ###
# url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"
# recv <- data.table::fread(url, drop = c("Lat", "Long"))
# 
# # melt 
# cols <- grep(x=names(recv), pattern = "^\\d", value=TRUE)
# recv <- data.table::melt(recv, measure.vars=cols, 
#                          variable.name="date",
#                          value.factor=FALSE, variable.factor=FALSE)

# cummulative recovered cases by country
# aggregate recovered count by day by country, some countries have province breakdown
# recv <- recv[, .(value = sum(value, na.rm=TRUE)), by = c("Country/Region", "date")]

# join
cols <- c("Country/Region", "date") # join keys
data <- confirmed[deaths, on = cols, nomatch=NA]

# rename cols
newCols <- c("country", "conf_count", "death_count")
data.table::setnames(data, c("Country/Region", 
                             grep(x=names(data), pattern="value", value=TRUE)),
                     newCols)

# do mortality rate (death/confirmed)
data[, mort := death_count/conf_count]


# get population by country ----
  # need these pkgs --> install them if necessary
pkgs <- c("xml2", "rvest", "lubridate")
for(pkg in pkgs){
  if(!nzchar(system.file(package = pkg))) install.packages(pkg, repos="http://cran.utstat.utoronto.ca/") # if not in sys -> install
}
rm(pkg,pkgs)

# read html page
page <- xml2::read_html("page_content/worldmeters.html")

# find table node
page <- rvest::html_nodes(page, "tbody")

# transform xml_node obj into text
dPop <- trimws(rvest::html_text(rvest::html_nodes(page, "td[style*='font-weight: bold']")))

# make vector into data.table
dPop <- data.table::as.data.table(matrix(dPop, ncol=2, byrow = TRUE))
names(dPop) <- c("country", "pop")  # rename cols
dPop[, pop := as.integer(gsub(x=pop, pattern= "\\,", ""))] # remove coma, into integer

# match countries whose names are different in each table
cntryLab <- c("US" = "United States", "Korea, South" = "South Korea", 
  "Czechia" = "Czech Republic (Czechia)", 
  "Taiwan*" = "Taiwan",
  "Cote d'Ivoire" = "Côte d'Ivoire", 
  "Saint Vincent and the Grenadines" = "St. Vincent & Grenadines",
  "Gambia, The" = "Gambia",
  "Bahamas, The" = "Bahamas", 
  "Cape Verde" = "Cabo Verde",
  "East Timor" = "Timor-Lest")
cntrNew <- names(cntryLab)

for(cntry in seq_along(cntryLab)){
  dPop[country == cntryLab[[cntry]], country := cntrNew[[cntry]]]
}

# merge data
data <- data[dPop, on = "country", nomatch = NA]

# calculate death count (per million)
data[, mort_pm := (death_count/pop) * 1e6]

# number of cases per million
data[, conf_pm := (conf_count/pop) * 1e6]

# relabel some countries
cntryLab <- c("South Korea" = "Korea, South",
              "Taiwan" = "Taiwan*")
cntrNew <- names(cntryLab)

for(cntry in seq_along(cntryLab)){
  data[country == cntryLab[[cntry]], country := cntrNew[[cntry]]]
}

# transform date column into date class
data[, date := lubridate::mdy(date)]


# keep data col
rm(list=ls()[!grepl(x=ls(), pattern="^data")])

# save data
saveRDS(data, "data/data_extraction.RDS")