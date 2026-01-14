test_that("Check how it works with single layers files", {
  # PNG
  img <- system.file("grays/grays.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_snapshot(raster <- rasterpic_img(x, img))

  expect_s4_class(raster, "SpatRaster")
  expect_true(terra::crs(raster) == terra::crs(x))
  expect_false(terra::has.RGB(raster))
  expect_equal(terra::nlyr(raster), 1)
})


test_that("Check how it works with 2 layer file", {
  # PNG
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r <- rasterpic_img(x, img)
  expect_identical(names(r), c("r", "g", "b"))

  # Write as geotiff with 2 layers

  tmp_tiff <- tempfile(fileext = ".tiff")
  r_12 <- terra::subset(r, 1:2)
  expect_equal(terra::nlyr(r_12), 2)
  terra::writeRaster(r_12, tmp_tiff)

  x2 <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  expect_snapshot(r_new <- rasterpic_img(x2, tmp_tiff))

  expect_s4_class(r_new, "SpatRaster")
  expect_true(terra::crs(r_new) == terra::crs(x2))
  expect_false(terra::has.RGB(r_new))
  expect_identical(terra::nlyr(r_new), terra::nlyr(r_12))
})


test_that("Check how it works with 6 layer file", {
  # PNG
  img <- system.file("img/transparent.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r <- rasterpic_img(x, img)

  r_8 <- c(r, r)
  # Write as geotiff with 6 layers

  tmp_tiff <- tempfile(fileext = ".tiff")
  expect_equal(terra::nlyr(r_8), 8)
  terra::writeRaster(r_8, tmp_tiff)

  x2 <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r_new <- rasterpic_img(x2, tmp_tiff)

  expect_s4_class(r_new, "SpatRaster")
  expect_true(terra::crs(r_new) == terra::crs(x2))
  expect_true(terra::has.RGB(r_new))
  expect_identical(terra::nlyr(r_new), terra::nlyr(r_8))
})


test_that("Check how it works with tif with RGB", {
  # PNG
  skip_on_cran()
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  r <- rasterpic_img(x, img)

  terra::RGB(r) <- c(3, 1, 2)
  expect_true(all(terra::RGB(r) == c(3, 1, 2)))
  tmp_tiff <- tempfile(fileext = ".tiff")
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
  expect_true(terra::crs(r_new) == terra::crs(x2))
  expect_true(terra::has.RGB(r_new))
  expect_identical(terra::nlyr(r_new), terra::nlyr(rr))
  expect_true(all(terra::RGB(r_new) == terra::RGB(rr)))
})
