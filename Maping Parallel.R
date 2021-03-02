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

#Selecting one county
county <- TXgeocre %>% 
  filter(ctname == "Bexar County")

#Creating one map for County
pal <- brewer.pal(5, "YlOrBr")
tm_shape(county) +
  tm_fill(col = "predrt_3", style = "quantile",palette = pal, title = "% people with 3+ risk factors") +
  tm_borders(col = "Grey", lwd = 1) +
  tm_layout(main.title =str_c(county$ctname, " People with 3+ Risk Factors Rate"),
            legend.position = c("right","bottom")
            )
############### Creating Function for map above
TXCountyMap <- function (countyname){

#Selecting one county
county <- TXgeocre %>% 
  filter(ctname == countyname)

#Creating map for County
pal <- brewer.pal(5, "YlOrBr")
mapplot <- tm_shape(county) +
  tm_fill(col = "predrt_3", style = "quantile",palette = pal, title = "% people with 3+ risk factors") +
  tm_borders(col = "Grey", lwd = 1) +
  tm_layout(main.title =str_c(county$ctname, " People with 3+ Risk Factors Rate"),
            legend.position = c("right","bottom")
  )
mapplot #output mapplot 
}




############################# Plotting in Series
#Creating for loop for all the counties 
TXcounties <- unique(TXgeocre$ctname)

savemap <- function (name, folder){
  jpeg(filename = str_c(folder,"/",name,".jpeg"))
  print(TXCountyMap(name))
  dev.off()
}


ptm <- proc.time()

lapply(TXcounties, savemap, folder = "Plots")

series <- proc.time() - ptm
print(c("Series",series))

############################## Plotting in Parallel

library(parallel)
ptm <- proc.time()
cl <- makeCluster(8)

clusterExport(cl,c("TXCountyMap",'TXgeocre')) #Exporting data and function TXCountyMap
clusterEvalQ(cl, {
  #Libraries
  library(tidyverse)
  library(tmap)
  library(tigris)
  library(sf)
  library(RColorBrewer)})



parLapply(cl,TXcounties, savemap, folder = "PlotsPar")


parallel <- proc.time() - ptm
print(c("Parallel",parallel))
stopCluster(cl)

print(c("Saved",series - parallel)) # Saves time on my pc 26 seconds
