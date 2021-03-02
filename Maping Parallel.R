#Libraries
library(tidyverse)
library(tmap)
library(tigris)
library(sf)
library(RColorBrewer)

#Reading in Community Resilience Estimates
cre <- read_csv("Data/cre-2018-a11.csv")


#Filtering for Texas
cretexas <- cre %>% 
  filter(stname == "Texas")

#Getting Geographies
TXtracts <- tracts("TX")

#Merging Geographies with cre data
TXgeocre <- left_join(TXtracts, cretexas, by = c("GEOID" = "geoid")) %>% 
  select("GEOID","county","stname":"predrt_3_moe")

unique(TXgeocre$ctname)

#Selecting one county

county <- TXgeocre %>% 
  filter(ctname == "Bexar County")


#Creating one map for County
pal <- brewer.pal(5, "YlOrBr")
tm_shape(bexar) +
  tm_fill(col = "predrt_3", style = "quantile",palette = pal, title = "% people with 3+ risk factors") +
  tm_borders(col = "Grey", lwd = 1) +
  #tm_shape(bexarcounty) +
  #tm_borders(col = "Black", lwd = 3) +
  tm_layout(main.title =str_c(bexar$ctname, " People with 3+ Risk Factors Rate"),
            legend.position = c("right","bottom")
            )


