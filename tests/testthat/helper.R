testhelp_load_rast <- function(path) {
  ext <- tools::file_ext(path)
  tmp_dir <- withr::local_tempdir(.local_envir = parent.frame())
  tmp <- withr::local_tempfile(
    tmpdir = tmp_dir,
    fileext = paste0(".", ext),
    .local_envir = parent.frame()
  )
  file.copy(path, tmp, overwrite = TRUE)

  x <- suppressWarnings(terra::rast(tmp))

  x
}

testhelp_logo_url <- function() {
  paste0(
    "https://raw.githubusercontent.com/dieghernan/rasterpic/",
    "main/man/figures/logo.png"
  )
}

expect_complementary_masks <- function(x, y) {
  testthat::expect_true(terra::compareGeom(x, y))

  x_na <- is.na(terra::values(x))
  y_na <- is.na(terra::values(y))
  x_mask <- x_na[, 1]
  y_mask <- y_na[, 1]

  testthat::expect_all_true(as.vector(x_na == x_mask))
  testthat::expect_all_true(as.vector(y_na == y_mask))
  testthat::expect_gt(sum(x_mask), 0)
  testthat::expect_gt(sum(y_mask), 0)
  testthat::expect_false(any(x_mask & y_mask))
  testthat::expect_false(any(!x_mask & !y_mask))
}

expect_extent_matches_bbox <- function(x, bbox) {
  expected <- as.double(bbox)
  actual <- as.vector(terra::ext(x))[c(1, 3, 2, 4)]
  resolution <- terra::res(x)
  tolerance <- c(resolution[1], resolution[2], resolution[1], resolution[2])

  testthat::expect_all_true(abs(expected - actual) <= tolerance)
}

expect_rgb_content_matches <- function(x, reference, info = NULL) {
  actual_values <- terra::values(x, mat = TRUE)[, 1:3, drop = FALSE]
  reference_values <- terra::values(reference, mat = TRUE)[, 1:3, drop = FALSE]

  testthat::expect_equal(dim(actual_values), dim(reference_values), info = info)

  difference <- abs(actual_values - reference_values)
  testthat::expect_lt(
    mean(difference, na.rm = TRUE),
    4,
    label = paste0("mean RGB difference for ", info)
  )
  testthat::expect_lte(
    unname(stats::quantile(difference, 0.99, na.rm = TRUE)),
    25,
    label = paste0("99th percentile RGB difference for ", info)
  )
  testthat::expect_lte(
    max(difference, na.rm = TRUE),
    70,
    label = paste0("maximum RGB difference for ", info)
  )
}
