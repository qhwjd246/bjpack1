#' Create a PRC for each model
#'
#' @param testy Observed outcome values of test dataset
#' @param x1 predicted values of a model
#' @param x2 model name
#'
#' @return PRC plot
#' @export
#'
#' @importFrom pROC roc coords ci.coords
#' @importFrom ggplot2 aes element_blank element_line element_text element_rect guide_legend ggplot geom_path geom_ribbon theme theme_minimal geom_abline coord_equal labs guides annotate
#' @examples
#' testy<-sample(c(0,1), 154, replace=TRUE)
#' pred_test1<-runif (154, min=0, max=1)
#' pred_test2<- runif (154, min=0, max=1)
#' apr=bjpr(testy, pred_test1, "Randomforest")
#' bpr=bjpr(testy, pred_test2, "Decision tree")
bjpr<-function(testy, x1, x2) {

  recall <- NULL

  ##creation of a dataframe having true and predicted values
  df1<-data.frame(testy)
  df2<-data.frame(x1)
  cdb<-cbind(df1, df2)
  colnames(cdb)<-c('yactual', 'ypred')


  ## generate ROC curve
  roc <- pROC::roc(cdb$yactual, cdb$ypred, plot=FALSE,legacy.axes=TRUE, percent=FALSE)

  ## compute recall and precision at each ROC curve's threshold
  prcoords <- pROC::coords(roc, "all", ret = c("threshold", "recall", "precision"), transpose = FALSE)


  ## compute 95% confidence intervals for recall and precision at each threshold
  pr.cis <- pROC::ci.coords(roc, prcoords$threshold, ret=c("recall", "precision"))

  ## build a dataframe where columns x contains recall values and lower/upper columns
  ## contain lower and upper bounds of corresponding precision values.
  pr.cis <- data.frame(pr.cis[2]) # convert precision coords to data frame
  pr.cis.df<- data.frame(x = prcoords$recall,
                         lower = pr.cis[, 1],
                         upper = pr.cis[, 3])

  ## plot precision recall coordinates along with confidence area
  pr<-ggplot(prcoords, aes(recall, precision)) +
    geom_path(aes(recall, precision), colour="salmon") + # needed to connect points in order of appearance
    geom_ribbon(aes(x=pr.cis.df$x, ymin=pr.cis.df$lower, ymax=pr.cis.df$upper),
                alpha=0.3,
                fill="lightblue") +
    theme(aspect.ratio = 1) +
    theme(panel.background = element_blank(),
          axis.line = element_line(colour = "black"))+
    theme_minimal() + geom_abline(slope=1, intercept = 0, linetype = "dashed", alpha=0.7, color = "darkgrey") + coord_equal()+geom_abline(linetype="dashed", slope=-1, intercept=1, size=0.5, color="grey")+labs(title="Precision Recall Curve", x="Recall", y="Precision")+theme(legend.title=element_text(size=8), plot.title=element_text(hjust=0.5, size=12, face="bold"), axis.title=element_text(size=10, face="bold"), axis.text=element_text(size=8), panel.background=element_rect(fill="white",color="gray"))+guides(color=guide_legend(title="Models"))+annotate("text", x=0.70, y=0.05, label=paste("The model is", x2), color="black", size=3)

  return(pr)
}
