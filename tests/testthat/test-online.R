test_that("Test error online", {
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

test_that("Test image online", {
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

  expect_silent(rasterpic_img(x, img))
})

test_that("rasterpic_img can download real online images", {
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

  expect_silent(rasterpic_img(x, img))
})

test_that("rpic_download_file downloads local file URLs", {
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
