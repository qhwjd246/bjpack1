#' Create a ROC with useful information of models in a neat way
#'
#' @param testy Observed outcome values of test dataset
#' @param list1 list of predicted values from binary classifiers
#' @param list2 list of model names of binary classifiers
#'
#' @return ROC plot
#' @export
#'
#' @importFrom pROC roc auc ci.se  ggroc
#' @importFrom ggplot2 aes element_text element_rect guide_legend theme_minimal geom_abline coord_equal labs theme guides annotate geom_ribbon
#' @examples
#' testy<-sample(c(0,1), 154, replace=TRUE)
#' pred_test1<-runif (154, min=0, max=1)
#' pred_test2<- runif (154, min=0, max=1)
#' predlist<-list(pred_test1, pred_test2)
#' modellist<-list("Randomforest","Decision tree")
#' newroc=bjroc(testy, predlist,modellist)
bjroc <-function(testy, list1, list2) {
  x <- lower <- upper <- NULL
  roclist<-c()##creation of ROC and AUC list from user's input
  auclist<-c()
  for (i in list1) {
    roclist<-list(roclist,roc(testy, i))
    auclist<-c(auclist, round(auc(testy, i), 2))
  }
  roclist[[1]]<-roclist[[1]][[2]]
  names(roclist)<-unlist(list2)

  ##creation of confidence intervals
  ci.list <- lapply(roclist, ci.se, specificities = seq(0, 1, l = 25))
  dat.ci.list <- lapply(ci.list, function(ciobj)
    data.frame(x = as.numeric(rownames(ciobj)),
               lower = ciobj[, 1],
               upper = ciobj[, 3]))

  ##creation of ROC graph according to the number of models (i.e., different codes depending on 1 model vs. >1 model)
  if(length(roclist)>1) {###when >1 model
    p <- ggroc(roclist, legacy.axes=F) + theme_minimal() + geom_abline(slope=1, intercept = 1, linetype = "dashed", alpha=0.7, color = "darkgrey") + coord_equal()+geom_abline(linetype="dashed", slope=-1, intercept=0, size=0.5, color="grey")+labs(title="ROC curve", x="Specificity", y="Sensitivity")+theme_minimal()+theme(legend.title=element_text(size=8), plot.title=element_text(hjust=0.5, size=12, face="bold"), axis.title=element_text(size=10, face="bold"), axis.text=element_text(size=8), panel.background=element_rect(fill="white",color="gray"))+guides(color=guide_legend(title="Models"))+annotate("text", x=0.35, y=0.06, label=paste0("AUC of ", list2[[which.max(auclist)]], ", the best model, is ", max(auclist)), color="black", size=2.5)
  } else {###when 1model
    p <- ggroc(roclist, legacy.axes=F) + theme_minimal() + geom_abline(slope=1, intercept = 1, linetype = "dashed", alpha=0.7, color = "darkgrey") + coord_equal()+geom_abline(linetype="dashed", slope=-1, intercept=0, size=0.5, color="grey")+labs(title="ROC curve", x="Specificity", y="Sensitivity")+theme_minimal()+theme(legend.title=element_text(size=8), plot.title=element_text(hjust=0.5, size=12, face="bold"), axis.title=element_text(size=10, face="bold"), axis.text=element_text(size=8), panel.background=element_rect(fill="white",color="gray"))+guides(color=guide_legend(title="Models"))+annotate("text", x=0.30, y=0.05, label=paste("AUC of the model is", auclist), color="black", size=3)
  }

  for(i in 1:length(roclist)) {###adding confidence intervals to the graph
    p <- p + geom_ribbon(
      data = dat.ci.list[[i]],
      aes(x = x, ymin = lower, ymax = upper),
      fill = i + 1,
      alpha = 0.2,
      inherit.aes = F)
  }

  return(p)
}
