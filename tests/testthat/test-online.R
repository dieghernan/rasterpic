test_that("Test error online", {
  skip_on_cran()
  skip_if_not_installed("curl")
  skip_if_offline()

  img <- "http://this_is_an_error_url.fake"
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_error(rasterpic_img(x, img))
})

test_that("Test image online", {
  skip_on_cran()
  skip_if_not_installed("curl")
  skip_if_offline()

  img <- "https://i.imgur.com/6yHmlwT.jpeg"
  x <- sf::st_read(system.file("gpkg/UK.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  expect_silent(rasterpic_img(x, img))
})
