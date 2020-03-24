# Cumulative reported deaths (after 10th confirmed death)
# first database for plot
d1 <- data[country %in% cntrys, ][
  death_count > 9, 
  ][
    , days := as.integer(date - min(date)), by = "country"
    ][
      order(country, days)
      ]


# create reference curves
args <- list(c("twoDays", "fiveDays", "sevenDays"),
             c(2,5,7))

# generate frames
for(it in seq_along(args[[1]])){
  assign(args[[1]][[it]], 
         .genRateFrame(x=d1[, unique(days)], dblEvery = args[[2]][[it]], 
                       maxY = d1[, max(death_count, na.rm=TRUE)], 
                       slope = 10))
}

# plot build ggplot plot
p <- ggplot(data=d1, aes(x=days, y=death_count, group=country, colour=country)) + 
  geom_line(data=twoDays, aes(x=x, y=y, group=NA, colour=NA),
            colour="grey60", linetype="dashed", size=0.75) +
  geom_line(data=sevenDays, aes(x=x, y=y, group=NA, colour=NA),
            colour="grey60", linetype="dashed", size=0.75) +
  geom_line(size=1) +
  geom_point(size=1, show.legend = FALSE) + 
  ggsci::scale_colour_d3(palette = c("category20c")) + 
  scale_y_continuous(labels = round,
                     trans = "log",
                     breaks =  .genBreaks) +
  labs(x="Days since 10th confirmed death", 
       y="Cumulative fatalities (log scale)", 
       title="Cumulative Reported Fatalities from COVID-19",
       caption = "Source: CSSE COVID-19 Dataset") + 
  theme_minimal() + 
  theme(legend.title = element_blank())

fig <- plotly::ggplotly(p)

# add title and subtit
fig <- plotly::layout(fig, title = list(text = paste0("Cumulative Reported Fatalities from COVID-19",
                                                      '<br>',
                                                      '<sup>',
                                                      "Last updated: ", maxDate,
                                                      '</sup>')))


# make changes to dashed lines
for(ind in 1:2){
  fig$x$data[[ind]]$hoverinfo <- "skip"
  fig$x$data[[ind]]$line$width <- 1
}
rm(ind)

# change country lines
# find the indices in plotly construct
inds <- which(unlist(lapply(fig$x$data, function(x){
  x$name
})) != "")

for(ind in inds){
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="\\s{2, }", " ")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="<br \\/>[Country: A-z\\s]+$", "")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="^days", "Days")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="death_count", "Total deaths")
  fig$x$data[[ind]]$text <- gsub(x=fig$x$data[[ind]]$text, pattern="country:", "Country:")
  fig$x$data[[ind]]$line$width <- 2
}
rm(ind)

fig <- plotly::add_annotations(fig, 
                               text=c("doubles every\n2 days", 
                                      "doubles every\nweek"),
                               x=c(twoDays[, max(x)], sevenDays[, max(x)]),
                               y=c(log(twoDays[, max(y)]),log(sevenDays[, max(y)])),
                               xref="x",
                               yref="y",
                               font=list(size=9,color="rgba(153,153,153,1)"),
                               showarrow=FALSE,
                               align="center",
                               hovertext=NULL,
                               textangle=c(-atan2(log(20), 2) * (180/pi), -atan2(log(20), 7) * (180/pi)),
                               ay=1
)

saveRDS(fig, "figures/deaths_acc.RDS")
rm(list=ls()[!grepl(x=ls(), pattern="^(data|maxDate|cntrys)$")])
