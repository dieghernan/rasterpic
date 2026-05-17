test_that("rasterpic_img is an S3 generic", {
  # nolint start
  rasterpic_img.rpic_test <- function(x, img, ...) {
    "dispatched"
  }
  # nolint end

  x <- structure(list(), class = "rpic_test")

  expect_identical(rasterpic_img(x, NULL), "dispatched")
})

test_that("rasterpic_img errors", {
  x <- "a"

  expect_snapshot(error = TRUE, rasterpic_img(x, NULL))

  class(x) <- c("foo", "bar")

  expect_snapshot(error = TRUE, rasterpic_img(x, NULL))
})

test_that("rasterpic_img registers supported input methods", {
  methods <- c(
    "default",
    "sf",
    "sfc",
    "sfg",
    "stars",
    "bbox",
    "numeric",
    "SpatRaster",
    "SpatVector",
    "SpatExtent"
  )

  for (method in methods) {
    expect_true(is.function(getS3method("rasterpic_img", method)))
  }
})
