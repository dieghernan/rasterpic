test_that("rpic_crs() normalizes missing CRS values", {
  expect_identical(rpic_crs(NULL), "")
  expect_identical(rpic_crs(NA_character_), "")
  expect_identical(rpic_crs("epsg:3857"), "epsg:3857")
})

test_that("rpic_check_unit_interval() accepts scalar values in [0, 1]", {
  expect_no_error(rpic_check_unit_interval(0, "halign"))
  expect_no_error(rpic_check_unit_interval(0.5, "halign"))
  expect_no_error(rpic_check_unit_interval(1, "halign"))
})

test_that("rpic_check_unit_interval() errors for invalid scalar values", {
  expect_snapshot(rpic_check_unit_interval(NA_real_, "halign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval(c(0, 1), "halign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval("top", "valign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval(-0.1, "valign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval(1.1, "valign"), error = TRUE)
})

test_that("rpic_check_bbox() accepts finite ordered bounding boxes", {
  expect_no_error(rpic_check_bbox(c(0, 1, 2, 3), "x"))
})

test_that("rpic_check_bbox() errors for invalid bounding boxes", {
  expect_snapshot(rpic_check_bbox(c(1, 2, 3), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(NA, 0, 1, 1), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(0, 0, Inf, 1), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(1, 0, 0, 1), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(0, 0, 1, 0), "x"), error = TRUE)
})

test_that("rpic_expand_box() expands each side by the same margin", {
  box <- c(0, 0, 10, 20)

  expect_equal(rpic_expand_box(box, 0), box)
  expect_equal(rpic_expand_box(box, 0.5), c(-5, -5, 15, 25))
  expect_equal(rpic_expand_box(box, 1), c(-10, -10, 20, 30))
})

test_that("rpic_place_extent() expands width when the image is wider", {
  rast <- terra::rast(nrows = 10, ncols = 20)

  placement <- rpic_place_extent(
    box = c(0, 0, 10, 10),
    rast = rast,
    halign = 0.5
  )

  expect_equal(placement$box_marg, c(0, 0, 10, 10))
  expect_equal(placement$ext, c(-5, 15, 0, 10))
})

test_that("rpic_place_extent() expands height when the image is taller", {
  rast <- terra::rast(nrows = 10, ncols = 10)

  placement <- rpic_place_extent(
    box = c(0, 0, 20, 10),
    rast = rast,
    valign = 0.25
  )

  expect_equal(placement$box_marg, c(0, 0, 20, 10))
  expect_equal(placement$ext, c(0, 20, -2.5, 17.5))
})

test_that("rpic_download_file() downloads local file URLs", {
  tmp_dir <- withr::local_tempdir()
  source_file <- withr::local_tempfile(tmpdir = tmp_dir, fileext = ".txt")
  dest_file <- withr::local_tempfile(tmpdir = tmp_dir, fileext = ".txt")
  writeLines("downloaded", source_file)

  source_url <- paste0(
    "file:///",
    normalizePath(source_file, winslash = "/", mustWork = TRUE)
  )

  expect_equal(rpic_download_file(source_url, dest_file), 0)
  expect_equal(readLines(dest_file), "downloaded")
})
