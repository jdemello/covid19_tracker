# select rows for countries
d2 <- data[country %in% cntrys, ][
  order(country, date)
  ][
    ,mort := data.table::fifelse(is.nan(mort) | is.na(mort), 0, mort, NA_real_)
    ]

# get the day-over-day variation
d2[, daily_death := death_count - data.table::shift(death_count), by = c("country")] # get daily deaths


# lead daily deaths and check the day over day variation
d2[, death_delta := daily_death / data.table::shift(death_count)]

# only after the 100th death
d2 <- d2[death_count >= 100L, ]

# count the days since 100th death
d2 <- d2[
  , days := as.integer(date - min(date)), by = "country"
  ][
    order(country, days)
    ]

# plot params parameters
# last updated object
maxDate <- format(d2[, max(date)], "%B %d, %Y")

# build plot
p <- ggplot(data=d2, aes(x=date, y=death_delta, group=country, colour=country)) + 
  geom_line(size=1) +
  geom_point(size=1, show.legend = FALSE) + 
  ggsci::scale_colour_d3(palette = c("category20c")) + 
  scale_y_continuous(labels = function(x) {
    x <- paste0(round(x * 100, 2), "%")
    x <- gsub(x=x, pattern="\\.00\\%$", replacement = "")
    return(x)
  },
  breaks = seq(0, d2[, max(death_delta, na.rm=TRUE)] + d2[, max(death_delta, na.rm=TRUE)]/10, 
               length.out = 5)) +
  labs(x="Days since 100th death confirmed", 
       y="Day-over-day change rates", 
       title="Daily Fatality Rate from COVID-19",
       caption = "Source: CSSE COVID-19 Dataset") + 
  theme_minimal() + 
  theme(legend.title = element_blank())

# plotly transformation ----
fig <- plotly::ggplotly(p)

# add title and subtit
fig <- plotly::layout(fig, title = list(text = paste0("Daily Fatality Rate from COVID-19",
                                                      '<br>',
                                                      '<sup>',
                                                      "Last updated: ", maxDate,
                                                      '</sup>')))
# change country lines and hover box
# find the indices in plotly construct
inds <- which(unlist(lapply(fig$x$data, function(x){
  x$name
})) != "")

# change some attributes of the hover line
for(ind in inds){
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="\\s{2, }", " ")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="<br \\/>[Country: A-z\\s]+$", "")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="^date", "Date")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="death_delta", "Day-over-day rate")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="country:", "Country:")
  fig$x$data[[ind]]$line$width <- 2
}
rm(ind)

rm(list=ls()[!grepl(x=ls(), pattern="^fig$")])
saveRDS(fig, "figures/death_rate.RDS")
