test_fun_bbox <- function(x, prefix, ...) {
  images <- list.files(system.file("img", package = "rasterpic"),
    full.names = TRUE
  )


  for (file in images) {
    raster <- rasterpic::rasterpic_img(x, file, ...)

    vdiffr::expect_doppelganger(
      paste(prefix, "_", basename(file)),
      function() {
        terra::plotRGB(raster, colNA = "red", bgalpha = 0)
        plot(sf::st_as_sfc(x),
          add = TRUE,
          border = "green",
          lwd = 2
        )
      }
    )
  }
}



test_that("bbox plots regular", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun_bbox(sf::st_bbox(x), "regular", crs = sf::st_crs(x)$wkt)
})

test_that("bbox plots expand", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun_bbox(sf::st_bbox(x), "expand", expand = 1, crs = sf::st_crs(x)$wkt)
})


test_that("bbox plots aligns", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun_bbox(sf::st_bbox(x), "left", halign = 0, crs = sf::st_crs(x)$wkt)
  test_fun_bbox(sf::st_bbox(x), "right", halign = 1, crs = sf::st_crs(x)$wkt)
  test_fun_bbox(sf::st_bbox(x), "bottom", valign = 0, crs = sf::st_crs(x)$wkt)
  test_fun_bbox(sf::st_bbox(x), "top", valign = 1, crs = sf::st_crs(x)$wkt)
})

test_that("bbox plots crop", {
  skip_if_not_installed("vdiffr")
  skip_on_cran()

  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )
  test_fun_bbox(sf::st_bbox(x), "crop", crop = TRUE, crs = sf::st_crs(x)$wkt)
})
