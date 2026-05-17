# rasterpic

**rasterpic** is a tiny package with a single goal: to transform an
image into a **terra** `SpatRaster` object (see
[`?terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)).

## Installation

Check the documentation for the development version at
<https://dieghernan.github.io/rasterpic/dev/>.

You can install the development version of **rasterpic** with:

``` r

# install.packages("pak")
pak::pak("dieghernan/rasterpic")
```

Alternatively, you can install **rasterpic** using the
[r-universe](https://dieghernan.r-universe.dev/rasterpic):

``` r

# Install rasterpic in R.
install.packages(
  "rasterpic",
  repos = c(
    "https://dieghernan.r-universe.dev",
    "https://cloud.r-project.org"
  )
)
```

## Example

This package allows you to create custom maps using a wide variety of
spatial objects:

- Spatial objects created with the **sf** package: `sf`, `sfc`, `sfg` or
  `bbox`.
- Spatial objects created with the **terra** package: `SpatRaster`,
  `SpatVector` and `SpatExtent`.
- A numeric coordinate vector of the form `c(xmin, ymin, xmax, ymax)`.

The main function,
[`rasterpic_img()`](https://dieghernan.github.io/rasterpic/dev/reference/rasterpic_img.md),
is an S3 generic, so other packages can provide methods for additional
spatial classes.

An example using an `sf` object:

``` r

library(rasterpic)
library(sf)
library(terra)

# Use the flag of the United Kingdom.
img <- system.file("img/UK_flag.png", package = "rasterpic")
uk <- read_sf(system.file("gpkg/UK.gpkg", package = "rasterpic"))

class(uk)
#> [1] "sf"         "tbl_df"     "tbl"        "data.frame"

# Rasterize the image.
uk_flag <- rasterpic_img(uk, img)

uk_flag
#> class       : SpatRaster
#> size        : 400, 800, 3  (nrow, ncol, nlyr)
#> resolution  : 5398.319, 5398.319  (x, y)
#> extent      : -2542183, 1776472, 6430573, 8589900  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / Pseudo-Mercator (EPSG:3857)
#> source(s)   : memory
#> colors rgb  : 1, 2, 3
#> names       :   r,   g,   b
#> min values  :   0,  14,  35
#> max values  : 255, 255, 255

# Plot with ggplot2 and tidyterra.
library(tidyterra)
library(ggplot2)

autoplot(uk_flag) +
  geom_sf(data = uk, color = alpha("blue", 0.5))
```

![Example using rasterpic with the UK
flag](reference/figures/README-example-basic-1.png)

We can also adjust other parameters and modify the alignment of the
image with respect to the object:

``` r

# Align, crop and mask.
uk_flag2 <- rasterpic_img(uk, img, halign = 0.2, crop = TRUE, mask = TRUE)

autoplot(uk_flag2) +
  geom_sf(data = uk, fill = NA)
```

![Example using rasterpic with the UK flag cropped to the
shape](reference/figures/README-align-crop-mask-1.png)

## Supported image formats

**rasterpic** can parse the following image formats:

- `png` files.
- `jpg/jpeg` files.
- `tif/tiff` files.

## Citation

Hernangómez D (2026). *rasterpic: Convert Digital Images to SpatRaster
Objects*.
[doi:10.32614/CRAN.package.rasterpic](https://doi.org/10.32614/CRAN.package.rasterpic).
<https://dieghernan.github.io/rasterpic/>.

A BibTeX entry for LaTeX users is:

``` R
@Manual{R-rasterpic,
  title = {{rasterpic}: Convert Digital Images to {SpatRaster} Objects},
  doi = {10.32614/CRAN.package.rasterpic},
  author = {Diego Hernangómez},
  year = {2026},
  version = {0.4.0.9000},
  url = {https://dieghernan.github.io/rasterpic/},
  abstract = {Create SpatRaster objects, as defined by the terra package, from digital images using a specified spatial object as a geographic reference. The main function is an S3 generic, allowing methods for additional spatial classes.},
}
```
