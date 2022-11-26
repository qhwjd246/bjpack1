context("Testing modelmeasure functionality")

testthat::test_that("errors", {

  testy<-sample(c(0,1), 154, replace=TRUE)
  pred_test1<-runif (154, min=0, max=1)
  pred_test2<- runif (154, min=0, max=1)
  predlist<-list(pred_test1, pred_test2)
  modellist<-list("Randomforest","Decision tree")
  newtab=modelmeasure(testy, predlist,modellist)

  testthat::expect_equal(flextable::nrow_part(newtab),9)


})
