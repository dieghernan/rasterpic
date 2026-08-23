test_that("custom S3 methods receive rasterpic_img() calls", {
  # nolint start
  rasterpic_img.rpic_test <- function(x, img, ...) {
    "dispatched"
  }
  # nolint end

  x <- structure(list(), class = "rpic_test")

  expect_identical(rasterpic_img(x, NULL), "dispatched")
})

test_that("unsupported S3 classes report the missing rasterpic_img() method", {
  x <- "a"

  expect_snapshot(error = TRUE, rasterpic_img(x, NULL))

  class(x) <- c("foo", "bar")

  expect_snapshot(error = TRUE, rasterpic_img(x, NULL))
})

test_that("every documented input class has a registered S3 method", {
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

test_that("numeric input with the wrong length reports bbox requirements", {
  x <- 1
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(rasterpic_img(x, img), error = TRUE)
})

test_that("missing files and unsupported extensions report actionable errors", {
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  img <- "nofile"
  expect_snapshot(rasterpic_img(x, img), error = TRUE)

  img2 <- system.file("gpkg/UK.gpkg", package = "rasterpic")

  expect_snapshot(rasterpic_img(x, img2), error = TRUE)
})

test_that("alignment values outside the unit interval report their bounds", {
  x <- c(1, 2, 3, 4)
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(rasterpic_img(x, img, valign = 1.2), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, valign = -1.2), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, halign = 1.2), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, halign = -1.2), error = TRUE)
})

test_that("nonscalar and nonnumeric alignments report scalar requirements", {
  x <- c(1, 2, 3, 4)
  img <- system.file("img/UK_flag.png", package = "rasterpic")

  expect_snapshot(rasterpic_img(x, img, halign = NA_real_), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, halign = c(0, 1)), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, valign = "top"), error = TRUE)

  expect_snapshot(rasterpic_img(x, img, halign = 0.5 + 0i), error = TRUE)
})

test_that("invalid image arguments report a scalar path requirement", {
  x <- c(1, 2, 3, 4)

  expect_snapshot(rasterpic_img(x, NA_character_), error = TRUE)
  expect_snapshot(rasterpic_img(x, character()), error = TRUE)
  expect_snapshot(rasterpic_img(x, c("a.png", "b.png")), error = TRUE)
  expect_snapshot(rasterpic_img(x, ""), error = TRUE)
})

test_that("invalid expansion values report finite nonnegative requirements", {
  x <- c(1, 2, 3, 4)
  img <- system.file("img/UK_flag.png", package = "rasterpic")

  expect_snapshot(rasterpic_img(x, img, expand = -0.1), error = TRUE)
  expect_snapshot(rasterpic_img(x, img, expand = Inf), error = TRUE)
  expect_snapshot(rasterpic_img(x, img, expand = c(0, 1)), error = TRUE)
})

test_that("nonlogical control flags report TRUE or FALSE requirements", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  bbox <- c(1, 2, 3, 4)

  expect_snapshot(rasterpic_img(bbox, img, crop = NA), error = TRUE)

  x <- terra::vect(sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  ))
  expect_snapshot(rasterpic_img(x, img, mask = 1), error = TRUE)
  expect_snapshot(rasterpic_img(x, img, inverse = NA), error = TRUE)
})

test_that("invalid CRS values report optional scalar string requirements", {
  x <- c(1, 2, 3, 4)
  img <- system.file("img/UK_flag.png", package = "rasterpic")

  expect_snapshot(rasterpic_img(x, img, crs = 4326), error = TRUE)
  expect_snapshot(
    rasterpic_img(x, img, crs = c("EPSG:4326", "EPSG:3857")),
    error = TRUE
  )
})

test_that("geographic sf input warns before planar placement", {
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

test_that("geographic SpatRaster input warns before planar placement", {
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

test_that("single-layer input warns and remains without RGB metadata", {
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

test_that("two-layer input warns and remains without RGB metadata", {
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

test_that("multilayer input preserves every layer and RGB metadata", {
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

test_that("download warnings become rasterpic_img() errors with their cause", {
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

test_that("download errors become rasterpic_img() errors with their cause", {
  testthat::local_mocked_bindings(
    rpic_download_file = function(url, destfile, ...) {
      stop("Cannot open URL")
    }
  )

  img <- "http://this_is_an_error_url.fake"
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_snapshot(rasterpic_img(x, img), error = TRUE)
})

test_that("nonzero download statuses become rasterpic_img() errors", {
  testthat::local_mocked_bindings(
    rpic_download_file = \(url, destfile, ...) 1
  )

  img <- "http://this_is_an_error_url.fake"
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_snapshot(rasterpic_img(x, img), error = TRUE)
})

test_that("successful mocked downloads produce geotagged RGB rasters", {
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

test_that("reachable online images produce geotagged RGB rasters", {
  skip_on_cran()
  skip_if_not_installed("curl")
  skip_if_offline()

  img <- testhelp_logo_url()
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

test_that("sfg input preserves an explicit CRS", {
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

test_that("SpatExtent input preserves an explicit CRS", {
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
  skip_if_not_installed("stars")

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

test_that("stars input preserves CRS through cropping", {
  skip_if_not_installed("stars")

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
  expect_extent_matches_bbox(crop, bbox_x)
})

test_that("stars input uses empty CRS when none is supplied", {
  skip_if_not_installed("stars")

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

test_that("numeric bounds preserve an explicit CRS through cropping", {
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
  expect_extent_matches_bbox(crop, x)
})
