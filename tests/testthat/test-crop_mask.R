test_that("Test crop", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x0 <- rasterpic_img(x, img, expand = 0, crop = TRUE)

  png_dim <- png::readPNG(img)
  expect_false(asp_ratio(x0) == dim(png_dim)[2] / dim(png_dim)[1])

  terra::plotRGB(x0)
  plot(sf::st_as_sfc(sf::st_bbox(x)), add = TRUE)
  # Bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- as.double(terra::ext(x0)@ptr[["vector"]])

  # Tolerance limit
  min_length <- min(abs(bbox_x))

  diff <- max(abs(bbox_x - bbox_x0[c(1, 3, 2, 4)]))

  expect_true(diff / min_length < 0.0001)
})

test_that("Test mask", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img, mask = TRUE)

  png_dim <- png::readPNG(img)

  expect_true(asp_ratio(raster) == dim(png_dim)[2] / dim(png_dim)[1])


  # Same y coords
  expect_true(terra::ymin(raster) == sf::st_bbox(x)[2])
  expect_true(terra::ymax(raster) == sf::st_bbox(x)[4])

  # Different x coords
  expect_true(terra::xmin(raster) < sf::st_bbox(x)[1])
  expect_true(terra::xmax(raster) > sf::st_bbox(x)[3])

  # Expect NAs
  df <- terra::values(raster, dataframe = TRUE)
  expect_true(any(is.na(df)))

  # Count NAs on layer1
  v1 <- length(df[is.na(df$lyr.1), 1])


  # Inverse
  raster_inv <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)

  expect_true(asp_ratio(raster_inv) == dim(png_dim)[2] / dim(png_dim)[1])


  # Same y coords
  expect_true(terra::ymin(raster_inv) == sf::st_bbox(x)[2])
  expect_true(terra::ymax(raster_inv) == sf::st_bbox(x)[4])

  # Different x coords
  expect_true(terra::xmin(raster_inv) < sf::st_bbox(x)[1])
  expect_true(terra::xmax(raster_inv) > sf::st_bbox(x)[3])

  # Expect NAs
  df2 <- terra::values(raster_inv, dataframe = TRUE)
  expect_true(any(is.na(df2)))
  v2 <- length(df2[is.na(df2$lyr.1), 1])
  expect_gt(v1, v2)
})
