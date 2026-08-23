test_that("NULL and NA CRS values become empty strings", {
  expect_identical(rpic_crs(NULL), "")
  expect_identical(rpic_crs(NA_character_), "")
  expect_identical(rpic_crs("epsg:3857"), "epsg:3857")
})

test_that("unit interval validation accepts boundaries and interior values", {
  expect_no_error(rpic_check_unit_interval(0, "halign"))
  expect_no_error(rpic_check_unit_interval(0.5, "halign"))
  expect_no_error(rpic_check_unit_interval(1, "halign"))
})

test_that("unit interval validation reports invalid type, length and range", {
  expect_snapshot(rpic_check_unit_interval(NA_real_, "halign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval(c(0, 1), "halign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval("top", "valign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval(-0.1, "valign"), error = TRUE)

  expect_snapshot(rpic_check_unit_interval(1.1, "valign"), error = TRUE)
})

test_that("bounding box validation accepts finite increasing coordinates", {
  expect_no_error(rpic_check_bbox(c(0, 1, 2, 3), "x"))
})

test_that("bounding box validation reports length, finiteness and ordering", {
  expect_snapshot(rpic_check_bbox(c(1, 2, 3), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(NA, 0, 1, 1), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(0, 0, Inf, 1), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(1, 0, 0, 1), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(0, 0, 1, 0), "x"), error = TRUE)

  expect_snapshot(rpic_check_bbox(c(0, 0, 1, 1) + 0i, "x"), error = TRUE)
})

test_that("box expansion adds the shortest-axis margin to every side", {
  box <- c(0, 0, 10, 20)

  expect_equal(rpic_expand_box(box, 0), box)
  expect_equal(rpic_expand_box(box, 0.5), c(-5, -5, 15, 25))
  expect_equal(rpic_expand_box(box, 1), c(-10, -10, 20, 30))
})

test_that("wide images expand width and preserve vertical bounds", {
  rast <- terra::rast(nrows = 10, ncols = 20)

  placement <- rpic_place_extent(
    box = c(0, 0, 10, 10),
    rast = rast,
    halign = 0.5
  )

  expect_equal(placement$box_marg, c(0, 0, 10, 10))
  expect_equal(placement$ext, c(-5, 15, 0, 10))
})

test_that("tall images expand height using the requested alignment", {
  rast <- terra::rast(nrows = 10, ncols = 10)

  placement <- rpic_place_extent(
    box = c(0, 0, 20, 10),
    rast = rast,
    valign = 0.25
  )

  expect_equal(placement$box_marg, c(0, 0, 20, 10))
  expect_equal(placement$ext, c(0, 20, -2.5, 17.5))
})

test_that("file URLs copy their contents and return a success status", {
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
