MatrizConfusion <- function(resultado,datatest)
{
  matriz<- confusionMatrix(data=as.factor(resultado), reference=as.factor(datatest$Survived))
}

PlotROCRyAUC <- function(predictions,datatest)
{
  
  ROCRpred <- prediction(na.omit(predictions), na.omit(datatest))
  ROCRperf <- performance(ROCRpred, measure = "tpr", x.measure = "fpr")
  plot(ROCRperf, colorize = TRUE, text.adj = c(-0.2,1.7), print.cutoffs.at = seq(0,1,0.1))
  
  auc <- performance(ROCRpred, measure = "auc")
  auc <- auc@y.values[[1]]
  auc
}
