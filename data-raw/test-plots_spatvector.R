test_fun_spat <- function(x, prefix, ...) {
  images <- list.files(system.file("img", package = "rasterpic"),
    full.names = TRUE
  )


  for (file in images) {
    raster <- rasterpic::rasterpic_img(x, file, ...)

    vdiffr::expect_doppelganger(
      paste(prefix, "_", basename(file)),
      function() {
        terra::plotRGB(raster, colNA = "red", bgalpha = 0)
        terra::plot(x,
          add = TRUE,
          border = "green",
          lwd = 2
        )
      }
    )
  }
}



test_that("SpatVector plots regular", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  test_fun_spat(x, "regular")
})

test_that("SpatVector plots expand", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  test_fun_spat(x, "expand", expand = 1)
})


test_that("SpatVector plots aligns", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  test_fun_spat(x, "left", halign = 0)
  test_fun_spat(x, "right", halign = 1)
  test_fun_spat(x, "bottom", valign = 0)
  test_fun_spat(x, "top", valign = 1)
})

test_that("SpatVector plots crop and mask", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  x <- terra::vect(x)
  expect_s4_class(x, "SpatVector")

  test_fun_spat(x, "crop", crop = TRUE)
  test_fun_spat(x, "mask", mask = TRUE)
  test_fun_spat(x, "maskinv", mask = TRUE, inverse = TRUE)
  test_fun_spat(x, "maskcrop", crop = TRUE, mask = TRUE)
})
