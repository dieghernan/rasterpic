# Get Started

Starting with **rasterpic** is very easy! You just need an image (`png`,
`jpeg/jpg` or `tif/tiff`) and a spatial object from the **sf** or the
**terra** package to start using it.

## Basic usage

Here we use the shape of Austria as an example:

``` r
library(sf)
library(terra)
library(rasterpic)

# Plot
library(tidyterra)
library(ggplot2)

# Shape and image
x <- read_sf(system.file("gpkg/austria.gpkg", package = "rasterpic"))
img <- system.file("img/vertical.png", package = "rasterpic")

# Create the raster!

default <- rasterpic_img(x, img)

autoplot(default) +
  geom_sf(data = x)
```

![](rasterpic_files/figure-html/fig-setup-1.png)

Figure 1: Raster map geolocated with the coordinates of Austria

## Options

The function provides several options for expansion, alignment, and
cropping.

### Expand

With this option, the image is expanded beyond the spatial object:

``` r
expand <- rasterpic_img(x, img, expand = 1)

autoplot(expand) +
  geom_sf(data = x)
```

![](rasterpic_files/figure-html/fig-expand-1.png)

Figure 2: Example of expansion of image

### Alignment

Decide where to align the image:

``` r
bottom <- rasterpic_img(x, img, valign = 0)

autoplot(bottom) +
  geom_sf(data = x)
```

![](rasterpic_files/figure-html/fig-bottom-1.png)

Figure 3: Example of alignment of image

### Crop and mask

Create impressive maps:

``` r
mask <- rasterpic_img(x, img, crop = TRUE, mask = TRUE)

autoplot(mask)

maskinverse <- rasterpic_img(x, img, crop = TRUE, mask = TRUE, inverse = TRUE)

autoplot(maskinverse)
```

![](rasterpic_files/figure-html/fig-mask-1.png)

Figure 4: Example of masked image

![](rasterpic_files/figure-html/fig-mask-2.png)

Figure 5: Example of masked image

## Supported objects for geotagging

- Spatial objects of the **sf** package: `sf`, `sfc`, `sfg` or `bbox`.
- Spatial objects of the **terra** package: `SpatRaster`, `SpatVector`,
  `SpatExtent`.
- A vector of coordinates with the form `c(xmin, ymin, xmax, ymax)`.

## Supported image formats

**rasterpic** can parse the following image formats:

- `png` files.
- `jpg/jpeg` files.
- `tif/tiff` files.
