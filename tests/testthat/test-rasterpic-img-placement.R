test_that("mask arguments leave SpatRaster output unchanged", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  res1 <- rasterpic_img(x, img)
  res2 <- rasterpic_img(x, img, mask = TRUE)

  expect_equal(as.vector(terra::ext(res1)), as.vector(terra::ext(res2)))
  expect_equal(terra::crs(res1), terra::crs(res2))
  expect_identical(terra::values(res1), terra::values(res2))
  expect_identical(names(res1), names(res2))
  expect_equal(terra::RGB(res1), terra::RGB(res2))
  expect_true(terra::compareGeom(res1, res2))
})

test_that("mask arguments leave SpatExtent output unchanged", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")
  img <- system.file("img/UK_flag.png", package = "rasterpic")

  extent <- terra::ext(x)
  crs <- terra::crs(x)

  res1 <- rasterpic_img(extent, img, crs = crs)

  res2 <- rasterpic_img(extent, img, mask = TRUE, crs = crs)

  expect_equal(as.vector(terra::ext(res1)), as.vector(terra::ext(res2)))
  expect_equal(terra::crs(res1), terra::crs(res2))
  v1 <- terra::values(res1)
  v2 <- terra::values(res2)

  expect_identical(v1, v2)
  expect_true(terra::compareGeom(res1, res2))
})

test_that("halign = 0 anchors the image to the left edge", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img, halign = 0)
  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::xmax(raster), bbox_x[3])
})

test_that("halign = 1 anchors the image to the right edge", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img, halign = 1)
  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])
  expect_equal(terra::xmax(raster), bbox_x[3])
  expect_lt(terra::xmin(raster), bbox_x[1])
})

test_that("valign = 0 anchors the image to the bottom edge", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img, valign = 0)
  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::xmax(raster), bbox_x[3])
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::ymax(raster), bbox_x[4])
})

test_that("valign = 1 anchors the image to the top edge", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img, valign = 1)
  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_equal(terra::ymax(raster), bbox_x[4])
  expect_equal(terra::xmax(raster), bbox_x[3])
  expect_lt(terra::ymin(raster), bbox_x[2])
})

test_that("bbox input preserves CRS and expands the shorter axis", {
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

  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster), unname(x[2]))
  expect_equal(terra::ymax(raster), unname(x[4]))

  # Different x coords
  expect_lt(terra::xmin(raster), unname(x[1]))
  expect_gt(terra::xmax(raster), unname(x[3]))
})

test_that("bbox input propagates an explicit CRS through cropping", {
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

  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster), unname(x[2]))
  expect_equal(terra::ymax(raster), unname(x[4]))

  # Different x coords
  expect_lt(terra::xmin(raster), unname(x[1]))
  expect_gt(terra::xmax(raster), unname(x[3]))

  # On crop ok
  crop <- rasterpic_img(x, img, crs = crs_wkt_sf, crop = TRUE)
  expect_extent_matches_bbox(crop, x)
})

test_that("crop trims sf output to the input bounding box", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x0 <- rasterpic_img(x, img, expand = 0, crop = TRUE)

  png_dim <- rpic_read_png(img)
  expect_false(identical(asp_ratio(x0), dim(png_dim)[2] / dim(png_dim)[1]))

  # Bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- as.vector(terra::ext(x0))

  # Tolerance limit
  min_length <- min(abs(bbox_x))

  diff <- max(abs(bbox_x - bbox_x0[c(1, 3, 2, 4)]))

  expect_lt(diff / min_length, 0.0001)
})

test_that("mask and inverse create complementary sf masks", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img, mask = TRUE)

  png_dim <- rpic_read_png(img)

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
  expect_complementary_masks(raster, raster_inv)
})

test_that("crop trims SpatVector output to the input bounding box", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  x0 <- rasterpic_img(x, img, expand = 0, crop = TRUE)

  png_dim <- rpic_read_png(img)
  expect_false(identical(asp_ratio(x0), dim(png_dim)[2] / dim(png_dim)[1]))

  # Bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- as.vector(terra::ext(x0))

  # Tolerance limit
  min_length <- min(abs(bbox_x))

  diff <- max(abs(bbox_x - bbox_x0[c(1, 3, 2, 4)]))

  expect_lt(diff / min_length, 0.0001)
})

test_that("mask and inverse create complementary SpatVector masks", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  raster <- rasterpic_img(x, img, mask = TRUE)

  expect_true(terra::has.RGB(raster))

  png_dim <- rpic_read_png(img)

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
  expect_complementary_masks(raster, raster_inv)
})

test_that("crop trims sfg output to the input bounding box", {
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

  png_dim <- rpic_read_png(img)
  expect_false(identical(asp_ratio(x0), dim(png_dim)[2] / dim(png_dim)[1]))

  # Bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- as.vector(terra::ext(x0))

  # Tolerance limit
  min_length <- min(abs(bbox_x))

  diff <- max(abs(bbox_x - bbox_x0[c(1, 3, 2, 4)]))

  expect_lt(diff / min_length, 0.0001)
})

test_that("mask and inverse create complementary sfg masks", {
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

  png_dim <- rpic_read_png(img)

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
  raster_inv <- rasterpic_img(
    x,
    img,
    mask = TRUE,
    inverse = TRUE,
    crs = crs_wkt_sf
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
  expect_complementary_masks(raster, raster_inv)
})

test_that("expand increases the output bounds while preserving aspect ratio", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x0 <- rasterpic_img(x, img, expand = 0)
  x_5 <- rasterpic_img(x, img, expand = 0.5)
  x1 <- rasterpic_img(x, img, expand = 1)

  # Asp ratios
  expect_equal(asp_ratio(x0), asp_ratio(x_5))
  expect_equal(asp_ratio(x0), asp_ratio(x1))

  # Check bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- unname(as.vector(terra::ext(x0)))
  expect_equal(bbox_x[c(2, 4)], bbox_x0[c(3, 4)])
  expect_gt(bbox_x[1], bbox_x0[1])
  expect_lt(bbox_x[3], bbox_x0[2])

  bbox_x_5 <- unname(as.vector(terra::ext(x_5)))
  expect_all_true(c(
    bbox_x[c(1, 3)] > bbox_x_5[c(1, 3)],
    bbox_x[c(2, 4)] < bbox_x_5[c(2, 4)]
  ))

  bbox_x1 <- unname(as.vector(terra::ext(x1)))
  expect_all_true(c(
    bbox_x_5[c(1, 3)] > bbox_x1[c(1, 3)],
    bbox_x_5[c(2, 4)] < bbox_x1[c(2, 4)]
  ))
})
