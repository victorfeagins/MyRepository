
#Shows a correlation plot for all data
corrplot<- function(numericdata){
  cormat <- round(cor(numericdata),2)
  melted_cormat <- reshape2::melt(cormat)
  graph<- ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
    geom_tile(color = "white")+
    scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                         midpoint = 0, limit = c(-1,1), space = "Lab", 
                         name="Pearson\nCorrelation")+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  graph
} 

#Shows a density plot for all data univariate
histogramplot <- function (numericdata){ 
  graph <- numericdata %>%
    gather() %>%                             
    ggplot(aes(value)) +                     
    facet_wrap(~ key, scales = "free") +  
    geom_density()
  graph
}