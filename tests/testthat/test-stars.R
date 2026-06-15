test_that("Test stars", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- stars::read_stars(
    system.file("tiff/elev.tiff", package = "rasterpic"),
    quiet = TRUE
  )
  expect_s3_class(x, "stars")

  expect_snapshot(raster <- rasterpic_img(x, img))

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- sf::st_bbox(x)

  # Raster extent contains the stars bbox.
  expect_lte(terra::xmin(raster), bbox_x[1])
  expect_lte(terra::ymin(raster), bbox_x[2])
  expect_gte(terra::xmax(raster), bbox_x[3])
  expect_gte(terra::ymax(raster), bbox_x[4])
})

test_that("Test stars with projs", {
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
  expect_true(terra::crs(raster) == crs_wkt_sf)

  png_dim <- terra::rast(img, noflip = TRUE)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- sf::st_bbox(x)

  # Raster extent contains the stars bbox.
  expect_lte(terra::xmin(raster), bbox_x[1])
  expect_lte(terra::ymin(raster), bbox_x[2])
  expect_gte(terra::xmax(raster), bbox_x[3])
  expect_gte(terra::ymax(raster), bbox_x[4])

  # Crop keeps the raster within the stars extent.
  crop <- rasterpic_img(x, img, crop = TRUE)
  expect_false(terra::ext(raster) == terra::ext(crop))
})

test_that("Test stars without crs", {
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
