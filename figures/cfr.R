# Mortality rate after the 10th death

# first database for plot
d1 <- data[country %in% cntrys, ][
  death_count > 9, 
  ][
    , days := as.integer(date - min(date)), by = "country"
    ][
      order(country, days)
      ]

# plot build ggplot plot
p <- ggplot(data=d1, aes(x=date, y=mort, group=country, colour=country)) + 
  geom_line(size=1) +
  geom_point(size=1, show.legend = FALSE) + 
  ggsci::scale_colour_d3(palette = c("category20c")) + 
  scale_y_continuous(labels = function(x) scales::percent(round(x * 100)/100),
                     breaks = function(x) seq(0, max(x), length.out = 5)) +
  scale_x_date(breaks = seq(d1[, min(date)], d1[, max(date)], length.out = 8),
               labels = function(x) format(x, "%m-%d")) + 
  labs(x="CFR since 10th confirmed death", 
       y=NULL, 
       title="Case Fatality Rate (CFR) from COVID-19",
       caption = "Source: CSSE COVID-19 Dataset") + 
  theme_minimal() + 
  theme(legend.title = element_blank())

fig <- plotly::ggplotly(p)

# add title and subtit
fig <- plotly::layout(fig, title = list(text = paste0("Case Fatality Rate (CFR) from COVID-19",
                                                      '<br>',
                                                      '<sup>',
                                                      "Last updated: ", maxDate,
                                                      '</sup>')))


# change country lines
# find the indices in plotly construct
inds <- which(unlist(lapply(fig$x$data, function(x){
  x$name
})) != "")

for(ind in inds){
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="\\s{2, }", " ")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="<br \\/>[Country: A-z\\s]+$", "")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="^days", "Days")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="mort", "CFR")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="country:", "Country:")
  fig$x$data[[ind]]$text <- .convToPct(x = fig$x$data[[ind]]$text)
  fig$x$data[[ind]]$line$width <- 2
}
rm(ind)


saveRDS(fig, "figures/cfr.RDS")

# remove all objects except data
rm(list=ls()[!grepl(x=ls(), pattern="^(data|maxDate|cntrys)$")])