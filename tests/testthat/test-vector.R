test_that("Test vector", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- as.double(sf::st_bbox(x))
  expect_true(is.numeric(x))
  expect_length(x, 4)

  expect_snapshot(raster <- rasterpic_img(x, img))
  expect_snapshot(rasterpic_img(x[1:3], img), error = TRUE)

  expect_false(nzchar(terra::crs(raster)))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster), x[2])
  expect_equal(terra::ymax(raster), x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), x[1])
  expect_gt(terra::xmax(raster), x[3])
})

test_that("Test vector with projs", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  x <- as.double(sf::st_bbox(x))
  expect_true(is.numeric(x))
  expect_length(x, 4)

  raster <- rasterpic_img(x, img, crs = crs_wkt_sf)
  expect_true(nzchar(terra::crs(raster)))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster), x[2])
  expect_equal(terra::ymax(raster), x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), x[1])
  expect_gt(terra::xmax(raster), x[3])

  # On crop ok
  crop <- rasterpic_img(x, img, crs = crs_wkt_sf, crop = TRUE)
  expect_false(identical(
    as.vector(terra::ext(raster)),
    as.vector(terra::ext(crop))
  ))
})
