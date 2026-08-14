test_that("rasterpic_img() dispatches as an S3 generic", {
  # nolint start
  rasterpic_img.rpic_test <- function(x, img, ...) {
    "dispatched"
  }
  # nolint end

  x <- structure(list(), class = "rpic_test")

  expect_identical(rasterpic_img(x, NULL), "dispatched")
})

test_that("rasterpic_img() errors for unsupported S3 classes", {
  x <- "a"

  expect_snapshot(error = TRUE, rasterpic_img(x, NULL))

  class(x) <- c("foo", "bar")

  expect_snapshot(error = TRUE, rasterpic_img(x, NULL))
})

test_that("rasterpic_img() registers supported input methods", {
  methods <- c(
    "default",
    "sf",
    "sfc",
    "sfg",
    "stars",
    "bbox",
    "numeric",
    "SpatRaster",
    "SpatVector",
    "SpatExtent"
  )

  for (method in methods) {
    expect_true(is.function(getS3method("rasterpic_img", method)))
  }
})

test_that("rasterpic_img() errors for invalid numeric coordinates", {
  x <- 1
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(rasterpic_img(x, img), error = TRUE)
})

test_that("rasterpic_img() errors for missing and unsupported image files", {
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  img <- "nofile"
  expect_snapshot(rasterpic_img(x, img), error = TRUE)

  img2 <- system.file("gpkg/UK.gpkg", package = "rasterpic")

  expect_snapshot(rasterpic_img(x, img2), error = TRUE)
})

test_that("rasterpic_img() errors for alignment values outside [0, 1]", {
  x <- c(1, 2, 3, 4)
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(rasterpic_img(x, img, valign = 1.2), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, valign = -1.2), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, halign = 1.2), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, halign = -1.2), error = TRUE)
})

test_that("rasterpic_img() errors for invalid alignment types", {
  x <- c(1, 2, 3, 4)
  img <- system.file("img/UK_flag.png", package = "rasterpic")

  expect_snapshot(rasterpic_img(x, img, halign = NA_real_), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, halign = c(0, 1)), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, valign = "top"), error = TRUE)
})

test_that("rasterpic_img() informs for geographic sf coordinates", {
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  x <- sf::st_transform(x, 4326)
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(s <- rasterpic_img(x, img))
  expect_s4_class(s, "SpatRaster")
  expect_true(terra::has.RGB(s))

  x2 <- sf::st_transform(x, 3857)

  expect_silent(s2 <- rasterpic_img(x2, img))
  expect_s4_class(s2, "SpatRaster")
  expect_true(terra::has.RGB(s2))
})

test_that("rasterpic_img() informs for geographic raster coordinates", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:4326")
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(s <- rasterpic_img(x, img))
  expect_s4_class(s, "SpatRaster")
  expect_true(terra::has.RGB(s))

  x2 <- terra::project(x, "epsg:3857")
  expect_silent(s2 <- rasterpic_img(x2, img))
  expect_s4_class(s2, "SpatRaster")
  expect_true(terra::has.RGB(s2))
})

test_that("mask is ignored for SpatRaster input", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  res1 <- rasterpic_img(x, img)
  res2 <- rasterpic_img(x, img, mask = TRUE)

  expect_equal(as.vector(terra::ext(res1)), as.vector(terra::ext(res2)))
  expect_equal(terra::crs(res1), terra::crs(res2))

  expect_true(terra::compareGeom(res1, res2))
})

test_that("mask is ignored for SpatExtent input", {
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
  png_dim <- terra::rast(img, noflip = TRUE)
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
  png_dim <- terra::rast(img, noflip = TRUE)
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
  png_dim <- terra::rast(img, noflip = TRUE)
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
  png_dim <- terra::rast(img, noflip = TRUE)
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

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster), unname(x[2]))
  expect_equal(terra::ymax(raster), unname(x[4]))

  # Different x coords
  expect_lt(terra::xmin(raster), unname(x[1]))
  expect_gt(terra::xmax(raster), unname(x[3]))
})

test_that("bbox input accepts an explicit CRS and can be cropped", {
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
  expect_equal(terra::ymin(raster), unname(x[2]))
  expect_equal(terra::ymax(raster), unname(x[4]))

  # Different x coords
  expect_lt(terra::xmin(raster), unname(x[1]))
  expect_gt(terra::xmax(raster), unname(x[3]))

  # On crop ok
  crop <- rasterpic_img(x, img, crs = crs_wkt_sf, crop = TRUE)
  expect_false(identical(
    as.vector(terra::ext(raster)),
    as.vector(terra::ext(crop))
  ))
})

test_that("crop trims sf output to the input bounding box", {
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

test_that("mask and inverse create complementary sf masks", {
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

test_that("horizontal images produce equivalent output across formats", {
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
  expect_setequal(
    basename(otherformats),
    c(
      "UK_flag.jpeg",
      "UK_flag.jpg",
      "UK_flag.png",
      "UK_flag.tif",
      "UK_flag.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
  }
})

test_that("vertical images produce equivalent sf output across formats", {
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
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
  }
})

test_that("vertical images produce equivalent raster output across formats", {
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
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
  }
})

test_that("vertical images produce equivalent sfc output across formats", {
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
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
  }
})

test_that("vertical images work with SpatExtent input across formats", {
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
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file, crs = "epsg:3035")
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
  }
})

test_that("transparent images keep the alpha layer", {
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

test_that("single-layer images warn and do not get RGB metadata", {
  # PNG
  img <- system.file("grays/grays.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_snapshot(raster <- rasterpic_img(x, img))

  expect_s4_class(raster, "SpatRaster")
  expect_equal(terra::crs(raster), terra::crs(x))
  expect_false(terra::has.RGB(raster))
  expect_equal(terra::nlyr(raster), 1)
})

test_that("two-layer images warn and do not get RGB metadata", {
  # PNG
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r <- rasterpic_img(x, img)
  expect_named(r, c("r", "g", "b"))

  # Write as geotiff with 2 layers
  tmp_dir <- withr::local_tempdir()
  tmp_tiff <- withr::local_tempfile(tmpdir = tmp_dir, fileext = ".tiff")
  r_12 <- terra::subset(r, 1:2)
  expect_equal(terra::nlyr(r_12), 2)
  terra::writeRaster(r_12, tmp_tiff)

  x2 <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  expect_snapshot(r_new <- rasterpic_img(x2, tmp_tiff))

  expect_s4_class(r_new, "SpatRaster")
  expect_equal(terra::crs(r_new), terra::crs(x2))
  expect_false(terra::has.RGB(r_new))
  expect_identical(terra::nlyr(r_new), terra::nlyr(r_12))
})

test_that("images with more than four layers keep RGB metadata", {
  # PNG
  img <- system.file("img/transparent.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r <- rasterpic_img(x, img)

  r_8 <- c(r, r)
  # Write as geotiff with 6 layers
  tmp_dir <- withr::local_tempdir()
  tmp_tiff <- withr::local_tempfile(tmpdir = tmp_dir, fileext = ".tiff")
  expect_equal(terra::nlyr(r_8), 8)
  terra::writeRaster(r_8, tmp_tiff)

  x2 <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r_new <- rasterpic_img(x2, tmp_tiff)

  expect_s4_class(r_new, "SpatRaster")
  expect_equal(terra::crs(r_new), terra::crs(x2))
  expect_true(terra::has.RGB(r_new))
  expect_identical(terra::nlyr(r_new), terra::nlyr(r_8))
})

test_that("tiff images with existing RGB metadata preserve that mapping", {
  # PNG
  skip_on_cran()
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r <- rasterpic_img(x, img)

  terra::RGB(r) <- c(3, 1, 2)
  expect_equal(terra::RGB(r), c(3, 1, 2))
  tmp_dir <- withr::local_tempdir()
  tmp_tiff <- withr::local_tempfile(tmpdir = tmp_dir, fileext = ".tiff")
  terra::writeRaster(r, tmp_tiff)
  rr <- terra::rast(tmp_tiff)
  # The tiff has RGB colors already

  expect_true(terra::has.RGB(rr))

  x2 <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r_new <- rasterpic_img(x2, tmp_tiff)

  expect_s4_class(r_new, "SpatRaster")
  expect_equal(terra::crs(r_new), terra::crs(x2))
  expect_true(terra::has.RGB(r_new))
  expect_identical(terra::nlyr(r_new), terra::nlyr(rr))
  expect_equal(terra::RGB(r_new), terra::RGB(rr))
})

test_that("remote image download warnings become rasterpic_img() errors", {
  testthat::local_mocked_bindings(
    rpic_download_file = function(url, destfile, ...) {
      warning("Cannot open URL")
    }
  )

  img <- "http://this_is_an_error_url.fake"
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_snapshot(rasterpic_img(x, img), error = TRUE)
})

test_that("rasterpic_img() geotags mocked remote images", {
  local_img <- system.file("img/UK_flag.png", package = "rasterpic")
  logo_url <- testhelp_logo_url()

  testthat::local_mocked_bindings(
    rpic_download_file = function(url, destfile, ...) {
      file.copy(local_img, destfile, overwrite = TRUE)
      0
    }
  )

  img <- logo_url
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_silent(raster <- rasterpic_img(x, img))
  expect_s4_class(raster, "SpatRaster")
  expect_true(terra::has.RGB(raster))
  expect_equal(terra::crs(raster), terra::crs(x))
})

test_that("rasterpic_img() can download real online images", {
  skip_on_cran()
  skip_if_not_installed("curl")
  skip_if_offline()

  img <- testhelp_logo_url()
  test_download <- suppressWarnings(
    try(
      rpic_download_file(img, withr::local_tempfile(fileext = ".png")),
      silent = TRUE
    )
  )
  skip_if(
    inherits(test_download, "try-error"),
    "Cannot download the test logo."
  )

  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_silent(raster <- rasterpic_img(x, img))
  expect_s4_class(raster, "SpatRaster")
  expect_true(terra::has.RGB(raster))
  expect_equal(terra::crs(raster), terra::crs(x))
})

test_that("sfg input uses empty CRS when none is supplied", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  # Create an sfg

  f <- sf::st_coordinates(sf::st_geometry(x))

  # Extract a polygon
  x <- sf::st_polygon(list(as.matrix(f[f[, 4] == 1, 1:2], ncol = 2)))

  expect_s3_class(x, "sfg")

  expect_snapshot(raster <- rasterpic_img(x, img))

  expect_false(nzchar(terra::crs(raster)))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Same y coords
  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::xmax(raster), bbox_x[3])
})

test_that("sfg input accepts an explicit CRS", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
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
  expect_true(nzchar(terra::crs(raster)))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Same y coords
  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::xmax(raster), bbox_x[3])
})

test_that("SpatExtent input uses empty CRS when none is supplied", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::ext(terra::vect(x))
  expect_s4_class(x, "SpatExtent")

  expect_snapshot(raster <- rasterpic_img(x, img))

  expect_false(nzchar(terra::crs(raster)))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster), terra::ymin(x))
  expect_equal(terra::ymax(raster), terra::ymax(x))

  # Different x coords
  expect_lt(terra::xmin(raster), terra::xmin(x))
  expect_gt(terra::xmax(raster), terra::xmax(x))
})

test_that("SpatExtent input accepts an explicit CRS", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  x_v <- terra::vect(x_a)
  crs_wkt_terra <- terra::crs(x_v)
  x <- terra::ext(x_v)
  expect_s4_class(x, "SpatExtent")

  raster <- rasterpic_img(x, img, crs = crs_wkt_terra)
  expect_equal(terra::crs(raster), crs_wkt_terra)

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Same y coords
  expect_equal(terra::ymin(raster), terra::ymin(x))
  expect_equal(terra::ymax(raster), terra::ymax(x))

  # Different x coords
  expect_lt(terra::xmin(raster), terra::xmin(x))
  expect_gt(terra::xmax(raster), terra::xmax(x))
})

test_that("stars input expands to contain the source bounds", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- stars::read_stars(
    system.file("tiff/elev.tiff", package = "rasterpic"),
    quiet = TRUE
  )
  expect_s3_class(x, "stars")

  expect_snapshot(raster <- rasterpic_img(x, img))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Raster extent contains the stars bbox.
  expect_lte(terra::xmin(raster), bbox_x[1])
  expect_lte(terra::ymin(raster), bbox_x[2])
  expect_gte(terra::xmax(raster), bbox_x[3])
  expect_gte(terra::ymax(raster), bbox_x[4])
})

test_that("stars input preserves CRS and can be cropped", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  x <- stars::st_as_stars(sf::st_bbox(x_a))
  expect_s3_class(x, "stars")

  raster <- rasterpic_img(x, img)
  expect_equal(terra::crs(raster), crs_wkt_sf)

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Raster extent contains the stars bbox.
  expect_lte(terra::xmin(raster), bbox_x[1])
  expect_lte(terra::ymin(raster), bbox_x[2])
  expect_gte(terra::xmax(raster), bbox_x[3])
  expect_gte(terra::ymax(raster), bbox_x[4])

  # Crop keeps the raster within the stars extent.
  crop <- rasterpic_img(x, img, crop = TRUE)
  expect_false(identical(
    as.vector(terra::ext(raster)),
    as.vector(terra::ext(crop))
  ))
})

test_that("stars input uses empty CRS when none is supplied", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  sf::st_crs(x) <- NA
  x <- stars::st_as_stars(sf::st_bbox(x))
  expect_s3_class(x, "stars")

  expect_snapshot(raster <- rasterpic_img(x, img))
  expect_false(nzchar(terra::crs(raster)))
})

test_that("numeric bounding box input uses empty CRS when none is supplied", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- as.double(sf::st_bbox(x))
  expect_type(x, "double")
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

test_that("numeric bounding box input rejects invalid coordinates", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")

  expect_snapshot(rasterpic_img(c(NA, 0, 1, 1), img), error = TRUE)

  expect_snapshot(rasterpic_img(c(0, 0, Inf, 1), img), error = TRUE)

  expect_snapshot(rasterpic_img(c(1, 0, 0, 1), img), error = TRUE)

  expect_snapshot(rasterpic_img(c(0, 0, 1, 0), img), error = TRUE)
})

test_that("numeric bounding box input accepts an explicit CRS", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x_a <- sf::st_transform(x, 25830)
  crs_wkt_sf <- sf::st_crs(x_a)$wkt

  x <- as.double(sf::st_bbox(x))
  expect_type(x, "double")
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
