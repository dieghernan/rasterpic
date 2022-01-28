test_that("Test SpatExtent", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::ext(terra::vect(x))
  expect_s4_class(x, "SpatExtent")

  expect_message(rasterpic_img(x, img), "'crs' is NA")
  raster <- rasterpic_img(x, img)

  expect_true(terra::crs(raster) == "")

  png_dim <- png::readPNG(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == terra::ymin(x))
  expect_true(terra::ymax(raster) == terra::ymax(x))

  # Different x coords
  expect_true(terra::xmin(raster) < terra::xmin(x))
  expect_true(terra::xmax(raster) > terra::xmax(x))
})

test_that("Test SpatExtent with projs", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  x_v <- terra::vect(x_a)
  crs_wkt_terra <- terra::crs(x_v)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  x <- terra::ext(x_v)
  expect_s4_class(x, "SpatExtent")

  raster <- rasterpic_img(x, img, crs = crs_wkt_terra)
  expect_true(terra::crs(raster) == crs_wkt_terra)

  png_dim <- png::readPNG(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == terra::ymin(x))
  expect_true(terra::ymax(raster) == terra::ymax(x))

  # Different x coords
  expect_true(terra::xmin(raster) < terra::xmin(x))
  expect_true(terra::xmax(raster) > terra::xmax(x))
})
