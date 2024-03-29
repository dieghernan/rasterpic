test_that("Error on bad x formatting", {
  x <- 1
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(
    rasterpic_img(x, img),
    error = TRUE
  )
})

test_that("Error on bad img formatting", {
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  img <- "nofile"
  expect_snapshot(
    rasterpic_img(x, img),
    error = TRUE
  )


  img2 <- system.file("gpkg/UK.gpkg", package = "rasterpic")

  expect_snapshot(
    rasterpic_img(x, img2),
    error = TRUE
  )
})

test_that("Error on invalid parameters", {
  x <- 1
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_snapshot(
    rasterpic_img(x, img, valign = 1.2),
    error = TRUE
  )

  expect_snapshot(
    rasterpic_img(x, img, valign = -1.2),
    error = TRUE
  )

  expect_snapshot(
    rasterpic_img(x, img, halign = 1.2),
    error = TRUE
  )

  expect_snapshot(
    rasterpic_img(x, img, halign = -1.2),
    error = TRUE
  )
})

test_that("Message in lonlat sf", {
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  x <- sf::st_transform(x, 4326)
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_message(
    rasterpic_img(x, img),
    "Warning: x has geographic coordinates. Assuming planar coordinates."
  )

  x2 <- sf::st_transform(x, 3857)

  expect_silent(rasterpic_img(x2, img))
})

test_that("Message in lonlat raster", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:4326")
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  expect_message(
    rasterpic_img(x, img),
    "Warning: x has geographic coordinates. Assuming planar coordinates."
  )

  x2 <- terra::project(x, "epsg:3857")
  expect_silent(rasterpic_img(x2, img))
})


test_that("Message in mask raster", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  res1 <- rasterpic_img(x, img)

  expect_message(
    res2 <- rasterpic_img(x, img, mask = TRUE),
    "'mask' only available when 'x' is an 'sf/sfc/SpatVector' object"
  )


  expect_true(terra::ext(res1) == terra::ext(res2))
  expect_true(terra::crs(res1) == terra::crs(res2))
  v1 <- terra::values(res1)
  v2 <- terra::values(res2)

  expect_identical(v1, v2)
})

test_that("Message in mask raster with SpatExtent", {
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")
  img <- system.file("img/UK_flag.png", package = "rasterpic")

  extent <- terra::ext(x)
  crs <- terra::crs(x)

  res1 <- rasterpic_img(extent, img, crs = crs)

  expect_message(
    res2 <- rasterpic_img(extent, img, mask = TRUE, crs = crs),
    "'mask' only available when 'x' is an 'sf/sfc/SpatVector' object"
  )


  expect_true(terra::ext(res1) == terra::ext(res2))
  expect_true(terra::crs(res1) == terra::crs(res2))
  v1 <- terra::values(res1)
  v2 <- terra::values(res2)

  expect_identical(v1, v2)
})
