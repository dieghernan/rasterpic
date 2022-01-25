test_fun <- function(x, prefix, ...) {
  images <- list.files(system.file("img", package = "rasterpic"),
    full.names = TRUE
  )


  for (file in images) {
    raster <- rasterpic::rasterpic_img(x, file, ...)

    vdiffr::expect_doppelganger(
      paste(prefix, "_", basename(file)),
      function() {
        terra::plotRGB(raster, colNA = "red", bgalpha = 0)
        plot(sf::st_geometry(x),
          add = TRUE,
          border = "green",
          lwd = 2
        )
      }
    )
  }
}



test_that("UK plots regular", {
  skip_if_not_installed("vdiffr")

  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun(x, "regular")
})

test_that("UK plots expand", {
  skip_if_not_installed("vdiffr")

  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun(x, "expand", expand = 1)
})


test_that("UK plots aligns", {
  skip_if_not_installed("vdiffr")

  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun(x, "left", halign = 0)
  test_fun(x, "right", halign = 1)
  test_fun(x, "bottom", valign = 0)
  test_fun(x, "top", valign = 1)
})

test_that("UK plots crop and mask", {
  skip_if_not_installed("vdiffr")

  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun(x, "crop", crop = TRUE)
  test_fun(x, "mask", mask = TRUE)
  test_fun(x, "maskinv", mask = TRUE, inverse = TRUE)
  test_fun(x, "maskcrop", crop = TRUE, mask = TRUE)
})
