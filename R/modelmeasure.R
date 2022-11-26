#' Calculate and collect important performance measures of binary classifiers in a table
#'
#' @param testy Observed outcome values of test dataset
#' @param list1 list of predicted values from binary classifiers
#' @param list2 list of model names of binary classifiers
#'
#' @return A table that includes measures of model performance
#' @export
#'
#' @importFrom pROC auc
#' @importFrom InformationValue sensitivity specificity precision misClassError confusionMatrix
#' @importFrom flextable flextable
#' @importFrom flextable set_caption
#' @importFrom flextable align
#' @importFrom flextable set_table_properties
#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @examples
#' testy<-sample(c(0,1), 154, replace=TRUE)
#' pred_test1<-runif (154, min=0, max=1)
#' pred_test2<- runif (154, min=0, max=1)
#' predlist<-list(pred_test1, pred_test2)
#' modellist<-list("Randomforest","Decision tree")
#' newtab=modelmeasure(testy, predlist,modellist)
modelmeasure = function(testy, list1, list2) {
  infolist<-list()
  for (i in list1) {
    ##calculate AUC
    auc<-round(auc(testy, i), 2)
    ##calculate sensitivity
    sen<-round(sensitivity(testy, i),2)
    ##calculate specificity
    spe<-round(specificity(testy, i),2)
    ##calculate precision
    prc<-round(precision(testy, i),2)
    ##calculate total misclassification error rate
    error<-round(misClassError(testy, i),2)

    ##create confusion matrix's information
    tp<-confusionMatrix(testy, i)[2,2]
    fn<-confusionMatrix(testy, i)[1,2]
    tn<-confusionMatrix(testy, i)[1,1]
    fp<-confusionMatrix(testy, i)[2,1]

    infolist<-list(infolist, c(auc, sen, spe,prc,error,tp,tn,fp,fn))
  }
  ##conversion of the list to data frame
  infolist[[1]]<-infolist[[1]][[2]]
  names(infolist) <-seq(1:length(infolist))
  infotable<-as.data.frame(infolist)
  firstcol<-c('AUC', 'Sensitivity', 'Specificity', 'Precision','Error rate', 'True Positive', 'True Negative', 'False Positive', 'False Negative')
  fst<-as.data.frame(firstcol)
  infotabler<-cbind(fst, infotable)
  colnames(infotabler) <- c("Measures", unlist(list2))
  infotab<-flextable(infotabler)%>% set_caption(caption = "Table 1. Measures of model performance by model", style = "Table Caption") %>%align(i=1, align="center", part="header") %>%  align(j=2:3, align="center", part="body") %>% set_table_properties(width=0.8, layout="autofit")

  return(infotab)
}
