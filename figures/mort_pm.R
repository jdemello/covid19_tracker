# Deaths per million (after 1 person per million) ----
# select rows in which death per mil exceeds 1
d1 <- data[country %in% cntrys, ][
  mort_pm > 1, 
  ][
    , days := as.integer(date - min(date)), by = "country"
    ][
      order(country, days)
      ]
# create ancillary data for baseline c urves
args <- list(c("twoDays", "fiveDays", "sevenDays"),
             c(2,5,7))

# generate frames
for(it in seq_along(args[[1]])){
  assign(args[[1]][[it]], 
         .genRateFrame(x=d1[, unique(days)], dblEvery = args[[2]][[it]], 
                       maxY = d1[, max(mort_pm, na.rm=TRUE)], 
                       slope = 1))
}

# build plot
p <- ggplot(data=d1, aes(x=days, y=mort_pm, group=country, colour=country)) + 
  geom_line(data=twoDays, aes(x=x, y=y, group=NA, colour=NA),
            colour="grey60", linetype="dashed", size=0.5) +
  geom_line(data=fiveDays, aes(x=x, y=y, group=NA, colour=NA),
            colour="grey60", linetype="dashed", size=0.5) +
  geom_line(data=sevenDays, aes(x=x, y=y, group=NA, colour=NA),
            colour="grey60", linetype="dashed", size=0.5) +
  geom_line(size=1) +
  geom_point(size=1, show.legend = FALSE) + 
  ggsci::scale_colour_d3(palette = c("category20c")) + 
  scale_y_continuous(labels = round,
                     trans = "log",
                     breaks =  2^seq(0, ceiling(log(d1[, max(mort_pm)] +1)/log(2)))) +
  labs(x="Days since confirmed fatalities per million exceeded 1", 
       y="Cumulative fatalities per million", 
       title="Cumulative Reported Fatalities (per million) from COVID-19",
       caption = "Source: CSSE COVID-19 Dataset") + 
  theme_minimal() + 
  theme(legend.title = element_blank())


# plotly transformation ----
fig <- plotly::ggplotly(p)

# add title and subtit
fig <- plotly::layout(fig, title = list(text = paste0("Cumulative Reported Fatalities (per million) from COVID-19",
                                                      '<br>',
                                                      '<sup>',
                                                      "Last updated: ", maxDate,
                                                      '</sup>')))

# make changes to dashed lines
# find the indices in plotly construct
inds <- which(unlist(lapply(fig$x$data, function(x){
  x$name
})) == "")

# remove hover and thin dashed lines
for(ind in inds){
  fig$x$data[[ind]]$hoverinfo <- "skip"
  fig$x$data[[ind]]$line$width <- 1
}
rm(ind)


# change country lines and hover box
# find the indices in plotly construct
inds <- which(unlist(lapply(fig$x$data, function(x){
  x$name
})) != "")

# change some attributes of the hover line
for(ind in inds){
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="\\s{2, }", " ")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="<br \\/>[Country: A-z\\s]+$", "")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="^days", "Days")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="mort_pm", "Fatalities (per million)")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="country:", "Country:")
  fig$x$data[[ind]]$line$width <- 2
}
rm(ind)

# add annotation and customize baselines
fig <- plotly::add_annotations(fig, 
                               text=c("doubles every\n2 days",
                                      "doubles every\n5 days",
                                      "doubles every\nweek"),
                               x=c(twoDays[, max(x)], fiveDays[, max(x)], sevenDays[, max(x)]),
                               y=c(log(twoDays[, max(y)]), log(fiveDays[, max(y)]), log(sevenDays[, max(y)])),
                               xref="x",
                               yref="y",
                               font=list(size=9,color="rgba(153,153,153,1)"),
                               showarrow=FALSE,
                               align="center",
                               hovertext=NULL,
                               xshift=rep(10, 3)
)

saveRDS(fig, "figures/mort_pm.RDS")

# remove all objects excep data
rm(list=ls()[!grepl(x=ls(), pattern="^(data|maxDate|cntrys)$")])