#' Create a Shiny gadget that creates a ROC or PRC according to a user's choice.
#'
#' @param testy Observed outcome values of test dataset
#' @param x1 predicted values of a model
#' @param x2 list of model names of binary classifiers
#'
#' @return Shiny gadget
#' @export
#'
#' @importFrom pROC roc auc ci.se coords ci.coords ggroc
#' @importFrom ggplot2 element_blank element_line aes ggplot element_text element_rect guide_legend geom_path theme_minimal geom_abline coord_equal labs theme guides annotate geom_ribbon
#' @importFrom shiny shinyApp fluidPage sidebarLayout sidebarPanel selectInput mainPanel plotOutput reactive renderPlot
#' @importFrom shinyWidgets radioGroupButtons
#' @examples
#' testy<-sample(c(0,1), 154, replace=TRUE)
#' pred_test1<-runif (154, min=0, max=1)
#' modellist=list("Randomforest","Decision tree")
#' newshiny=bjshiny (testy, pred_test1,modellist)
bjshiny<-function(testy, x1, x2) {
  x <- lower <- upper <-recall <- NULL
  ui <- fluidPage(

    sidebarLayout(

      # Inputs
      sidebarPanel(

        # Put input here
        selectInput(inputId = 'modellist',
                    label = 'Select model(s)',
                    choices = unique(x2),
                    selected = x2[[1]]),
        radioGroupButtons(inputId = 'plot',
                          label = 'Select a plot',
                          choices = c('ROC', 'PRC'),
                          selected = 'ROC')
      ),

      # Outputs
      mainPanel(
        plotOutput('plot')
      )
    )
  )

  # Server
  server <- function(input, output) {

    plot <- reactive({
      if (input$plot == 'ROC') {

        roclist<-c()##creation of ROC and AUC list from user's input
        auclist<-c()
        roclist<-list(roclist,roc(testy, x1))
        auclist<-c(auclist, round(auc(testy, x1), 2))

        roclist[[1]]<-roclist[[1]][[2]]
        names(roclist)<-input$modellist

        ##creation of confidence intervals
        ci.list <- lapply(roclist, ci.se, specificities = seq(0, 1, l = 25))
        dat.ci.list <- lapply(ci.list, function(x) data.frame(x = as.numeric(rownames(x)),
                                                              lower = x[, 1],
                                                              upper = x[, 3]))

        ggroc(roclist, legacy.axes=F) + theme_minimal() +
          geom_abline(slope=1, intercept = 1, linetype = "dashed", alpha=0.7,
                      color = "darkgrey") + coord_equal()+
          geom_abline(linetype="dashed", slope=-1, intercept=0, size=0.5, color="grey")+
          labs(title="ROC curve", x="Specificity", y="Sensitivity")+
          theme_minimal()+theme(legend.title=element_text(size=8),
                                plot.title=element_text(hjust=0.5, size=12, face="bold"),
                                axis.title=element_text(size=10, face="bold"),
                                axis.text=element_text(size=8),
                                panel.background=element_rect(fill="white",color="gray"))+
          guides(color=guide_legend(title="Models"))+
          annotate("text", x=0.30, y=0.05, label=paste("AUC of",input$modellist, "model is", auclist),
                   color="black", size=3) +geom_ribbon(
                     data = dat.ci.list[[1]],
                     aes(x = x, ymin = lower, ymax = upper),
                     fill = 4,
                     alpha = 0.2,
                     inherit.aes = F)
      }else {
        ##creation of a dataframe having true and predicted values
        df1<-data.frame(testy)
        df2<-data.frame(x1)
        cdb1<-cbind(df1, df2)
        colnames(cdb1)<-c('yactual', 'ypred')


        ## generate ROC curve
        roc1 <- pROC::roc(cdb1$yactual, cdb1$ypred, plot=FALSE,legacy.axes=TRUE, percent=FALSE)

        ## compute recall and precision at each ROC curve's threshold
        prcoords1 <- pROC::coords(roc1, "all", ret = c("threshold", "recall", "precision"), transpose = FALSE)


        ## compute 95% confidence intervals for recall and precision at each threshold
        pr.cis1 <- pROC::ci.coords(roc1, prcoords1$threshold, ret=c("recall", "precision"))

        ## build a dataframe where columns x contains recall values and lower/upper columns
        ## contain lower and upper bounds of corresponding precision values.
        pr.cis1 <- data.frame(pr.cis1[2]) # convert precision coords to data frame
        pr.cis.df1<- data.frame(x = prcoords1$recall,
                                lower = pr.cis1[, 1],
                                upper = pr.cis1[, 3])
        ggplot(prcoords1, aes(recall, precision)) +
          geom_path(aes(recall, precision), colour="salmon") + # needed to connect points in order of appearance
          geom_ribbon(aes(x=pr.cis.df1$x, ymin=pr.cis.df1$lower, ymax=pr.cis.df1$upper),
                      alpha=0.3,
                      fill="lightblue") +
          theme(aspect.ratio = 1) +
          theme(panel.background = element_blank(),
                axis.line = element_line(colour = "black"))+
          theme_minimal() + geom_abline(slope=1, intercept = 0, linetype = "dashed", alpha=0.7, color = "darkgrey") + coord_equal()+geom_abline(linetype="dashed", slope=-1, intercept=1, size=0.5, color="grey")+labs(title="Precision Recall Curve", x="Recall", y="Precision")+theme(legend.title=element_text(size=8), plot.title=element_text(hjust=0.5, size=12, face="bold"), axis.title=element_text(size=10, face="bold"), axis.text=element_text(size=8), panel.background=element_rect(fill="white",color="gray"))+guides(color=guide_legend(title="Models"))+annotate("text", x=0.80, y=0.05, label=paste("The model is", input$modellist), color="black", size=3)

      }
    })

    output$plot <- renderPlot({
      plot()
    })

  }
  # Create a Shiny app object
  return(shinyApp(ui = ui, server = server))
}
