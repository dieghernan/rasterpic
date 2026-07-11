test_that("Test crop", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x0 <- rasterpic_img(x, img, expand = 0, crop = TRUE)

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_false(identical(asp_ratio(x0), dim(png_dim)[2] / dim(png_dim)[1]))

  # Bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- as.vector(terra::ext(x0))

  # Tolerance limit
  min_length <- min(abs(bbox_x))

  diff <- max(abs(bbox_x - bbox_x0[c(1, 3, 2, 4)]))

  expect_lt(diff / min_length, 0.0001)
})

test_that("Test mask", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img, mask = TRUE)

  png_dim <- terra::rast(img, noflip = TRUE)

  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Same y coords
  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::xmax(raster), bbox_x[3])

  # Expect NAs
  rws <- terra::ncell(raster)
  df <- as.data.frame(raster, na.rm = TRUE)
  expect_gt(rws, nrow(df))

  # Inverse
  raster_inv <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)

  expect_equal(asp_ratio(raster_inv), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster_inv), bbox_x[2])
  expect_equal(terra::ymax(raster_inv), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster_inv), bbox_x[1])
  expect_gt(terra::xmax(raster_inv), bbox_x[3])

  # Expect NAs
  df2 <- as.data.frame(raster_inv, na.rm = TRUE)
  expect_gt(rws, nrow(df2))
  expect_gt(nrow(df2), nrow(df))
})

test_that("Test crop SpatVector", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  x0 <- rasterpic_img(x, img, expand = 0, crop = TRUE)

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_false(identical(asp_ratio(x0), dim(png_dim)[2] / dim(png_dim)[1]))

  # Bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- as.vector(terra::ext(x0))

  # Tolerance limit
  min_length <- min(abs(bbox_x))

  diff <- max(abs(bbox_x - bbox_x0[c(1, 3, 2, 4)]))

  expect_lt(diff / min_length, 0.0001)
})

test_that("Test mask SpatVector", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  raster <- rasterpic_img(x, img, mask = TRUE)

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

  # Expect NAs
  rws <- terra::ncell(raster)
  df <- as.data.frame(raster, na.rm = TRUE)
  expect_gt(rws, nrow(df))

  # Inverse
  raster_inv <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)

  expect_true(terra::has.RGB(raster_inv))

  expect_equal(asp_ratio(raster_inv), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster_inv), bbox_x[2])
  expect_equal(terra::ymax(raster_inv), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster_inv), bbox_x[1])
  expect_gt(terra::xmax(raster_inv), bbox_x[3])

  # Expect NAs
  df2 <- as.data.frame(raster_inv, na.rm = TRUE)
  expect_gt(rws, nrow(df2))
  expect_gt(nrow(df2), nrow(df))
})

test_that("Test crop sfg", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  # Create an sfg

  f <- sf::st_coordinates(sf::st_geometry(x))

  # Extract a polygon
  x <- sf::st_polygon(list(as.matrix(f[f[, 4] == 1, 1:2], ncol = 2)))

  expect_s3_class(x, "sfg")

  x0 <- rasterpic_img(x, img, expand = 0, crop = TRUE, crs = crs_wkt_sf)

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_false(identical(asp_ratio(x0), dim(png_dim)[2] / dim(png_dim)[1]))

  # Bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- as.vector(terra::ext(x0))

  # Tolerance limit
  min_length <- min(abs(bbox_x))

  diff <- max(abs(bbox_x - bbox_x0[c(1, 3, 2, 4)]))

  expect_lt(diff / min_length, 0.0001)
})

test_that("Test mask sfg", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  # Create an sfg

  f <- sf::st_coordinates(sf::st_geometry(x))

  # Extract a polygon
  x <- sf::st_polygon(list(as.matrix(f[f[, 4] == 1, 1:2], ncol = 2)))

  expect_s3_class(x, "sfg")

  raster <- rasterpic_img(x, img, mask = TRUE, crs = crs_wkt_sf)

  png_dim <- terra::rast(img, noflip = TRUE)

  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Same y coords
  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::xmax(raster), bbox_x[3])

  # Expect NAs
  rws <- terra::ncell(raster)
  df <- as.data.frame(raster, na.rm = TRUE)
  expect_gt(rws, nrow(df))

  # Inverse
  expect_snapshot(
    raster_inv <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)
  )

  expect_equal(asp_ratio(raster_inv), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster_inv), bbox_x[2])
  expect_equal(terra::ymax(raster_inv), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster_inv), bbox_x[1])
  expect_gt(terra::xmax(raster_inv), bbox_x[3])

  # Expect NAs
  df2 <- as.data.frame(raster_inv, na.rm = TRUE)
  expect_gt(rws, nrow(df2))
  expect_gt(nrow(df2), nrow(df))
})
