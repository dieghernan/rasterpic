test_that("asp_ratio() computes columns divided by rows for rasters", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  expect_s4_class(x, "SpatRaster")

  ratio <- asp_ratio(x)
  expect_type(ratio, "double")
  expect_length(ratio, 1)
  expect_equal(ratio, terra::ncol(x) / terra::nrow(x))
})

test_that("asp_ratio() computes width divided by height for vector bounds", {
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  expect_s3_class(x, "sf")
  bbox <- as.double(sf::st_bbox(x))
  expected <- (bbox[3] - bbox[1]) / (bbox[4] - bbox[2])

  ratio <- asp_ratio(x)
  expect_type(ratio, "double")
  expect_length(ratio, 1)
  expect_equal(ratio, expected)

  # sfc
  x2 <- sf::st_geometry(x)
  ratio2 <- asp_ratio(x2)
  expect_s3_class(x2, "sfc")
  expect_type(ratio2, "double")
  expect_length(ratio2, 1)
  expect_equal(ratio2, expected)

  expect_identical(asp_ratio(x), asp_ratio(x2))

  # bbox
  x3 <- as.double(sf::st_bbox(x))
  ratio3 <- asp_ratio(x3)
  expect_type(x3, "double")
  expect_type(ratio3, "double")
  expect_length(ratio3, 1)
  expect_equal(ratio3, expected)

  expect_identical(asp_ratio(x), asp_ratio(x3))
})

test_that("asp_ratio() errors for unsupported inputs", {
  df <- data.frame(x = 1, y = 3)
  expect_snapshot(asp_ratio(df), error = TRUE)

  s <- c(1, 2)
  expect_snapshot(asp_ratio(s), error = TRUE)

  chars <- c("1", "2", "3", "4")
  expect_length(chars, 4)
  expect_snapshot(asp_ratio(chars), error = TRUE)
})

test_that("asp_ratio() supports numeric bounding boxes", {
  chars <- c("1", "2", "3", "4")
  nums <- as.double(chars)
  rat <- asp_ratio(nums)
  expect_equal(rat, (3 - 1) / (4 - 2))
})
