test_that("Test vector", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- as.double(sf::st_bbox(x))
  expect_true(is.numeric(x))
  expect_length(x, 4)

  expect_error(rasterpic_img(x[1:3], img))
  expect_message(raster <- rasterpic_img(x, img), "'crs' is NA")

  expect_true(terra::crs(raster) == "")

  png_dim <- png::readPNG(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == x[2])
  expect_true(terra::ymax(raster) == x[4])

  # Different x coords
  expect_true(terra::xmin(raster) < x[1])
  expect_true(terra::xmax(raster) > x[3])
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
  expect_false(terra::crs(raster) == "")

  png_dim <- png::readPNG(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == x[2])
  expect_true(terra::ymax(raster) == x[4])

  # Different x coords
  expect_true(terra::xmin(raster) < x[1])
  expect_true(terra::xmax(raster) > x[3])

  # On mask message
  expect_message(mask <- rasterpic_img(x, img, crs = crs_wkt_sf, mask = TRUE))

  expect_true(terra::ext(raster) == terra::ext(mask))

  # On crop ok
  crop <- rasterpic_img(x, img, crs = crs_wkt_sf, crop = TRUE)
  expect_false(terra::ext(raster) == terra::ext(crop))
})
