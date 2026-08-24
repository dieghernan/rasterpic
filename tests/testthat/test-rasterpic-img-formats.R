test_that("horizontal images produce equivalent output across formats", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))
  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Same y coords
  expect_equal(terra::ymin(raster), bbox_x[2])
  expect_equal(terra::ymax(raster), bbox_x[4])

  # Different x coords
  expect_lt(terra::xmin(raster), bbox_x[1])
  expect_gt(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^UK_flag",
    full.names = TRUE
  )
  expect_setequal(
    basename(otherformats),
    c(
      "UK_flag.jpeg",
      "UK_flag.jpg",
      "UK_flag.png",
      "UK_flag.tif",
      "UK_flag.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
    expect_rgb_content_matches(raster_test, raster, info = file_name)
  }
})

test_that("lossless PNG input preserves representative pixel values", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img)
  pixels <- terra::values(raster, mat = TRUE)

  expect_equal(dim(raster), c(400, 800, 3))
  expect_equal(pixels[1, ], c(r = 221, g = 89, b = 104))
  expect_equal(pixels[159600, ], c(r = 206, g = 17, b = 38))
  expect_equal(pixels[320000, ], c(r = 221, g = 89, b = 104))
})

test_that("vertical images produce equivalent sf output across formats", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))

  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Different y coords
  expect_lt(terra::ymin(raster), bbox_x[2])
  expect_gt(terra::ymax(raster), bbox_x[4])

  # Same x coords
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_equal(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
    expect_rgb_content_matches(raster_test, raster, info = file_name)
  }
})

test_that("vertical images produce equivalent raster output across formats", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- testhelp_load_rast(system.file("tiff/elev.tiff", package = "rasterpic"))

  # Project
  x <- terra::project(x, "epsg:3857")

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))
  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  # Different y coords
  expect_lt(terra::ymin(raster), terra::ymin(x))
  expect_gt(terra::ymax(raster), terra::ymax(x))

  # Same x coords
  expect_equal(terra::xmin(raster), terra::xmin(x))
  expect_equal(terra::xmax(raster), terra::xmax(x))

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
    expect_rgb_content_matches(raster_test, raster, info = file_name)
  }
})

test_that("vertical images produce equivalent sfc output across formats", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- sf::st_geometry(x)
  expect_s3_class(x, "sfc")

  raster <- rasterpic_img(x, img)
  expect_true(terra::has.RGB(raster))

  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Different y coords
  expect_lt(terra::ymin(raster), bbox_x[2])
  expect_gt(terra::ymax(raster), bbox_x[4])

  # Same x coords
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_equal(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file)
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_true(terra::has.RGB(raster_test), info = file_name)
    expect_rgb_content_matches(raster_test, raster, info = file_name)
  }
})

test_that("vertical formats preserve SpatExtent placement", {
  img <- system.file("img/vertical.png", package = "rasterpic")
  x <- sf::st_read(
    system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x <- terra::ext(terra::vect(x))
  expect_s4_class(x, "SpatExtent")

  raster <- rasterpic_img(x, img, crs = "epsg:3035")
  png_dim <- rpic_read_png(img)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  bbox_x <- unname(sf::st_bbox(x))

  # Different y coords
  expect_lt(terra::ymin(raster), bbox_x[2])
  expect_gt(terra::ymax(raster), bbox_x[4])

  # Same x coords
  expect_equal(terra::xmin(raster), bbox_x[1])
  expect_equal(terra::xmax(raster), bbox_x[3])

  otherformats <- list.files(
    system.file("img", package = "rasterpic"),
    pattern = "^vertical",
    full.names = TRUE
  )
  expect_setequal(
    basename(otherformats),
    c(
      "vertical.jpeg",
      "vertical.jpg",
      "vertical.png",
      "vertical.tif",
      "vertical.tiff"
    )
  )

  for (file in otherformats) {
    file_name <- basename(file)
    raster_test <- rasterpic_img(x, file, crs = "epsg:3035")
    expect_equal(asp_ratio(raster_test), asp_ratio(raster), info = file_name)
    expect_equal(
      as.vector(terra::ext(raster_test)),
      as.vector(terra::ext(raster)),
      info = file_name
    )
    expect_equal(terra::crs(raster_test), terra::crs(raster), info = file_name)
    expect_rgb_content_matches(raster_test, raster, info = file_name)
  }
})

test_that("transparent PNG input preserves RGB and alpha channels", {
  img <- system.file("img/transparent.png", package = "rasterpic")

  x <- sf::st_read(
    system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  raster <- rasterpic_img(x, img)

  expect_named(raster, c("r", "g", "b", "alpha"))

  expect_true(terra::has.RGB(raster))

  png_dim <- suppressWarnings(terra::rast(img))
  png_dim <- terra::colorize(png_dim, to = "rgb", alpha = TRUE)

  expect_equal(dim(png_dim)[3], 4)
  expect_equal(terra::nlyr(raster), 4)
  expect_equal(asp_ratio(raster), dim(png_dim)[2] / dim(png_dim)[1])

  pixels <- terra::values(raster, mat = TRUE)
  expect_equal(dim(raster), c(480, 482, 4))
  expect_all_true(is.na(pixels[1, ]))
  expect_equal(pixels[115439, ], c(r = 89, g = 95, b = 113, alpha = 255))
})
