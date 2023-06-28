library(flowWorkspace)
test_that("Can make transformed gs", {
  gs = make_transformed_gs()
  expect_equal(sampleNames(gs), c("4000_TNK-CR1", "4001_TNK-CR1", "4002_TNK-CR1", "4003_TNK-CR1"))
})