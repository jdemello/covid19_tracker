# list of internal functions

# generate break values for y-axis
.genBreaks <- function(x){
  z <- max(x, na.rm=TRUE)
  if(z %% 2 == 0) return(2^seq(2, ceiling(log(z)/log(2))))
  return(2^seq(2, ceiling(log(z+1)/log(2))))
}

.genRateFrame <- function(x, dblEvery, maxY, slope){
  out <- data.table::data.table(
    x=x,
    y=(2^(x/dblEvery))*slope
  )[
    y <= maxY
  ]
  
  return(out)
}

# convert decimals into pct
.convToPct <- function(x, roundFct = 2L){
  # get percentages
  pcts <- paste0(round(as.numeric(regmatches(x, regexec(text=x, "0\\.\\d+")))* 100, roundFct), "%")
  
  # loop over values and substitute by pcts...
  out <- lapply(seq_along(pcts), function(i){
    gsub(pattern="0\\.\\d+", replacement = pcts[[i]], x=x[[i]])
  })
  
  return(unlist(out))
}

