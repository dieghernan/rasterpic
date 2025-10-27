## code to prepare `logo` dataset goes here
library(giscoR)

coast <- gisco_get_coastallines(resolution = "3")
coast <- sf::st_transform(coast, "+proj=robin")

pic <- rasterpic_img(
  coast,
  "data-raw/artem-sapegin-8c6eS43iq1o-unsplash.jpg",
  expand = 1
)

asp <- asp_ratio(pic)
png("data-raw/modify.png", width = 900, height = 900 / asp)
terra::plotRGB(pic)
plot(
  coast$geometry,
  add = TRUE,
  col = adjustcolor("white", alpha = 0.7),
  border = "grey10"
)

dev.off()

# Font

sysfonts::font_add(
  "cabin",
  regular = "data-raw/CabinSketch-Regular.ttf",
  bold = "data-raw/CabinSketch-Bold.ttf"
)

showtext::showtext_auto()

library(ggplot2)
library(hexSticker)

# Subplot
img <- magick::image_read("data-raw/modify.png")
g <- grid::rasterGrob(img, interpolate = TRUE)

p <- ggplot2::ggplot() +
  ggplot2::annotation_custom(
    g,
    xmin = -Inf,
    xmax = Inf,
    ymin = -Inf,
    ymax = Inf
  ) +
  ggplot2::theme_void()

p

sticker(
  p,
  package = "rasterpic",
  p_family = "cabin",
  p_fontface = "bold",
  s_width = 3,
  s_height = 3,
  s_x = 1,
  s_y = 1,
  p_color = "black",
  p_size = 21,
  p_y = 1.6,
  h_fill = "white",
  h_color = adjustcolor("brown", alpha.f = 0.5),
  filename = "data-raw/logo.png",
  white_around_sticker = TRUE
)

# Remove white

r <- png::readPNG("data-raw/logo.png") * 255
library(terra)
img <- terra::rast(r)
terra::plotRGB(img)
f <- values(img, dataframe = TRUE)
# Identify white and change to NA

mod <- lapply(seq_len(nrow(f)), function(x) {
  s <- f[x, ]
  if (s[, 1] == 255 & s[, 2] == 255 & s[, 3] == 255) {
    s[1, ] <- NA
  }
  return(s)
})

newf <- dplyr::bind_rows(mod)
newf_m <- as.matrix(newf)

values(img) <- newf_m
nrow(img)


# New logo
ragg::agg_png(
  "data-raw/logo_alpha.png",
  width = ncol(img),
  height = nrow(img),
  bg = "transparent",
  pointsize = 120
)
plotRGB(img, colNA = NA, bgalpha = 0)
dev.off()


usethis::use_logo("data-raw/logo_alpha.png")
pkgdown::build_favicons(overwrite = TRUE)
