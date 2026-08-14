testhelp_load_rast <- function(path) {
  ext <- tools::file_ext(path)
  tmp_dir <- withr::local_tempdir(.local_envir = parent.frame())
  tmp <- withr::local_tempfile(
    tmpdir = tmp_dir,
    fileext = paste0(".", ext),
    .local_envir = parent.frame()
  )
  file.copy(path, tmp, overwrite = TRUE)

  x <- terra::rast(tmp)

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

  testthat::expect_true(all(x_na == x_mask))
  testthat::expect_true(all(y_na == y_mask))
  testthat::expect_gt(sum(x_mask), 0)
  testthat::expect_gt(sum(y_mask), 0)
  testthat::expect_false(any(x_mask & y_mask))
  testthat::expect_false(any(!x_mask & !y_mask))
}
