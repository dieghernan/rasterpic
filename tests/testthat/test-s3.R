test_that("rasterpic_img is an S3 generic", {
  # nolint start
  rasterpic_img.rpic_test <- function(x, img, ...) {
    "dispatched"
  }
  # nolint end

  x <- structure(list(), class = "rpic_test")

  expect_identical(rasterpic_img(x, NULL), "dispatched")
})

test_that("rasterpic_img registers supported input methods", {
  methods <- c(
    "default",
    "sf",
    "sfc",
    "sfg",
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

test_that("rpic_input registers supported input methods", {
  methods <- c(
    "default",
    "sf",
    "sfc",
    "sfg",
    "bbox",
    "numeric",
    "SpatRaster",
    "SpatVector",
    "SpatExtent"
  )

  for (method in methods) {
    expect_true(is.function(getS3method("rpic_input", method)))
  }
})
