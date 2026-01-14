test_that("Test horizontal alignments", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  # Left
  raster_x0 <- rasterpic_img(x, img, halign = 0)
  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster_x0), dim(png_dim)[2] / dim(png_dim)[1])

  # Same coords
  expect_true(terra::ymin(raster_x0) == sf::st_bbox(x)[2])
  expect_true(terra::ymax(raster_x0) == sf::st_bbox(x)[4])
  expect_true(terra::xmin(raster_x0) == sf::st_bbox(x)[1])

  # Different x coords
  expect_true(terra::xmax(raster_x0) > sf::st_bbox(x)[3])

  # Right
  raster_x1 <- rasterpic_img(x, img, halign = 1)
  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster_x1), dim(png_dim)[2] / dim(png_dim)[1])

  # Same coords
  expect_true(terra::ymin(raster_x1) == sf::st_bbox(x)[2])
  expect_true(terra::ymax(raster_x1) == sf::st_bbox(x)[4])
  expect_true(terra::xmax(raster_x1) == sf::st_bbox(x)[3])

  # Different x coords
  expect_true(terra::xmin(raster_x1) < sf::st_bbox(x)[1])
})


test_that("Test vertical alignments", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  # Bottom
  raster_y0 <- rasterpic_img(x, img, valign = 0)
  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster_y0), dim(png_dim)[2] / dim(png_dim)[1])

  # Same coords
  expect_true(terra::ymin(raster_y0) == sf::st_bbox(x)[2])
  expect_true(terra::xmax(raster_y0) == sf::st_bbox(x)[3])
  expect_true(terra::xmin(raster_y0) == sf::st_bbox(x)[1])

  # Different x coords
  expect_true(terra::ymax(raster_y0) > sf::st_bbox(x)[4])

  # Top
  raster_y1 <- rasterpic_img(x, img, valign = 1)
  expect_equal(asp_ratio(raster_y1), dim(png_dim)[2] / dim(png_dim)[1])

  # Same coords
  expect_true(terra::xmin(raster_y1) == sf::st_bbox(x)[1])
  expect_true(terra::ymax(raster_y1) == sf::st_bbox(x)[4])
  expect_true(terra::xmax(raster_y1) == sf::st_bbox(x)[3])

  # Different x coords
  expect_true(terra::ymin(raster_y1) < sf::st_bbox(x)[2])
})
