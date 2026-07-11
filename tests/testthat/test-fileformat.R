test_that("Test all image formats with UK", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))
  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Same y coords
  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^UK_flag",
    full.names = TRUE
  )

  # Test
  for (file in otherformats) {
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster))
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster))
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster))
    expect_true(terra::has.RGB(raster_test))
  }
})

test_that("Test all image formats with AT vertical", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Different y coords
  expect_lt(terra::ymin(raster), bbox_x[2])
  expect_gt(terra::ymax(raster), bbox_x[4])

  # Same x coords
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_equal(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )

  # Test
  for (file in otherformats) {
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster))
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster))
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster))
    expect_true(terra::has.RGB(raster_test))
  }
})

test_that("Test all image formats with a raster", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))

  # Project
  x <- terra::project(x, "epsg:3857")

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))
  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Different y coords
  expect_lt(terra::ymin(raster), terra::ymin(x))
  expect_gt(terra::ymax(raster), terra::ymax(x))

  # Same x coords
  expect_equal(terra::xmin(raster), terra::xmin(x))
  expect_equal(terra::xmax(raster), terra::xmax(x))

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )

  # Test
  for (file in otherformats) {
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster))
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster))
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster))
    expect_true(terra::has.RGB(raster_test))
  }
})

test_that("Test all image formats with sfc vertical", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- sf::st_geometry(x)
  expect_s3_class(x, "sfc")

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Different y coords
  expect_lt(terra::ymin(raster), bbox_x[2])
  expect_gt(terra::ymax(raster), bbox_x[4])

  # Same x coords
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_equal(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )

  # Test
  for (file in otherformats) {
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster))
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster))
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster))
    expect_true(terra::has.RGB(raster_test))
  }
})

test_that("Test all image formats with SpatExtent", {
  skip_on_cran()

  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::ext(terra::vect(x))
  expect_s4_class(x, "SpatExtent")

  raster <- rasterpic_img(x, img, crs = "epsg:3035")
  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Different y coords
  expect_lt(terra::ymin(raster), bbox_x[2])
  expect_gt(terra::ymax(raster), bbox_x[4])

  # Same x coords
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_equal(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )

  # Test
  for (file in otherformats) {
    raster_test <- rasterpic_img(x, file, crs = "epsg:3035")
    expect_equal(asp_ratio(raster_test), asp_ratio(raster))
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster))
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster))
  }
})

test_that("Test transparent", {
  img <- system.file("img/transparent.png", package = "rasterpic")

  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img)

  expect_named(raster, c("r", "g", "b", "alpha"))

  expect_true(terra::has.RGB(raster))

  png_dim <- terra::rast(img, noflip = TRUE)
  png_dim <- terra::colorize(png_dim, to = "rgb", alpha = TRUE)

  expect_equal(dim(png_dim)[3], 4)
  expect_equal(terra::nlyr(raster), 4)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])
})
