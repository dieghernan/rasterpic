## code to prepare `graycolor.png` dataset goes here
library(ggplot2)
library(terra)
library(giscoR)
x <- gisco_get_nuts(
  country = "Austria", nuts_level = 0, resolution = 60,
  epsg = 3035
)

png("inst/grays/grays.png")
ggplot(x) +
  geom_sf(fill = "black") +
  theme_void() +
  theme(plot.background = element_rect(fill = "white"))
dev.off()

knitr::plot_crop("inst/grays/grays.png")


# Check

pn <- png::readPNG("inst/grays/grays.png", native = TRUE)

ff <- terra::rast("inst/grays/grays.png")
terra::nlyr(ff)
