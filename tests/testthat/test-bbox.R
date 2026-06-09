test_that("Test bbox", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- sf::st_bbox(x)
  expect_s3_class(x, "bbox")

  expect_silent(raster <- rasterpic_img(x, img))

  v <- terra::vect(sf::st_as_sfc(x))
  expect_identical(terra::crs(raster), terra::crs(v))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == x[2])
  expect_true(terra::ymax(raster) == x[4])

  # Different x coords
  expect_true(terra::xmin(raster) < x[1])
  expect_true(terra::xmax(raster) > x[3])
})

test_that("Test bbox with projs", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  sf::st_crs(x) <- NA
  x <- sf::st_bbox(x)
  expect_s3_class(x, "bbox")

  # NULL crs
  raster_null <- rasterpic_img(x, img)
  expect_false(nzchar(terra::crs(raster_null)))

  raster <- rasterpic_img(x, img, crs = crs_wkt_sf)
  expect_true(nzchar(terra::crs(raster)))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == x[2])
  expect_true(terra::ymax(raster) == x[4])

  # Different x coords
  expect_true(terra::xmin(raster) < x[1])
  expect_true(terra::xmax(raster) > x[3])

  # On crop ok
  crop <- rasterpic_img(x, img, crs = crs_wkt_sf, crop = TRUE)
  expect_false(terra::ext(raster) == terra::ext(crop))
})
