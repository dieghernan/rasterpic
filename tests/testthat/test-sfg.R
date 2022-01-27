test_that("Test sfg", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  # Create an sfg

  f <- sf::st_coordinates(sf::st_geometry(x))

  # Extract a polygon
  x <- sf::st_polygon(list(as.matrix(f[f[, 4] == 1, 1:2], ncol = 2)))

  expect_s3_class(x, "sfg")

  expect_message(rasterpic_img(x, img), "'crs' is NA")
  raster <- rasterpic_img(x, img)

  expect_true(terra::crs(raster) == "")

  png_dim <- png::readPNG(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == sf::st_bbox(x)[2])
  expect_true(terra::ymax(raster) == sf::st_bbox(x)[4])

  # Different x coords
  expect_true(terra::xmin(raster) < sf::st_bbox(x)[1])
  expect_true(terra::xmax(raster) > sf::st_bbox(x)[3])
})

test_that("Test sfg with projs", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  # Create an sfg

  f <- sf::st_coordinates(sf::st_geometry(x))

  # Extract a polygon
  x <- sf::st_polygon(list(as.matrix(f[f[, 4] == 1, 1:2], ncol = 2)))

  expect_s3_class(x, "sfg")

  raster <- rasterpic_img(x, img, crs = crs_wkt_sf)
  expect_false(terra::crs(raster) == "")


  png_dim <- png::readPNG(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_true(terra::ymin(raster) == sf::st_bbox(x)[2])
  expect_true(terra::ymax(raster) == sf::st_bbox(x)[4])

  # Different x coords
  expect_true(terra::xmin(raster) < sf::st_bbox(x)[1])
  expect_true(terra::xmax(raster) > sf::st_bbox(x)[3])
})
