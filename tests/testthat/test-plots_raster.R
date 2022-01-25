test_fun_rast <- function(x, prefix, ...) {
  images <- list.files(system.file("img", package = "rasterpic"),
    full.names = TRUE
  )


  for (file in images) {
    raster <- rasterpic::rasterpic_img(x, file, ...)

    vdiffr::expect_doppelganger(
      paste(prefix, "_", basename(file)),
      function() {
        terra::plotRGB(raster, colNA = "red", bgalpha = 0)
        terra::plot(x, add = TRUE)
      }
    )
  }
}



test_that("Raster plots regular", {
  skip_if_not_installed("vdiffr")

  x <- terra::rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")

  test_fun_rast(x, "regular")
})

test_that("Raster plots expand", {
  skip_if_not_installed("vdiffr")

  x <- terra::rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")

  test_fun_rast(x, "expand", expand = 1)
})


test_that("Raster plots aligns", {
  skip_if_not_installed("vdiffr")

  x <- terra::rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")

  test_fun_rast(x, "left", halign = 0)
  test_fun_rast(x, "right", halign = 1)
  test_fun_rast(x, "bottom", valign = 0)
  test_fun_rast(x, "top", valign = 1)
})

test_that("Raster plots crop", {
  skip_if_not_installed("vdiffr")

  x <- terra::rast(system.file("tiff/elev.tiff", package = "rasterpic"))
  x <- terra::project(x, "epsg:3857")

  test_fun_rast(x, "crop", crop = TRUE)
})
