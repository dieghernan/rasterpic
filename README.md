
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rasterpic <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rasterpic)](https://CRAN.R-project.org/package=rasterpic)
[![CRAN
results](https://badges.cranchecks.info/worst/rasterpic.svg)](https://cran.r-project.org/web/checks/check_results_rasterpic.html)
[![R-CMD-check](https://github.com/dieghernan/rasterpic/actions/workflows/check-full.yaml/badge.svg)](https://github.com/dieghernan/rasterpic/actions/workflows/check-full.yaml)
[![R-hub](https://github.com/dieghernan/rasterpic/actions/workflows/rhub.yaml/badge.svg)](https://github.com/dieghernan/rasterpic/actions/workflows/rhub.yaml)
[![codecov](https://codecov.io/gh/dieghernan/rasterpic/branch/main/graph/badge.svg?token=jSZ4RIsj91)](https://app.codecov.io/gh/dieghernan/rasterpic)
[![r-universe](https://dieghernan.r-universe.dev/badges/rasterpic)](https://dieghernan.r-universe.dev/rasterpic)
[![CodeFactor](https://www.codefactor.io/repository/github/dieghernan/rasterpic/badge)](https://www.codefactor.io/repository/github/dieghernan/rasterpic)
[![DOI](https://img.shields.io/badge/DOI-10.32614/CRAN.package.rasterpic-blue)](https://doi.org/10.32614/CRAN.package.rasterpic)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![status](https://tinyverse.netlify.app/status/rasterpic)](https://CRAN.R-project.org/package=rasterpic)

<!-- badges: end -->

**rasterpic** is a tiny package with a single goal: to transform an
image into a `SpatRaster` object (see `?terra::SpatRaster`).

## Installation

<div class="pkgdown-release">

Install **rasterpic** from
[**CRAN**](https://CRAN.R-project.org/package=rasterpic):

``` r
install.packages("rasterpic")
```

</div>

<div class="pkgdown-devel">

You can install the developing version of **rasterpic** with:

``` r
# install.packages("pak")
pak::pak("dieghernan/rasterpic")
```

Alternatively, you can install **rasterpic** using the
[r-universe](https://dieghernan.r-universe.dev/rasterpic):

``` r
# Install rasterpic in R:
install.packages("rasterpic",
  repos = c(
    "https://dieghernan.r-universe.dev",
    "https://cloud.r-project.org"
  )
)
```

</div>

## Example

This package allows you to create custom maps by using a wide variety of
objects:

- Spatial object created with the **sf** package: `sf`, `sfc`, `sfg` or
  `bbox`.
- Spatial objects created with the **terra** package: `SpatRaster`,
  `SpatVector`, `SpatExtent`.
- A vector of coordinates with the form `c(xmin, ymin, xmax, ymax)`

An example using an `sf` object:

``` r
library(rasterpic)
library(sf)
library(terra)

# The flag of the United Kingdom
img <- system.file("img/UK_flag.png", package = "rasterpic")
uk <- read_sf(system.file("gpkg/UK.gpkg", package = "rasterpic"))


class(uk)
#> [1] "sf"         "tbl_df"     "tbl"        "data.frame"

# Rasterize the image!
uk_flag <- rasterpic_img(uk, img)

uk_flag
#> class       : SpatRaster 
#> size        : 400, 800, 3  (nrow, ncol, nlyr)
#> resolution  : 5398.319, 5398.319  (x, y)
#> extent      : -2542183, 1776472, 6430573, 8589900  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / Pseudo-Mercator (EPSG:3857) 
#> source(s)   : memory
#> colors RGB  : 1, 2, 3 
#> names       :   r,   g,   b 
#> min values  :   0,  14,  35 
#> max values  : 255, 255, 255

# Plot it!
# Using ggplot2 + tidyterra
library(tidyterra)
library(ggplot2)

autoplot(uk_flag) +
  geom_sf(data = uk, color = alpha("blue", 0.5))
```

<img src="man/figures/README-example-basic-1.png" alt="" width="100%" />

We can also adjust other parameters, as well as modifying the alignment
of the image with respect to the object:

``` r
# Align, crop and mask
uk_flag2 <- rasterpic_img(uk, img, halign = 0.2, crop = TRUE, mask = TRUE)

autoplot(uk_flag2) +
  geom_sf(data = uk, fill = NA)
```

<img src="man/figures/README-align-crop-mask-1.png" alt="" width="100%" />

## Supported image formats

**rasterpic** can parse the following image formats:

- `png` files.
- `jpg/jpeg` files.
- `tif/tiff` files.

## Citation

<p>
Hernangómez D (2026). <em>rasterpic: Convert Digital Images into
SpatRaster Objects</em>.
<a href="https://doi.org/10.32614/CRAN.package.rasterpic">doi:10.32614/CRAN.package.rasterpic</a>,
<a href="https://dieghernan.github.io/rasterpic/">https://dieghernan.github.io/rasterpic/</a>.
</p>

A BibTeX entry for LaTeX users is:

    @Manual{R-rasterpic,
      title = {{rasterpic}: Convert Digital Images into {SpatRaster} Objects},
      doi = {10.32614/CRAN.package.rasterpic},
      author = {Diego Hernangómez},
      year = {2026},
      version = {0.3.1},
      url = {https://dieghernan.github.io/rasterpic/},
      abstract = {Generate SpatRaster objects, as defined by the terra package, from digital images, using a specified spatial object as a geographical reference.},
    }
