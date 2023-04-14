test_that("Expand factor", {
  img <- system.file("img/UK_flag.png", package = "rasterpic")
  x <- sf::st_read(system.file("gpkg/austria.gpkg", package = "rasterpic"),
    quiet = TRUE
  )

  x0 <- rasterpic_img(x, img, expand = 0)
  x_5 <- rasterpic_img(x, img, expand = 0.5)
  x1 <- rasterpic_img(x, img, expand = 1)

  # Asp ratios
  expect_equal(asp_ratio(x0), asp_ratio(x_5))
  expect_equal(asp_ratio(x0), asp_ratio(x1))

  # Check bboxes
  bbox_x <- as.double(sf::st_bbox(x))
  bbox_x0 <- unname(as.vector(terra::ext(x0)))
  expect_equal(bbox_x[c(2, 4)], bbox_x0[c(3, 4)])
  expect_true(bbox_x[1] > bbox_x0[1])
  expect_true(bbox_x[3] < bbox_x0[2])

  bbox_x_5 <- unname(as.vector(terra::ext(x_5)))
  expect_true(
    all(
      c(
        bbox_x[c(1, 3)] > bbox_x_5[c(1, 3)],
        bbox_x[c(2, 4)] < bbox_x_5[c(2, 4)]
      )
    )
  )

  bbox_x1 <- unname(as.vector(terra::ext(x1)))
  expect_true(
    all(
      c(
        bbox_x_5[c(1, 3)] > bbox_x1[c(1, 3)],
        bbox_x_5[c(2, 4)] < bbox_x1[c(2, 4)]
      )
    )
  )
})
