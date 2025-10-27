test_that("asp_ratio for raster", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  expect_s4_class(x, "SpatRaster")
  expect_type(asp_ratio(x), "double")
  expect_length(asp_ratio(x), 1)
})

test_that("asp_ratio for sf/sfc/bbox", {
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  expect_s3_class(x, "sf")
  expect_type(asp_ratio(x), "double")
  expect_length(asp_ratio(x), 1)

  # sfc
  x2 <- sf::st_geometry(x)
  expect_s3_class(x2, "sfc")
  expect_type(asp_ratio(x2), "double")
  expect_length(asp_ratio(x2), 1)

  expect_identical(asp_ratio(x), asp_ratio(x2))

  # bbox
  x3 <- as.double(sf::st_bbox(x))
  expect_type(x3, "double")
  expect_type(asp_ratio(x3), "double")
  expect_length(asp_ratio(x3), 1)

  expect_identical(asp_ratio(x), asp_ratio(x3))
})

test_that("Error on asp_ratio", {
  df <- data.frame(x = 1, y = 3)
  expect_error(asp_ratio(df), "Don't know how to compute the ratio")

  s <- c(1, 2)
  expect_error(asp_ratio(s), "Don't know how to compute the ratio")

  chars <- c("1", "2", "3", "4")
  expect_length(chars, 4)
  expect_error(asp_ratio(chars), "Don't know how to compute the ratio")
})

test_that("asp_ratio for numeric", {
  chars <- c("1", "2", "3", "4")
  nums <- as.double(chars)
  rat <- asp_ratio(nums)
  expect_equal(rat, (3 - 1) / (4 - 2))
})
