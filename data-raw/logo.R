## code to prepare `logo` dataset goes here
library(giscoR)

devtools::load_all()
coast <- gisco_get_coastallines(resolution = "3")
coast <- sf::st_transform(coast, "+proj=robin")

pic <- rasterpic_img(
  coast,
  "data-raw/vecteezy_abstract-seamless-pattern-with-brushstrokes-colorful_.jpg",
  expand = 1,
  crop = TRUE
)
terra::plotRGB(pic)

pic2 <- terra::mask(pic, coast)
terra::plotRGB(pic2)

library(tidyterra)
library(ggplot2)

ggplot() +
  geom_spatraster_rgb(data = pic2, maxcell = Inf) +
  theme_void()

ggsave("data-raw/modify.png", dpi = 300, scale = 2)
knitr::plot_crop("data-raw/modify.png")


file.copy("data-raw/logo.png", "man/figures", overwrite = TRUE)
pkgdown::build_favicons(overwrite = TRUE)
