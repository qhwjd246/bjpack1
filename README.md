
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bjpack1

The goal of bjpack1 is to create a table that includes all of the
important performance measures of classifier to intuitively provide
important information at once that is necessary for the comparison of
the models’ performance, to create a ROC with useful information of the
best model in a neat way, to create a PRC for each model, and to create
a shiny gadget that provides a ROC/PRC according to a user’s choice.

## Installation

You can install the development version of bjpack1 like so:

``` r
install.packages("bjpack1")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(bjpack1)

## basic example code
testy<-sample(c(0,1), 154, replace=TRUE)
pred_test1<-runif (154, min=0, max=1)
pred_test2<- runif (154, min=0, max=1)
predlist<-list(pred_test1, pred_test2)
modellist<-list("Randomforest","Decision tree")
```

    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls > cases
    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls < cases
    #> Warning in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, : 윈
    #> 도우즈 폰트데이터베이스에서 찾을 수 없는 폰트페밀리입니다

<img src="man/figures/README-newtab-1.png" width="100%" />

    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls > cases
    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls > cases
    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls < cases
    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls < cases

<img src="man/figures/README-newroc-1.png" width="100%" />

    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls > cases
    #> Setting levels: control = 0, case = 1
    #> Setting direction: controls < cases
    #> 필요한 패키지를 로딩중입니다: ggplot2
    #> Warning: Removed 1 row containing missing values (`geom_path()`).
    #> Removed 1 row containing missing values (`geom_path()`).

<img src="man/figures/README-prc-1.png" width="100%" />

``` r
##shiny gadget
newshiny=bjshiny (testy, pred_test1,modellist)
```
